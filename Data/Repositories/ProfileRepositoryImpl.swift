//
//  ProfileRepository.swift
//  enone
//
//  Created by Asbel on 17/12/25.
//

import Foundation

final class ProfileRepositoryImpl: ProfileRepositoryProtocol {
    
    private let dataSource: ProfileDataSource
    
    init(dataSource: ProfileDataSource = ProfileDataSource()) {
        self.dataSource = dataSource
    }
    
    func validateDNI(dni: String) async throws -> RENIECData {
        return try await dataSource.fetchDNIData(dni: dni)
    }
    
    func updateProfile(
        userId: String,
        phone: String,
        dni: String,
        firstName: String,
        firstLastName: String,
        secondLastName: String,
        gender: String,
        reniecData: RENIECData
    ) async throws {
        try await dataSource.updateProfile(
            userId: userId,
            phone: phone,
            dni: dni,
            firstName: firstName,
            firstLastName: firstLastName,
            secondLastName: secondLastName,
            gender: gender,
            reniecData: reniecData
        )
    }
    
    func getUserProfile(userId: String) async throws -> Profile {
        return try await dataSource.getUserProfile(userId: userId)
    }
    
    func createLimitChangeOTP(userId: String, newLimit: Double, email: String) async throws -> String {
        return try await dataSource.createLimitChangeOTP(userId: userId, newLimit: newLimit, email: email)
    }
    
    func verifyLimitOTP(userId: String, otp: String) async throws -> Double {
        return try await dataSource.verifyLimitOTP(userId: userId, otp: otp)
    }
    
    func clearUserLimitOTPs(userId: String) async throws {
        try await dataSource.clearUserLimitOTPs(userId: userId)
    }
    
    func updateTransactionLimit(userId: String, newLimit: Double) async throws {
        try await dataSource.updateTransactionLimit(userId: userId, newLimit: newLimit)
    }
    
    func requestTwoFactorOTP(userId: String, email: String) async throws -> String {
        return try await dataSource.requestTwoFactorOTP(userId: userId, email: email)
    }
    
    func verifyTwoFactorOTP(userId: String, otp: String) async throws -> Bool {
        return try await dataSource.verifyTwoFactorOTP(userId: userId, otp: otp)
    }
    
    // MARK: - Verificaciones de duplicados
    
    func checkDuplicateDNI(dni: String, excludeUserId: String) async throws -> Bool {
        return try await dataSource.checkDuplicateDNI(dni: dni, excludeUserId: excludeUserId)
    }
    
    func checkDuplicatePhone(phone: String, excludeUserId: String) async throws -> Bool {
        return try await dataSource.checkDuplicatePhone(phone: phone, excludeUserId: excludeUserId)
    }
}
