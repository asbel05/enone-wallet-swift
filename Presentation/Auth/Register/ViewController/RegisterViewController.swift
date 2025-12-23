//
//  RegisterViewController.swift
//  enone
//
//  Created by Asbel on 16/12/25.
//

import UIKit

final class RegisterViewController: UIViewController {

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
    
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = Theme.Colors.textPrimary
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Crear Cuenta"
        label.font = Theme.Fonts.title
        label.textColor = Theme.Colors.textPrimary
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Únete a Enone y comienza a gestionar tu dinero"
        label.font = Theme.Fonts.body
        label.textColor = Theme.Colors.textSecondary
        label.textAlignment = .left
        label.numberOfLines = 0
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
    
    private let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Contraseña (mínimo 8 caracteres)"
        tf.font = Theme.Fonts.body
        tf.textColor = Theme.Colors.textPrimary
        tf.backgroundColor = Theme.Colors.surface
        tf.layer.cornerRadius = Theme.Layout.cornerRadius
        tf.isSecureTextEntry = true
        tf.textContentType = .oneTimeCode
        tf.autocorrectionType = .no
        tf.autocapitalizationType = .none
        tf.spellCheckingType = .no
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
    
    private let registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Crear Cuenta", for: .normal)
        button.titleLabel?.font = Theme.Fonts.button
        button.setTitleColor(Theme.Colors.textOnPrimary, for: .normal)
        button.backgroundColor = Theme.Colors.primary
        button.layer.cornerRadius = Theme.Layout.cornerRadius
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        
        let text = "¿Ya tienes cuenta? Inicia sesión"
        let attributedText = NSMutableAttributedString(string: text)
        
        let normalRange = NSRange(location: 0, length: 19)
        let highlightRange = NSRange(location: 19, length: 13)
        
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
    
    private let viewModel: RegisterViewModel

    init(viewModel: RegisterViewModel) {
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

// MARK: - Setup

private extension RegisterViewController {
    
    func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(backButton)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(emailTextField)
        contentView.addSubview(passwordTextField)
        contentView.addSubview(errorLabel)
        contentView.addSubview(registerButton)
        registerButton.addSubview(activityIndicator)
        contentView.addSubview(loginButton)
        
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
            
            backButton.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 16),
            backButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.Layout.padding),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),
            
            titleLabel.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.Layout.padding),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Theme.Layout.padding),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.Layout.padding),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Theme.Layout.padding),
            
            emailTextField.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 40),
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
            
            registerButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 32),
            registerButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.Layout.padding),
            registerButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Theme.Layout.padding),
            registerButton.heightAnchor.constraint(equalToConstant: Theme.Layout.buttonHeight),
            
            activityIndicator.centerYAnchor.constraint(equalTo: registerButton.centerYAnchor),
            activityIndicator.trailingAnchor.constraint(equalTo: registerButton.trailingAnchor, constant: -16),
            
            loginButton.topAnchor.constraint(equalTo: registerButton.bottomAnchor, constant: 24),
            loginButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            loginButton.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -40)
        ])
    }
    
    func setupPasswordToggle() {
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        containerView.addSubview(passwordToggleButton)
        passwordTextField.rightView = containerView
        passwordTextField.rightViewMode = .always
    }
    
    func setupActions() {
        registerButton.addTarget(self, action: #selector(didTapRegister), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(didTapLogin), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
    }
    
    func setupKeyboardDismiss() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
}

private extension RegisterViewController {
    
    @objc func didTapRegister() {
        hideError()
        
        guard let email = emailTextField.text, !email.isEmpty else {
            showError("Ingresa tu correo electrónico")
            return
        }
        
        guard email.contains("@") && email.contains(".") else {
            showError("Ingresa un correo válido")
            return
        }
        
        guard let password = passwordTextField.text, !password.isEmpty else {
            showError("Ingresa una contraseña")
            return
        }
        
        guard password.count >= 8 else {
            showError("La contraseña debe tener al menos 8 caracteres")
            return
        }
        
        dismissKeyboard()
        viewModel.register(email: email, password: password)
    }
    
    @objc func didTapLogin() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func didTapBack() {
        navigationController?.popViewController(animated: true)
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

private extension RegisterViewController {
    func setupBindings() {
        viewModel.onLoadingChange = { [weak self] isLoading in
            DispatchQueue.main.async {
                self?.registerButton.isEnabled = !isLoading
                self?.registerButton.alpha = isLoading ? 0.7 : 1.0
                if isLoading {
                    self?.activityIndicator.startAnimating()
                    self?.registerButton.setTitle("", for: .normal)
                } else {
                    self?.activityIndicator.stopAnimating()
                    self?.registerButton.setTitle("Crear Cuenta", for: .normal)
                }
            }
        }
        
        viewModel.onError = { [weak self] message in
            DispatchQueue.main.async {
                self?.showError(message)
            }
        }
        
        viewModel.onRegisterSuccess = { [weak self] email in
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
    }
}
