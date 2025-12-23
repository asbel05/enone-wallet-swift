//
//  ResendOTPUseCase.swift
//  enone
//
//  Created by Asbel on 17/12/25.
//

import Foundation

final class ResendOTPUseCase {
    private let repository: AuthRepositoryProtocol
    
    init(repository: AuthRepositoryProtocol = AuthRepositoryImpl()) {
        self.repository = repository
    }
    
    func execute(email: String) async throws {
        try await repository.resendOTP(email: email)
    }
}
