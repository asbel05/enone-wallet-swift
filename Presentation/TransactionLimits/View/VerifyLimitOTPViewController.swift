//
//  VerifyLimitOTPViewController.swift
//  enone
//
//  Created by Asbel on 18/12/25.
//

import UIKit

final class VerifyLimitOTPViewController: UIViewController {
    
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
        label.text = "Verificar Código"
        label.font = Theme.Fonts.title
        label.textColor = Theme.Colors.textPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let instructionsLabel: UILabel = {
        let label = UILabel()
        label.text = "Ingresa el código de 6 dígitos"
        label.font = Theme.Fonts.body
        label.textColor = Theme.Colors.textSecondary
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let newLimitSummaryLabel: UILabel = {
        let label = UILabel()
        label.text = "Tu nuevo límite será:"
        label.font = Theme.Fonts.caption
        label.textColor = Theme.Colors.textSecondary
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let newLimitAmountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textColor = Theme.Colors.primary
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let otpLabel: UILabel = {
        let label = UILabel()
        label.text = "Código de Verificación"
        label.font = Theme.Fonts.bodyMedium
        label.textColor = Theme.Colors.textPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let otpTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "_ _ _ _ _ _"
        tf.font = UIFont.monospacedSystemFont(ofSize: 24, weight: .medium)
        tf.textColor = Theme.Colors.textPrimary
        tf.backgroundColor = Theme.Colors.surface
        tf.layer.cornerRadius = Theme.Layout.cornerRadius
        tf.keyboardType = .numberPad
        tf.textAlignment = .center
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    

    
    private let verifyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Verificar y Cambiar Límite", for: .normal)
        button.titleLabel?.font = Theme.Fonts.button
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = Theme.Colors.primary
        button.layer.cornerRadius = Theme.Layout.cornerRadius
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let viewModel: TransactionLimitsViewModel
    private let newLimit: Double
    private let otp: String
    
    init(viewModel: TransactionLimitsViewModel, newLimit: Double, otp: String) {
        self.viewModel = viewModel
        self.newLimit = newLimit
        self.otp = otp
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
        
        newLimitAmountLabel.text = "S/ \(String(format: "%.2f", newLimit))"
        
        otpTextField.delegate = self
        
        otpTextField.becomeFirstResponder()
    }
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(backButton)
        contentView.addSubview(titleLabel)
        contentView.addSubview(instructionsLabel)
        contentView.addSubview(newLimitSummaryLabel)
        contentView.addSubview(newLimitAmountLabel)
        contentView.addSubview(otpLabel)
        contentView.addSubview(otpTextField)

        contentView.addSubview(verifyButton)
        
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
            
            instructionsLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            instructionsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.Layout.padding),
            instructionsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Theme.Layout.padding),
            
            newLimitSummaryLabel.topAnchor.constraint(equalTo: instructionsLabel.bottomAnchor, constant: 24),
            newLimitSummaryLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            newLimitAmountLabel.topAnchor.constraint(equalTo: newLimitSummaryLabel.bottomAnchor, constant: 8),
            newLimitAmountLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            otpLabel.topAnchor.constraint(equalTo: newLimitAmountLabel.bottomAnchor, constant: 32),
            otpLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.Layout.padding),
            
            otpTextField.topAnchor.constraint(equalTo: otpLabel.bottomAnchor, constant: 12),
            otpTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.Layout.padding),
            otpTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Theme.Layout.padding),
            otpTextField.heightAnchor.constraint(equalToConstant: Theme.Layout.inputHeight),
            
            verifyButton.topAnchor.constraint(equalTo: otpTextField.bottomAnchor, constant: 32),
            verifyButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.Layout.padding),
            verifyButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Theme.Layout.padding),
            verifyButton.heightAnchor.constraint(equalToConstant: Theme.Layout.buttonHeight),
            verifyButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }
    
    private func setupActions() {
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        verifyButton.addTarget(self, action: #selector(didTapVerify), for: .touchUpInside)
    }
    
    private func setupBindings() {
        viewModel.onLoadingChange = { [weak self] isLoading in
            self?.verifyButton.isEnabled = !isLoading
            self?.verifyButton.alpha = isLoading ? 0.5 : 1.0
        }
        
        viewModel.onError = { [weak self] message in
            self?.showError(message)
        }
        
        viewModel.onLimitUpdated = { [weak self] in
            self?.showSuccess()
        }
    }
    
    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func didTapVerify() {
        guard let otp = otpTextField.text, otp.isValid2FACode else {
            showError("Ingresa el código de 6 dígitos")
            return
        }
        
        viewModel.verifyOTPAndUpdate(otp: otp)
    }
    
    private func showSuccess() {
        let alert = UIAlertController(
            title: "✅ Límite Actualizado",
            message: "Tu nuevo límite de S/\(String(format: "%.2f", newLimit)) se aplicó correctamente",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.navigationController?.popToRootViewController(animated: true)
        })
        present(alert, animated: true)
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension VerifyLimitOTPViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.isEmpty { return true }
        
        guard string.isOnlyDigits else { return false }
        
        let currentText = textField.text ?? ""
        let newLength = currentText.count + string.count - range.length
        return newLength <= 6
    }
}
