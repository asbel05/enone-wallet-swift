//
//  CurrencyConversionViewController.swift
//  enone
//
//  Created by Asbel on 21/12/25.
//

import UIKit

final class CurrencyConversionViewController: UIViewController {

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.backgroundColor = Theme.Colors.background
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.alwaysBounceVertical = true
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
    
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "Convertir Moneda"
        label.font = Theme.Fonts.title
        label.textColor = Theme.Colors.textPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let exchangeRateCard: UIView = {
        let view = UIView()
        view.backgroundColor = Theme.Colors.primary.withAlphaComponent(0.08)
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1.5
        view.layer.borderColor = Theme.Colors.primary.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let rateIconImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "chart.line.uptrend.xyaxis")
        iv.tintColor = Theme.Colors.primary
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let rateTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Tipo de cambio actual"
        label.font = Theme.Fonts.caption
        label.textColor = Theme.Colors.primary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let rateValueLabel: UILabel = {
        let label = UILabel()
        label.text = "1 PEN = 0.0000 USD"
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.textColor = Theme.Colors.textPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let rateUpdateLabel: UILabel = {
        let label = UILabel()
        label.text = "Actualizado en tiempo real"
        label.font = Theme.Fonts.small
        label.textColor = Theme.Colors.textSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let fromSectionLabel: UILabel = {
        let label = UILabel()
        label.text = "Desde"
        label.font = Theme.Fonts.caption
        label.textColor = Theme.Colors.textSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let fromDropdownButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = Theme.Colors.surface
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 1
        button.layer.borderColor = Theme.Colors.divider.cgColor
        button.contentHorizontalAlignment = .left
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let fromFlagLabel: UILabel = {
        let label = UILabel()
        label.text = "🇵🇪"
        label.font = UIFont.systemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let fromCurrencyLabel: UILabel = {
        let label = UILabel()
        label.text = "Soles (PEN)"
        label.font = Theme.Fonts.body
        label.textColor = Theme.Colors.textPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let fromChevron: UIImageView = {
        let iv = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        iv.image = UIImage(systemName: "chevron.down", withConfiguration: config)
        iv.tintColor = Theme.Colors.textSecondary
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let amountSectionLabel: UILabel = {
        let label = UILabel()
        label.text = "Monto a convertir"
        label.font = Theme.Fonts.caption
        label.textColor = Theme.Colors.textSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let amountContainer: UIView = {
        let view = UIView()
        view.backgroundColor = Theme.Colors.surface
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = Theme.Colors.divider.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let amountTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "100.00"
        tf.text = "100.00"
        tf.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        tf.textColor = Theme.Colors.textPrimary
        tf.keyboardType = .decimalPad
        tf.borderStyle = .none
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let toSectionLabel: UILabel = {
        let label = UILabel()
        label.text = "A"
        label.font = Theme.Fonts.caption
        label.textColor = Theme.Colors.textSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let toDropdownButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = Theme.Colors.surface
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 1
        button.layer.borderColor = Theme.Colors.divider.cgColor
        button.contentHorizontalAlignment = .left
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let toFlagLabel: UILabel = {
        let label = UILabel()
        label.text = "🇺🇸"
        label.font = UIFont.systemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let toCurrencyLabel: UILabel = {
        let label = UILabel()
        label.text = "Dólares (USD)"
        label.font = Theme.Fonts.body
        label.textColor = Theme.Colors.textPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let toChevron: UIImageView = {
        let iv = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        iv.image = UIImage(systemName: "chevron.down", withConfiguration: config)
        iv.tintColor = Theme.Colors.textSecondary
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let resultPreviewContainer: UIView = {
        let view = UIView()
        view.backgroundColor = Theme.Colors.primary.withAlphaComponent(0.05)
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let resultTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Recibirás aproximadamente"
        label.font = Theme.Fonts.caption
        label.textColor = Theme.Colors.textSecondary
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let resultValueLabel: UILabel = {
        let label = UILabel()
        label.text = "$ 0.00"
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textColor = Theme.Colors.primary
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let convertButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = Theme.Colors.primary
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        let image = UIImage(systemName: "arrow.triangle.2.circlepath", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.setTitle("  Convertir", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = Theme.Fonts.button

        return button
    }()
    
    private let balanceInfoLabel: UILabel = {
        let label = UILabel()
        label.text = "Saldo disponible: S/ 0.00"
        label.font = Theme.Fonts.caption
        label.textColor = Theme.Colors.textSecondary
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let viewModel: CurrencyConversionViewModel
    private var isFromPEN: Bool = true

    init(viewModel: CurrencyConversionViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Theme.Colors.background

        isFromPEN = !viewModel.isUsdToPen
        
        setupNavigation()
        setupUI()
        setupConstraints()
        setupActions()
        setupBindings()
        setupKeyboardDismiss()
        
        amountTextField.delegate = self
        
        viewModel.loadData()
    }
    
    private func setupNavigation() {
        navigationController?.navigationBar.isHidden = true
    }

    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(backButton)
        contentView.addSubview(headerLabel)
        
        contentView.addSubview(exchangeRateCard)
        exchangeRateCard.addSubview(rateIconImageView)
        exchangeRateCard.addSubview(rateTitleLabel)
        exchangeRateCard.addSubview(rateValueLabel)
        exchangeRateCard.addSubview(rateUpdateLabel)
        
        contentView.addSubview(fromSectionLabel)
        contentView.addSubview(fromDropdownButton)
        fromDropdownButton.addSubview(fromFlagLabel)
        fromDropdownButton.addSubview(fromCurrencyLabel)
        fromDropdownButton.addSubview(fromChevron)
        
        contentView.addSubview(amountSectionLabel)
        contentView.addSubview(amountContainer)
        amountContainer.addSubview(amountTextField)
        
        contentView.addSubview(toSectionLabel)
        contentView.addSubview(toDropdownButton)
        toDropdownButton.addSubview(toFlagLabel)
        toDropdownButton.addSubview(toCurrencyLabel)
        toDropdownButton.addSubview(toChevron)
        
        contentView.addSubview(resultPreviewContainer)
        resultPreviewContainer.addSubview(resultTitleLabel)
        resultPreviewContainer.addSubview(resultValueLabel)
        
        contentView.addSubview(balanceInfoLabel)
        
        contentView.addSubview(convertButton)
    }
    
    private func setupConstraints() {
        let padding = Theme.Layout.padding
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            backButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            backButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),
            
            headerLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            headerLabel.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 8),
            
            exchangeRateCard.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 24),
            exchangeRateCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            exchangeRateCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            
            rateIconImageView.topAnchor.constraint(equalTo: exchangeRateCard.topAnchor, constant: 16),
            rateIconImageView.leadingAnchor.constraint(equalTo: exchangeRateCard.leadingAnchor, constant: 16),
            rateIconImageView.widthAnchor.constraint(equalToConstant: 16),
            rateIconImageView.heightAnchor.constraint(equalToConstant: 16),
            
            rateTitleLabel.centerYAnchor.constraint(equalTo: rateIconImageView.centerYAnchor),
            rateTitleLabel.leadingAnchor.constraint(equalTo: rateIconImageView.trailingAnchor, constant: 8),
            
            rateValueLabel.topAnchor.constraint(equalTo: rateIconImageView.bottomAnchor, constant: 8),
            rateValueLabel.leadingAnchor.constraint(equalTo: exchangeRateCard.leadingAnchor, constant: 16),
            
            rateUpdateLabel.topAnchor.constraint(equalTo: rateValueLabel.bottomAnchor, constant: 4),
            rateUpdateLabel.leadingAnchor.constraint(equalTo: exchangeRateCard.leadingAnchor, constant: 16),
            rateUpdateLabel.bottomAnchor.constraint(equalTo: exchangeRateCard.bottomAnchor, constant: -16),
            
            fromSectionLabel.topAnchor.constraint(equalTo: exchangeRateCard.bottomAnchor, constant: 28),
            fromSectionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            
            fromDropdownButton.topAnchor.constraint(equalTo: fromSectionLabel.bottomAnchor, constant: 10),
            fromDropdownButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            fromDropdownButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            fromDropdownButton.heightAnchor.constraint(equalToConstant: 56),
            
            fromFlagLabel.centerYAnchor.constraint(equalTo: fromDropdownButton.centerYAnchor),
            fromFlagLabel.leadingAnchor.constraint(equalTo: fromDropdownButton.leadingAnchor, constant: 16),
            
            fromCurrencyLabel.centerYAnchor.constraint(equalTo: fromDropdownButton.centerYAnchor),
            fromCurrencyLabel.leadingAnchor.constraint(equalTo: fromFlagLabel.trailingAnchor, constant: 12),
            
            fromChevron.centerYAnchor.constraint(equalTo: fromDropdownButton.centerYAnchor),
            fromChevron.trailingAnchor.constraint(equalTo: fromDropdownButton.trailingAnchor, constant: -16),
            
            amountSectionLabel.topAnchor.constraint(equalTo: fromDropdownButton.bottomAnchor, constant: 24),
            amountSectionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            
            amountContainer.topAnchor.constraint(equalTo: amountSectionLabel.bottomAnchor, constant: 10),
            amountContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            amountContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            amountContainer.heightAnchor.constraint(equalToConstant: 56),
            
            amountTextField.centerYAnchor.constraint(equalTo: amountContainer.centerYAnchor),
            amountTextField.leadingAnchor.constraint(equalTo: amountContainer.leadingAnchor, constant: 16),
            amountTextField.trailingAnchor.constraint(equalTo: amountContainer.trailingAnchor, constant: -16),
            
            toSectionLabel.topAnchor.constraint(equalTo: amountContainer.bottomAnchor, constant: 24),
            toSectionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            
            toDropdownButton.topAnchor.constraint(equalTo: toSectionLabel.bottomAnchor, constant: 10),
            toDropdownButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            toDropdownButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            toDropdownButton.heightAnchor.constraint(equalToConstant: 56),
            
            toFlagLabel.centerYAnchor.constraint(equalTo: toDropdownButton.centerYAnchor),
            toFlagLabel.leadingAnchor.constraint(equalTo: toDropdownButton.leadingAnchor, constant: 16),
            
            toCurrencyLabel.centerYAnchor.constraint(equalTo: toDropdownButton.centerYAnchor),
            toCurrencyLabel.leadingAnchor.constraint(equalTo: toFlagLabel.trailingAnchor, constant: 12),
            
            toChevron.centerYAnchor.constraint(equalTo: toDropdownButton.centerYAnchor),
            toChevron.trailingAnchor.constraint(equalTo: toDropdownButton.trailingAnchor, constant: -16),
            
            resultPreviewContainer.topAnchor.constraint(equalTo: toDropdownButton.bottomAnchor, constant: 28),
            resultPreviewContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            resultPreviewContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            
            resultTitleLabel.topAnchor.constraint(equalTo: resultPreviewContainer.topAnchor, constant: 16),
            resultTitleLabel.centerXAnchor.constraint(equalTo: resultPreviewContainer.centerXAnchor),
            
            resultValueLabel.topAnchor.constraint(equalTo: resultTitleLabel.bottomAnchor, constant: 8),
            resultValueLabel.centerXAnchor.constraint(equalTo: resultPreviewContainer.centerXAnchor),
            resultValueLabel.bottomAnchor.constraint(equalTo: resultPreviewContainer.bottomAnchor, constant: -16),
            
            balanceInfoLabel.topAnchor.constraint(equalTo: resultPreviewContainer.bottomAnchor, constant: 12),
            balanceInfoLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            convertButton.topAnchor.constraint(equalTo: balanceInfoLabel.bottomAnchor, constant: 24),
            convertButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            convertButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            convertButton.heightAnchor.constraint(equalToConstant: 56),
            convertButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }
    
    private func setupActions() {
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        fromDropdownButton.addTarget(self, action: #selector(didTapFromDropdown), for: .touchUpInside)
        toDropdownButton.addTarget(self, action: #selector(didTapToDropdown), for: .touchUpInside)
        convertButton.addTarget(self, action: #selector(didTapConvert), for: .touchUpInside)
        amountTextField.addTarget(self, action: #selector(amountDidChange), for: .editingChanged)
    }
    
    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
    
    private func setupBindings() {
        viewModel.onStateChanged = { [weak self] in
            guard let self = self else { return }
            self.updateUI()
        }
        
        viewModel.onError = { [weak self] message in
            self?.showAlert(title: "Error", message: message)
        }
        
        viewModel.onSuccess = { [weak self] message in
            self?.showAlert(title: "✅ Éxito", message: message)
        }
    }
    
    private func setupKeyboardDismiss() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    private func updateUI() {
        if isFromPEN {
            if let rate = viewModel.penToUsdRate {
                rateValueLabel.text = "1 PEN = \(String(format: "%.4f", rate.rate)) USD"
            }
            fromFlagLabel.text = "🇵🇪"
            fromCurrencyLabel.text = "Soles (PEN)"
            toFlagLabel.text = "🇺🇸"
            toCurrencyLabel.text = "Dólares (USD)"
        } else {
            if let rate = viewModel.usdToPenRate {
                rateValueLabel.text = "1 USD = \(String(format: "%.4f", rate.rate)) PEN"
            }
            fromFlagLabel.text = "🇺🇸"
            fromCurrencyLabel.text = "Dólares (USD)"
            toFlagLabel.text = "🇵🇪"
            toCurrencyLabel.text = "Soles (PEN)"
        }
        
        let resultSymbol = isFromPEN ? "$" : "S/"
        let result = calculateResult()
        resultValueLabel.text = "\(resultSymbol) \(String(format: "%.2f", result))"
        
        let fromCurrency = isFromPEN ? "PEN" : "USD"
        let fromSymbol = isFromPEN ? "S/" : "$"
        if let wallet = viewModel.wallets.first(where: { $0.currency == fromCurrency }) {
            balanceInfoLabel.text = "Saldo disponible: \(fromSymbol) \(String(format: "%.2f", wallet.balance))"
            
            let amount = Double(amountTextField.text ?? "0") ?? 0
            if amount > wallet.balance {
                balanceInfoLabel.textColor = Theme.Colors.error
                convertButton.isEnabled = false
                convertButton.backgroundColor = Theme.Colors.textSecondary
            } else {
                balanceInfoLabel.textColor = Theme.Colors.textSecondary
                convertButton.isEnabled = !viewModel.isLoading
                convertButton.backgroundColor = Theme.Colors.primary
            }
        }
        
        if viewModel.isLoading {
            convertButton.setTitle("  Procesando...", for: .normal)
            convertButton.isEnabled = false
        } else {
            convertButton.setTitle("  Convertir", for: .normal)
        }
    }
    
    private func calculateResult() -> Double {
        let amount = Double(amountTextField.text ?? "0") ?? 0
        
        if isFromPEN {
            return amount * (viewModel.penToUsdRate?.rate ?? 0)
        } else {
            return amount * (viewModel.usdToPenRate?.rate ?? 0)
        }
    }
    
    @objc private func didTapFromDropdown() {
        showCurrencyPicker(isFrom: true)
    }
    
    @objc private func didTapToDropdown() {
        showCurrencyPicker(isFrom: false)
    }
    
    @objc private func didTapConvert() {
        let amount = Double(amountTextField.text ?? "0") ?? 0
        let fromCurrency = isFromPEN ? "PEN" : "USD"
        let toCurrency = isFromPEN ? "USD" : "PEN"
        let fromSymbol = isFromPEN ? "S/" : "$"
        let toSymbol = isFromPEN ? "$" : "S/"
        let result = calculateResult()
        
        let alert = UIAlertController(
            title: "Confirmar Conversión",
            message: "¿Convertir \(fromSymbol) \(String(format: "%.2f", amount)) \(fromCurrency) a \(toSymbol) \(String(format: "%.2f", result)) \(toCurrency)?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        alert.addAction(UIAlertAction(title: "Convertir", style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            self.viewModel.isUsdToPen = !self.isFromPEN
            self.viewModel.updateAmount(amount)
            self.viewModel.executeExchange()
        })
        
        present(alert, animated: true)
    }
    
    @objc private func amountDidChange() {
        updateUI()
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func showCurrencyPicker(isFrom: Bool) {
        let alert = UIAlertController(title: "Seleccionar Moneda", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "🇵🇪 Soles (PEN)", style: .default) { [weak self] _ in
            guard let self = self else { return }
            if isFrom {
                self.isFromPEN = true
            } else {
                self.isFromPEN = false
            }
            self.updateUI()
        })
        
        alert.addAction(UIAlertAction(title: "🇺🇸 Dólares (USD)", style: .default) { [weak self] _ in
            guard let self = self else { return }
            if isFrom {
                self.isFromPEN = false
            } else {
                self.isFromPEN = true
            }
            self.updateUI()
        })
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension CurrencyConversionViewController: UITextFieldDelegate {
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
