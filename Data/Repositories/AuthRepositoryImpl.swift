//
//  AuthRepository.swift
//  enone
//
//  Created by Asbel on 16/12/25.
//

import Foundation

final class AuthRepositoryImpl: AuthRepositoryProtocol {
    private let authDataSource: SupabaseAuthDataSource
    private let profileDataSource: ProfileDataSource
    private let sessionManager: SessionManager

    init(
        authDataSource: SupabaseAuthDataSource = SupabaseAuthDataSource(),
        profileDataSource: ProfileDataSource = ProfileDataSource(),
        sessionManager: SessionManager = .shared
    ) {
        self.authDataSource = authDataSource
        self.profileDataSource = profileDataSource
        self.sessionManager = sessionManager
    }

    func login(email: String, password: String) async throws {
        try await authDataSource.signIn(email: email, password: password)
    }

    func register(email: String, password: String) async throws {
        // Solo registrar en Supabase Auth
        // El trigger de Supabase creará automáticamente el perfil
        try await authDataSource.signUp(email: email, password: password)
    }

    func logout() async throws {
        try await authDataSource.signOut()
    }

    func isLoggedIn() async -> Bool {
        await sessionManager.isLoggedIn()
    }

    func currentUserId() async -> String? {
        await sessionManager.currentUserId()
    }

    func currentEmail() async -> String? {
        await sessionManager.currentEmail()
    }
    
    func verifyEmailOTP(email: String, token: String) async throws {
        try await authDataSource.verifyEmailOTP(
            email: email,
            token: token
        )

        let session = try await SupabaseClientProvider.shared
            .client
            .auth
            .session

        let userId = session.user.id.uuidString
        
        try await profileDataSource.markEmailAsVerified(
            userId: userId
        )
    }
    
    func resendOTP(email: String) async throws {
        try await authDataSource.resendOTP(email: email)
    }
}
