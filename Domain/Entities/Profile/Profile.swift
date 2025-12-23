//
//  Profile.swift
//  enone
//
//  Created by Asbel on 17/12/25.
//

import Foundation

struct Profile: Codable {
    let id: String
    let email: String?
    let emailVerified: Bool
    let onboardingCompleted: Bool
    let phone: String?
    let dni: String?
    let firstName: String?
    let firstLastName: String?
    let secondLastName: String?
    let fullName: String?
    let gender: String?
    let transactionLimit: Double?
    let lastLimitChange: String?
    let dailyVolume: Double?
    let dailyVolumeUSD: Double?
    let twoFactorEnabled: Bool
    let twoFactorSecret: String?
    let createdAt: String?
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case emailVerified = "email_verified"
        case onboardingCompleted = "onboarding_completed"
        case phone
        case dni
        case firstName = "first_name"
        case firstLastName = "first_last_name"
        case secondLastName = "second_last_name"
        case fullName = "full_name"
        case gender
        case transactionLimit = "transaction_limit"
        case lastLimitChange = "last_limit_change"
        case dailyVolume = "daily_volume_pen"
        case dailyVolumeUSD = "daily_volume_usd"
        case twoFactorEnabled = "two_factor_enabled"
        case twoFactorSecret = "two_factor_secret"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    func getUserStatus(email: String) -> UserStatus {
        if !emailVerified {
            return .emailNotVerified(email: email)
        }
        
        if !onboardingCompleted {
            return .profileIncomplete
        }
        
        return .fullyVerified
    }
}
