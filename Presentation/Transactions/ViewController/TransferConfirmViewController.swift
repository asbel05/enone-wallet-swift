//
//  TransferConfirmViewController.swift
//  enone
//
//  Created by Asbel on 18/12/25.
//

import UIKit

final class TransferConfirmViewController: UIViewController {

    private let viewModel: TransactionsViewModel

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
        label.text = "Confirmar Operación"
        label.font = Theme.Fonts.title
        label.textColor = Theme.Colors.textPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let mainCard: UIView = {
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
    
    private let amountTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Monto a enviar"
        label.font = Theme.Fonts.caption
        label.textColor = Theme.Colors.textSecondary
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        label.textColor = Theme.Colors.primary
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let divider: UIView = {
        let view = UIView()
        view.backgroundColor = Theme.Colors.divider
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let detailsStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 16
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let verificationContainer: UIView = {
        let view = UIView()
        view.backgroundColor = Theme.Colors.surface
        view.layer.cornerRadius = 12
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let verificationLabel: UILabel = {
        let label = UILabel()
        label.text = "Código de verificación"
        label.font = Theme.Fonts.bodyMedium
        label.textColor = Theme.Colors.textPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let verificationInfoLabel: UILabel = {
        let label = UILabel()
        label.text = "Te enviamos un código a tu email"
        label.font = Theme.Fonts.caption
        label.textColor = Theme.Colors.textSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let codeTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "_ _ _ _ _ _"
        tf.font = UIFont.monospacedSystemFont(ofSize: 24, weight: .medium)
        tf.textColor = Theme.Colors.textPrimary
        tf.backgroundColor = .white
        tf.layer.cornerRadius = Theme.Layout.cornerRadius
        tf.keyboardType = .numberPad
        tf.textAlignment = .center
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private lazy var confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("✓ Confirmar Transferencia", for: .normal)
        button.titleLabel?.font = Theme.Fonts.button
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = Theme.Colors.primary
        button.layer.cornerRadius = Theme.Layout.cornerRadius
        button.addTarget(self, action: #selector(didTapConfirm), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("⊘ Volver", for: .normal)
        button.titleLabel?.font = Theme.Fonts.body
        button.setTitleColor(Theme.Colors.textSecondary, for: .normal)
        button.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
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
        
        setupUI()
        setupConstraints()
        setupBindings()
        populateData()
        
        codeTextField.delegate = self
    }
}

private extension TransferConfirmViewController {
    
    func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(backButton)
        contentView.addSubview(titleLabel)
        contentView.addSubview(mainCard)
        
        mainCard.addSubview(amountTitleLabel)
        mainCard.addSubview(amountLabel)
        mainCard.addSubview(divider)
        mainCard.addSubview(detailsStack)
        
        contentView.addSubview(verificationContainer)
        verificationContainer.addSubview(verificationLabel)
        verificationContainer.addSubview(verificationInfoLabel)
        verificationContainer.addSubview(codeTextField)
        
        contentView.addSubview(confirmButton)
        contentView.addSubview(cancelButton)
        confirmButton.addSubview(loadingIndicator)
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
            
            backButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            backButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),
            
            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 8),
            
            mainCard.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 24),
            mainCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            mainCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            
            amountTitleLabel.topAnchor.constraint(equalTo: mainCard.topAnchor, constant: 24),
            amountTitleLabel.centerXAnchor.constraint(equalTo: mainCard.centerXAnchor),
            
            amountLabel.topAnchor.constraint(equalTo: amountTitleLabel.bottomAnchor, constant: 8),
            amountLabel.centerXAnchor.constraint(equalTo: mainCard.centerXAnchor),
            
            divider.topAnchor.constraint(equalTo: amountLabel.bottomAnchor, constant: 24),
            divider.leadingAnchor.constraint(equalTo: mainCard.leadingAnchor, constant: 20),
            divider.trailingAnchor.constraint(equalTo: mainCard.trailingAnchor, constant: -20),
            divider.heightAnchor.constraint(equalToConstant: 1),
            
            detailsStack.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 20),
            detailsStack.leadingAnchor.constraint(equalTo: mainCard.leadingAnchor, constant: 20),
            detailsStack.trailingAnchor.constraint(equalTo: mainCard.trailingAnchor, constant: -20),
            detailsStack.bottomAnchor.constraint(equalTo: mainCard.bottomAnchor, constant: -24),
            
            verificationContainer.topAnchor.constraint(equalTo: mainCard.bottomAnchor, constant: 20),
            verificationContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            verificationContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            
            verificationLabel.topAnchor.constraint(equalTo: verificationContainer.topAnchor, constant: 16),
            verificationLabel.leadingAnchor.constraint(equalTo: verificationContainer.leadingAnchor, constant: 16),
            
            verificationInfoLabel.topAnchor.constraint(equalTo: verificationLabel.bottomAnchor, constant: 4),
            verificationInfoLabel.leadingAnchor.constraint(equalTo: verificationContainer.leadingAnchor, constant: 16),
            
            codeTextField.topAnchor.constraint(equalTo: verificationInfoLabel.bottomAnchor, constant: 12),
            codeTextField.leadingAnchor.constraint(equalTo: verificationContainer.leadingAnchor, constant: 16),
            codeTextField.trailingAnchor.constraint(equalTo: verificationContainer.trailingAnchor, constant: -16),
            codeTextField.heightAnchor.constraint(equalToConstant: Theme.Layout.inputHeight),
            codeTextField.bottomAnchor.constraint(equalTo: verificationContainer.bottomAnchor, constant: -16),
            
            confirmButton.topAnchor.constraint(equalTo: mainCard.bottomAnchor, constant: 32),
            confirmButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            confirmButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            confirmButton.heightAnchor.constraint(equalToConstant: Theme.Layout.buttonHeight),
            
            cancelButton.topAnchor.constraint(equalTo: confirmButton.bottomAnchor, constant: 16),
            cancelButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            cancelButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: confirmButton.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: confirmButton.centerYAnchor)
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
        
        viewModel.onTransferCompleted = { [weak self] result in
            DispatchQueue.main.async {
                self?.navigateToSuccess(result: result)
            }
        }
        
        viewModel.on2FARequired = { [weak self] in
            DispatchQueue.main.async {
                self?.show2FAInput()
            }
        }
    }
    
    func populateData() {
        guard let request = viewModel.pendingTransferRequest else { return }
        
        let symbol = request.currency == "PEN" ? "S/" : "$"
        amountLabel.text = "\(symbol) \(String(format: "%.2f", request.amount))"
        
        addDetailRow(icon: "person.fill", title: "Enviar a:", value: viewModel.destinationEmail ?? "")
        addDetailRow(icon: "wallet.pass.fill", title: "Desde:", value: "Wallet Principal (\(request.currency))")
        addDetailRow(icon: "tag.fill", title: "Comisión:", value: "Gratis", valueColor: Theme.Colors.success)
        
        if let description = request.description, !description.isEmpty {
            addDetailRow(icon: "doc.text.fill", title: "Descripción:", value: description)
        }
        
        if viewModel.pendingValidation?.requires2FA == true {
            show2FAInput()
        }
    }
    
    func addDetailRow(icon: String, title: String, value: String, valueColor: UIColor = Theme.Colors.textPrimary) {
        let row = UIView()
        row.translatesAutoresizingMaskIntoConstraints = false
        
        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = Theme.Colors.textSecondary
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = Theme.Fonts.caption
        titleLabel.textColor = Theme.Colors.textSecondary
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = Theme.Fonts.bodyMedium
        valueLabel.textColor = valueColor
        valueLabel.textAlignment = .right
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        row.addSubview(iconView)
        row.addSubview(titleLabel)
        row.addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            row.heightAnchor.constraint(equalToConstant: 24),
            
            iconView.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            iconView.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 16),
            iconView.heightAnchor.constraint(equalToConstant: 16),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 8),
            titleLabel.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            
            valueLabel.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            valueLabel.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            valueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 8)
        ])
        
        detailsStack.addArrangedSubview(row)
    }
    
    func setLoading(_ loading: Bool) {
        confirmButton.isEnabled = !loading
        if loading {
            confirmButton.setTitle("", for: .normal)
            loadingIndicator.startAnimating()
        } else {
            confirmButton.setTitle("✓ Confirmar Transferencia", for: .normal)
            loadingIndicator.stopAnimating()
        }
    }
    
    func show2FAInput() {
        verificationContainer.isHidden = false
        
        confirmButton.topAnchor.constraint(equalTo: verificationContainer.bottomAnchor, constant: 32).isActive = true
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
        codeTextField.becomeFirstResponder()
    }
    
    func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func navigateToSuccess(result: TransferResult) {
        let successVC = TransferSuccessViewController(
            result: result,
            destinationEmail: viewModel.destinationEmail ?? ""
        )
        successVC.modalPresentationStyle = .fullScreen
        present(successVC, animated: true) {
            self.navigationController?.popToRootViewController(animated: false)
        }
    }
}

private extension TransferConfirmViewController {
    
    @objc func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func didTapConfirm() {
        if !verificationContainer.isHidden {
            guard let code = codeTextField.text, code.isValid2FACode else {
                showError("Ingresa el código de 6 dígitos")
                return
            }
            viewModel.executeTransfer(verificationCode: code)
        } else {
            viewModel.executeTransfer()
        }
    }
}

extension TransferConfirmViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.isEmpty { return true }
        
        guard string.isOnlyDigits else { return false }
        
        let currentText = textField.text ?? ""
        let newLength = currentText.count + string.count - range.length
        return newLength <= 6
    }
}
