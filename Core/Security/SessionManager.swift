//
//  SessionManager.swift
//  enone
//
//  Created by Asbel on 14/12/25.
//

import Foundation
import Supabase

final class SessionManager {

    static let shared = SessionManager()

    private let client: SupabaseClient

    private init(
        client: SupabaseClient = SupabaseClientProvider.shared.client
    ) {
        self.client = client
    }

    func isLoggedIn() async -> Bool {
        do {
            _ = try await client.auth.session
            return true
        } catch {
            return false
        }
    }

    func currentUserId() async -> String? {
        do {
            let session = try await client.auth.session
            return session.user.id.uuidString
        } catch {
            return nil
        }
    }

    func currentEmail() async -> String? {
        do {
            let session = try await client.auth.session
            return session.user.email
        } catch {
            return nil
        }
    }

    func logout() async throws {
        CacheManager.shared.clearAll()
        KeychainManager.shared.clearAll()
        
        try await client.auth.signOut()
    }
}
