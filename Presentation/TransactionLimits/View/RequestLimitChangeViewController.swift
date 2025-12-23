//
//  RequestLimitChangeViewController.swift
//  enone
//
//  Created by Asbel on 18/12/25.
//

import UIKit

final class RequestLimitChangeViewController: UIViewController {
    
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
        label.text = "Modificar Límite"
        label.font = Theme.Fonts.title
        label.textColor = Theme.Colors.textPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let currentLimitCard: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.08
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let currentLimitLabel: UILabel = {
        let label = UILabel()
        label.text = "Tu límite actual"
        label.font = Theme.Fonts.caption
        label.textColor = Theme.Colors.textSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let currentAmountLabel: UILabel = {
        let label = UILabel()
        label.text = "S/ 500.00"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = Theme.Colors.textPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let newLimitLabel: UILabel = {
        let label = UILabel()
        label.text = "Nuevo límite diario (S/)"
        label.font = Theme.Fonts.bodyMedium
        label.textColor = Theme.Colors.textPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let limitTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "1000.00"
        tf.font = Theme.Fonts.body
        tf.textColor = Theme.Colors.textPrimary
        tf.backgroundColor = Theme.Colors.surface
        tf.layer.cornerRadius = Theme.Layout.cornerRadius
        tf.keyboardType = .decimalPad
        tf.textAlignment = .center
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        tf.leftViewMode = .always
        tf.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        tf.rightViewMode = .always
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let quickAmountsStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.spacing = 12
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let requestButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Solicitar Código", for: .normal)
        button.titleLabel?.font = Theme.Fonts.button
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = Theme.Colors.primary
        button.layer.cornerRadius = Theme.Layout.cornerRadius
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let viewModel: TransactionLimitsViewModel
    private let currentInfo: TransactionLimitInfo
    
    init(viewModel: TransactionLimitsViewModel, currentInfo: TransactionLimitInfo) {
        self.viewModel = viewModel
        self.currentInfo = currentInfo
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
        currentAmountLabel.text = currentInfo.formattedLimit
        setupQuickAmounts()
        
        limitTextField.delegate = self
    }
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(backButton)
        contentView.addSubview(titleLabel)
        contentView.addSubview(currentLimitCard)
        contentView.addSubview(newLimitLabel)
        contentView.addSubview(limitTextField)
        contentView.addSubview(quickAmountsStack)
        contentView.addSubview(requestButton)
        
        currentLimitCard.addSubview(currentLimitLabel)
        currentLimitCard.addSubview(currentAmountLabel)
        
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
            
            currentLimitCard.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            currentLimitCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.Layout.padding),
            currentLimitCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Theme.Layout.padding),
            currentLimitCard.heightAnchor.constraint(equalToConstant: 80),
            
            currentLimitLabel.topAnchor.constraint(equalTo: currentLimitCard.topAnchor, constant: 16),
            currentLimitLabel.centerXAnchor.constraint(equalTo: currentLimitCard.centerXAnchor),
            
            currentAmountLabel.topAnchor.constraint(equalTo: currentLimitLabel.bottomAnchor, constant: 8),
            currentAmountLabel.centerXAnchor.constraint(equalTo: currentLimitCard.centerXAnchor),
            
            newLimitLabel.topAnchor.constraint(equalTo: currentLimitCard.bottomAnchor, constant: 32),
            newLimitLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.Layout.padding),
            
            limitTextField.topAnchor.constraint(equalTo: newLimitLabel.bottomAnchor, constant: 12),
            limitTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.Layout.padding),
            limitTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Theme.Layout.padding),
            limitTextField.heightAnchor.constraint(equalToConstant: Theme.Layout.inputHeight),
            
            quickAmountsStack.topAnchor.constraint(equalTo: limitTextField.bottomAnchor, constant: 16),
            quickAmountsStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.Layout.padding),
            quickAmountsStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Theme.Layout.padding),
            quickAmountsStack.heightAnchor.constraint(equalToConstant: 44),
            
            requestButton.topAnchor.constraint(equalTo: quickAmountsStack.bottomAnchor, constant: 32),
            requestButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.Layout.padding),
            requestButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Theme.Layout.padding),
            requestButton.heightAnchor.constraint(equalToConstant: Theme.Layout.buttonHeight),
            requestButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }
    
    private func setupActions() {
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        requestButton.addTarget(self, action: #selector(didTapRequest), for: .touchUpInside)
    }
    
    private func setupBindings() {
        viewModel.onLoadingChange = { [weak self] isLoading in
            self?.requestButton.isEnabled = !isLoading
            self?.requestButton.alpha = isLoading ? 0.5 : 1.0
        }
        
        viewModel.onError = { [weak self] message in
            self?.showError(message)
        }
        
        viewModel.onOTPGenerated = { [weak self] otp in
            guard let self = self, let newLimit = self.viewModel.pendingNewLimit else { return }
            let verifyVC = VerifyLimitOTPViewController(viewModel: self.viewModel, newLimit: newLimit, otp: otp)
            self.navigationController?.pushViewController(verifyVC, animated: true)
        }
    }
    
    private func setupQuickAmounts() {
        let amounts = [500.0, 1000.0, 2000.0]
        for amount in amounts {
            let button = createQuickAmountButton(amount: amount)
            quickAmountsStack.addArrangedSubview(button)
        }
    }
    
    private func createQuickAmountButton(amount: Double) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("S/\(Int(amount))", for: .normal)
        button.titleLabel?.font = Theme.Fonts.bodyMedium
        button.setTitleColor(Theme.Colors.primary, for: .normal)
        button.backgroundColor = Theme.Colors.primary.withAlphaComponent(0.1)
        button.layer.cornerRadius = 8
        button.tag = Int(amount)
        button.addTarget(self, action: #selector(didTapQuickAmount(_:)), for: .touchUpInside)
        return button
    }
    
    @objc private func didTapQuickAmount(_ sender: UIButton) {
        limitTextField.text = "\(sender.tag).00"
    }
    
    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func didTapRequest() {
        guard let limitText = limitTextField.text,
              let newLimit = Double(limitText),
              newLimit >= 500 && newLimit <= 2000 else {
            showError("Ingresa un límite válido entre S/ 500 y S/ 2000")
            return
        }
        
        viewModel.requestLimitChange(newLimit: newLimit)
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension RequestLimitChangeViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.isEmpty { return true }
        
        let allowedCharacters = CharacterSet(charactersIn: "0123456789.")
        guard string.unicodeScalars.allSatisfy({ allowedCharacters.contains($0) }) else { return false }
        
        let currentText = textField.text ?? ""
        if currentText.contains(".") && string == "." {
            return false
        }
        
        return true
    }
}
