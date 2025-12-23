//
//  CompleteProfileViewController.swift
//  enone
//
//  Created by Asbel on 17/12/25.
//

import UIKit

final class CompleteProfileViewController: UIViewController {

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
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Completa tu Perfil"
        label.font = Theme.Fonts.title
        label.textColor = Theme.Colors.textPrimary
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Ingresa tus datos exactamente como aparecen en tu DNI"
        label.font = Theme.Fonts.body
        label.textColor = Theme.Colors.textSecondary
        label.textAlignment = .left
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let phoneTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Teléfono (9 dígitos)"
        tf.font = Theme.Fonts.body
        tf.textColor = Theme.Colors.textPrimary
        tf.backgroundColor = Theme.Colors.surface
        tf.layer.cornerRadius = Theme.Layout.cornerRadius
        tf.keyboardType = .numberPad
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        tf.leftViewMode = .always
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let dniTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "DNI (8 dígitos)"
        tf.font = Theme.Fonts.body
        tf.textColor = Theme.Colors.textPrimary
        tf.backgroundColor = Theme.Colors.surface
        tf.layer.cornerRadius = Theme.Layout.cornerRadius
        tf.keyboardType = .numberPad
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        tf.leftViewMode = .always
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let firstNameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Nombres"
        tf.font = Theme.Fonts.body
        tf.textColor = Theme.Colors.textPrimary
        tf.backgroundColor = Theme.Colors.surface
        tf.layer.cornerRadius = Theme.Layout.cornerRadius
        tf.autocapitalizationType = .allCharacters
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        tf.leftViewMode = .always
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let firstLastNameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Apellido Paterno"
        tf.font = Theme.Fonts.body
        tf.textColor = Theme.Colors.textPrimary
        tf.backgroundColor = Theme.Colors.surface
        tf.layer.cornerRadius = Theme.Layout.cornerRadius
        tf.autocapitalizationType = .allCharacters
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        tf.leftViewMode = .always
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let secondLastNameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Apellido Materno"
        tf.font = Theme.Fonts.body
        tf.textColor = Theme.Colors.textPrimary
        tf.backgroundColor = Theme.Colors.surface
        tf.layer.cornerRadius = Theme.Layout.cornerRadius
        tf.autocapitalizationType = .allCharacters
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        tf.leftViewMode = .always
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let genderLabel: UILabel = {
        let label = UILabel()
        label.text = "Género"
        label.font = Theme.Fonts.caption
        label.textColor = Theme.Colors.textSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let genderSegmentedControl: UISegmentedControl = {
        let items = ["Masculino", "Femenino"]
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = 0
        control.backgroundColor = Theme.Colors.surface
        control.selectedSegmentTintColor = Theme.Colors.primary
        
        let normalTextAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: Theme.Colors.textSecondary,
            .font: Theme.Fonts.caption
        ]
        let selectedTextAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .font: Theme.Fonts.caption
        ]
        
        control.setTitleTextAttributes(normalTextAttributes, for: .normal)
        control.setTitleTextAttributes(selectedTextAttributes, for: .selected)
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Verificar y Finalizar", for: .normal)
        button.titleLabel?.font = Theme.Fonts.button
        button.setTitleColor(Theme.Colors.textOnPrimary, for: .normal)
        button.backgroundColor = Theme.Colors.primary
        button.layer.cornerRadius = Theme.Layout.cornerRadius
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
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.text = "Los datos deben coincidir exactamente con tu DNI"
        label.font = Theme.Fonts.small
        label.textColor = Theme.Colors.textSecondary
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let viewModel: CompleteProfileViewModel

    init(viewModel: CompleteProfileViewModel = CompleteProfileViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Theme.Colors.background
        navigationItem.hidesBackButton = true
        setupUI()
        setupActions()
        setupBindings()
        setupKeyboardDismiss()
        setupTextFieldDelegates()
    }
}

private extension CompleteProfileViewController {
    
    func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(phoneTextField)
        contentView.addSubview(dniTextField)
        contentView.addSubview(firstNameTextField)
        contentView.addSubview(firstLastNameTextField)
        contentView.addSubview(secondLastNameTextField)
        contentView.addSubview(genderLabel)
        contentView.addSubview(genderSegmentedControl)
        contentView.addSubview(infoLabel)
        contentView.addSubview(errorLabel)
        contentView.addSubview(actionButton)
        actionButton.addSubview(activityIndicator)
        
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
            
            titleLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.Layout.padding),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Theme.Layout.padding),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.Layout.padding),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Theme.Layout.padding),
            
            phoneTextField.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 32),
            phoneTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.Layout.padding),
            phoneTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Theme.Layout.padding),
            phoneTextField.heightAnchor.constraint(equalToConstant: Theme.Layout.inputHeight),
            
            dniTextField.topAnchor.constraint(equalTo: phoneTextField.bottomAnchor, constant: Theme.Layout.spacing),
            dniTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.Layout.padding),
            dniTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Theme.Layout.padding),
            dniTextField.heightAnchor.constraint(equalToConstant: Theme.Layout.inputHeight),
            
            firstNameTextField.topAnchor.constraint(equalTo: dniTextField.bottomAnchor, constant: Theme.Layout.spacing),
            firstNameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.Layout.padding),
            firstNameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Theme.Layout.padding),
            firstNameTextField.heightAnchor.constraint(equalToConstant: Theme.Layout.inputHeight),
            
            firstLastNameTextField.topAnchor.constraint(equalTo: firstNameTextField.bottomAnchor, constant: Theme.Layout.spacing),
            firstLastNameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.Layout.padding),
            firstLastNameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Theme.Layout.padding),
            firstLastNameTextField.heightAnchor.constraint(equalToConstant: Theme.Layout.inputHeight),
            
            secondLastNameTextField.topAnchor.constraint(equalTo: firstLastNameTextField.bottomAnchor, constant: Theme.Layout.spacing),
            secondLastNameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.Layout.padding),
            secondLastNameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Theme.Layout.padding),
            secondLastNameTextField.heightAnchor.constraint(equalToConstant: Theme.Layout.inputHeight),
            
            genderLabel.topAnchor.constraint(equalTo: secondLastNameTextField.bottomAnchor, constant: 24),
            genderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.Layout.padding),
            
            genderSegmentedControl.topAnchor.constraint(equalTo: genderLabel.bottomAnchor, constant: 8),
            genderSegmentedControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.Layout.padding),
            genderSegmentedControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Theme.Layout.padding),
            genderSegmentedControl.heightAnchor.constraint(equalToConstant: 44),
            
            infoLabel.topAnchor.constraint(equalTo: genderSegmentedControl.bottomAnchor, constant: 16),
            infoLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.Layout.padding),
            infoLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Theme.Layout.padding),
            
            errorLabel.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 8),
            errorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.Layout.padding),
            errorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Theme.Layout.padding),
            
            actionButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 24),
            actionButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.Layout.padding),
            actionButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Theme.Layout.padding),
            actionButton.heightAnchor.constraint(equalToConstant: Theme.Layout.buttonHeight),
            actionButton.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -40),
            
            activityIndicator.centerYAnchor.constraint(equalTo: actionButton.centerYAnchor),
            activityIndicator.trailingAnchor.constraint(equalTo: actionButton.trailingAnchor, constant: -16)
        ])
    }
    
    func setupActions() {
        actionButton.addTarget(self, action: #selector(didTapSubmit), for: .touchUpInside)
    }
    
    func setupKeyboardDismiss() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    func getSelectedGender() -> String {
        switch genderSegmentedControl.selectedSegmentIndex {
        case 0: return "M"
        case 1: return "F"
        default: return "M"
        }
    }
    
    func setupTextFieldDelegates() {
        phoneTextField.delegate = self
        dniTextField.delegate = self
        firstNameTextField.delegate = self
        firstLastNameTextField.delegate = self
        secondLastNameTextField.delegate = self
    }
}

private extension CompleteProfileViewController {
    
    @objc func didTapSubmit() {
        hideError()
        
        guard let phone = phoneTextField.text, phone.count == 9 else {
            showError("Ingresa un teléfono válido de 9 dígitos")
            return
        }
        
        guard let dni = dniTextField.text, dni.count == 8 else {
            showError("Ingresa un DNI válido de 8 dígitos")
            return
        }
        
        guard let firstName = firstNameTextField.text, !firstName.isEmpty else {
            showError("Ingresa tus nombres")
            return
        }
        
        guard let firstLastName = firstLastNameTextField.text, !firstLastName.isEmpty else {
            showError("Ingresa tu apellido paterno")
            return
        }
        
        guard let secondLastName = secondLastNameTextField.text, !secondLastName.isEmpty else {
            showError("Ingresa tu apellido materno")
            return
        }
        
        dismissKeyboard()
        
        viewModel.submit(
            phone: phone,
            dni: dni,
            firstName: firstName,
            firstLastName: firstLastName,
            secondLastName: secondLastName,
            gender: getSelectedGender()
        )
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

private extension CompleteProfileViewController {
    func setupBindings() {
        viewModel.onLoadingChange = { [weak self] isLoading in
            DispatchQueue.main.async {
                self?.actionButton.isEnabled = !isLoading
                self?.actionButton.alpha = isLoading ? 0.7 : 1.0
                if isLoading {
                    self?.activityIndicator.startAnimating()
                    self?.actionButton.setTitle("Verificando...", for: .normal)
                } else {
                    self?.activityIndicator.stopAnimating()
                    self?.actionButton.setTitle("Verificar y Finalizar", for: .normal)
                }
            }
        }
        
        viewModel.onError = { [weak self] message in
            DispatchQueue.main.async {
                self?.showError(message)
            }
        }
        
        viewModel.onNameValidated = { fullName in
            print("Identidad validada: \(fullName)")
        }
        
        viewModel.onSuccess = { [weak self] in
            DispatchQueue.main.async {
                self?.navigateToHome()
            }
        }
    }
    
    func navigateToHome() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        
        let walletRepository = WalletRepositoryImpl()
        let getWalletsUseCase = GetWalletsUseCase(repository: walletRepository)
        let homeViewModel = HomeViewModel(getWalletsUseCase: getWalletsUseCase)
        let homeVC = HomeViewController(viewModel: homeViewModel)
        
        let nav = UINavigationController(rootViewController: homeVC)
        nav.navigationBar.isHidden = true
        
        window.rootViewController = nav
        window.makeKeyAndVisible()
    }
}

extension CompleteProfileViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.isEmpty { return true }
        
        let currentText = textField.text ?? ""
        let newLength = currentText.count + string.count - range.length
        
        switch textField {
        case phoneTextField:
            guard string.isOnlyDigits else { return false }
            return newLength <= 9
            
        case dniTextField:
            guard string.isOnlyDigits else { return false }
            return newLength <= 8
            
        case firstNameTextField, firstLastNameTextField, secondLastNameTextField:
            guard string.isOnlyLettersAndSpaces else { return false }
            return true
            
        default:
            return true
        }
    }
}
