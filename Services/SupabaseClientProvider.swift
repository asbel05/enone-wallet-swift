
//  SupabaseClientProvider.swift
//  enone
//
//  Created by Asbel on 14/12/25.
//

import Foundation
import Supabase

final class SupabaseClientProvider {
    static let shared = SupabaseClientProvider()

    let client: SupabaseClient
    let anonKey: String

    private struct Config {
        static let supabaseURL = "https://roqxzsczeapqxyrkeekg.supabase.co/"
        static let supabaseKey = "sb_publishable_PboYDvkpGrG2v27woc0ZYA_JGg9lqt8"
    }

    private init() {
        guard let url = URL(string: Config.supabaseURL) else {
            fatalError("Invalid Supabase URL")
        }

        self.anonKey = Config.supabaseKey

        client = SupabaseClient(
            supabaseURL: url,
            supabaseKey: Config.supabaseKey
        )
    }
}

