import Foundation
import Supabase

final class ProfileDataSource {
    private let client: SupabaseClient
    
    init(client: SupabaseClient = SupabaseClientProvider.shared.client) {
        self.client = client
    }
    
    func markEmailAsVerified(userId: String) async throws {
        try await client
            .from("profiles")
            .update(["email_verified": true])
            .eq("id", value: userId)
            .execute()
    }
    
    func fetchDNIData(dni: String) async throws -> RENIECData {
        guard let url = DecolectaAPIConfig.dniEndpoint(dni: dni) else {
            throw NSError(domain: "ProfileError", code: 0, userInfo: [NSLocalizedDescriptionKey: "URL inválida"])
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = DecolectaAPIConfig.headers
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let jsonString = String(data: data, encoding: .utf8) {
            print("📦 RAW RENIEC RESPONSE: \(jsonString)")
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
             throw NSError(domain: "ProfileError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Error de red"])
        }
        
        if httpResponse.statusCode == 400 {
            if let errorResponse = try? JSONDecoder().decode(RENIECError.self, from: data) {
                throw NSError(domain: "ProfileError", code: 400, userInfo: [NSLocalizedDescriptionKey: errorResponse.error ?? "DNI no válido"])
            }
            throw NSError(domain: "ProfileError", code: 400, userInfo: [NSLocalizedDescriptionKey: "DNI no encontrado"])
        }
        
        guard httpResponse.statusCode == 200 else {
            throw NSError(domain: "ProfileError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Error en API RENIEC: \(httpResponse.statusCode)"])
        }
        
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(RENIECData.self, from: data)
            return result
        } catch {
            print("Decoding Error: \(error)")
            throw error
        }
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
        struct UpdateProfileParams: Encodable {
            let phone: String
            let dni: String
            let first_name: String
            let first_last_name: String
            let second_last_name: String
            let full_name: String
            let gender: String
            let onboarding_completed: Bool
        }
        
        let updateData = UpdateProfileParams(
            phone: phone,
            dni: dni,
            first_name: reniecData.firstName ?? firstName,
            first_last_name: reniecData.firstLastName ?? firstLastName,
            second_last_name: reniecData.secondLastName ?? secondLastName,
            full_name: reniecData.fullName ?? "\(firstName) \(firstLastName) \(secondLastName)",
            gender: gender,
            onboarding_completed: true
        )
        
        try await client
            .from("profiles")
            .update(updateData)
            .eq("id", value: userId)
            .execute()
    }
    
    func createInitialProfile(userId: String, email: String, phone: String) async throws {
        struct InitialProfileParams: Encodable {
            let id: String
            let email: String
            let phone: String
            let email_verified: Bool
            let onboarding_completed: Bool
        }
        
        let profileData = InitialProfileParams(
            id: userId,
            email: email,
            phone: phone,
            email_verified: false,
            onboarding_completed: false
        )
        
        try await client
            .from("profiles")
            .upsert(profileData)
            .execute()
    }
    
    func getUserProfile(userId: String) async throws -> Profile {
        let response: [Profile] = try await client
            .from("profiles")
            .select()
            .eq("id", value: userId)
            .execute()
            .value
        
        guard let profile = response.first else {
            throw NSError(domain: "ProfileError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Perfil no encontrado"])
        }
        
        return profile
    }

    func createLimitChangeOTP(userId: String, newLimit: Double, email: String) async throws -> String {
        let otp = String(format: "%06d", Int.random(in: 100000...999999))
        
        struct LimitOTP: Encodable {
            let user_id: String
            let otp: String
            let new_limit: Double
            let verified: Bool
        }
        
        try await client
            .from("limit_change_otps")
            .insert(LimitOTP(user_id: userId, otp: otp, new_limit: newLimit, verified: false))
            .execute()
        
        try await sendOTPEmail(email: email, otp: otp, newLimit: newLimit)
        
        print("📧 OTP generado y enviado a \(email): \(otp)")
        return otp
    }
    
    private func sendOTPEmail(email: String, otp: String, newLimit: Double) async throws {
        let emailService = EmailServiceProvider.shared
        let html = emailService.generateLimitOTPEmailHTML(otp: otp, newLimit: newLimit)
        
        try await emailService.sendEmail(
            to: email,
            subject: "Código de verificación - Cambio de límite",
            html: html
        )
    }
    
    func verifyLimitOTP(userId: String, otp: String) async throws -> Double {
        struct OTPRecord: Decodable {
            let id: Int
            let new_limit: Double
            let created_at: String
        }
        
        let response: [OTPRecord] = try await client
            .from("limit_change_otps")
            .select()
            .eq("user_id", value: userId)
            .eq("otp", value: otp)
            .eq("verified", value: false)
            .execute()
            .value
        
        guard let record = response.first else {
            throw NSError(domain: "ProfileError", code: 401, userInfo: [NSLocalizedDescriptionKey: "Código inválido"])
        }
        
        // Verificar expiración (10 min)
        let formatter = ISO8601DateFormatter()
        if let createdDate = formatter.date(from: record.created_at) {
            let minutesSince = Date().timeIntervalSince(createdDate) / 60
            if minutesSince > 10 {
                throw NSError(domain: "ProfileError", code: 401, userInfo: [NSLocalizedDescriptionKey: "Código expirado"])
            }
        }
        
        try await client
            .from("limit_change_otps")
            .update(["verified": true])
            .eq("id", value: record.id)
            .execute()
        
        return record.new_limit
    }
    
    func clearUserLimitOTPs(userId: String) async throws {
        try await client
            .from("limit_change_otps")
            .delete()
            .eq("user_id", value: userId)
            .execute()
    }
    
    func updateTransactionLimit(userId: String, newLimit: Double) async throws {
        struct UpdateLimit: Encodable {
            let transaction_limit: Double
            let last_limit_change: String
        }
        
        let updateData = UpdateLimit(
            transaction_limit: newLimit,
            last_limit_change: ISO8601DateFormatter().string(from: Date())
        )
        
        try await client
            .from("profiles")
            .update(updateData)
            .eq("id", value: userId)
            .execute()
    }
    
    func checkDuplicateDNI(dni: String, excludeUserId: String) async throws -> Bool {
        struct DNIRecord: Decodable {
            let id: String
        }
        
        let response: [DNIRecord] = try await client
            .from("profiles")
            .select("id")
            .eq("dni", value: dni)
            .neq("id", value: excludeUserId)
            .execute()
            .value
        
        return !response.isEmpty
    }
    
    func checkDuplicatePhone(phone: String, excludeUserId: String) async throws -> Bool {
        struct PhoneRecord: Decodable {
            let id: String
        }
        
        let response: [PhoneRecord] = try await client
            .from("profiles")
            .select("id")
            .eq("phone", value: phone)
            .neq("id", value: excludeUserId)
            .execute()
            .value
        
        return !response.isEmpty
    }
    
    func findUserByEmail(email: String) async throws -> Profile? {
        let response: [Profile] = try await client
            .from("profiles")
            .select()
            .eq("email", value: email.lowercased())
            .execute()
            .value
        
        return response.first
    }
    
    func requestTwoFactorOTP(userId: String, email: String) async throws -> String {
        let otp = String(format: "%06d", Int.random(in: 100000...999999))
        let expirationDate = Date().addingTimeInterval(5 * 60)
        let otpData = "\(otp)|\(ISO8601DateFormatter().string(from: expirationDate))"
        
        try await client
            .from("profiles")
            .update(["two_factor_secret": otpData])
            .eq("id", value: userId)
            .execute()
        
        try await sendTwoFactorOTPEmail(email: email, otp: otp)
        
        print("🔐 2FA OTP enviado a \(email): \(otp)")
        return otp
    }
    
    func verifyTwoFactorOTP(userId: String, otp: String) async throws -> Bool {
        struct SecretData: Decodable {
            let two_factor_secret: String?
            let two_factor_enabled: Bool
        }
        
        let response: [SecretData] = try await client
            .from("profiles")
            .select("two_factor_secret, two_factor_enabled")
            .eq("id", value: userId)
            .execute()
            .value
        
        guard let data = response.first, let secret = data.two_factor_secret else {
            throw NSError(domain: "ProfileError", code: 401, userInfo: [NSLocalizedDescriptionKey: "No hay código pendiente"])
        }
        
        let components = secret.split(separator: "|")
        guard components.count == 2 else {
            throw NSError(domain: "ProfileError", code: 401, userInfo: [NSLocalizedDescriptionKey: "Formato inválido"])
        }
        
        let storedOtp = String(components[0])
        let expirationString = String(components[1])
        
        guard storedOtp == otp else {
            throw NSError(domain: "ProfileError", code: 401, userInfo: [NSLocalizedDescriptionKey: "Código incorrecto"])
        }
        
        let formatter = ISO8601DateFormatter()
        guard let expirationDate = formatter.date(from: expirationString), Date() < expirationDate else {
            throw NSError(domain: "ProfileError", code: 401, userInfo: [NSLocalizedDescriptionKey: "El código ha expirado"])
        }
        
        let newState = !data.two_factor_enabled
        
        if newState {
            struct Enable2FA: Encodable {
                let two_factor_enabled: Bool
                let two_factor_secret: String
            }
            let totpSecret = TOTPService.shared.generateSecret()
            try await client
                .from("profiles")
                .update(Enable2FA(two_factor_enabled: true, two_factor_secret: totpSecret))
                .eq("id", value: userId)
                .execute()
        } else {
            struct Disable2FA: Encodable {
                let two_factor_enabled: Bool
                let two_factor_secret: String?
            }
            try await client
                .from("profiles")
                .update(Disable2FA(two_factor_enabled: false, two_factor_secret: nil))
                .eq("id", value: userId)
                .execute()
        }
        
        return newState
    }
    
    private func sendTwoFactorOTPEmail(email: String, otp: String) async throws {
        let emailService = EmailServiceProvider.shared
        let html = """
        <div style="font-family: Arial, sans-serif; padding: 20px; color: #333;">
            <h2 style="color: #16BFA5;">Código de Seguridad EnOne</h2>
            <p>Usa el siguiente código para modificar tu configuración de seguridad (2FA):</p>
            <div style="background: #f4f4f4; padding: 15px; text-align: center; border-radius: 8px; font-size: 24px; letter-spacing: 5px; font-weight: bold;">
                \(otp)
            </div>
            <p>Este código expira en 5 minutos.</p>
            <p style="color: #999; font-size: 12px;">Si no solicitaste esto, ignora este mensaje.</p>
        </div>
        """
        
        try await emailService.sendEmail(
            to: email,
            subject: "Código de Seguridad 2FA - EnOne",
            html: html
        )
    }
}
