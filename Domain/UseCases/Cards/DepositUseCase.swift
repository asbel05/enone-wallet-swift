//
//  DepositUseCase.swift
//  enone
//
//  Created by Asbel on 20/12/25.
//

import Foundation

struct DepositUseCase {
    
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
        
        guard amount <= 10000 else {
            return CardOperationResponse(
                success: false,
                error: "El monto máximo por depósito es S/ 10,000",
                cardId: nil,
                maskedNumber: nil,
                transactionId: nil,
                newBalance: nil,
                message: nil
            )
        }
        
        return try await cardRepository.deposit(userId: userId, amount: amount, currency: currency)
    }
}
