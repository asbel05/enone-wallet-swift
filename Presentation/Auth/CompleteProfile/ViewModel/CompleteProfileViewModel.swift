//
//  CompleteProfileViewModel.swift
//  enone
//
//  Created by Asbel on 17/12/25.
//

import Foundation

final class CompleteProfileViewModel {
    
    var onLoadingChange: ((Bool) -> Void)?
    var onError: ((String) -> Void)?
    var onSuccess: (() -> Void)?
    var onNameValidated: ((String) -> Void)?
    
    private let validateDNIUseCase: ValidateDNIUseCase
    private let completeProfileUseCase: CompleteProfileUseCase
    private let getCurrentUserIdUseCase: GetCurrentUserIdUseCase
    
    init(
        validateDNIUseCase: ValidateDNIUseCase? = nil,
        completeProfileUseCase: CompleteProfileUseCase? = nil,
        getCurrentUserIdUseCase: GetCurrentUserIdUseCase = GetCurrentUserIdUseCase()
    ) {
        let profileRepo = ProfileRepositoryImpl()
        self.validateDNIUseCase = validateDNIUseCase ?? ValidateDNIUseCase()
        self.completeProfileUseCase = completeProfileUseCase ?? CompleteProfileUseCase()
        self.getCurrentUserIdUseCase = getCurrentUserIdUseCase
    }
    
    func submit(
        phone: String,
        dni: String,
        firstName: String,
        firstLastName: String,
        secondLastName: String,
        gender: String
    ) {
        let cleanPhone = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanDNI = dni.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanFirstName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanFirstLastName = firstLastName.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanSecondLastName = secondLastName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard cleanPhone.isValidPeruvianPhone else {
            if cleanPhone.count != 9 {
                onError?("El teléfono debe tener exactamente 9 dígitos")
            } else if cleanPhone.first != "9" {
                onError?("El teléfono debe empezar con 9")
            } else {
                onError?("El teléfono solo debe contener números")
            }
            return
        }
        
        guard cleanDNI.isValidDNI else {
            onError?("El DNI debe tener 8 dígitos numéricos")
            return
        }
        
        guard !cleanFirstName.isEmpty else {
            onError?("Ingresa tus nombres")
            return
        }
        
        guard cleanFirstName.isOnlyLettersAndSpaces else {
            onError?("Los nombres solo deben contener letras")
            return
        }
        
        guard !cleanFirstLastName.isEmpty else {
            onError?("Ingresa tu primer apellido (paterno)")
            return
        }
        
        guard cleanFirstLastName.isOnlyLettersAndSpaces else {
            onError?("El primer apellido solo debe contener letras")
            return
        }
        
        guard !cleanSecondLastName.isEmpty else {
            onError?("Ingresa tu segundo apellido (materno)")
            return
        }
        
        guard cleanSecondLastName.isOnlyLettersAndSpaces else {
            onError?("El segundo apellido solo debe contener letras")
            return
        }
        
        onLoadingChange?(true)
        
        Task {
            do {
                guard let userId = await getCurrentUserIdUseCase.execute() else {
                    await MainActor.run {
                        onLoadingChange?(false)
                        onError?("No se pudo identificar al usuario. Inicia sesión nuevamente.")
                    }
                    return
                }
                
                let isDuplicateDNI = try await completeProfileUseCase.checkDuplicateDNI(
                    dni: cleanDNI,
                    excludeUserId: userId
                )
                if isDuplicateDNI {
                    await MainActor.run {
                        onLoadingChange?(false)
                        onError?("Este DNI ya está registrado en otra cuenta")
                    }
                    return
                }
                
                let isDuplicatePhone = try await completeProfileUseCase.checkDuplicatePhone(
                    phone: cleanPhone,
                    excludeUserId: userId
                )
                if isDuplicatePhone {
                    await MainActor.run {
                        onLoadingChange?(false)
                        onError?("Este número de teléfono ya está registrado en otra cuenta")
                    }
                    return
                }
                
                let reniecData = try await validateDNIUseCase.execute(
                    dni: cleanDNI,
                    firstName: cleanFirstName,
                    firstLastName: cleanFirstLastName,
                    secondLastName: cleanSecondLastName
                )
                
                await MainActor.run {
                    let validatedName = reniecData.fullName ?? "\(cleanFirstName) \(cleanFirstLastName) \(cleanSecondLastName)"
                    onNameValidated?(validatedName)
                }
                
                try await completeProfileUseCase.execute(
                    userId: userId,
                    phone: cleanPhone,
                    dni: cleanDNI,
                    firstName: cleanFirstName,
                    firstLastName: cleanFirstLastName,
                    secondLastName: cleanSecondLastName,
                    gender: gender,
                    reniecData: reniecData
                )
                
                await MainActor.run {
                    onLoadingChange?(false)
                    onSuccess?()
                }
                
            } catch let error as DNIValidationError {
                await MainActor.run {
                    onLoadingChange?(false)
                    onError?(error.localizedDescription)
                }
            } catch {
                await MainActor.run {
                    onLoadingChange?(false)
                    onError?(parseError(error))
                    print("❌ Complete Profile Error: \(error)")
                }
            }
        }
    }
    
    private func parseError(_ error: Error) -> String {
        let errorDescription = error.localizedDescription.lowercased()
        
        if errorDescription.contains("dni") || errorDescription.contains("reniec") {
            return "No se pudo validar el DNI. Verifica que sea correcto."
        }
        
        if errorDescription.contains("network") || errorDescription.contains("connection") {
            return "Error de conexión. Verifica tu internet."
        }
        
        if errorDescription.contains("404") || errorDescription.contains("not found") {
            return "DNI no encontrado en RENIEC"
        }
        
        return "Error: \(error.localizedDescription)"
    }
}
