//
//  TransferFundsUseCase.swift
//  enone
//
//  Created by Asbel on 18/12/25.
//

import Foundation

final class TransferFundsUseCase {
    
    private let transactionRepository: TransactionRepositoryProtocol
    private let profileRepository: ProfileRepositoryProtocol
    
    init(
        transactionRepository: TransactionRepositoryProtocol = TransactionRepositoryImpl(),
        profileRepository: ProfileRepositoryProtocol = ProfileRepositoryImpl()
    ) {
        self.transactionRepository = transactionRepository
        self.profileRepository = profileRepository
    }
    
    func execute(
        userId: String,
        fromWalletId: Int,
        request: TransferRequest,
        verificationCode: String?
    ) async throws -> TransferResult {
        
        try request.validate()
        
        let validation = try await transactionRepository.validateTransfer(
            userId: userId,
            fromWalletId: fromWalletId,
            toWalletNumber: request.destinationWalletNumber,
            amount: request.amount,
            currency: request.currency
        )
        
        guard validation.isValid else {
            if let error = validation.errorMessage {
                throw TransferExecutionError.validationFailed(error)
            }
            throw TransferError.transactionFailed
        }
        
        if validation.requires2FA {
            guard let code = verificationCode else {
                throw TransferError.twoFactorRequired
            }
            
            let profile = try await profileRepository.getUserProfile(userId: userId)
            
            guard let userSecret = profile.twoFactorSecret else {
                throw TransferError.twoFactorInvalid
            }
            
            guard TOTPService.shared.validateCode(code, secret: userSecret) else {
                throw TransferError.twoFactorInvalid
            }
        }
        
        let result = try await transactionRepository.executeTransfer(
            fromWalletId: fromWalletId,
            toWalletNumber: request.destinationWalletNumber,
            amount: request.amount,
            currency: request.currency,
            description: request.description
        )
        
        try await transactionRepository.updateDailyVolume(
            userId: userId,
            amount: request.amount,
            currency: request.currency
        )
        
        return result
    }
}

enum TransferExecutionError: LocalizedError {
    case validationFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .validationFailed(let message):
            return message
        }
    }
}
