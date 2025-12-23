//
//  ValidateDNIUseCase.swift
//  enone
//
//  Created by Asbel on 17/12/25.
//

import Foundation

enum DNIValidationError: LocalizedError {
    case invalidDNI
    case namesMismatch
    case firstNameMismatch
    case firstLastNameMismatch
    case secondLastNameMismatch
    case apiError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidDNI:
            return "DNI no encontrado en RENIEC"
        case .namesMismatch:
            return "Los nombres y apellidos no coinciden con los datos de RENIEC"
        case .firstNameMismatch:
            return "Los nombres no coinciden con los registrados en RENIEC"
        case .firstLastNameMismatch:
            return "El primer apellido no coincide con el registrado en RENIEC"
        case .secondLastNameMismatch:
            return "El segundo apellido no coincide con el registrado en RENIEC"
        case .apiError(let message):
            return message
        }
    }
}

final class ValidateDNIUseCase {
    private let repository: ProfileRepositoryProtocol
    
    init(repository: ProfileRepositoryProtocol = ProfileRepositoryImpl()) {
        self.repository = repository
    }
    
    func execute(
        dni: String,
        firstName: String,
        firstLastName: String,
        secondLastName: String
    ) async throws -> RENIECData {
        let reniecData = try await repository.validateDNI(dni: dni)
        
        guard reniecData.validateNames(
            inputFirstName: firstName,
            inputFirstLastName: firstLastName,
            inputSecondLastName: secondLastName
        ) else {
            throw DNIValidationError.namesMismatch
        }
        
        return reniecData
    }
}
