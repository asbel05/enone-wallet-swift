//
//  VerifyEmailViewModel.swift
//  enone
//
//  Created by Asbel on 17/12/25.
//

import Foundation

final class VerifyEmailViewModel {

    var onLoadingChange: ((Bool) -> Void)?
    var onError: ((String) -> Void)?
    var onVerificationSuccess: (() -> Void)?
    var onResendSuccess: (() -> Void)?

    private let verifyEmailOTPUseCase: VerifyEmailOTPUseCase
    private let resendOTPUseCase: ResendOTPUseCase
    let email: String

    init(
        verifyEmailOTPUseCase: VerifyEmailOTPUseCase,
        resendOTPUseCase: ResendOTPUseCase,
        email: String
    ) {
        self.verifyEmailOTPUseCase = verifyEmailOTPUseCase
        self.resendOTPUseCase = resendOTPUseCase
        self.email = email
    }

    func verify(token: String) {
        let cleanToken = token.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !cleanToken.isEmpty else {
            onError?("Ingresa el código de verificación")
            return
        }
        
        guard cleanToken.isValidOTP else {
            onError?("El código debe tener 8 dígitos numéricos")
            return
        }
        
        onLoadingChange?(true)

        Task {
            do {
                try await verifyEmailOTPUseCase.execute(email: email, token: cleanToken)
                await MainActor.run {
                    onLoadingChange?(false)
                    onVerificationSuccess?()
                }
            } catch {
                await MainActor.run {
                    onLoadingChange?(false)
                    
                    print("❌ Verify OTP Error: \(error)")
                    print("❌ Error description: \(error.localizedDescription)")
                    
                    let errorMessage = parseVerifyError(error)
                    onError?(errorMessage)
                }
            }
        }
    }
    
    func resendCode() {
        onLoadingChange?(true)
        
        Task {
            do {
                try await resendOTPUseCase.execute(email: email)
                await MainActor.run {
                    onLoadingChange?(false)
                    onResendSuccess?()
                }
            } catch {
                await MainActor.run {
                    onLoadingChange?(false)
                    
                    print("❌ Resend OTP Error: \(error)")
                    let errorMessage = parseResendError(error)
                    onError?(errorMessage)
                }
            }
        }
    }
    
    private func parseVerifyError(_ error: Error) -> String {
        let errorDescription = error.localizedDescription.lowercased()
        
        if errorDescription.contains("invalid") ||
           errorDescription.contains("incorrect") {
            return "Código inválido o expirado"
        }
        
        if errorDescription.contains("expired") {
            return "El código ha expirado. Solicita uno nuevo."
        }
        
        if errorDescription.contains("not found") {
            return "No se encontró el código. Verifica tu email."
        }
        
        if errorDescription.contains("otp") {
            return "Código incorrecto. Intenta de nuevo."
        }
        
        return "Error: \(error.localizedDescription)"
    }
    
    private func parseResendError(_ error: Error) -> String {
        let errorDescription = error.localizedDescription.lowercased()
        
        if errorDescription.contains("rate limit") || errorDescription.contains("too many") {
            return "Espera un momento antes de solicitar otro código"
        }
        
        if errorDescription.contains("network") || errorDescription.contains("connection") {
            return "Error de conexión. Verifica tu internet."
        }
        
        return "Error al reenviar código: \(error.localizedDescription)"
    }
}
