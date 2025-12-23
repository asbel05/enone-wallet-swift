//
//  WithdrawViewModel.swift
//  enone
//
//  Created by Asbel on 20/12/25.
//

import Foundation

final class WithdrawViewModel {
    
    var onLoadingChange: ((Bool) -> Void)?
    var onError: ((String) -> Void)?
    var onSuccess: ((String, Double) -> Void)?
    var onCardLoaded: ((Card?) -> Void)?
    var onBalanceLoaded: ((Double) -> Void)?
    
    private let getCurrentUserIdUseCase: GetCurrentUserIdUseCase
    private let getWalletBalanceUseCase: GetWalletBalanceUseCase
    private let withdrawUseCase: WithdrawUseCase
    private let getActiveCardUseCase: GetActiveCardUseCase
    
    private(set) var activeCard: Card?
    private(set) var currentBalance: Double = 0
    private(set) var currency: String
    
    init(
        currency: String = "PEN",
        getCurrentUserIdUseCase: GetCurrentUserIdUseCase = GetCurrentUserIdUseCase(),
        getWalletBalanceUseCase: GetWalletBalanceUseCase = GetWalletBalanceUseCase(),
        cardRepository: CardRepositoryProtocol = CardRepositoryImpl()
    ) {
        self.currency = currency
        self.getCurrentUserIdUseCase = getCurrentUserIdUseCase
        self.getWalletBalanceUseCase = getWalletBalanceUseCase
        self.withdrawUseCase = WithdrawUseCase(cardRepository: cardRepository)
        self.getActiveCardUseCase = GetActiveCardUseCase(cardRepository: cardRepository)
    }
    
    var hasActiveCard: Bool {
        return activeCard != nil
    }
    
    func loadInitialData() {
        onLoadingChange?(true)
        Task {
            guard let userId = await getCurrentUserIdUseCase.execute() else {
                await MainActor.run {
                    onLoadingChange?(false)
                }
                return
            }
            
            do {
                async let cardTask = getActiveCardUseCase.execute(userId: userId)
                async let balanceTask = getWalletBalanceUseCase.execute(userId: userId, currency: currency)
                
                let (card, balance) = try await (cardTask, balanceTask)
                
                await MainActor.run {
                    self.activeCard = card
                    self.currentBalance = balance
                    self.onCardLoaded?(card)
                    self.onBalanceLoaded?(balance)
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
    
    func withdraw(amount: Double) {
        guard hasActiveCard else {
            onError?("No tienes una tarjeta activa")
            return
        }
        
        guard amount > 0 else {
            onError?("El monto debe ser mayor a 0")
            return
        }
        
        guard amount <= currentBalance else {
            onError?("Saldo insuficiente")
            return
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
                let response = try await withdrawUseCase.execute(userId: userId, amount: amount, currency: currency)
                
                if response.success {
                    let newBalance = response.newBalance ?? currentBalance - amount
                    await MainActor.run {
                        self.currentBalance = newBalance
                        self.onSuccess?("Retiro realizado correctamente", newBalance)
                        self.onLoadingChange?(false)
                    }
                } else {
                    await MainActor.run {
                        self.onError?(response.error ?? "Error al retirar")
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
