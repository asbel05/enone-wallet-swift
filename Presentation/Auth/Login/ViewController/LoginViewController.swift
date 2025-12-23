//
//  LoginViewController.swift
//  enone
//
//  Created by Asbel on 16/12/25.
//

import UIKit

final class LoginViewController: UIViewController {

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.showsVerticalScrollIndicator = false
        sv.backgroundColor = Theme.Colors.background
        return sv
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Theme.Colors.background
        return view
    }()
    
    private let logoLabel: UILabel = {
        let label = UILabel()
        label.text = "ENONE"
        label.font = Theme.Fonts.largeTitle
        label.textColor = Theme.Colors.primary
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let sloganLabel: UILabel = {
        let label = UILabel()
        label.text = "Tu billetera digital"
        label.font = Theme.Fonts.caption
        label.textColor = Theme.Colors.textSecondary
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Iniciar Sesión"
        label.font = Theme.Fonts.title
        label.textColor = Theme.Colors.textPrimary
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Ingresa tus datos para continuar"
        label.font = Theme.Fonts.body
        label.textColor = Theme.Colors.textSecondary
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Correo electrónico"
        tf.font = Theme.Fonts.body
        tf.textColor = Theme.Colors.textPrimary
        tf.backgroundColor = Theme.Colors.surface
        tf.layer.cornerRadius = Theme.Layout.cornerRadius
        tf.keyboardType = .emailAddress
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        tf.leftViewMode = .always
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    // Password Field
    private let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Contraseña"
        tf.font = Theme.Fonts.body
        tf.textColor = Theme.Colors.textPrimary
        tf.backgroundColor = Theme.Colors.surface
        tf.layer.cornerRadius = Theme.Layout.cornerRadius
        tf.isSecureTextEntry = true
        tf.textContentType = .none
        tf.autocorrectionType = .no
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        tf.leftViewMode = .always
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private lazy var passwordToggleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        button.tintColor = Theme.Colors.textSecondary
        button.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        button.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        return button
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Ingresar", for: .normal)
        button.titleLabel?.font = Theme.Fonts.button
        button.setTitleColor(Theme.Colors.textOnPrimary, for: .normal)
        button.backgroundColor = Theme.Colors.primary
        button.layer.cornerRadius = Theme.Layout.cornerRadius
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let registerButton: UIButton = {
        let button = UIButton(type: .system)
        
        let text = "¿No tienes cuenta? Regístrate"
        let attributedText = NSMutableAttributedString(string: text)
        
        let normalRange = NSRange(location: 0, length: 18)
        let highlightRange = NSRange(location: 18, length: 11)
        
        attributedText.addAttribute(.foregroundColor, value: Theme.Colors.textSecondary, range: normalRange)
        attributedText.addAttribute(.font, value: Theme.Fonts.caption, range: normalRange)
        attributedText.addAttribute(.foregroundColor, value: Theme.Colors.primary, range: highlightRange)
        attributedText.addAttribute(.font, value: Theme.Fonts.button, range: highlightRange)
        
        button.setAttributedTitle(attributedText, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = Theme.Colors.textOnPrimary
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.Fonts.caption
        label.textColor = Theme.Colors.error
        label.textAlignment = .left
        label.numberOfLines = 0
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let viewModel: LoginViewModel

    init(viewModel: LoginViewModel) {
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
        setupBindings()
        setupKeyboardDismiss()
        setupPasswordToggle()
    }
}

private extension LoginViewController {
    
    func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(logoLabel)
        contentView.addSubview(sloganLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(emailTextField)
        contentView.addSubview(passwordTextField)
        contentView.addSubview(errorLabel)
        contentView.addSubview(loginButton)
        loginButton.addSubview(activityIndicator)
        contentView.addSubview(registerButton)
        
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
            contentView.heightAnchor.constraint(greaterThanOrEqualTo: view.heightAnchor),
            
            logoLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 60),
            logoLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            sloganLabel.topAnchor.constraint(equalTo: logoLabel.bottomAnchor, constant: 8),
            sloganLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: sloganLabel.bottomAnchor, constant: 48),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.Layout.padding),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Theme.Layout.padding),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.Layout.padding),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Theme.Layout.padding),
            
            emailTextField.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 32),
            emailTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.Layout.padding),
            emailTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Theme.Layout.padding),
            emailTextField.heightAnchor.constraint(equalToConstant: Theme.Layout.inputHeight),
            
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: Theme.Layout.spacing),
            passwordTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.Layout.padding),
            passwordTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Theme.Layout.padding),
            passwordTextField.heightAnchor.constraint(equalToConstant: Theme.Layout.inputHeight),
            
            errorLabel.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 8),
            errorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.Layout.padding),
            errorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Theme.Layout.padding),
            
            loginButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 24),
            loginButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.Layout.padding),
            loginButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Theme.Layout.padding),
            loginButton.heightAnchor.constraint(equalToConstant: Theme.Layout.buttonHeight),
            
            activityIndicator.centerYAnchor.constraint(equalTo: loginButton.centerYAnchor),
            activityIndicator.trailingAnchor.constraint(equalTo: loginButton.trailingAnchor, constant: -16),
            
            registerButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 24),
            registerButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            registerButton.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -40)
        ])
    }
    
    func setupPasswordToggle() {
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        containerView.addSubview(passwordToggleButton)
        passwordTextField.rightView = containerView
        passwordTextField.rightViewMode = .always
    }
    
    func setupActions() {
        loginButton.addTarget(self, action: #selector(didTapLogin), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(didTapRegister), for: .touchUpInside)
    }
    
    func setupKeyboardDismiss() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
}

private extension LoginViewController {
    
    @objc func didTapLogin() {
        hideError()
        
        guard let email = emailTextField.text, !email.isEmpty else {
            showError("Ingresa tu correo electrónico")
            return
        }
        
        guard let password = passwordTextField.text, !password.isEmpty else {
            showError("Ingresa tu contraseña")
            return
        }
        
        dismissKeyboard()
        viewModel.login(email: email, password: password)
    }
    
    @objc func didTapRegister() {
        let registerUseCase = RegisterUseCase(repository: AuthRepositoryImpl())
        let registerViewModel = RegisterViewModel(registerUseCase: registerUseCase)
        let registerVC = RegisterViewController(viewModel: registerViewModel)
        navigationController?.pushViewController(registerVC, animated: true)
    }
    
    @objc func togglePasswordVisibility() {
        passwordTextField.isSecureTextEntry.toggle()
        let imageName = passwordTextField.isSecureTextEntry ? "eye.slash" : "eye"
        passwordToggleButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
    }
    
    func hideError() {
        errorLabel.isHidden = true
    }
}

private extension LoginViewController {
    func setupBindings() {
        viewModel.onLoadingChange = { [weak self] isLoading in
            DispatchQueue.main.async {
                self?.loginButton.isEnabled = !isLoading
                self?.loginButton.alpha = isLoading ? 0.7 : 1.0
                if isLoading {
                    self?.activityIndicator.startAnimating()
                    self?.loginButton.setTitle("", for: .normal)
                } else {
                    self?.activityIndicator.stopAnimating()
                    self?.loginButton.setTitle("Ingresar", for: .normal)
                }
            }
        }
        
        viewModel.onError = { [weak self] message in
            DispatchQueue.main.async {
                self?.showError(message)
            }
        }
        
        viewModel.onNavigateToVerifyEmail = { [weak self] email in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                let verifyUseCase = VerifyEmailOTPUseCase(repository: AuthRepositoryImpl())
                let resendUseCase = ResendOTPUseCase(repository: AuthRepositoryImpl())
                
                let verifyViewModel = VerifyEmailViewModel(
                    verifyEmailOTPUseCase: verifyUseCase,
                    resendOTPUseCase: resendUseCase,
                    email: email
                )
                
                let verifyVC = VerifyEmailViewController(viewModel: verifyViewModel)
                self.navigationController?.pushViewController(verifyVC, animated: true)
            }
        }
        
        viewModel.onNavigateToCompleteProfile = { [weak self] in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                let completeViewModel = CompleteProfileViewModel()
                let completeVC = CompleteProfileViewController(viewModel: completeViewModel)
                self.navigationController?.pushViewController(completeVC, animated: true)
            }
        }
        
        viewModel.onNavigateToHome = { [weak self] in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                let walletRepository = WalletRepositoryImpl()
                let getWalletsUseCase = GetWalletsUseCase(repository: walletRepository)
                let homeViewModel = HomeViewModel(getWalletsUseCase: getWalletsUseCase)
                let homeVC = HomeViewController(viewModel: homeViewModel)
                
                self.navigationController?.setViewControllers([homeVC], animated: true)
            }
        }
    }
}
