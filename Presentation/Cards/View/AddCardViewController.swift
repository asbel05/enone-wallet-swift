//
//  AddCardViewController.swift
//  enone
//
//  Created by Asbel on 20/12/25.
//

import UIKit

final class AddCardViewController: UIViewController {
    
    private let viewModel = CardViewModel()

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
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
        label.text = "Tarjeta asociada"
        label.font = Theme.Fonts.title
        label.textColor = Theme.Colors.textPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let cardPreview: UIView = {
        let view = UIView()
        view.backgroundColor = Theme.Colors.primary
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let cardChipIcon: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "cpu")
        iv.tintColor = UIColor.white.withAlphaComponent(0.8)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let cardNumberPreview: UILabel = {
        let label = UILabel()
        label.text = "**** **** **** ****"
        label.font = UIFont.monospacedSystemFont(ofSize: 20, weight: .medium)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let cardHolderPreview: UILabel = {
        let label = UILabel()
        label.text = "NOMBRE DEL TITULAR"
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor.white.withAlphaComponent(0.8)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let cardExpiryPreview: UILabel = {
        let label = UILabel()
        label.text = "MM/YY"
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor.white.withAlphaComponent(0.8)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let cardBrandLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let activeCardContainer: UIView = {
        let view = UIView()
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let cardStatusLabel: UILabel = {
        let label = UILabel()
        label.text = "Tarjeta activa"
        label.font = Theme.Fonts.bodyMedium
        label.textColor = Theme.Colors.success
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let changeCardButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cambiar tarjeta", for: .normal)
        button.setTitleColor(Theme.Colors.primary, for: .normal)
        button.titleLabel?.font = Theme.Fonts.button
        button.backgroundColor = Theme.Colors.primary.withAlphaComponent(0.1)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let formContainer: UIView = {
        let view = UIView()
        view.isHidden = true // Hidden by default until we know card state
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let numberLabel: UILabel = {
        let label = UILabel()
        label.text = "Número de tarjeta"
        label.font = Theme.Fonts.caption
        label.textColor = Theme.Colors.textSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let numberTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "0000 0000 0000 0000"
        tf.font = UIFont.monospacedSystemFont(ofSize: 18, weight: .regular)
        tf.keyboardType = .numberPad
        tf.backgroundColor = Theme.Colors.surface
        tf.layer.cornerRadius = 12
        tf.layer.borderWidth = 1
        tf.layer.borderColor = Theme.Colors.divider.cgColor
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        tf.leftViewMode = .always
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let holderLabel: UILabel = {
        let label = UILabel()
        label.text = "Nombre del titular"
        label.font = Theme.Fonts.caption
        label.textColor = Theme.Colors.textSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let holderTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Como aparece en la tarjeta"
        tf.font = Theme.Fonts.body
        tf.autocapitalizationType = .allCharacters
        tf.backgroundColor = Theme.Colors.surface
        tf.layer.cornerRadius = 12
        tf.layer.borderWidth = 1
        tf.layer.borderColor = Theme.Colors.divider.cgColor
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        tf.leftViewMode = .always
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let expiryLabel: UILabel = {
        let label = UILabel()
        label.text = "Vencimiento"
        label.font = Theme.Fonts.caption
        label.textColor = Theme.Colors.textSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let expiryTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "MM/YY"
        tf.font = Theme.Fonts.body
        tf.keyboardType = .numberPad
        tf.backgroundColor = Theme.Colors.surface
        tf.layer.cornerRadius = 12
        tf.layer.borderWidth = 1
        tf.layer.borderColor = Theme.Colors.divider.cgColor
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        tf.leftViewMode = .always
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let cvvLabel: UILabel = {
        let label = UILabel()
        label.text = "CVV"
        label.font = Theme.Fonts.caption
        label.textColor = Theme.Colors.textSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let cvvTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "123"
        tf.font = Theme.Fonts.body
        tf.keyboardType = .numberPad
        tf.isSecureTextEntry = true
        tf.backgroundColor = Theme.Colors.surface
        tf.layer.cornerRadius = 12
        tf.layer.borderWidth = 1
        tf.layer.borderColor = Theme.Colors.divider.cgColor
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        tf.leftViewMode = .always
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let activateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Vincular Tarjeta", for: .normal)
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
    
    private let testCardLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = Theme.Fonts.small
        label.textColor = Theme.Colors.textSecondary
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Theme.Colors.background
        setupUI()
        setupActions()
        setupBindings()
        setupKeyboardDismiss()
        setupTextFieldDelegates()
        
        viewModel.loadActiveCard()
    }
    
    private func setupTextFieldDelegates() {
        numberTextField.delegate = self
        holderTextField.delegate = self
        expiryTextField.delegate = self
        cvvTextField.delegate = self
    }

    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(backButton)
        contentView.addSubview(titleLabel)
        contentView.addSubview(cardPreview)
        cardPreview.addSubview(cardChipIcon)
        cardPreview.addSubview(cardNumberPreview)
        cardPreview.addSubview(cardHolderPreview)
        cardPreview.addSubview(cardExpiryPreview)
        cardPreview.addSubview(cardBrandLabel)
        
        contentView.addSubview(activeCardContainer)
        activeCardContainer.addSubview(cardStatusLabel)
        activeCardContainer.addSubview(changeCardButton)
        
        contentView.addSubview(formContainer)
        formContainer.addSubview(numberLabel)
        formContainer.addSubview(numberTextField)
        formContainer.addSubview(holderLabel)
        formContainer.addSubview(holderTextField)
        formContainer.addSubview(expiryLabel)
        formContainer.addSubview(expiryTextField)
        formContainer.addSubview(cvvLabel)
        formContainer.addSubview(cvvTextField)
        formContainer.addSubview(activateButton)
        activateButton.addSubview(loadingIndicator)
        formContainer.addSubview(testCardLabel)
        
        let padding = Theme.Layout.padding
        
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
            backButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),
            
            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 8),
            
            cardPreview.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            cardPreview.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            cardPreview.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            cardPreview.heightAnchor.constraint(equalToConstant: 180),
            
            cardChipIcon.topAnchor.constraint(equalTo: cardPreview.topAnchor, constant: 24),
            cardChipIcon.leadingAnchor.constraint(equalTo: cardPreview.leadingAnchor, constant: 24),
            cardChipIcon.widthAnchor.constraint(equalToConstant: 40),
            cardChipIcon.heightAnchor.constraint(equalToConstant: 32),
            
            cardBrandLabel.topAnchor.constraint(equalTo: cardPreview.topAnchor, constant: 24),
            cardBrandLabel.trailingAnchor.constraint(equalTo: cardPreview.trailingAnchor, constant: -24),
            
            cardNumberPreview.centerYAnchor.constraint(equalTo: cardPreview.centerYAnchor),
            cardNumberPreview.leadingAnchor.constraint(equalTo: cardPreview.leadingAnchor, constant: 24),
            
            cardHolderPreview.bottomAnchor.constraint(equalTo: cardPreview.bottomAnchor, constant: -24),
            cardHolderPreview.leadingAnchor.constraint(equalTo: cardPreview.leadingAnchor, constant: 24),
            
            cardExpiryPreview.bottomAnchor.constraint(equalTo: cardPreview.bottomAnchor, constant: -24),
            cardExpiryPreview.trailingAnchor.constraint(equalTo: cardPreview.trailingAnchor, constant: -24),
            
            activeCardContainer.topAnchor.constraint(equalTo: cardPreview.bottomAnchor, constant: 24),
            activeCardContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            activeCardContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            
            cardStatusLabel.topAnchor.constraint(equalTo: activeCardContainer.topAnchor),
            cardStatusLabel.centerXAnchor.constraint(equalTo: activeCardContainer.centerXAnchor),
            
            changeCardButton.topAnchor.constraint(equalTo: cardStatusLabel.bottomAnchor, constant: 24),
            changeCardButton.leadingAnchor.constraint(equalTo: activeCardContainer.leadingAnchor),
            changeCardButton.trailingAnchor.constraint(equalTo: activeCardContainer.trailingAnchor),
            changeCardButton.heightAnchor.constraint(equalToConstant: 56),
            changeCardButton.bottomAnchor.constraint(equalTo: activeCardContainer.bottomAnchor),
            
            // Form container
            formContainer.topAnchor.constraint(equalTo: cardPreview.bottomAnchor, constant: 28),
            formContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            formContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            formContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40),
            
            numberLabel.topAnchor.constraint(equalTo: formContainer.topAnchor),
            numberLabel.leadingAnchor.constraint(equalTo: formContainer.leadingAnchor),
            
            numberTextField.topAnchor.constraint(equalTo: numberLabel.bottomAnchor, constant: 8),
            numberTextField.leadingAnchor.constraint(equalTo: formContainer.leadingAnchor),
            numberTextField.trailingAnchor.constraint(equalTo: formContainer.trailingAnchor),
            numberTextField.heightAnchor.constraint(equalToConstant: 52),
            
            holderLabel.topAnchor.constraint(equalTo: numberTextField.bottomAnchor, constant: 20),
            holderLabel.leadingAnchor.constraint(equalTo: formContainer.leadingAnchor),
            
            holderTextField.topAnchor.constraint(equalTo: holderLabel.bottomAnchor, constant: 8),
            holderTextField.leadingAnchor.constraint(equalTo: formContainer.leadingAnchor),
            holderTextField.trailingAnchor.constraint(equalTo: formContainer.trailingAnchor),
            holderTextField.heightAnchor.constraint(equalToConstant: 52),
            
            expiryLabel.topAnchor.constraint(equalTo: holderTextField.bottomAnchor, constant: 20),
            expiryLabel.leadingAnchor.constraint(equalTo: formContainer.leadingAnchor),
            
            expiryTextField.topAnchor.constraint(equalTo: expiryLabel.bottomAnchor, constant: 8),
            expiryTextField.leadingAnchor.constraint(equalTo: formContainer.leadingAnchor),
            expiryTextField.widthAnchor.constraint(equalTo: formContainer.widthAnchor, multiplier: 0.4),
            expiryTextField.heightAnchor.constraint(equalToConstant: 52),
            
            cvvLabel.topAnchor.constraint(equalTo: holderTextField.bottomAnchor, constant: 20),
            cvvLabel.leadingAnchor.constraint(equalTo: expiryTextField.trailingAnchor, constant: 16),
            
            cvvTextField.topAnchor.constraint(equalTo: cvvLabel.bottomAnchor, constant: 8),
            cvvTextField.leadingAnchor.constraint(equalTo: expiryTextField.trailingAnchor, constant: 16),
            cvvTextField.trailingAnchor.constraint(equalTo: formContainer.trailingAnchor),
            cvvTextField.heightAnchor.constraint(equalToConstant: 52),
            
            activateButton.topAnchor.constraint(equalTo: expiryTextField.bottomAnchor, constant: 32),
            activateButton.leadingAnchor.constraint(equalTo: formContainer.leadingAnchor),
            activateButton.trailingAnchor.constraint(equalTo: formContainer.trailingAnchor),
            activateButton.heightAnchor.constraint(equalToConstant: 56),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: activateButton.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: activateButton.centerYAnchor),
            
            testCardLabel.topAnchor.constraint(equalTo: activateButton.bottomAnchor, constant: 20),
            testCardLabel.leadingAnchor.constraint(equalTo: formContainer.leadingAnchor),
            testCardLabel.trailingAnchor.constraint(equalTo: formContainer.trailingAnchor),
            testCardLabel.bottomAnchor.constraint(equalTo: formContainer.bottomAnchor)
        ])
    }
    
    private func setupActions() {
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        activateButton.addTarget(self, action: #selector(didTapActivate), for: .touchUpInside)
        changeCardButton.addTarget(self, action: #selector(didTapChangeCard), for: .touchUpInside)
        
        numberTextField.addTarget(self, action: #selector(numberChanged), for: .editingChanged)
        holderTextField.addTarget(self, action: #selector(holderChanged), for: .editingChanged)
        expiryTextField.addTarget(self, action: #selector(expiryChanged), for: .editingChanged)
    }
    
    private func setupBindings() {
        viewModel.onLoadingChange = { [weak self] isLoading in
            self?.setLoading(isLoading)
        }
        
        viewModel.onCardLoaded = { [weak self] card in
            self?.updateUIForCard(card)
        }
        
        viewModel.onError = { [weak self] message in
            self?.showError(message)
        }
        
        viewModel.onSuccess = { [weak self] message in
            self?.showSuccess(message)
        }
    }
    
    private func setupKeyboardDismiss() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    private func updateUIForCard(_ card: Card?) {
        if let card = card {
            cardNumberPreview.text = card.displayNumber
            cardHolderPreview.text = card.holderName ?? "TITULAR"
            cardExpiryPreview.text = card.expiryDate
            cardBrandLabel.text = card.cardBrand ?? ""
            
            activeCardContainer.isHidden = false
            formContainer.isHidden = true
            titleLabel.text = "Tarjeta asociada"
        } else {
            cardNumberPreview.text = "**** **** **** ****"
            cardHolderPreview.text = "NOMBRE DEL TITULAR"
            cardExpiryPreview.text = "MM/YY"
            cardBrandLabel.text = ""
            
            activeCardContainer.isHidden = true
            formContainer.isHidden = false
            titleLabel.text = "Vincular Tarjeta"
        }
    }

    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func didTapActivate() {
        guard let number = numberTextField.text?.replacingOccurrences(of: " ", with: ""),
              let holder = holderTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let expiry = expiryTextField.text,
              let cvv = cvvTextField.text else { return }
        
        guard number.isValidCardNumber else {
            showError("El número de tarjeta debe tener 16 dígitos")
            return
        }
        
        guard !holder.isEmpty else {
            showError("Ingresa el nombre del titular")
            return
        }
        
        guard holder.isOnlyLettersAndSpaces else {
            showError("El nombre solo debe contener letras")
            return
        }
        
        guard expiry.isValidExpiryDate else {
            showError("Fecha de vencimiento inválida (MM/YY)")
            return
        }
        
        guard cvv.isValidCVV else {
            showError("El CVV debe tener 3 dígitos")
            return
        }
        
        viewModel.activateCard(cardNumber: number, cvv: cvv, expiryDate: expiry, holderName: holder)
    }
    
    @objc private func didTapChangeCard() {
        activeCardContainer.isHidden = true
        formContainer.isHidden = false
        titleLabel.text = "Cambiar Tarjeta"
        
        cardNumberPreview.text = "**** **** **** ****"
        cardHolderPreview.text = "NOMBRE DEL TITULAR"
        cardExpiryPreview.text = "MM/YY"
        cardBrandLabel.text = ""
        
        numberTextField.text = ""
        holderTextField.text = ""
        expiryTextField.text = ""
        cvvTextField.text = ""
    }
    
    @objc private func numberChanged(_ textField: UITextField) {
        guard let text = textField.text else { return }
        let cleaned = text.replacingOccurrences(of: " ", with: "")
        let limited = String(cleaned.prefix(16))
        
        var formatted = ""
        for (index, char) in limited.enumerated() {
            if index > 0 && index % 4 == 0 {
                formatted += " "
            }
            formatted += String(char)
        }
        textField.text = formatted
        
        let masked = "**** **** **** " + String(limited.suffix(4))
        cardNumberPreview.text = limited.count >= 4 ? masked : "**** **** **** ****"
        
        if limited.hasPrefix("4") {
            cardBrandLabel.text = "VISA"
        } else if limited.hasPrefix("5") {
            cardBrandLabel.text = "MASTERCARD"
        } else {
            cardBrandLabel.text = ""
        }
    }
    
    @objc private func holderChanged(_ textField: UITextField) {
        cardHolderPreview.text = textField.text?.uppercased() ?? "NOMBRE DEL TITULAR"
    }
    
    @objc private func expiryChanged(_ textField: UITextField) {
        guard let text = textField.text else { return }
        let cleaned = text.replacingOccurrences(of: "/", with: "")
        let limited = String(cleaned.prefix(4))
        
        if limited.count >= 2 {
            let month = String(limited.prefix(2))
            let year = String(limited.suffix(limited.count - 2))
            textField.text = month + "/" + year
        } else {
            textField.text = limited
        }
        
        cardExpiryPreview.text = textField.text ?? "MM/YY"
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func setLoading(_ loading: Bool) {
        activateButton.isEnabled = !loading
        if loading {
            activateButton.setTitle("", for: .normal)
            loadingIndicator.startAnimating()
        } else {
            activateButton.setTitle("Vincular Tarjeta", for: .normal)
            loadingIndicator.stopAnimating()
        }
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showSuccess(_ message: String) {
        let alert = UIAlertController(title: "Éxito", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.viewModel.loadActiveCard()
        })
        present(alert, animated: true)
    }
}

extension AddCardViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.isEmpty { return true }
        
        let currentText = textField.text ?? ""
        let newLength = currentText.count + string.count - range.length
        
        switch textField {
        case numberTextField:
            guard string.isOnlyDigits else { return false }
            let cleaned = currentText.replacingOccurrences(of: " ", with: "")
            return cleaned.count + string.count <= 16
            
        case holderTextField:
            guard string.isOnlyLettersAndSpaces else { return false }
            return true
            
        case expiryTextField:
            let allowedCharacters = CharacterSet(charactersIn: "0123456789/")
            guard string.unicodeScalars.allSatisfy({ allowedCharacters.contains($0) }) else { return false }
            return newLength <= 5
            
        case cvvTextField:
            guard string.isOnlyDigits else { return false }
            return newLength <= 3
            
        default:
            return true
        }
    }
}
