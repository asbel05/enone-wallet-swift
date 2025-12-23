//
//   TransactionLimitsViewController.swift
//  enone
//
//  Created by Asbel on 18/12/25.
//

import UIKit

final class TransactionLimitsViewController: UIViewController {
    
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
        button.tintColor = Theme.Colors.primary
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Límites transaccionales"
        label.font = Theme.Fonts.title
        label.textColor = Theme.Colors.textPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Usage Card (única tarjeta)
    private let usageCard: UIView = {
        let view = UIView()
        view.backgroundColor = Theme.Colors.primary.withAlphaComponent(0.05)
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = Theme.Colors.primary.withAlphaComponent(0.2).cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0 // Oculto por defecto para evitar flash
        return view
    }()
    
    private let usageIconContainer: UIView = {
        let view = UIView()
        view.backgroundColor = Theme.Colors.primary.withAlphaComponent(0.15)
        view.layer.cornerRadius = 22
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let usageIcon: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "chart.line.uptrend.xyaxis")
        iv.tintColor = Theme.Colors.primary
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let usageTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Límite Diario"
        label.font = Theme.Fonts.bodyMedium
        label.textColor = Theme.Colors.textPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let usageSubtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Transacciones salientes"
        label.font = Theme.Fonts.small
        label.textColor = Theme.Colors.textSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let usageTopeLabel: UILabel = {
        let label = UILabel()
        label.text = "S/ 500.00"
        label.font = Theme.Fonts.headline
        label.textColor = Theme.Colors.primary
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let usageProgressView: UIProgressView = {
        let pv = UIProgressView(progressViewStyle: .default)
        pv.progressTintColor = Theme.Colors.primary
        pv.trackTintColor = Theme.Colors.primary.withAlphaComponent(0.2)
        pv.layer.cornerRadius = 4
        pv.clipsToBounds = true
        pv.translatesAutoresizingMaskIntoConstraints = false
        return pv
    }()
    
    private let usageAmountLabel: UILabel = {
        let label = UILabel()
        label.text = "Uso: S/ 0.00"
        label.font = Theme.Fonts.caption
        label.textColor = Theme.Colors.textSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let usagePercentLabel: UILabel = {
        let label = UILabel()
        label.text = "0%"
        label.font = Theme.Fonts.caption
        label.textColor = Theme.Colors.textSecondary
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let availableAmountLabel: UILabel = {
        let label = UILabel()
        label.text = "Disponible: S/ 500.00"
        label.font = Theme.Fonts.bodyMedium
        label.textColor = Theme.Colors.success
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let modifyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Modificar >", for: .normal)
        button.titleLabel?.font = Theme.Fonts.bodyMedium
        button.setTitleColor(Theme.Colors.primary, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.text = "ℹ️ El límite se reinicia diariamente a las 00:00"
        label.font = Theme.Fonts.caption
        label.textColor = Theme.Colors.textSecondary
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let viewModel: TransactionLimitsViewModel
    
    init(viewModel: TransactionLimitsViewModel = TransactionLimitsViewModel()) {
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
        viewModel.loadLimitInfo()
    }
}

private extension TransactionLimitsViewController {
    
    func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(backButton)
        contentView.addSubview(titleLabel)
        
        contentView.addSubview(usageCard)
        usageCard.addSubview(usageIconContainer)
        usageIconContainer.addSubview(usageIcon)
        usageCard.addSubview(usageTitleLabel)
        usageCard.addSubview(usageSubtitleLabel)
        usageCard.addSubview(usageTopeLabel)
        usageCard.addSubview(usageProgressView)
        usageCard.addSubview(usageAmountLabel)
        usageCard.addSubview(usagePercentLabel)
        usageCard.addSubview(availableAmountLabel)
        usageCard.addSubview(modifyButton)
        
        contentView.addSubview(infoLabel)
        
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
            
            usageCard.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            usageCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            usageCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            
            usageIconContainer.topAnchor.constraint(equalTo: usageCard.topAnchor, constant: 16),
            usageIconContainer.leadingAnchor.constraint(equalTo: usageCard.leadingAnchor, constant: 16),
            usageIconContainer.widthAnchor.constraint(equalToConstant: 44),
            usageIconContainer.heightAnchor.constraint(equalToConstant: 44),
            
            usageIcon.centerXAnchor.constraint(equalTo: usageIconContainer.centerXAnchor),
            usageIcon.centerYAnchor.constraint(equalTo: usageIconContainer.centerYAnchor),
            usageIcon.widthAnchor.constraint(equalToConstant: 22),
            usageIcon.heightAnchor.constraint(equalToConstant: 22),
            
            usageTitleLabel.topAnchor.constraint(equalTo: usageCard.topAnchor, constant: 16),
            usageTitleLabel.leadingAnchor.constraint(equalTo: usageIconContainer.trailingAnchor, constant: 12),
            
            usageSubtitleLabel.topAnchor.constraint(equalTo: usageTitleLabel.bottomAnchor, constant: 2),
            usageSubtitleLabel.leadingAnchor.constraint(equalTo: usageTitleLabel.leadingAnchor),
            
            usageTopeLabel.centerYAnchor.constraint(equalTo: usageIconContainer.centerYAnchor),
            usageTopeLabel.trailingAnchor.constraint(equalTo: usageCard.trailingAnchor, constant: -16),
            
            usageProgressView.topAnchor.constraint(equalTo: usageIconContainer.bottomAnchor, constant: 16),
            usageProgressView.leadingAnchor.constraint(equalTo: usageCard.leadingAnchor, constant: 16),
            usageProgressView.trailingAnchor.constraint(equalTo: usageCard.trailingAnchor, constant: -16),
            usageProgressView.heightAnchor.constraint(equalToConstant: 8),
            
            usageAmountLabel.topAnchor.constraint(equalTo: usageProgressView.bottomAnchor, constant: 8),
            usageAmountLabel.leadingAnchor.constraint(equalTo: usageCard.leadingAnchor, constant: 16),
            
            usagePercentLabel.topAnchor.constraint(equalTo: usageProgressView.bottomAnchor, constant: 8),
            usagePercentLabel.trailingAnchor.constraint(equalTo: usageCard.trailingAnchor, constant: -16),
            
            availableAmountLabel.topAnchor.constraint(equalTo: usageAmountLabel.bottomAnchor, constant: 16),
            availableAmountLabel.leadingAnchor.constraint(equalTo: usageCard.leadingAnchor, constant: 16),
            availableAmountLabel.bottomAnchor.constraint(equalTo: usageCard.bottomAnchor, constant: -16),
            
            modifyButton.centerYAnchor.constraint(equalTo: availableAmountLabel.centerYAnchor),
            modifyButton.trailingAnchor.constraint(equalTo: usageCard.trailingAnchor, constant: -16),
            
            infoLabel.topAnchor.constraint(equalTo: usageCard.bottomAnchor, constant: 24),
            infoLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            infoLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            infoLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }
    
    func setupActions() {
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        modifyButton.addTarget(self, action: #selector(didTapChangeLimit), for: .touchUpInside)
    }
    
    func setupBindings() {
        viewModel.onLimitInfoLoaded = { [weak self] info in
            self?.updateUI(with: info)
        }
        
        viewModel.onError = { [weak self] message in
            self?.showError(message)
        }
    }
    
    func updateUI(with info: TransactionLimitInfo) {
        let limit = info.limit
        let used = info.usedToday
        let available = max(0, limit - used)
        let percent = limit > 0 ? min((used / limit) * 100, 100) : 0
        let progress = limit > 0 ? min(Float(used / limit), 1.0) : 0
        let exceededAmount = max(0, used - limit)
        
        usageTopeLabel.text = info.formattedLimit
        usageProgressView.setProgress(progress, animated: true)
        usageAmountLabel.text = "Uso: S/ \(String(format: "%.2f", used))"
        usagePercentLabel.text = "\(String(format: "%.1f", percent))%"
        
        if exceededAmount > 0 {
            availableAmountLabel.text = "Excedido: S/ \(String(format: "%.2f", exceededAmount))"
            availableAmountLabel.textColor = .systemRed
            usageProgressView.progressTintColor = .systemRed
        } else if percent >= 80 {
            availableAmountLabel.text = "Disponible: S/ \(String(format: "%.2f", available))"
            usageProgressView.progressTintColor = .systemRed
            availableAmountLabel.textColor = .systemRed
        } else if percent >= 50 {
            availableAmountLabel.text = "Disponible: S/ \(String(format: "%.2f", available))"
            usageProgressView.progressTintColor = .systemOrange
            availableAmountLabel.textColor = .systemOrange
        } else {
            availableAmountLabel.text = "Disponible: S/ \(String(format: "%.2f", available))"
            usageProgressView.progressTintColor = Theme.Colors.primary
            availableAmountLabel.textColor = Theme.Colors.success
        }
        
        if let timeMessage = info.timeUntilCanChange {
            infoLabel.text = "⏱️ \(timeMessage)"
        } else {
            infoLabel.text = "Puedes modificar tu límite ahora"
        }
        
        UIView.animate(withDuration: 0.3) {
            self.usageCard.alpha = 1
        }
    }
    
    @objc func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func didTapChangeLimit() {
        guard let info = viewModel.currentLimitInfo else { return }
        
        let requestVC = RequestLimitChangeViewController(viewModel: viewModel, currentInfo: info)
        navigationController?.pushViewController(requestVC, animated: true)
    }
    
    func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
