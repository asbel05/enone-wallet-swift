//
//  FindWalletByEmailUseCase.swift
//  enone
//
//  Created by Asbel on 21/12/25.
//

import Foundation

final class FindWalletByEmailUseCase {
    private let repository: TransactionRepositoryProtocol
    
    init(repository: TransactionRepositoryProtocol = TransactionRepositoryImpl()) {
        self.repository = repository
    }
    
    func execute(email: String, currency: String) async throws -> WalletSearchResult? {
        return try await repository.findWalletByUserEmail(email: email, currency: currency)
    }
}
