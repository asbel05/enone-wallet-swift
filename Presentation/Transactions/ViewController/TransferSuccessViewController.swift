//
//  TransferSuccessViewController.swift
//  enone
//
//  Created by Asbel on 18/12/25.
//

import UIKit

final class TransferSuccessViewController: UIViewController {

    private let result: TransferResult
    private let destinationEmail: String

    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = Theme.Colors.primary
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let successIconView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        view.layer.cornerRadius = 40
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let successIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "arrow.up.circle.fill"))
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "¡EnOne enviado!"
        label.font = Theme.Fonts.title
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 42, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let detailsCard: UIView = {
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
    
    private let codeSection: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let codeTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "◐ CÓDIGO DE SEGURIDAD"
        label.font = Theme.Fonts.small
        label.textColor = Theme.Colors.textSecondary
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let codeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.monospacedSystemFont(ofSize: 32, weight: .bold)
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
    
    private let dataTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "DATOS DE LA TRANSACCIÓN"
        label.font = Theme.Fonts.small
        label.textColor = Theme.Colors.textSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let detailsStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 12
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Volver a mi wallet", for: .normal)
        button.titleLabel?.font = Theme.Fonts.button
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = Theme.Colors.primary
        button.layer.cornerRadius = Theme.Layout.cornerRadius
        button.addTarget(self, action: #selector(didTapDone), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Init
    
    init(result: TransferResult, destinationEmail: String) {
        self.result = result
        self.destinationEmail = destinationEmail
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Theme.Colors.background
        
        setupUI()
        setupConstraints()
        populateData()
        animateSuccess()
    }
}

private extension TransferSuccessViewController {
    
    func setupUI() {
        view.addSubview(headerView)
        headerView.addSubview(successIconView)
        successIconView.addSubview(successIcon)
        headerView.addSubview(titleLabel)
        headerView.addSubview(amountLabel)
        
        view.addSubview(detailsCard)
        detailsCard.addSubview(codeSection)
        codeSection.addSubview(codeTitleLabel)
        codeSection.addSubview(codeLabel)
        detailsCard.addSubview(divider)
        detailsCard.addSubview(dataTitleLabel)
        detailsCard.addSubview(detailsStack)
        
        view.addSubview(doneButton)
    }
    
    func setupConstraints() {
        let padding = Theme.Layout.padding
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 280),
            
            successIconView.topAnchor.constraint(equalTo: headerView.safeAreaLayoutGuide.topAnchor, constant: 20),
            successIconView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            successIconView.widthAnchor.constraint(equalToConstant: 80),
            successIconView.heightAnchor.constraint(equalToConstant: 80),
            
            successIcon.centerXAnchor.constraint(equalTo: successIconView.centerXAnchor),
            successIcon.centerYAnchor.constraint(equalTo: successIconView.centerYAnchor),
            successIcon.widthAnchor.constraint(equalToConstant: 50),
            successIcon.heightAnchor.constraint(equalToConstant: 50),
            
            titleLabel.topAnchor.constraint(equalTo: successIconView.bottomAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            
            amountLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            amountLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            
            detailsCard.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 24),
            detailsCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            detailsCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            
            codeSection.topAnchor.constraint(equalTo: detailsCard.topAnchor, constant: 24),
            codeSection.leadingAnchor.constraint(equalTo: detailsCard.leadingAnchor),
            codeSection.trailingAnchor.constraint(equalTo: detailsCard.trailingAnchor),
            
            codeTitleLabel.topAnchor.constraint(equalTo: codeSection.topAnchor),
            codeTitleLabel.centerXAnchor.constraint(equalTo: codeSection.centerXAnchor),
            
            codeLabel.topAnchor.constraint(equalTo: codeTitleLabel.bottomAnchor, constant: 8),
            codeLabel.centerXAnchor.constraint(equalTo: codeSection.centerXAnchor),
            codeLabel.bottomAnchor.constraint(equalTo: codeSection.bottomAnchor),
            
            divider.topAnchor.constraint(equalTo: codeSection.bottomAnchor, constant: 20),
            divider.leadingAnchor.constraint(equalTo: detailsCard.leadingAnchor, constant: 20),
            divider.trailingAnchor.constraint(equalTo: detailsCard.trailingAnchor, constant: -20),
            divider.heightAnchor.constraint(equalToConstant: 1),
            
            dataTitleLabel.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 20),
            dataTitleLabel.leadingAnchor.constraint(equalTo: detailsCard.leadingAnchor, constant: 20),
            
            detailsStack.topAnchor.constraint(equalTo: dataTitleLabel.bottomAnchor, constant: 16),
            detailsStack.leadingAnchor.constraint(equalTo: detailsCard.leadingAnchor, constant: 20),
            detailsStack.trailingAnchor.constraint(equalTo: detailsCard.trailingAnchor, constant: -20),
            detailsStack.bottomAnchor.constraint(equalTo: detailsCard.bottomAnchor, constant: -24),
            
            doneButton.topAnchor.constraint(equalTo: detailsCard.bottomAnchor, constant: 32),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            doneButton.heightAnchor.constraint(equalToConstant: Theme.Layout.buttonHeight)
        ])
    }
    
    func populateData() {
        let symbol = result.currency == "PEN" ? "S/" : "$"
        amountLabel.text = "-\(result.currency) \(String(format: "%.2f", result.amount))"
        
        codeLabel.text = result.securityCode
        
        addDetailRow(title: "Destino", value: destinationEmail, isLink: true)
        addDetailRow(title: "Nro. de operación", value: String(format: "%08d", result.transactionId))
        addDetailRow(title: "Fecha y Hora", value: formatDate(result.timestamp))
        
        if let description = result.description, !description.isEmpty {
            addDetailRow(title: "Descripción", value: description)
        } else {
            addDetailRow(title: "Descripción", value: "Transferencia")
        }
    }
    
    func addDetailRow(title: String, value: String, isLink: Bool = false) {
        let row = UIView()
        row.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = Theme.Fonts.caption
        titleLabel.textColor = Theme.Colors.textSecondary
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = Theme.Fonts.bodyMedium
        valueLabel.textColor = isLink ? Theme.Colors.primary : Theme.Colors.textPrimary
        valueLabel.textAlignment = .right
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        row.addSubview(titleLabel)
        row.addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            row.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            
            valueLabel.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            valueLabel.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            valueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 16)
        ])
        
        detailsStack.addArrangedSubview(row)
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d 'de' MMMM 'de' yyyy, hh:mm:ss a"
        formatter.locale = Locale(identifier: "es_PE")
        return formatter.string(from: date)
    }
    
    func animateSuccess() {
        successIconView.transform = CGAffineTransform(scaleX: 0, y: 0)
        successIconView.alpha = 0
        
        UIView.animate(withDuration: 0.5, delay: 0.2, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5) {
            self.successIconView.transform = .identity
            self.successIconView.alpha = 1
        }
    }
    
    @objc func didTapDone() {
        dismiss(animated: true)
    }
}
