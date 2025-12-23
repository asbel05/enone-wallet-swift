//
//  UpdateTransactionLimitUseCase.swift
//  enone
//
//  Created by Asbel on 18/12/25.
//

import Foundation

final class UpdateTransactionLimitUseCase {
    private let profileRepository: ProfileRepositoryProtocol
    private let authRepository: AuthRepositoryProtocol
    
    init(
        profileRepository: ProfileRepositoryProtocol,
        authRepository: AuthRepositoryProtocol
    ) {
        self.profileRepository = profileRepository
        self.authRepository = authRepository
    }
    
    func requestLimitChange(newLimit: Double) async throws -> String {
        guard newLimit >= 500 && newLimit <= 2000 else {
            throw TransactionLimitError.invalidLimit
        }
        
        guard let userId = await authRepository.currentUserId() else {
            throw TransactionLimitError.userNotAuthenticated
        }
        
        let profile = try await profileRepository.getUserProfile(userId: userId)
        
        if let lastChange = profile.lastLimitChange {
            let formatter = ISO8601DateFormatter()
            if let lastChangeDate = formatter.date(from: lastChange) {
                let hoursSince = Date().timeIntervalSince(lastChangeDate) / 3600
                if hoursSince < 24 {
                    throw TransactionLimitError.cannotChangeYet
                }
            }
        }
        
        guard let email = profile.email else {
            throw NSError(domain: "TransactionLimits", code: 400, userInfo: [NSLocalizedDescriptionKey: "No se encontró email del usuario"])
        }
        
        let otp = try await profileRepository.createLimitChangeOTP(userId: userId, newLimit: newLimit, email: email)
        
        print("OTP enviado a \(email): \(otp) (visible solo en testing)")
        
        return otp
    }
    
    func verifyAndUpdateLimit(otp: String) async throws {
        guard let userId = await authRepository.currentUserId() else {
            throw TransactionLimitError.userNotAuthenticated
        }
        
        let newLimit = try await profileRepository.verifyLimitOTP(userId: userId, otp: otp)
        
        try await profileRepository.updateTransactionLimit(userId: userId, newLimit: newLimit)
        
        try await profileRepository.clearUserLimitOTPs(userId: userId)
        
        print("Límite actualizado a S/ \(newLimit)")
    }
}
