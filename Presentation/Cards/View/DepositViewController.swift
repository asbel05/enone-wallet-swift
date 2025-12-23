//
//  DepositViewController.swift
//  enone
//
//  Created by Asbel on 20/12/25.
//

import UIKit

final class DepositViewController: UIViewController {
    
    private let viewModel: DepositViewModel

    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = Theme.Colors.textPrimary
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Depositar"
        label.font = Theme.Fonts.title
        label.textColor = Theme.Colors.textPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let cardInfoContainer: UIView = {
        let view = UIView()
        view.backgroundColor = Theme.Colors.surface
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = Theme.Colors.divider.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0
        return view
    }()
    
    private let cardIcon: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "creditcard.fill")
        iv.tintColor = Theme.Colors.primary
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let cardNumberLabel: UILabel = {
        let label = UILabel()
        label.text = "**** **** **** ****"
        label.font = UIFont.monospacedSystemFont(ofSize: 16, weight: .medium)
        label.textColor = Theme.Colors.textPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let cardBrandLabel: UILabel = {
        let label = UILabel()
        label.text = "Tarjeta activa"
        label.font = Theme.Fonts.caption
        label.textColor = Theme.Colors.textSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.text = "¿Cuánto quieres depositar?"
        label.font = Theme.Fonts.caption
        label.textColor = Theme.Colors.textSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let currencyLabel: UILabel = {
        let label = UILabel()
        label.text = "S/"
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textColor = Theme.Colors.textPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let amountTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "0.00"
        tf.font = UIFont.systemFont(ofSize: 40, weight: .bold)
        tf.textColor = Theme.Colors.textPrimary
        tf.keyboardType = .decimalPad
        tf.borderStyle = .none
        tf.textAlignment = .left
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
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.text = "El dinero se cargará desde tu tarjeta vinculada"
        label.font = Theme.Fonts.caption
        label.textColor = Theme.Colors.textSecondary
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let depositButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Depositar dinero", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = Theme.Fonts.button
        button.backgroundColor = Theme.Colors.primary
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.color = .white
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    init(currency: String = "PEN") {
        self.viewModel = DepositViewModel(currency: currency)
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
        
        amountTextField.delegate = self
        
        if viewModel.currency == "USD" {
            currencyLabel.text = "$"
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadInitialData()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.addSubview(cardInfoContainer)
        cardInfoContainer.addSubview(cardIcon)
        cardInfoContainer.addSubview(cardNumberLabel)
        cardInfoContainer.addSubview(cardBrandLabel)
        view.addSubview(amountLabel)
        view.addSubview(currencyLabel)
        view.addSubview(amountTextField)
        view.addSubview(quickAmountsStack)
        view.addSubview(infoLabel)
        view.addSubview(depositButton)
        depositButton.addSubview(loadingIndicator)
        
        setupQuickAmounts()
        
        let padding = Theme.Layout.padding
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),
            
            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 8),
            
            cardInfoContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            cardInfoContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            cardInfoContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            cardInfoContainer.heightAnchor.constraint(equalToConstant: 72),
            
            cardIcon.leadingAnchor.constraint(equalTo: cardInfoContainer.leadingAnchor, constant: 16),
            cardIcon.centerYAnchor.constraint(equalTo: cardInfoContainer.centerYAnchor),
            cardIcon.widthAnchor.constraint(equalToConstant: 32),
            cardIcon.heightAnchor.constraint(equalToConstant: 24),
            
            cardNumberLabel.leadingAnchor.constraint(equalTo: cardIcon.trailingAnchor, constant: 12),
            cardNumberLabel.topAnchor.constraint(equalTo: cardInfoContainer.topAnchor, constant: 16),
            
            cardBrandLabel.leadingAnchor.constraint(equalTo: cardIcon.trailingAnchor, constant: 12),
            cardBrandLabel.bottomAnchor.constraint(equalTo: cardInfoContainer.bottomAnchor, constant: -16),
            
            amountLabel.topAnchor.constraint(equalTo: cardInfoContainer.bottomAnchor, constant: 32),
            amountLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            
            currencyLabel.topAnchor.constraint(equalTo: amountLabel.bottomAnchor, constant: 12),
            currencyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            
            amountTextField.centerYAnchor.constraint(equalTo: currencyLabel.centerYAnchor),
            amountTextField.leadingAnchor.constraint(equalTo: currencyLabel.trailingAnchor, constant: 8),
            amountTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            
            quickAmountsStack.topAnchor.constraint(equalTo: currencyLabel.bottomAnchor, constant: 24),
            quickAmountsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            quickAmountsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            quickAmountsStack.heightAnchor.constraint(equalToConstant: 44),
            
            infoLabel.topAnchor.constraint(equalTo: quickAmountsStack.bottomAnchor, constant: 24),
            infoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            infoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            
            depositButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            depositButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            depositButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            depositButton.heightAnchor.constraint(equalToConstant: 56),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: depositButton.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: depositButton.centerYAnchor)
        ])
    }
    
    private func setupQuickAmounts() {
        let amounts = [50, 100, 200, 500]
        let symbol = viewModel.currency == "USD" ? "$" : "S/"
        for amount in amounts {
            let button = UIButton(type: .system)
            button.setTitle("\(symbol) \(amount)", for: .normal)
            button.setTitleColor(Theme.Colors.primary, for: .normal)
            button.titleLabel?.font = Theme.Fonts.bodyMedium
            button.backgroundColor = Theme.Colors.primary.withAlphaComponent(0.1)
            button.layer.cornerRadius = 8
            button.tag = amount
            button.addTarget(self, action: #selector(didTapQuickAmount(_:)), for: .touchUpInside)
            quickAmountsStack.addArrangedSubview(button)
        }
    }
    
    private func setupActions() {
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        depositButton.addTarget(self, action: #selector(didTapDeposit), for: .touchUpInside)
    }
    
    private func setupBindings() {
        viewModel.onLoadingChange = { [weak self] isLoading in
            self?.setLoading(isLoading)
        }
        
        viewModel.onCardLoaded = { [weak self] card in
            guard let self = self else { return }
            if let card = card {
                self.cardNumberLabel.text = card.displayNumber
                self.cardBrandLabel.text = card.cardBrand ?? "Tarjeta activa"
            } else {
                self.cardNumberLabel.text = "Sin tarjeta"
                self.cardBrandLabel.text = "Vincula una tarjeta primero"
            }
            UIView.animate(withDuration: 0.3) {
                self.cardInfoContainer.alpha = 1
            }
        }
        
        viewModel.onError = { [weak self] message in
            self?.showError(message)
        }
        
        viewModel.onSuccess = { [weak self] message, newBalance in
            self?.showSuccess(message, newBalance: newBalance)
        }
    }
    
    private func setupKeyboardDismiss() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func didTapDeposit() {
        guard viewModel.hasActiveCard else {
            showNoCardAlert()
            return
        }
        
        guard let amountText = amountTextField.text,
              let amount = Double(amountText),
              amount > 0 else {
            showError("Ingresa un monto válido")
            return
        }
        
        viewModel.deposit(amount: amount)
    }
    
    @objc private func didTapQuickAmount(_ sender: UIButton) {
        amountTextField.text = String(sender.tag)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func setLoading(_ loading: Bool) {
        depositButton.isEnabled = !loading
        if loading {
            depositButton.setTitle("", for: .normal)
            loadingIndicator.startAnimating()
        } else {
            depositButton.setTitle("Depositar dinero", for: .normal)
            loadingIndicator.stopAnimating()
        }
    }
    
    private func showNoCardAlert() {
        let alert = UIAlertController(
            title: "Sin tarjeta vinculada",
            message: "Para depositar dinero necesitas vincular una tarjeta primero.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Vincular ahora", style: .default) { [weak self] _ in
            let addCardVC = AddCardViewController()
            self?.navigationController?.pushViewController(addCardVC, animated: true)
        })
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        present(alert, animated: true)
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showSuccess(_ message: String, newBalance: Double) {
        let symbol = viewModel.currency == "USD" ? "$" : "S/"
        let alert = UIAlertController(
            title: "¡Depósito exitoso!",
            message: "\(message)\n\nNuevo saldo: \(symbol) \(String(format: "%.2f", newBalance))",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
}

extension DepositViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.isEmpty { return true }
        
        let allowedCharacters = CharacterSet(charactersIn: "0123456789.,")
        guard string.unicodeScalars.allSatisfy({ allowedCharacters.contains($0) }) else { return false }
        
        let currentText = textField.text ?? ""
        if (currentText.contains(".") || currentText.contains(",")) && (string == "." || string == ",") {
            return false
        }
        
        return true
    }
}
