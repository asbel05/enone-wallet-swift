//
//  CardViewModel.swift
//  enone
//
//  Created by Asbel on 20/12/25.
//

import Foundation

final class CardViewModel {
    
    var onLoadingChange: ((Bool) -> Void)?
    var onError: ((String) -> Void)?
    var onSuccess: ((String) -> Void)?
    var onCardLoaded: ((Card?) -> Void)?
    var onCardActivated: ((Card) -> Void)?
    
    private let getCurrentUserIdUseCase: GetCurrentUserIdUseCase
    private let activateCardUseCase: ActivateCardUseCase
    private let getActiveCardUseCase: GetActiveCardUseCase
    
    private(set) var activeCard: Card?
    
    init(
        getCurrentUserIdUseCase: GetCurrentUserIdUseCase = GetCurrentUserIdUseCase(),
        cardRepository: CardRepositoryProtocol = CardRepositoryImpl()
    ) {
        self.getCurrentUserIdUseCase = getCurrentUserIdUseCase
        self.activateCardUseCase = ActivateCardUseCase(cardRepository: cardRepository)
        self.getActiveCardUseCase = GetActiveCardUseCase(cardRepository: cardRepository)
    }
    
    func loadActiveCard() {
        if let cached = KeychainManager.shared.getActiveCard() {
            let cachedCard = Card(
                id: 0,
                userId: "",
                cardNumberMasked: cached.maskedNumber,
                cardNumberHash: nil,
                holderName: cached.holderName,
                expiryMonth: nil,
                expiryYear: nil,
                cardBrand: cached.brand,
                isActive: true,
                isVerified: true,
                createdAt: nil,
                updatedAt: nil
            )
            self.onCardLoaded?(cachedCard)
        }
        
        onLoadingChange?(true)
        Task {
            guard let userId = await getCurrentUserIdUseCase.execute() else {
                await MainActor.run {
                    onLoadingChange?(false)
                }
                return
            }
            
            do {
                let card = try await getActiveCardUseCase.execute(userId: userId)
                await MainActor.run {
                    self.activeCard = card
                    
                    // Guardar en Keychain (almacenamiento seguro encriptado)
                    if let card = card {
                        let secureCard = KeychainManager.SecureCard(
                            maskedNumber: card.displayNumber,
                            brand: card.cardBrand,
                            holderName: card.holderName,
                            expiryDate: card.expiryDate
                        )
                        KeychainManager.shared.saveActiveCard(secureCard)
                    } else {
                        KeychainManager.shared.deleteActiveCard()
                    }
                    
                    self.onCardLoaded?(card)
                    self.onLoadingChange?(false)
                }
            } catch {
                await MainActor.run {
                    self.onError?(error.localizedDescription)
                    self.onLoadingChange?(false)
                }
            }
        }
    }
    
    func activateCard(cardNumber: String, cvv: String, expiryDate: String, holderName: String) {
        onLoadingChange?(true)
        Task {
            guard let userId = await getCurrentUserIdUseCase.execute() else {
                await MainActor.run {
                    onLoadingChange?(false)
                    onError?("Usuario no identificado")
                }
                return
            }
            
            do {
                let response = try await activateCardUseCase.execute(
                    userId: userId,
                    cardNumber: cardNumber,
                    cvv: cvv,
                    expiryDate: expiryDate,
                    holderName: holderName
                )
                
                if response.success {
                    let card = try await getActiveCardUseCase.execute(userId: userId)
                    await MainActor.run {
                        self.activeCard = card
                        
                        if let card = card {
                            let secureCard = KeychainManager.SecureCard(
                                maskedNumber: card.displayNumber,
                                brand: card.cardBrand,
                                holderName: card.holderName,
                                expiryDate: card.expiryDate
                            )
                            KeychainManager.shared.saveActiveCard(secureCard)
                        }
                        
                        self.onSuccess?(response.message ?? "Tarjeta activada correctamente")
                        if let card = card {
                            self.onCardActivated?(card)
                        }
                        self.onLoadingChange?(false)
                    }
                } else {
                    await MainActor.run {
                        self.onError?(response.error ?? "Error al activar tarjeta")
                        self.onLoadingChange?(false)
                    }
                }
            } catch {
                await MainActor.run {
                    self.onError?(error.localizedDescription)
                    self.onLoadingChange?(false)
                }
            }
        }
    }
}
