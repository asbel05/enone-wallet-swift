//
//  ProfileViewController.swift
//  enone
//
//  Created by Asbel on 18/12/25.
//

import UIKit

final class ProfileViewController: UIViewController {

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.backgroundColor = Theme.Colors.background
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = Theme.Colors.textPrimary
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Mi perfil"
        label.font = Theme.Fonts.title
        label.textColor = Theme.Colors.textPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let accountSectionLabel: UILabel = {
        let label = UILabel()
        label.text = "Mi cuenta"
        label.font = Theme.Fonts.caption
        label.textColor = Theme.Colors.textSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let accountStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.distribution = .fill
        sv.spacing = 12
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let settingsSectionLabel: UILabel = {
        let label = UILabel()
        label.text = "Ajustes"
        label.font = Theme.Fonts.caption
        label.textColor = Theme.Colors.textSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let settingsStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.distribution = .fill
        sv.spacing = 12
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let versionLabel: UILabel = {
        let label = UILabel()
        label.text = "Versión enone 1.0"
        label.font = Theme.Fonts.caption
        label.textColor = Theme.Colors.textSecondary
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cerrar Sesión", for: .normal)
        button.titleLabel?.font = Theme.Fonts.button
        button.setTitleColor(.systemRed, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = Theme.Layout.cornerRadius
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 8
        button.layer.shadowOpacity = 0.08
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let viewModel: ProfileViewModel
    
    init(viewModel: ProfileViewModel = ProfileViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Theme.Colors.background
        setupUI()
        setupActions()
        setupMenuItems()
        viewModel.loadProfile()
    }
}

private extension ProfileViewController {
    
    func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(backButton)
        contentView.addSubview(titleLabel)
        
        contentView.addSubview(accountSectionLabel)
        contentView.addSubview(accountStack)
        
        contentView.addSubview(settingsSectionLabel)
        contentView.addSubview(settingsStack)
        
        contentView.addSubview(logoutButton)
        contentView.addSubview(versionLabel)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            backButton.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 16),
            backButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.Layout.padding),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),
            
            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 8),
            
            accountSectionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 32),
            accountSectionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.Layout.padding),
            
            accountStack.topAnchor.constraint(equalTo: accountSectionLabel.bottomAnchor, constant: 12),
            accountStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.Layout.padding),
            accountStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Theme.Layout.padding),
            
            settingsSectionLabel.topAnchor.constraint(equalTo: accountStack.bottomAnchor, constant: 32),
            settingsSectionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.Layout.padding),
            
            settingsStack.topAnchor.constraint(equalTo: settingsSectionLabel.bottomAnchor, constant: 12),
            settingsStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.Layout.padding),
            settingsStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Theme.Layout.padding),
            
            logoutButton.topAnchor.constraint(equalTo: settingsStack.bottomAnchor, constant: 32),
            logoutButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.Layout.padding),
            logoutButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Theme.Layout.padding),
            logoutButton.heightAnchor.constraint(equalToConstant: Theme.Layout.buttonHeight),
            
            versionLabel.topAnchor.constraint(equalTo: logoutButton.bottomAnchor, constant: 24),
            versionLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            versionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }
    
    func setupActions() {
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        logoutButton.addTarget(self, action: #selector(didTapLogout), for: .touchUpInside)
        
        viewModel.onTwoFactorChanged = { [weak self] newState in
            let stateStr = newState ? "ACTIVADA" : "DESACTIVADA"
            let alert = UIAlertController(title: "Éxito", message: "Seguridad 2FA \(stateStr) correctamente.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(alert, animated: true)
        }
        
        viewModel.onError = { [weak self] error in
            self?.showError(error)
        }
        
        viewModel.onLoadingChange = { isLoading in
        }
    }
    
    func setupMenuItems() {
        accountStack.addArrangedSubview(createMenuOption(
            icon: "person.text.rectangle",
            title: "Mi Información Personal",
            action: #selector(didTapPersonalInfo)
        ))

        settingsStack.addArrangedSubview(createMenuOption(
            icon: "creditcard.fill",
            title: "Tarjeta asociada",
            action: #selector(didTapCard)
        ))
        
        settingsStack.addArrangedSubview(createMenuOption(
            icon: "lock.shield",
            title: "Autenticación de 2 Factores",
            action: #selector(didTapTwoFactor)
        ))
        
        settingsStack.addArrangedSubview(createMenuOption(
            icon: "checkmark.shield",
            title: "Confirmación de monto alto",
            action: #selector(didTapConfirmation)
        ))
        
        settingsStack.addArrangedSubview(createMenuOption(
            icon: "dollarsign.circle",
            title: "Límites transaccionales",
            action: #selector(didTapLimits)
        ))
    }
    
    func createMenuOption(icon: String, title: String, action: Selector, isDestructive: Bool = false) -> UIView {
        let container = UIButton(type: .system)
        container.backgroundColor = .white
        container.layer.cornerRadius = 16
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOffset = CGSize(width: 0, height: 2)
        container.layer.shadowRadius = 8
        container.layer.shadowOpacity = 0.08
        container.addTarget(self, action: action, for: .touchUpInside)
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let iconContainer = UIView()
        iconContainer.backgroundColor = isDestructive ? UIColor.systemRed.withAlphaComponent(0.1) : Theme.Colors.primary.withAlphaComponent(0.1)
        iconContainer.layer.cornerRadius = 12
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.isUserInteractionEnabled = false
        
        let iconView = UIImageView()
        iconView.image = UIImage(systemName: icon)
        iconView.tintColor = isDestructive ? .systemRed : Theme.Colors.primary
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.isUserInteractionEnabled = false
        
        iconContainer.addSubview(iconView)
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = Theme.Fonts.bodyMedium
        titleLabel.textColor = isDestructive ? .systemRed : Theme.Colors.textPrimary
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.isUserInteractionEnabled = false
        
        let arrowView = UIImageView()
        arrowView.image = UIImage(systemName: "chevron.right")
        arrowView.tintColor = Theme.Colors.textSecondary
        arrowView.contentMode = .scaleAspectFit
        arrowView.translatesAutoresizingMaskIntoConstraints = false
        arrowView.isUserInteractionEnabled = false
        
        container.addSubview(iconContainer)
        container.addSubview(titleLabel)
        container.addSubview(arrowView)
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 68),
            
            iconContainer.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            iconContainer.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 44),
            iconContainer.heightAnchor.constraint(equalToConstant: 44),
            
            iconView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: arrowView.leadingAnchor, constant: -8),
            
            arrowView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            arrowView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            arrowView.widthAnchor.constraint(equalToConstant: 14),
            arrowView.heightAnchor.constraint(equalToConstant: 14)
        ])
        
        return container
    }

    @objc func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func didTapPersonalInfo() {
        let detailViewModel = ProfileViewModel()
        let detailVC = ProfileDetailViewController(viewModel: detailViewModel)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    @objc func didTapDeleteAccount() {
        showComingSoon("Eliminar cuenta")
    }
    
    @objc func didTapConfirmation() {
        showComingSoon("Confirmación de enoneo alto")
    }
    
    @objc func didTapLimits() {
        let limitsViewModel = TransactionLimitsViewModel()
        let limitsVC = TransactionLimitsViewController(viewModel: limitsViewModel)
        navigationController?.pushViewController(limitsVC, animated: true)
    }
    
    @objc func didTapNotifications() {
        showComingSoon("Notificaciones")
    }
    
    @objc func didTapLogout() {
        let alert = UIAlertController(
            title: "Cerrar Sesión",
            message: "¿Estás seguro que deseas cerrar sesión?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        alert.addAction(UIAlertAction(title: "Cerrar Sesión", style: .destructive) { _ in
            self.performLogout()
        })
        
        present(alert, animated: true)
    }
    
    func performLogout() {
        Task {
            do {
                try await SessionManager.shared.logout()
                await MainActor.run {
                    navigateToLogin()
                }
            } catch {
                await MainActor.run {
                    showError("Error al cerrar sesión")
                }
            }
        }
    }
    
    func navigateToLogin() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        
        let loginUseCase = LoginUseCase(repository: AuthRepositoryImpl())
        let checkStatusUseCase = CheckUserStatusUseCase(
            authRepository: AuthRepositoryImpl(),
            profileRepository: ProfileRepositoryImpl()
        )
        let loginVM = LoginViewModel(
            loginUseCase: loginUseCase,
            checkUserStatusUseCase: checkStatusUseCase
        )
        let loginVC = LoginViewController(viewModel: loginVM)
        let nav = UINavigationController(rootViewController: loginVC)
        nav.navigationBar.isHidden = true
        
        window.rootViewController = nav
        window.makeKeyAndVisible()
    }
    
    func showComingSoon(_ feature: String) {
        let alert = UIAlertController(
            title: "Próximamente",
            message: "\(feature) estará disponible pronto",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @objc func didTapCard() {
        let addCardVC = AddCardViewController()
        navigationController?.pushViewController(addCardVC, animated: true)
    }
    
    @objc func didTapTwoFactor() {
        let twoFactorVC = TwoFactorViewController()
        navigationController?.pushViewController(twoFactorVC, animated: true)
    }
    
    func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
