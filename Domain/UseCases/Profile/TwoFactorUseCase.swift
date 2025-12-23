//
//  TwoFactorUseCase.swift
//  enone
//
//  Created by Asbel on 18/12/25.
//

import Foundation

struct TwoFactorUseCase {
    private let repository: ProfileRepositoryProtocol
    
    init(repository: ProfileRepositoryProtocol = ProfileRepositoryImpl()) {
        self.repository = repository
    }
    
    func requestOTP(userId: String, email: String) async throws -> String {
        return try await repository.requestTwoFactorOTP(userId: userId, email: email)
    }
    
    func verifyOTP(userId: String, otp: String) async throws -> Bool {
        return try await repository.verifyTwoFactorOTP(userId: userId, otp: otp)
    }
    
    func getSecret(userId: String) async throws -> String? {
        let profile = try await repository.getUserProfile(userId: userId)
        return profile.twoFactorSecret
    }
}
