//
//  CardRepositoryProtocol.swift
//  enone
//
//  Created by Asbel on 20/12/25.
//

import Foundation

protocol CardRepositoryProtocol {
    func getActiveCard(userId: String) async throws -> Card?
    func getAllCards(userId: String) async throws -> [Card]
    func activateCard(userId: String, cardNumber: String, cvv: String, expiryDate: String, holderName: String) async throws -> CardOperationResponse
    func deposit(userId: String, amount: Double, currency: String) async throws -> CardOperationResponse
    func withdraw(userId: String, amount: Double, currency: String) async throws -> CardOperationResponse
}
