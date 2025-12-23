//
//  LoginViewModel.swift
//  enone
//
//  Created by Asbel on 16/12/25.
//

import Foundation

final class LoginViewModel {

    var onLoadingChange: ((Bool) -> Void)?
    var onError: ((String) -> Void)?
    
    var onNavigateToVerifyEmail: ((String) -> Void)?
    var onNavigateToCompleteProfile: (() -> Void)?
    var onNavigateToHome: (() -> Void)?

    private let loginUseCase: LoginUseCase
    private let checkUserStatusUseCase: CheckUserStatusUseCase

    init(
        loginUseCase: LoginUseCase,
        checkUserStatusUseCase: CheckUserStatusUseCase
    ) {
        self.loginUseCase = loginUseCase
        self.checkUserStatusUseCase = checkUserStatusUseCase
    }

    func login(email: String, password: String) {
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let cleanPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !cleanEmail.isEmpty else {
            onError?("Ingresa tu correo electrónico")
            return
        }
        
        guard cleanEmail.isValidEmail else {
            onError?("Ingresa un correo electrónico válido")
            return
        }
        
        guard !cleanPassword.isEmpty else {
            onError?("Ingresa tu contraseña")
            return
        }
        
        onLoadingChange?(true)

        Task {
            do {
                try await loginUseCase.execute(
                    email: cleanEmail,
                    password: cleanPassword
                )
                
                let userStatus = try await checkUserStatusUseCase.execute()
                
                await MainActor.run {
                    onLoadingChange?(false)
                    
                    switch userStatus {
                    case .notAuthenticated:
                        onError?("Error de autenticación. Intenta de nuevo.")
                        
                    case .emailNotVerified(let userEmail):
                        onNavigateToVerifyEmail?(userEmail)
                        
                    case .profileIncomplete:
                        onNavigateToCompleteProfile?()
                        
                    case .fullyVerified:
                        onNavigateToHome?()
                    }
                }
                
            } catch {
                await MainActor.run {
                    onLoadingChange?(false)
                    
                    let errorMessage = parseSupabaseError(error)
                    onError?(errorMessage)
                    
                    print("❌ Login Error: \(error)")
                }
            }
        }
    }
    
    private func parseSupabaseError(_ error: Error) -> String {
        let errorDescription = error.localizedDescription.lowercased()
        
        if errorDescription.contains("invalid login") ||
           errorDescription.contains("invalid credentials") {
            return "Correo o contraseña incorrectos"
        }
        
        if errorDescription.contains("email not confirmed") {
            return "Tu email aún no ha sido verificado"
        }
        
        if errorDescription.contains("email not found") ||
           errorDescription.contains("user not found") {
            return "Usuario no encontrado. ¿Necesitas crear una cuenta?"
        }
        
        if errorDescription.contains("network") ||
           errorDescription.contains("connection") {
            return "Error de conexión. Verifica tu internet."
        }
        
        if errorDescription.contains("rate limit") {
            return "Demasiados intentos. Espera un momento."
        }
        
        if errorDescription.contains("profile") || errorDescription.contains("404") {
            return "Perfil no encontrado. Por favor regístrate."
        }
        
        return "Error: \(error.localizedDescription)"
    }
}
