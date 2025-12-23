//
//  GetWalletBalanceUseCase.swift
//  enone
//
//  Created by Asbel on 21/12/25.
//

import Foundation

final class GetWalletBalanceUseCase {
    private let repository: WalletRepositoryProtocol
    
    init(repository: WalletRepositoryProtocol = WalletRepositoryImpl()) {
        self.repository = repository
    }
    
    func execute(userId: String, currency: String) async throws -> Double {
        return try await repository.getBalance(userId: userId, currency: currency)
    }
}
