//
//  ProfileRepositoryProtocol.swift
//  enone
//
//  Created by Asbel on 17/12/25.
//

import Foundation

protocol ProfileRepositoryProtocol {
    func validateDNI(dni: String) async throws -> RENIECData
    
    func updateProfile(
        userId: String,
        phone: String,
        dni: String,
        firstName: String,
        firstLastName: String,
        secondLastName: String,
        gender: String,
        reniecData: RENIECData
    ) async throws
    
    func getUserProfile(userId: String) async throws -> Profile
    
    func checkDuplicateDNI(dni: String, excludeUserId: String) async throws -> Bool
    func checkDuplicatePhone(phone: String, excludeUserId: String) async throws -> Bool
    
    func createLimitChangeOTP(userId: String, newLimit: Double, email: String) async throws -> String
    func verifyLimitOTP(userId: String, otp: String) async throws -> Double
    func clearUserLimitOTPs(userId: String) async throws
    func updateTransactionLimit(userId: String, newLimit: Double) async throws
    
    func requestTwoFactorOTP(userId: String, email: String) async throws -> String
    func verifyTwoFactorOTP(userId: String, otp: String) async throws -> Bool
}
