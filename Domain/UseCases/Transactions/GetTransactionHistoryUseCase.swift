//
//  GetTransactionHistoryUseCase.swift
//  enone
//
//  Created by Asbel on 18/12/25.
//

import Foundation

final class GetTransactionHistoryUseCase {
    
    private let transactionRepository: TransactionRepositoryProtocol
    
    init(transactionRepository: TransactionRepositoryProtocol = TransactionRepositoryImpl()) {
        self.transactionRepository = transactionRepository
    }
    
    func execute(
        walletId: Int,
        page: Int = 0,
        pageSize: Int = 20
    ) async throws -> [Transaction] {
        let offset = page * pageSize
        
        return try await transactionRepository.getTransactionHistory(
            walletId: walletId,
            limit: pageSize,
            offset: offset
        )
    }
    
    func getDetail(transactionId: Int) async throws -> Transaction {
        return try await transactionRepository.getTransaction(id: transactionId)
    }
}
