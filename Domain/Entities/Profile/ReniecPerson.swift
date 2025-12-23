//
//  ReniecPerson.swift
//  enone
//
//  Created by Asbel on 17/12/25.
//

import Foundation

/// Modelo que representa la respuesta de la API de decolecta
struct RENIECData: Codable {
    let firstName: String?
    let firstLastName: String?
    let secondLastName: String?
    let fullName: String?
    let documentNumber: String?
    
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case firstLastName = "first_last_name"
        case secondLastName = "second_last_name"
        case fullName = "full_name"
        case documentNumber = "document_number"
    }

    /// - Parameters:
    ///   - inputFirstName: Nombres ingresados por el usuario (debe coincidir exactamente)
    ///   - inputFirstLastName: Primer apellido ingresado por el usuario
    ///   - inputSecondLastName: Segundo apellido ingresado por el usuario
    func validateNames(
        inputFirstName: String,
        inputFirstLastName: String,
        inputSecondLastName: String
    ) -> Bool {
        let normalizedInputFirstName = normalize(inputFirstName)
        let normalizedInputFirstLastName = normalize(inputFirstLastName)
        let normalizedInputSecondLastName = normalize(inputSecondLastName)
        
        let normalizedReniecFirstName = normalize(firstName ?? "")
        let normalizedReniecFirstLastName = normalize(firstLastName ?? "")
        let normalizedReniecSecondLastName = normalize(secondLastName ?? "")
        
        let firstNameMatch = normalizedInputFirstName == normalizedReniecFirstName
        let firstLastNameMatch = normalizedInputFirstLastName == normalizedReniecFirstLastName
        let secondLastNameMatch = normalizedInputSecondLastName == normalizedReniecSecondLastName
        
        return firstNameMatch && firstLastNameMatch && secondLastNameMatch
    }
    
    /// Normaliza un string: mayúsculas, sin espacios extras, sin acentos
    private func normalize(_ text: String) -> String {
        return text
            .uppercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: .diacriticInsensitive, locale: .current)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
    }
}

struct RENIECError: Codable {
    let error: String?
}
