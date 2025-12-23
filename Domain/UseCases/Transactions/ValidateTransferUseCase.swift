//
//  ValidateTransferUseCase.swift
//  enone
//
//  Created by Asbel on 18/12/25.
//

import Foundation

final class ValidateTransferUseCase {
    
    private let transactionRepository: TransactionRepositoryProtocol
    
    init(transactionRepository: TransactionRepositoryProtocol = TransactionRepositoryImpl()) {
        self.transactionRepository = transactionRepository
    }
    
    func execute(
        userId: String,
        fromWalletId: Int,
        request: TransferRequest
    ) async throws -> TransferValidation {
        
        try request.validate()
        
        let validation = try await transactionRepository.validateTransfer(
            userId: userId,
            fromWalletId: fromWalletId,
            toWalletNumber: request.destinationWalletNumber,
            amount: request.amount,
            currency: request.currency
        )
        
        return validation
    }
}
