//
//  SceneDelegate.swift
//  enone
//
//  Created by Asbel on 14/12/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)

        let authRepository = AuthRepositoryImpl()
        let profileRepository = ProfileRepositoryImpl()
        
        let loginUseCase = LoginUseCase(repository: authRepository)
        let checkUserStatusUseCase = CheckUserStatusUseCase(
            authRepository: authRepository,
            profileRepository: profileRepository
        )
        
        let loginViewModel = LoginViewModel(
            loginUseCase: loginUseCase,
            checkUserStatusUseCase: checkUserStatusUseCase
        )
        
        let loginVC = LoginViewController(viewModel: loginViewModel)

        let nav = UINavigationController(rootViewController: loginVC)
        nav.navigationBar.isHidden = true
        
        window.rootViewController = nav

        self.window = window
        window.makeKeyAndVisible()
    }
}
