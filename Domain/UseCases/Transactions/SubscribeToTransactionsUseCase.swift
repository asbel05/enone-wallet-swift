//
//  SubscribeToTransactionsUseCase.swift
//  enone
//
//  Created by DESIGN on 19/12/25.
//

import Foundation

struct SubscribeToTransactionsUseCase {
    private let repository: TransactionRepositoryProtocol
    
    init(repository: TransactionRepositoryProtocol = TransactionRepositoryImpl()) {
        self.repository = repository
    }
    
    func execute(userId: UUID) -> AsyncStream<[Transaction]> {
        return repository.subscribeToTransactions(userId: userId)
    }
}
