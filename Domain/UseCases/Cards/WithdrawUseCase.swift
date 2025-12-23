//
//  WithdrawUseCase.swift
//  enone
//
//  Created by Asbel on 20/12/25.
//

import Foundation

struct WithdrawUseCase {
    
    private let cardRepository: CardRepositoryProtocol
    
    init(cardRepository: CardRepositoryProtocol = CardRepositoryImpl()) {
        self.cardRepository = cardRepository
    }
    
    func execute(userId: String, amount: Double, currency: String = "PEN") async throws -> CardOperationResponse {
        
        guard amount > 0 else {
            return CardOperationResponse(
                success: false,
                error: "El monto debe ser mayor a 0",
                cardId: nil,
                maskedNumber: nil,
                transactionId: nil,
                newBalance: nil,
                message: nil
            )
        }
        
        guard amount >= 10 else {
            return CardOperationResponse(
                success: false,
                error: "El monto mínimo de retiro es S/ 10",
                cardId: nil,
                maskedNumber: nil,
                transactionId: nil,
                newBalance: nil,
                message: nil
            )
        }
        
        return try await cardRepository.withdraw(userId: userId, amount: amount, currency: currency)
    }
}
