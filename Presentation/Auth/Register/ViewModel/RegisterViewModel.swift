//
//  RegisterViewModel.swift
//  enone
//
//  Created by Asbel on 16/12/25.
//

import Foundation

final class RegisterViewModel {
    
    var onLoadingChange: ((Bool) -> Void)?
    var onError: ((String) -> Void)?
    var onRegisterSuccess: ((String) -> Void)?
    
    private let registerUseCase: RegisterUseCase
    
    init(registerUseCase: RegisterUseCase) {
        self.registerUseCase = registerUseCase
    }
    
    func register(email: String, password: String) {
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let cleanPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !cleanEmail.isEmpty else {
            onError?("El correo no puede estar vacío")
            return
        }
        
        guard cleanEmail.isValidEmail else {
            onError?("Ingresa un correo válido")
            return
        }
        
        guard !cleanPassword.isEmpty else {
            onError?("La contraseña no puede estar vacía")
            return
        }
        
        guard cleanPassword.hasMinLength else {
            onError?("La contraseña debe tener al menos 8 caracteres")
            return
        }
        
        guard cleanPassword.hasUppercase else {
            onError?("La contraseña debe tener al menos una mayúscula")
            return
        }
        
        guard cleanPassword.hasNumber else {
            onError?("La contraseña debe tener al menos un número")
            return
        }
        
        onLoadingChange?(true)
        
        Task {
            do {
                try await registerUseCase.execute(
                    email: cleanEmail,
                    password: cleanPassword
                )
                await MainActor.run {
                    onLoadingChange?(false)
                    onRegisterSuccess?(cleanEmail)
                }
            } catch {
                await MainActor.run {
                    onLoadingChange?(false)
                    
                    let errorMessage = parseSupabaseError(error)
                    onError?(errorMessage)
                    
                    print("❌ Register Error: \(error)")
                }
            }
        }
    }
    
    private func parseSupabaseError(_ error: Error) -> String {
        let errorDescription = error.localizedDescription.lowercased()
        
        if errorDescription.contains("already registered") ||
           errorDescription.contains("already exists") ||
           errorDescription.contains("duplicate") {
            return "Este correo ya está registrado. Intenta iniciar sesión."
        }
        
        if errorDescription.contains("invalid email") {
            return "Correo electrónico inválido"
        }
        
        if errorDescription.contains("weak password") ||
           errorDescription.contains("password") {
            return "La contraseña es muy débil. Usa al menos 8 caracteres."
        }
        
        if errorDescription.contains("network") ||
           errorDescription.contains("connection") {
            return "Error de conexión. Verifica tu internet."
        }
        
        if errorDescription.contains("rate limit") {
            return "Demasiados intentos. Espera un momento."
        }
        
        return "Error: \(error.localizedDescription)"
    }
}
