//
//  VerificationCode.swift
//  enone
//
//  Created by Asbel on 18/12/25.
//

import Foundation

/// Código de verificación unificado (OTP)
struct VerificationCode: Codable {
    let id: Int
    let userId: String
    let purpose: VerificationPurpose
    let code: String
    let metadata: [String: Any]?
    let expiresAt: String
    let usedAt: String?
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case purpose
        case code
        case metadata
        case expiresAt = "expires_at"
        case usedAt = "used_at"
        case createdAt = "created_at"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        userId = try container.decode(String.self, forKey: .userId)
        purpose = try container.decode(VerificationPurpose.self, forKey: .purpose)
        code = try container.decode(String.self, forKey: .code)
        expiresAt = try container.decode(String.self, forKey: .expiresAt)
        usedAt = try container.decodeIfPresent(String.self, forKey: .usedAt)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        
        // Metadata es JSONB, lo parseamos manualmente
        if let metadataData = try? container.decode([String: String].self, forKey: .metadata) {
            metadata = metadataData
        } else {
            metadata = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(userId, forKey: .userId)
        try container.encode(purpose, forKey: .purpose)
        try container.encode(code, forKey: .code)
        try container.encode(expiresAt, forKey: .expiresAt)
        try container.encodeIfPresent(usedAt, forKey: .usedAt)
        try container.encode(createdAt, forKey: .createdAt)
    }
    
    var isExpired: Bool {
        let formatter = ISO8601DateFormatter()
        guard let expiryDate = formatter.date(from: expiresAt) else {
            return true
        }
        return Date() > expiryDate
    }
    
    var isUsed: Bool {
        return usedAt != nil
    }
}

/// Propósitos de verificación
enum VerificationPurpose: String, Codable {
    case limitChange = "LIMIT_CHANGE"
    case transfer = "TRANSFER"
    case enable2FA = "ENABLE_2FA"
    case disable2FA = "DISABLE_2FA"
    case passwordReset = "PASSWORD_RESET"
    
    var displayName: String {
        switch self {
        case .limitChange: return "Cambio de límite"
        case .transfer: return "Transferencia"
        case .enable2FA: return "Activar 2FA"
        case .disable2FA: return "Desactivar 2FA"
        case .passwordReset: return "Recuperar contraseña"
        }
    }
    
    var expirationMinutes: Int {
        switch self {
        case .limitChange, .transfer, .enable2FA, .disable2FA:
            return 10
        case .passwordReset:
            return 30
        }
    }
}
