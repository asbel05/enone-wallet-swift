//
//  GetActiveCardUseCase.swift
//  enone
//
//  Created by Asbel on 20/12/25.
//

import Foundation

struct GetActiveCardUseCase {
    
    private let cardRepository: CardRepositoryProtocol
    
    init(cardRepository: CardRepositoryProtocol = CardRepositoryImpl()) {
        self.cardRepository = cardRepository
    }
    
    func execute(userId: String) async throws -> Card? {
        return try await cardRepository.getActiveCard(userId: userId)
    }
}
