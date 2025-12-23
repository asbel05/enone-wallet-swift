//
//  ProfileCache.swift
//  enone
//
//  Created by Asbel on 21/12/25.
//

import Foundation

final class ProfileCache: CacheStorage {
    
    static let shared = ProfileCache()
    
    private let defaults = UserDefaults.standard
    
    private enum Keys {
        static let profile = "cache_profile_data"
    }
    
    private init() {}

    struct CachedProfile: Codable {
        let userId: String
        let fullName: String?
        let email: String?
        let phone: String?
        let dni: String?
        let gender: String?
        
        init(
            userId: String,
            fullName: String? = nil,
            email: String? = nil,
            phone: String? = nil,
            dni: String? = nil,
            gender: String? = nil
        ) {
            self.userId = userId
            self.fullName = fullName
            self.email = email
            self.phone = phone
            self.dni = dni
            self.gender = gender
        }
    }

    func save(_ profile: CachedProfile) {
        guard let data = try? JSONEncoder().encode(profile) else {
            print("ProfileCache: Error encoding profile")
            return
        }
        defaults.set(data, forKey: Keys.profile)
    }
    
    func get() -> CachedProfile? {
        guard let data = defaults.data(forKey: Keys.profile),
              let profile = try? JSONDecoder().decode(CachedProfile.self, from: data) else {
            return nil
        }
        return profile
    }
    
    func clear() {
        defaults.removeObject(forKey: Keys.profile)
    }
    
    func updateFullName(_ fullName: String) {
        guard var profile = get() else { return }
        let updated = CachedProfile(
            userId: profile.userId,
            fullName: fullName,
            email: profile.email,
            phone: profile.phone,
            dni: profile.dni,
            gender: profile.gender
        )
        save(updated)
    }
}
