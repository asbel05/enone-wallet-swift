final class VerifyEmailOTPUseCase {

    private let repository: AuthRepositoryProtocol

    init(repository: AuthRepositoryProtocol = AuthRepositoryImpl()) {
        self.repository = repository
    }

    func execute(email: String, token: String) async throws {
        try await repository.verifyEmailOTP(email: email,token: token)
    }
}
