//
//  CheckUserStatusUseCase.swift
//  enone
//
//  Created by Asbel on 17/12/25.
//

import Foundation

final class CheckUserStatusUseCase {
    private let authRepository: AuthRepositoryProtocol
    private let profileRepository: ProfileRepositoryProtocol
    
    init(
        authRepository: AuthRepositoryProtocol,
        profileRepository: ProfileRepositoryProtocol
    ) {
        self.authRepository = authRepository
        self.profileRepository = profileRepository
    }

    func execute() async throws -> UserStatus {
        guard await authRepository.isLoggedIn() else {
            return .notAuthenticated
        }
        
        guard let userId = await authRepository.currentUserId(),
              let email = await authRepository.currentEmail() else {
            return .notAuthenticated
        }
        
        let profile = try await profileRepository.getUserProfile(userId: userId)
        
        return profile.getUserStatus(email: email)
    }
}
