//
//  SupabaseAuthDataSource.swift
//  enone
//
//  Created by Asbel on 16/12/25.
//

import Foundation
import Supabase

final class SupabaseAuthDataSource {

    private let client: SupabaseClient

    init(client: SupabaseClient = SupabaseClientProvider.shared.client) {
        self.client = client
    }

    func signIn(email: String, password: String) async throws {
        try await client.auth.signIn(email: email, password: password)
    }

    func signUp(email: String, password: String) async throws {
        try await client.auth.signUp(email: email, password: password)
    }

    func signOut() async throws {
        try await client.auth.signOut()
    }
    
    func verifyEmailOTP(email: String, token: String) async throws {
        try await client.auth.verifyOTP(email: email, token: token, type: .email)
    }
    
    func resendOTP(email: String) async throws {
        try await client.auth.resend(email: email, type: .signup)
    }
    
    func getSession() async throws -> Session {
        return try await client.auth.session
    }
}
