//
//  GetWalletsUseCase.swift
//  enone
//
//  Created by Asbel on 18/12/25.
//

import Foundation

struct GetWalletsUseCase {
    private let repository: WalletRepositoryProtocol
    
    init(repository: WalletRepositoryProtocol = WalletRepositoryImpl()) {
        self.repository = repository
    }
    
    func execute(userId: UUID) async throws -> [Wallet] {
        return try await repository.getWallets(userId: userId)
    }
}
