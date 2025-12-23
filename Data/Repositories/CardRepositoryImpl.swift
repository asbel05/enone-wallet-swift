//
//  CardRepository.swift
//  enone
//
//  Created by Asbel on 20/12/25.
//

import Foundation

final class CardRepositoryImpl: CardRepositoryProtocol {
    
    private let dataSource: CardDataSource
    
    init(dataSource: CardDataSource = CardDataSource()) {
        self.dataSource = dataSource
    }
    
    func getActiveCard(userId: String) async throws -> Card? {
        return try await dataSource.getActiveCard(userId: userId)
    }
    
    func getAllCards(userId: String) async throws -> [Card] {
        return try await dataSource.getAllCards(userId: userId)
    }
    
    func activateCard(
        userId: String,
        cardNumber: String,
        cvv: String,
        expiryDate: String,
        holderName: String
    ) async throws -> CardOperationResponse {
        return try await dataSource.activateCard(
            userId: userId,
            cardNumber: cardNumber,
            cvv: cvv,
            expiryDate: expiryDate,
            holderName: holderName
        )
    }
    
    func deposit(userId: String, amount: Double, currency: String) async throws -> CardOperationResponse {
        return try await dataSource.deposit(userId: userId, amount: amount, currency: currency)
    }
    
    func withdraw(userId: String, amount: Double, currency: String) async throws -> CardOperationResponse {
        return try await dataSource.withdraw(userId: userId, amount: amount, currency: currency)
    }
}
