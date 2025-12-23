//
//  VerifyEmailViewController.swift
//  enone
//
//  Created by Asbel on 17/12/25.
//

import UIKit

final class VerifyEmailViewController: UIViewController {
    
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
    
    private let iconContainer: UIView = {
        let view = UIView()
        view.backgroundColor = Theme.Colors.primary.withAlphaComponent(0.15)
        view.layer.cornerRadius = 40
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let iconView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "envelope.badge")
        iv.tintColor = Theme.Colors.primary
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Verifica tu correo"
        label.font = Theme.Fonts.title
        label.textColor = Theme.Colors.textPrimary
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.Fonts.body
        label.textColor = Theme.Colors.textSecondary
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let otpTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Código de 8 dígitos"
        tf.font = UIFont.monospacedDigitSystemFont(ofSize: 20, weight: .semibold)
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
        button.setTitle("Verificar Código", for: .normal)
        button.titleLabel?.font = Theme.Fonts.button
        button.setTitleColor(Theme.Colors.textOnPrimary, for: .normal)
        button.backgroundColor = Theme.Colors.primary
        button.layer.cornerRadius = Theme.Layout.cornerRadius
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let resendButton: UIButton = {
        let button = UIButton(type: .system)
        
        let text = "¿No recibiste el código? Reenviar"
        let attributedText = NSMutableAttributedString(string: text)
        
        let normalRange = NSRange(location: 0, length: 25)
        let highlightRange = NSRange(location: 25, length: 8)
        
        attributedText.addAttribute(.foregroundColor, value: Theme.Colors.textSecondary, range: normalRange)
        attributedText.addAttribute(.font, value: Theme.Fonts.caption, range: normalRange)
        attributedText.addAttribute(.foregroundColor, value: Theme.Colors.primary, range: highlightRange)
        attributedText.addAttribute(.font, value: Theme.Fonts.button, range: highlightRange)
        
        button.setAttributedTitle(attributedText, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let errorLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.Fonts.caption
        label.textColor = Theme.Colors.error
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let successLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.Fonts.caption
        label.textColor = Theme.Colors.success
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = Theme.Colors.textOnPrimary
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    private let viewModel: VerifyEmailViewModel

    init(viewModel: VerifyEmailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Theme.Colors.background
        navigationItem.hidesBackButton = true
        setupUI()
        setupBindings()
        setupKeyboardDismiss()
        updateSubtitle()
        
        otpTextField.delegate = self
    }
}

private extension VerifyEmailViewController {
    
    func updateSubtitle() {
        subtitleLabel.text = "Ingresa el código de 8 dígitos que enviamos a \(viewModel.email)"
    }

    func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(iconContainer)
        iconContainer.addSubview(iconView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(otpTextField)
        contentView.addSubview(errorLabel)
        contentView.addSubview(successLabel)
        contentView.addSubview(verifyButton)
        verifyButton.addSubview(activityIndicator)
        contentView.addSubview(resendButton)

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
            
            iconContainer.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 60),
            iconContainer.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 80),
            iconContainer.heightAnchor.constraint(equalToConstant: 80),
            
            iconView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 40),
            iconView.heightAnchor.constraint(equalToConstant: 40),
            
            titleLabel.topAnchor.constraint(equalTo: iconContainer.bottomAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.Layout.padding),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Theme.Layout.padding),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.Layout.padding),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Theme.Layout.padding),

            otpTextField.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 40),
            otpTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.Layout.padding),
            otpTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Theme.Layout.padding),
            otpTextField.heightAnchor.constraint(equalToConstant: 64),
            
            errorLabel.topAnchor.constraint(equalTo: otpTextField.bottomAnchor, constant: 12),
            errorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.Layout.padding),
            errorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Theme.Layout.padding),
            
            successLabel.topAnchor.constraint(equalTo: otpTextField.bottomAnchor, constant: 12),
            successLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.Layout.padding),
            successLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Theme.Layout.padding),

            verifyButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 24),
            verifyButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.Layout.padding),
            verifyButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Theme.Layout.padding),
            verifyButton.heightAnchor.constraint(equalToConstant: Theme.Layout.buttonHeight),
            
            activityIndicator.centerYAnchor.constraint(equalTo: verifyButton.centerYAnchor),
            activityIndicator.trailingAnchor.constraint(equalTo: verifyButton.trailingAnchor, constant: -16),
            
            resendButton.topAnchor.constraint(equalTo: verifyButton.bottomAnchor, constant: 24),
            resendButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            resendButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])

        verifyButton.addTarget(self, action: #selector(didTapVerify), for: .touchUpInside)
        resendButton.addTarget(self, action: #selector(didTapResend), for: .touchUpInside)
    }
    
    func setupKeyboardDismiss() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
}

private extension VerifyEmailViewController {
    func setupBindings() {
        viewModel.onLoadingChange = { [weak self] isLoading in
            DispatchQueue.main.async {
                self?.verifyButton.isEnabled = !isLoading
                self?.resendButton.isEnabled = !isLoading
                self?.verifyButton.alpha = isLoading ? 0.7 : 1.0
                if isLoading {
                    self?.activityIndicator.startAnimating()
                    self?.verifyButton.setTitle("", for: .normal)
                } else {
                    self?.activityIndicator.stopAnimating()
                    self?.verifyButton.setTitle("Verificar Código", for: .normal)
                }
            }
        }
        
        viewModel.onError = { [weak self] message in
            DispatchQueue.main.async {
                self?.successLabel.isHidden = true
                self?.errorLabel.text = message
                self?.errorLabel.isHidden = false
            }
        }
        
        viewModel.onResendSuccess = { [weak self] in
            DispatchQueue.main.async {
                self?.errorLabel.isHidden = true
                self?.successLabel.text = "¡Código reenviado exitosamente!"
                self?.successLabel.isHidden = false
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self?.successLabel.isHidden = true
                }
            }
        }

        viewModel.onVerificationSuccess = { [weak self] in
            DispatchQueue.main.async {
                self?.navigateToCompleteProfile()
            }
        }
    }
}

private extension VerifyEmailViewController {
    @objc func didTapVerify() {
        hideMessages()
        dismissKeyboard()
        viewModel.verify(token: otpTextField.text ?? "")
    }
    
    @objc func didTapResend() {
        hideMessages()
        dismissKeyboard()
        viewModel.resendCode()
    }

    func navigateToCompleteProfile() {
        let viewModel = CompleteProfileViewModel()
        let completeProfileVC = CompleteProfileViewController(viewModel: viewModel)
        navigationController?.pushViewController(completeProfileVC, animated: true)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func hideMessages() {
        errorLabel.isHidden = true
        successLabel.isHidden = true
    }
}

extension VerifyEmailViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.isEmpty { return true }
        
        guard string.isOnlyDigits else { return false }
        
        let currentText = textField.text ?? ""
        let newLength = currentText.count + string.count - range.length
        return newLength <= 8
    }
}
