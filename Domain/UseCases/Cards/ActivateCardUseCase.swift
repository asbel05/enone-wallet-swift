//
//  ActivateCardUseCase.swift
//  enone
//
//  Created by Asbel on 20/12/25.
//

import Foundation

struct ActivateCardUseCase {
    
    private let cardRepository: CardRepositoryProtocol
    
    init(cardRepository: CardRepositoryProtocol = CardRepositoryImpl()) {
        self.cardRepository = cardRepository
    }
    
    func execute(
        userId: String,
        cardNumber: String,
        cvv: String,
        expiryDate: String,
        holderName: String
    ) async throws -> CardOperationResponse {
        
        let cleanNumber = cardNumber.replacingOccurrences(of: " ", with: "")
        
        guard cleanNumber.count == 16, cleanNumber.allSatisfy({ $0.isNumber }) else {
            return CardOperationResponse(
                success: false,
                error: "Número de tarjeta inválido",
                cardId: nil,
                maskedNumber: nil,
                transactionId: nil,
                newBalance: nil,
                message: nil
            )
        }
        
        guard cvv.count == 3, cvv.allSatisfy({ $0.isNumber }) else {
            return CardOperationResponse(
                success: false,
                error: "CVV inválido",
                cardId: nil,
                maskedNumber: nil,
                transactionId: nil,
                newBalance: nil,
                message: nil
            )
        }
        
        return try await cardRepository.activateCard(
            userId: userId,
            cardNumber: cleanNumber,
            cvv: cvv,
            expiryDate: expiryDate,
            holderName: holderName.uppercased()
        )
    }
}
