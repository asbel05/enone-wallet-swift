//
//  VerificationCodeRepositoryProtocol.swift
//  enone
//
//  Created by Asbel on 18/12/25.
//

import Foundation

protocol VerificationCodeRepositoryProtocol {
    
    func createCode(userId: String, purpose: VerificationPurpose, metadata: [String: Any]?) async throws -> String
    
    func verifyCode(
        userId: String,
        purpose: VerificationPurpose,
        code: String
    ) async throws -> VerificationCode
    
    func markAsUsed(codeId: Int) async throws
    
    func getCodeMetadata(codeId: Int) async throws -> [String: Any]?
    
    func invalidatePendingCodes(userId: String, purpose: VerificationPurpose) async throws
    
    func cleanupExpiredCodes() async throws
}
