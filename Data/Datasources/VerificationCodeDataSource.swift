//
//  VerificationCodeDataSource.swift
//  enone
//
//  Created by Asbel on 18/12/25.
//

import Foundation
import Supabase

final class VerificationCodeDataSource {
    
    private let client: SupabaseClient
    private let emailService: EmailServiceProvider
    
    init(
        client: SupabaseClient = SupabaseClientProvider.shared.client,
        emailService: EmailServiceProvider = EmailServiceProvider.shared
    ) {
        self.client = client
        self.emailService = emailService
    }

    func createCode(
        userId: String,
        email: String,
        purpose: VerificationPurpose,
        metadata: [String: Any]?
    ) async throws -> String {
        let code = String(format: "%06d", Int.random(in: 100000...999999))
        
        let expiresAt = Date().addingTimeInterval(TimeInterval(purpose.expirationMinutes * 60))
        let formatter = ISO8601DateFormatter()
        let expiresAtString = formatter.string(from: expiresAt)
        
        var metadataJSON: String = "{}"
        if let metadata = metadata {
            if let jsonData = try? JSONSerialization.data(withJSONObject: metadata),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                metadataJSON = jsonString
            }
        }
        
        struct InsertCode: Encodable {
            let user_id: String
            let purpose: String
            let code: String
            let metadata: String
            let expires_at: String
        }
        
        let insertData = InsertCode(
            user_id: userId,
            purpose: purpose.rawValue,
            code: code,
            metadata: metadataJSON,
            expires_at: expiresAtString
        )
        
        try await client
            .from("verification_codes")
            .insert(insertData)
            .execute()
        
        let emailHTML = generateEmailHTML(code: code, purpose: purpose, metadata: metadata)
        try await emailService.sendEmail(
            to: email,
            subject: getEmailSubject(purpose: purpose),
            html: emailHTML
        )
        
        print("Código \(purpose.rawValue) enviado a \(email): \(code)")
        return code
    }

    func verifyCode(
        userId: String,
        purpose: VerificationPurpose,
        code: String
    ) async throws -> VerificationCodeRecord {
        struct CodeRecord: Decodable {
            let id: Int
            let metadata: String?
            let expires_at: String
            let used_at: String?
        }
        
        let response: [CodeRecord] = try await client
            .from("verification_codes")
            .select()
            .eq("user_id", value: userId)
            .eq("purpose", value: purpose.rawValue)
            .eq("code", value: code)
            .execute()
            .value
        
        guard let record = response.first(where: { $0.used_at == nil }) else {
            throw VerificationCodeError.invalidCode
        }
        
        let formatter = ISO8601DateFormatter()
        if let expiryDate = formatter.date(from: record.expires_at),
           Date() > expiryDate {
            throw VerificationCodeError.codeExpired
        }
        
        return VerificationCodeRecord(
            id: record.id,
            metadataJSON: record.metadata
        )
    }

    func markAsUsed(codeId: Int) async throws {
        let now = ISO8601DateFormatter().string(from: Date())
        
        try await client
            .from("verification_codes")
            .update(["used_at": now])
            .eq("id", value: codeId)
            .execute()
    }

    func invalidatePendingCodes(userId: String, purpose: VerificationPurpose) async throws {
        let now = ISO8601DateFormatter().string(from: Date())
        
        struct CodeId: Decodable {
            let id: Int
            let used_at: String?
        }
        
        let codes: [CodeId] = try await client
            .from("verification_codes")
            .select("id, used_at")
            .eq("user_id", value: userId)
            .eq("purpose", value: purpose.rawValue)
            .execute()
            .value
        
        for code in codes where code.used_at == nil {
            try await client
                .from("verification_codes")
                .update(["used_at": now])
                .eq("id", value: code.id)
                .execute()
        }
    }

    private func getEmailSubject(purpose: VerificationPurpose) -> String {
        switch purpose {
        case .limitChange:
            return "Código de verificación - Cambio de límite"
        case .transfer:
            return "Código de verificación - Confirmar transferencia"
        case .enable2FA:
            return "Código de verificación - Activar 2FA"
        case .disable2FA:
            return "Código de verificación - Desactivar 2FA"
        case .passwordReset:
            return "Código de verificación - Recuperar contraseña"
        }
    }
    
    private func generateEmailHTML(code: String, purpose: VerificationPurpose, metadata: [String: Any]?) -> String {
        var additionalInfo = ""
        
        switch purpose {
        case .limitChange:
            if let newLimit = metadata?["new_limit"] as? Double {
                additionalInfo = "<p><strong>Nuevo límite solicitado:</strong> S/ \(String(format: "%.2f", newLimit))</p>"
            }
        case .transfer:
            if let amount = metadata?["amount"] as? Double,
               let currency = metadata?["currency"] as? String,
               let walletTo = metadata?["wallet_to"] as? String {
                additionalInfo = """
                <p><strong>Monto:</strong> \(currency) \(String(format: "%.2f", amount))</p>
                <p><strong>Destino:</strong> \(walletTo)</p>
                """
            }
        default:
            break
        }
        
        return """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="utf-8">
            <style>
                body { font-family: -apple-system, sans-serif; line-height: 1.6; color: #333; }
                .container { max-width: 600px; margin: 0 auto; padding: 20px; }
                .header { background: linear-gradient(135deg, #3385B3, #4D99BF); color: white; padding: 30px; text-align: center; border-radius: 12px 12px 0 0; }
                .content { background: #fff; padding: 30px; border: 1px solid #eee; }
                .code-box { background: #f8f9fa; border: 2px solid #3385B3; border-radius: 8px; padding: 20px; text-align: center; margin: 20px 0; }
                .code { font-size: 36px; font-weight: bold; color: #3385B3; font-family: monospace; letter-spacing: 6px; }
                .warning { background: #fff3cd; border-left: 4px solid #ffc107; padding: 15px; margin: 20px 0; }
                .footer { text-align: center; color: #666; font-size: 12px; padding: 20px; }
            </style>
        </head>
        <body>
            <div class="container">
                <div class="header">
                    <h1>🔐 EnOne</h1>
                    <h2>\(purpose.displayName)</h2>
                </div>
                <div class="content">
                    <p>Hola,</p>
                    <p>Has solicitado verificar una acción en tu cuenta EnOne.</p>
                    
                    <div class="code-box">
                        <p style="margin: 0; color: #666;">Tu código de verificación es:</p>
                        <p class="code">\(code)</p>
                    </div>
                    
                    \(additionalInfo)
                    
                    <div class="warning">
                        <p><strong>⚠️ Importante:</strong></p>
                        <p>• Este código expira en <strong>\(purpose.expirationMinutes) minutos</strong></p>
                        <p>• No compartas este código con nadie</p>
                    </div>
                    
                    <p style="color: #888;">Si no solicitaste esto, ignora este correo.</p>
                </div>
                <div class="footer">
                    <p>© 2024 EnOne - Billetera Digital</p>
                </div>
            </div>
        </body>
        </html>
        """
    }
}

struct VerificationCodeRecord {
    let id: Int
    let metadataJSON: String?
    
    func getMetadata() -> [String: Any]? {
        guard let json = metadataJSON,
              let data = json.data(using: .utf8),
              let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        return dict
    }
}

enum VerificationCodeError: LocalizedError {
    case invalidCode
    case codeExpired
    case alreadyUsed
    
    var errorDescription: String? {
        switch self {
        case .invalidCode:
            return "Código de verificación inválido"
        case .codeExpired:
            return "El código ha expirado"
        case .alreadyUsed:
            return "El código ya fue utilizado"
        }
    }
}
