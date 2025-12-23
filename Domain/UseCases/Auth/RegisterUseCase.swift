//
//  RegisterUseCase.swift
//  enone
//
//  Created by Asbel on 16/12/25.
//

import Foundation

final class RegisterUseCase {
    private let repository: AuthRepositoryProtocol

    init(repository: AuthRepositoryProtocol = AuthRepositoryImpl()) {
        self.repository = repository
    }

    func execute(email: String, password: String) async throws {
        try await repository.register(email: email, password: password)
    }
}
