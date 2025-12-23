//
//  VerificationCodeRepository.swift
//  enone
//
//  Created by Asbel on 18/12/25.
//

import Foundation

final class VerificationCodeRepositoryImpl: VerificationCodeRepositoryProtocol {
    
    private let dataSource: VerificationCodeDataSource
    private let profileDataSource: ProfileDataSource
    
    init(
        dataSource: VerificationCodeDataSource = VerificationCodeDataSource(),
        profileDataSource: ProfileDataSource = ProfileDataSource()
    ) {
        self.dataSource = dataSource
        self.profileDataSource = profileDataSource
    }
    
    func createCode(
        userId: String,
        purpose: VerificationPurpose,
        metadata: [String: Any]?
    ) async throws -> String {
        let profile = try await profileDataSource.getUserProfile(userId: userId)
        guard let email = profile.email, !email.isEmpty else {
            throw VerificationCodeError.invalidCode
        }
        
        try? await dataSource.invalidatePendingCodes(userId: userId, purpose: purpose)
        
        return try await dataSource.createCode(
            userId: userId,
            email: email,
            purpose: purpose,
            metadata: metadata
        )
    }
    
    func verifyCode(
        userId: String,
        purpose: VerificationPurpose,
        code: String
    ) async throws -> VerificationCode {
        let record = try await dataSource.verifyCode(userId: userId, purpose: purpose, code: code)
        
        try await dataSource.markAsUsed(codeId: record.id)
        
        return VerificationCode(
            id: record.id,
            userId: userId,
            purpose: purpose,
            code: code,
            record: record
        )
    }
    
    func markAsUsed(codeId: Int) async throws {
        try await dataSource.markAsUsed(codeId: codeId)
    }
    
    func getCodeMetadata(codeId: Int) async throws -> [String: Any]? {
        // Se obtiene del record durante la verificación
        return nil
    }
    
    func invalidatePendingCodes(
        userId: String,
        purpose: VerificationPurpose
    ) async throws {
        try await dataSource.invalidatePendingCodes(userId: userId, purpose: purpose)
    }
    
    func cleanupExpiredCodes() async throws {
        // Se hace automáticamente con la función SQL
    }
}

extension VerificationCode {
    init(id: Int, userId: String, purpose: VerificationPurpose, code: String, record: VerificationCodeRecord) {
        self.id = id
        self.userId = userId
        self.purpose = purpose
        self.code = code
        self.metadata = record.getMetadata()
        self.expiresAt = ""
        self.usedAt = ISO8601DateFormatter().string(from: Date())
        self.createdAt = ""
    }
}
