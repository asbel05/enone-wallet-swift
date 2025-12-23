//
//  CompleteProfileUseCase.swift
//  enone
//
//  Created by Asbel on 17/12/25.
//

import Foundation

final class CompleteProfileUseCase {
    private let repository: ProfileRepositoryProtocol
    
    init(repository: ProfileRepositoryProtocol = ProfileRepositoryImpl()) {
        self.repository = repository
    }
    
    func execute(
        userId: String,
        phone: String,
        dni: String,
        firstName: String,
        firstLastName: String,
        secondLastName: String,
        gender: String,
        reniecData: RENIECData
    ) async throws {
        try await repository.updateProfile(
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

    func checkDuplicateDNI(dni: String, excludeUserId: String) async throws -> Bool {
        return try await repository.checkDuplicateDNI(dni: dni, excludeUserId: excludeUserId)
    }
    
    func checkDuplicatePhone(phone: String, excludeUserId: String) async throws -> Bool {
        return try await repository.checkDuplicatePhone(phone: phone, excludeUserId: excludeUserId)
    }
}
