//
//  TransferViewController.swift
//  enone
//
//  Created by Asbel on 18/12/25.
//

import UIKit

final class TransferViewController: UIViewController {

    private let viewModel: TransactionsViewModel
    private var selectedCurrency: String = "PEN"

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
    
    private let headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        button.setImage(UIImage(systemName: "chevron.left", withConfiguration: config), for: .normal)
        button.tintColor = Theme.Colors.textPrimary
        button.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Enviar Dinero"
        label.font = Theme.Fonts.title
        label.textColor = Theme.Colors.textPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Email Field
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.text = "Email del destinatario"
        label.font = Theme.Fonts.caption
        label.textColor = Theme.Colors.textSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "usuario@email.com"
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
    
    private let currencyLabel: UILabel = {
        let label = UILabel()
        label.text = "Moneda"
        label.font = Theme.Fonts.caption
        label.textColor = Theme.Colors.textSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let currencySegment: UISegmentedControl = {
        let items = ["Soles (PEN)", "Dólares (USD)"]
        let segment = UISegmentedControl(items: items)
        segment.selectedSegmentIndex = 0
        segment.backgroundColor = Theme.Colors.surface
        segment.selectedSegmentTintColor = Theme.Colors.primary
        segment.setTitleTextAttributes([.foregroundColor: Theme.Colors.textSecondary], for: .normal)
        segment.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        segment.translatesAutoresizingMaskIntoConstraints = false
        return segment
    }()
    
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.text = "Monto a enviar"
        label.font = Theme.Fonts.caption
        label.textColor = Theme.Colors.textSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let amountContainer: UIView = {
        let view = UIView()
        view.backgroundColor = Theme.Colors.surface
        view.layer.cornerRadius = Theme.Layout.cornerRadius
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let currencySymbolLabel: UILabel = {
        let label = UILabel()
        label.text = "S/"
        label.font = Theme.Fonts.headline
        label.textColor = Theme.Colors.textSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let amountTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "0.00"
        tf.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        tf.textColor = Theme.Colors.textPrimary
        tf.keyboardType = .decimalPad
        tf.textAlignment = .right
        tf.backgroundColor = .clear
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let balanceLabel: UILabel = {
        let label = UILabel()
        label.text = "Saldo disponible: S/ 0.00"
        label.font = Theme.Fonts.small
        label.textColor = Theme.Colors.textSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Description Field
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Descripción (opcional)"
        label.font = Theme.Fonts.caption
        label.textColor = Theme.Colors.textSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Pago de..."
        tf.font = Theme.Fonts.body
        tf.textColor = Theme.Colors.textPrimary
        tf.backgroundColor = Theme.Colors.surface
        tf.layer.cornerRadius = Theme.Layout.cornerRadius
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        tf.leftViewMode = .always
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private lazy var continueButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Continuar a Confirmación", for: .normal)
        button.titleLabel?.font = Theme.Fonts.button
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = Theme.Colors.primary
        button.layer.cornerRadius = Theme.Layout.cornerRadius
        button.addTarget(self, action: #selector(didTapContinue), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    init(viewModel: TransactionsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Theme.Colors.background
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        selectedCurrency = viewModel.currentCurrency
        
        setupUI()
        setupConstraints()
        setupBindings()
        
        currencySegment.selectedSegmentIndex = (selectedCurrency == "USD") ? 1 : 0
        
        updateUIForCurrency()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
}

private extension TransferViewController {
    
    func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(headerView)
        headerView.addSubview(backButton)
        headerView.addSubview(titleLabel)
        
        contentView.addSubview(emailLabel)
        contentView.addSubview(emailTextField)
        
        contentView.addSubview(currencyLabel)
        contentView.addSubview(currencySegment)
        
        contentView.addSubview(amountLabel)
        contentView.addSubview(amountContainer)
        amountContainer.addSubview(currencySymbolLabel)
        amountContainer.addSubview(amountTextField)
        contentView.addSubview(balanceLabel)
        
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(descriptionTextField)
        
        contentView.addSubview(continueButton)
        continueButton.addSubview(loadingIndicator)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        currencySegment.addTarget(self, action: #selector(currencyChanged), for: .valueChanged)
    }
    
    func setupConstraints() {
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

            headerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            headerView.heightAnchor.constraint(equalToConstant: 44),
            
            backButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            backButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),
            
            titleLabel.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 8),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            emailLabel.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 32),
            emailLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            
            emailTextField.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 8),
            emailTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            emailTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            emailTextField.heightAnchor.constraint(equalToConstant: Theme.Layout.inputHeight),

            currencyLabel.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 24),
            currencyLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            
            currencySegment.topAnchor.constraint(equalTo: currencyLabel.bottomAnchor, constant: 8),
            currencySegment.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            currencySegment.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            currencySegment.heightAnchor.constraint(equalToConstant: 44),

            amountLabel.topAnchor.constraint(equalTo: currencySegment.bottomAnchor, constant: 24),
            amountLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            
            amountContainer.topAnchor.constraint(equalTo: amountLabel.bottomAnchor, constant: 8),
            amountContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            amountContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            amountContainer.heightAnchor.constraint(equalToConstant: Theme.Layout.inputHeight),
            
            currencySymbolLabel.leadingAnchor.constraint(equalTo: amountContainer.leadingAnchor, constant: 16),
            currencySymbolLabel.centerYAnchor.constraint(equalTo: amountContainer.centerYAnchor),
            
            amountTextField.leadingAnchor.constraint(equalTo: currencySymbolLabel.trailingAnchor, constant: 8),
            amountTextField.trailingAnchor.constraint(equalTo: amountContainer.trailingAnchor, constant: -16),
            amountTextField.centerYAnchor.constraint(equalTo: amountContainer.centerYAnchor),
            
            balanceLabel.topAnchor.constraint(equalTo: amountContainer.bottomAnchor, constant: 8),
            balanceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),

            descriptionLabel.topAnchor.constraint(equalTo: balanceLabel.bottomAnchor, constant: 24),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            
            descriptionTextField.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
            descriptionTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            descriptionTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            descriptionTextField.heightAnchor.constraint(equalToConstant: Theme.Layout.inputHeight),

            continueButton.topAnchor.constraint(equalTo: descriptionTextField.bottomAnchor, constant: 40),
            continueButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            continueButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            continueButton.heightAnchor.constraint(equalToConstant: Theme.Layout.buttonHeight),
            continueButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: continueButton.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: continueButton.centerYAnchor)
        ])
    }
    
    func setupBindings() {
        viewModel.onLoadingChange = { [weak self] isLoading in
            DispatchQueue.main.async {
                self?.setLoading(isLoading)
            }
        }
        
        viewModel.onError = { [weak self] message in
            DispatchQueue.main.async {
                self?.showError(message)
            }
        }
        
        viewModel.onTransferValidated = { [weak self] validation in
            DispatchQueue.main.async {
                self?.navigateToConfirmation(validation: validation)
            }
        }
    }
    
    func updateUIForCurrency() {
        let isPEN = selectedCurrency == "PEN"
        currencySymbolLabel.text = isPEN ? "S/" : "$"
        
        let balance = getBalanceForCurrency(selectedCurrency)
        let symbol = isPEN ? "S/" : "$"
        balanceLabel.text = "Saldo disponible: \(symbol) \(String(format: "%.2f", balance))"
    }
    
    func getBalanceForCurrency(_ currency: String) -> Double {
        if currency == "PEN" {
            return viewModel.balancePEN
        } else if currency == "USD" {
            return viewModel.balanceUSD
        }
        return 0
    }
}

private extension TransferViewController {
    
    @objc func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func currencyChanged() {
        selectedCurrency = currencySegment.selectedSegmentIndex == 0 ? "PEN" : "USD"
        updateUIForCurrency()
    }
    
    @objc func didTapContinue() {
        guard let email = emailTextField.text, !email.isEmpty else {
            showError("Ingresa el email del destinatario")
            return
        }
        
        guard email.isValidEmail else {
            showError("Ingresa un email válido")
            return
        }
        
        guard let amountText = amountTextField.text,
              let amount = Double(amountText.replacingOccurrences(of: ",", with: ".")),
              amount > 0 else {
            showError("Ingresa un monto válido")
            return
        }
        
        let balance = getBalanceForCurrency(selectedCurrency)
        guard amount <= balance else {
            showError("Saldo insuficiente")
            return
        }
 
        viewModel.currentCurrency = selectedCurrency
        viewModel.destinationEmail = email

        viewModel.validateTransferByEmail(
            destinationEmail: email,
            amount: amount,
            currency: selectedCurrency,
            description: descriptionTextField.text
        )
    }
    
    func setLoading(_ loading: Bool) {
        continueButton.isEnabled = !loading
        if loading {
            continueButton.setTitle("", for: .normal)
            loadingIndicator.startAnimating()
        } else {
            continueButton.setTitle("Continuar a Confirmación", for: .normal)
            loadingIndicator.stopAnimating()
        }
    }
    
    func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func navigateToConfirmation(validation: TransferValidation) {
        let confirmVC = TransferConfirmViewController(viewModel: viewModel)
        navigationController?.pushViewController(confirmVC, animated: true)
    }
}
