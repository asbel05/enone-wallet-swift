//
//  String+Validation.swift
//  enone
//
//  Created by Asbel on 21/12/25.
//

import Foundation

extension String {
    
    // MARK: - Email
    var isValidEmail: Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: self)
    }
    
    // MARK: - Números
    var isOnlyDigits: Bool {
        return !isEmpty && allSatisfy { $0.isNumber }
    }
    
    // MARK: - Teléfono Perú (9 dígitos, empieza con 9)
    
    var isValidPeruvianPhone: Bool {
        return count == 9 && first == "9" && isOnlyDigits
    }
    
    // MARK: - DNI Perú (8 dígitos numéricos)
    var isValidDNI: Bool {
        return count == 8 && isOnlyDigits
    }
    
    // MARK: - OTP Email (8 dígitos numéricos)
    var isValidOTP: Bool {
        return count == 8 && isOnlyDigits
    }
    
    // MARK: - Código 2FA (6 dígitos numéricos)
    var isValid2FACode: Bool {
        return count == 6 && isOnlyDigits
    }
    
    // MARK: - Nombres (solo letras y espacios)
    var isOnlyLettersAndSpaces: Bool {
        return !isEmpty && allSatisfy { $0.isLetter || $0.isWhitespace }
    }
    
    // MARK: - Password segura
    var hasMinLength: Bool {
        return count >= 8
    }
    
    var hasUppercase: Bool {
        return contains { $0.isUppercase }
    }
    
    var hasLowercase: Bool {
        return contains { $0.isLowercase }
    }
    
    var hasNumber: Bool {
        return contains { $0.isNumber }
    }
    
    var isStrongPassword: Bool {
        return hasMinLength && hasUppercase && hasLowercase && hasNumber
    }
    
    // MARK: - Tarjetas
    var isValidCardNumber: Bool {
        let cleaned = replacingOccurrences(of: " ", with: "")
        return cleaned.count == 16 && cleaned.isOnlyDigits
    }
    
    var isValidCVV: Bool {
        return count == 3 && isOnlyDigits
    }
    
    var isValidExpiryDate: Bool {
        let parts = components(separatedBy: "/")
        guard parts.count == 2 else { return false }
        guard let month = Int(parts[0]), let year = Int(parts[1]) else { return false }
        return (1...12).contains(month) && year >= 24
    }
    
    // MARK: - Montos
    var isValidAmount: Bool {
        let cleaned = replacingOccurrences(of: ",", with: ".")
        guard let amount = Double(cleaned) else { return false }
        return amount > 0
    }
    
    var toAmount: Double? {
        let cleaned = replacingOccurrences(of: ",", with: ".")
        return Double(cleaned)
    }
}
