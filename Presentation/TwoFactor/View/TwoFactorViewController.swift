//
//  TwoFactorViewController.swift
//  enone
//
//  Created by Asbel on 19/12/25.
//

import UIKit

final class TwoFactorViewController: UIViewController {
    
    private let viewModel: TwoFactorViewModel

    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = Theme.Colors.textPrimary
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Seguridad 2FA"
        label.font = Theme.Fonts.title
        label.textColor = Theme.Colors.textPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let iconContainer: UIView = {
        let view = UIView()
        view.backgroundColor = Theme.Colors.primary.withAlphaComponent(0.1)
        view.layer.cornerRadius = 40
        view.alpha = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "shield.check.fill")
        iv.tintColor = Theme.Colors.primary
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = Theme.Fonts.headline
        label.textAlignment = .center
        label.textColor = Theme.Colors.textPrimary
        label.alpha = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "La autenticación de dos factores añade una capa extra de seguridad. Te enviaremos un código a tu correo para confirmar transacciones importantes."
        label.font = Theme.Fonts.body
        label.textColor = Theme.Colors.textSecondary
        label.textAlignment = .center
        label.numberOfLines = 0
        label.alpha = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let totpContainer: UIView = {
        let view = UIView()
        view.backgroundColor = Theme.Colors.surface
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = Theme.Colors.primary.withAlphaComponent(0.2).cgColor
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let totpTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Código de seguridad actual (TOTP)"
        label.font = Theme.Fonts.caption
        label.textColor = Theme.Colors.textSecondary
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let totpCodeLabel: UILabel = {
        let label = UILabel()
        label.text = "------"
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 48, weight: .bold)
        label.textColor = Theme.Colors.textPrimary
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let totpTimerLabel: UILabel = {
        let label = UILabel()
        label.text = "Expira en 5:00"
        label.font = Theme.Fonts.caption
        label.textColor = Theme.Colors.textSecondary
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let totpProgressView: UIProgressView = {
        let pv = UIProgressView(progressViewStyle: .default)
        pv.progressTintColor = Theme.Colors.primary
        pv.trackTintColor = Theme.Colors.primary.withAlphaComponent(0.2)
        pv.translatesAutoresizingMaskIntoConstraints = false
        return pv
    }()
    
    private let showHideButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("👁 Mostrar código", for: .normal)
        button.titleLabel?.font = Theme.Fonts.body
        button.setTitleColor(Theme.Colors.primary, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var totpTimer: Timer?
    private var isCodeVisible = false
    private var userSecret: String?
    
    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Activar Seguridad", for: .normal)
        button.titleLabel?.font = Theme.Fonts.button
        button.backgroundColor = Theme.Colors.primary
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = Theme.Layout.cornerRadius
        button.alpha = 0 // Hidden until state loads
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let otpContainer: UIView = {
        let view = UIView()
        view.isHidden = true
        view.alpha = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let otpInstructionLabel: UILabel = {
        let label = UILabel()
        label.text = "Ingresa el código de 6 dígitos enviado a tu correo:"
        label.font = Theme.Fonts.body
        label.textColor = Theme.Colors.textPrimary
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let otpTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "000000"
        tf.font = UIFont.monospacedDigitSystemFont(ofSize: 32, weight: .bold)
        tf.textAlignment = .center
        tf.keyboardType = .numberPad
        tf.borderStyle = .none
        tf.backgroundColor = Theme.Colors.surface
        tf.layer.cornerRadius = 12
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    init(viewModel: TwoFactorViewModel = TwoFactorViewModel()) {
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
        
        otpTextField.delegate = self
        
        viewModel.loadInitialState()
    }
    
    private func setupUI() {
        view.addSubview(backButton)
        view.addSubview(titleLabel)
        
        view.addSubview(iconContainer)
        iconContainer.addSubview(iconImageView)
        
        view.addSubview(statusLabel)
        view.addSubview(descriptionLabel)
        
        view.addSubview(totpContainer)
        totpContainer.addSubview(totpTitleLabel)
        totpContainer.addSubview(totpCodeLabel)
        totpContainer.addSubview(totpTimerLabel)
        totpContainer.addSubview(totpProgressView)
        totpContainer.addSubview(showHideButton)
        
        view.addSubview(actionButton)
        
        view.addSubview(otpContainer)
        otpContainer.addSubview(otpInstructionLabel)
        otpContainer.addSubview(otpTextField)
        otpContainer.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Theme.Layout.padding),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),
            
            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 8),
            
            iconContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 60),
            iconContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 80),
            iconContainer.heightAnchor.constraint(equalToConstant: 80),
            
            iconImageView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 40),
            iconImageView.heightAnchor.constraint(equalToConstant: 40),
            
            statusLabel.topAnchor.constraint(equalTo: iconContainer.bottomAnchor, constant: 24),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Theme.Layout.padding),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Theme.Layout.padding),
            
            descriptionLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            totpContainer.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 24),
            totpContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Theme.Layout.padding),
            totpContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Theme.Layout.padding),
            
            totpTitleLabel.topAnchor.constraint(equalTo: totpContainer.topAnchor, constant: 16),
            totpTitleLabel.leadingAnchor.constraint(equalTo: totpContainer.leadingAnchor, constant: 16),
            totpTitleLabel.trailingAnchor.constraint(equalTo: totpContainer.trailingAnchor, constant: -16),
            
            totpCodeLabel.topAnchor.constraint(equalTo: totpTitleLabel.bottomAnchor, constant: 12),
            totpCodeLabel.centerXAnchor.constraint(equalTo: totpContainer.centerXAnchor),
            
            totpProgressView.topAnchor.constraint(equalTo: totpCodeLabel.bottomAnchor, constant: 16),
            totpProgressView.leadingAnchor.constraint(equalTo: totpContainer.leadingAnchor, constant: 24),
            totpProgressView.trailingAnchor.constraint(equalTo: totpContainer.trailingAnchor, constant: -24),
            totpProgressView.heightAnchor.constraint(equalToConstant: 6),
            
            totpTimerLabel.topAnchor.constraint(equalTo: totpProgressView.bottomAnchor, constant: 8),
            totpTimerLabel.centerXAnchor.constraint(equalTo: totpContainer.centerXAnchor),
            
            showHideButton.topAnchor.constraint(equalTo: totpTimerLabel.bottomAnchor, constant: 12),
            showHideButton.centerXAnchor.constraint(equalTo: totpContainer.centerXAnchor),
            showHideButton.bottomAnchor.constraint(equalTo: totpContainer.bottomAnchor, constant: -16),
            
            actionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            actionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Theme.Layout.padding),
            actionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Theme.Layout.padding),
            actionButton.heightAnchor.constraint(equalToConstant: Theme.Layout.buttonHeight),
            
            otpContainer.topAnchor.constraint(equalTo: totpContainer.bottomAnchor, constant: 20),
            otpContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Theme.Layout.padding),
            otpContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Theme.Layout.padding),
            otpContainer.bottomAnchor.constraint(lessThanOrEqualTo: actionButton.topAnchor, constant: -20),
            
            otpInstructionLabel.topAnchor.constraint(equalTo: otpContainer.topAnchor),
            otpInstructionLabel.leadingAnchor.constraint(equalTo: otpContainer.leadingAnchor),
            otpInstructionLabel.trailingAnchor.constraint(equalTo: otpContainer.trailingAnchor),
            
            otpTextField.topAnchor.constraint(equalTo: otpInstructionLabel.bottomAnchor, constant: 20),
            otpTextField.centerXAnchor.constraint(equalTo: otpContainer.centerXAnchor),
            otpTextField.widthAnchor.constraint(equalToConstant: 200),
            otpTextField.heightAnchor.constraint(equalToConstant: 60),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: otpContainer.centerXAnchor),
            loadingIndicator.topAnchor.constraint(equalTo: otpTextField.bottomAnchor, constant: 20)
        ])
        
        totpProgressView.layer.cornerRadius = 3
        totpProgressView.clipsToBounds = true
    }
    
    private func setupActions() {
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        actionButton.addTarget(self, action: #selector(didTapAction), for: .touchUpInside)
        otpTextField.addTarget(self, action: #selector(otpChanged), for: .editingChanged)
        showHideButton.addTarget(self, action: #selector(didTapShowHide), for: .touchUpInside)
    }
    
    private func setupBindings() {
        viewModel.onStateChanged = { [weak self] isEnabled, secret in
            self?.userSecret = secret
            self?.updateStateUI(isEnabled: isEnabled)
        }
        
        viewModel.onOTPRequested = { [weak self] in
            self?.showOTPInput()
        }
        
        viewModel.onLoadingChange = { [weak self] isLoading in
            if isLoading {
                self?.loadingIndicator.startAnimating()
                self?.actionButton.isEnabled = false
                self?.actionButton.alpha = 0.7
            } else {
                self?.loadingIndicator.stopAnimating()
                self?.actionButton.isEnabled = true
                self?.actionButton.alpha = 1.0
            }
        }
        
        viewModel.onError = { [weak self] message in
            self?.showError(message)
        }
        
        viewModel.onSuccess = { [weak self] message in
            self?.showSuccess(message)
            self?.hideOTPInput()
        }
    }

    private func updateStateUI(isEnabled: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.iconContainer.alpha = 1
            self.statusLabel.alpha = 1
            self.descriptionLabel.alpha = 1
            self.actionButton.alpha = 1
        }
        
        statusLabel.text = isEnabled ? "ACTIVADO" : "DESACTIVADO"
        statusLabel.textColor = isEnabled ? Theme.Colors.success : Theme.Colors.textSecondary
        
        iconImageView.image = UIImage(systemName: isEnabled ? "lock.shield.fill" : "lock.shield")
        iconContainer.backgroundColor = isEnabled ? Theme.Colors.success.withAlphaComponent(0.1) : Theme.Colors.textSecondary.withAlphaComponent(0.1)
        iconImageView.tintColor = isEnabled ? Theme.Colors.success : Theme.Colors.textSecondary
        
        actionButton.setTitle(isEnabled ? "Desactivar Seguridad" : "Activar Seguridad", for: .normal)
        actionButton.backgroundColor = isEnabled ? .systemRed : Theme.Colors.primary
        
        descriptionLabel.text = isEnabled
            ? "Tu cuenta está protegida. Se solicitará un código para realizar transacciones de alto valor."
            : "Activa la seguridad para proteger tu cuenta contra transacciones no autorizadas."
        
        totpContainer.isHidden = !isEnabled
        
        if isEnabled {
            startTOTPTimer()
            updateTOTPDisplay()
        } else {
            stopTOTPTimer()
        }
    }
    
    private func startTOTPTimer() {
        stopTOTPTimer()
        totpTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTOTPDisplay()
        }
    }
    
    private func stopTOTPTimer() {
        totpTimer?.invalidate()
        totpTimer = nil
    }
    
    private func updateTOTPDisplay() {
        guard let secret = userSecret else {
            totpCodeLabel.text = "------"
            return
        }
        let code = TOTPService.shared.generateCode(secret: secret)
        let secondsRemaining = TOTPService.shared.secondsRemaining()
        let progress = 1.0 - TOTPService.shared.progress()
        
        if isCodeVisible {
            totpCodeLabel.text = code
        } else {
            totpCodeLabel.text = "● ● ● ● ● ●"
        }
        
        let minutes = secondsRemaining / 60
        let seconds = secondsRemaining % 60
        totpTimerLabel.text = "Expira en \(minutes):\(String(format: "%02d", seconds))"
        
        UIView.animate(withDuration: 0.3) {
            self.totpProgressView.setProgress(Float(progress), animated: true)
        }
        
        if secondsRemaining < 30 {
            totpProgressView.progressTintColor = .systemOrange
        } else {
            totpProgressView.progressTintColor = Theme.Colors.primary
        }
    }
    
    @objc private func didTapShowHide() {
        isCodeVisible.toggle()
        showHideButton.setTitle(isCodeVisible ? "👁 Ocultar código" : "👁 Mostrar código", for: .normal)
        updateTOTPDisplay()
    }
    
    private func showOTPInput() {
        UIView.animate(withDuration: 0.3) {
            self.otpContainer.isHidden = false
            self.otpContainer.alpha = 1
            self.actionButton.alpha = 0
        }
        otpTextField.text = ""
        otpTextField.becomeFirstResponder()
    }
    
    private func hideOTPInput() {
        view.endEditing(true)
        UIView.animate(withDuration: 0.3) {
            self.otpContainer.isHidden = true
            self.otpContainer.alpha = 0
            self.actionButton.alpha = 1
        }
    }

    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func didTapAction() {
        viewModel.requestToggle()
    }
    
    @objc private func otpChanged(_ sender: UITextField) {
        if let text = sender.text, text.count == 6 {
            viewModel.submitOTP(text)
        }
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
        
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.6
        animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0 ]
        otpTextField.layer.add(animation, forKey: "shake")
    }
    
    private func showSuccess(_ message: String) {
        let alert = UIAlertController(title: "Éxito", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension TwoFactorViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.isEmpty { return true }
        
        guard string.isOnlyDigits else { return false }
        
        let currentText = textField.text ?? ""
        let newLength = currentText.count + string.count - range.length
        return newLength <= 6
    }
}
