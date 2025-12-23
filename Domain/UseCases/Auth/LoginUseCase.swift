//
//  LoginUseCase.swift
//  enone
//
//  Created by Asbel on 16/12/25.
//

import Foundation

final class LoginUseCase {
    private let repository: AuthRepositoryProtocol

    init(repository: AuthRepositoryProtocol = AuthRepositoryImpl()) {
        self.repository = repository
    }

    func execute(email: String, password: String) async throws {
        try await repository.login(email: email, password: password)
    }
}
