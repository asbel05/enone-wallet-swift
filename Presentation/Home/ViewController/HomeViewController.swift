//
//  HomeViewController.swift
//  enone
//
//  Created by Asbel on 18/12/25.
//

import UIKit

final class HomeViewController: UIViewController {

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
    
    private let headerTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Inicio"
        label.font = Theme.Fonts.title
        label.textColor = Theme.Colors.textPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let profileButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 32, weight: .medium)
        let image = UIImage(systemName: "person.circle.fill", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = Theme.Colors.primary
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var isShowingPEN: Bool = true
    private let walletCard = WalletCardView()
    
    private let quickActionsTitle: UILabel = {
        let label = UILabel()
        label.text = "Operaciones"
        label.font = Theme.Fonts.headline
        label.textColor = Theme.Colors.textPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let quickActionsScrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsHorizontalScrollIndicator = false
        sv.showsVerticalScrollIndicator = false
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    private let quickActionsStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fill
        sv.spacing = 16
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let walletsTitle: UILabel = {
        let label = UILabel()
        label.text = "Mis Cuentas"
        label.font = Theme.Fonts.headline
        label.textColor = Theme.Colors.textPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let walletsStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.distribution = .fill
        sv.spacing = 12
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let viewModel: HomeViewModel
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Theme.Colors.background
        
        isShowingPEN = viewModel.isShowingPEN
        
        setupUI()
        setupConstraints()
        setupActions()
        setupQuickActions()
        setupBindings()
        viewModel.loadData()
    }
}

private extension HomeViewController {
    
    func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(headerView)
        headerView.addSubview(headerTitleLabel)
        headerView.addSubview(profileButton)
        
        contentView.addSubview(walletCard)
        
        walletCard.onTap = { [weak self] in
            self?.didTapMainCard()
        }
        
        contentView.addSubview(quickActionsTitle)
        contentView.addSubview(quickActionsScrollView)
        quickActionsScrollView.addSubview(quickActionsStack)
        
        contentView.addSubview(walletsTitle)
        contentView.addSubview(walletsStack)
    }
    
    func setupConstraints() {
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
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.Layout.padding),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Theme.Layout.padding),
            headerView.heightAnchor.constraint(equalToConstant: 44),
            
            headerTitleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            headerTitleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            profileButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            profileButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            profileButton.widthAnchor.constraint(equalToConstant: 44),
            profileButton.heightAnchor.constraint(equalToConstant: 44),
            
            walletCard.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 24),
            walletCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.Layout.padding),
            walletCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Theme.Layout.padding),
            walletCard.heightAnchor.constraint(equalToConstant: 180),
            
            quickActionsTitle.topAnchor.constraint(equalTo: walletCard.bottomAnchor, constant: 32),
            quickActionsTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.Layout.padding),
            quickActionsScrollView.topAnchor.constraint(equalTo: quickActionsTitle.bottomAnchor, constant: 16),
            quickActionsScrollView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.Layout.padding),
            quickActionsScrollView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Theme.Layout.padding),
            quickActionsScrollView.heightAnchor.constraint(equalToConstant: 90),
            quickActionsStack.topAnchor.constraint(equalTo: quickActionsScrollView.topAnchor),
            quickActionsStack.leadingAnchor.constraint(equalTo: quickActionsScrollView.leadingAnchor),
            quickActionsStack.trailingAnchor.constraint(equalTo: quickActionsScrollView.trailingAnchor),
            quickActionsStack.bottomAnchor.constraint(equalTo: quickActionsScrollView.bottomAnchor),
            quickActionsStack.heightAnchor.constraint(equalTo: quickActionsScrollView.heightAnchor),
            
            walletsTitle.topAnchor.constraint(equalTo: quickActionsStack.bottomAnchor, constant: 32),
            walletsTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.Layout.padding),
            
            walletsStack.topAnchor.constraint(equalTo: walletsTitle.bottomAnchor, constant: 16),
            walletsStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.Layout.padding),
            walletsStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Theme.Layout.padding),
            walletsStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }
    
    func setupActions() {
        profileButton.addTarget(self, action: #selector(didTapProfile), for: .touchUpInside)
    }
    
    func setupQuickActions() {
        let actions: [(String, String, Selector)] = [
            ("Depositar", "plus", #selector(didTapDeposit)),
            ("Enviar", "paperplane", #selector(didTapTransfer)),
            ("Retirar", "arrow.down", #selector(didTapWithdraw)),
            ("Historial", "clock", #selector(didTapHistory)),
            ("Convertir", "arrow.triangle.2.circlepath", #selector(didTapCurrencyConversion))
        ]
        
        for (title, iconName, action) in actions {
            let container = createQuickActionButton(title: title, iconName: iconName, action: action)
            quickActionsStack.addArrangedSubview(container)
        }
    }
    
    func createQuickActionButton(title: String, iconName: String, action: Selector) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let iconContainer = UIView()
        iconContainer.backgroundColor = Theme.Colors.surface
        iconContainer.layer.cornerRadius = 24
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let iconView = UIImageView()
        iconView.image = UIImage(systemName: iconName)
        iconView.tintColor = Theme.Colors.primary
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        iconContainer.addSubview(iconView)
        
        let label = UILabel()
        label.text = title
        label.font = Theme.Fonts.small
        label.textColor = Theme.Colors.textSecondary
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(iconContainer)
        container.addSubview(label)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: action)
        container.addGestureRecognizer(tapGesture)
        container.isUserInteractionEnabled = true
        
        NSLayoutConstraint.activate([
            iconContainer.topAnchor.constraint(equalTo: container.topAnchor),
            iconContainer.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 48),
            iconContainer.heightAnchor.constraint(equalToConstant: 48),
            
            iconView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 22),
            iconView.heightAnchor.constraint(equalToConstant: 22),
            
            label.topAnchor.constraint(equalTo: iconContainer.bottomAnchor, constant: 8),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor)
            
        ])
        NSLayoutConstraint.activate([
            container.widthAnchor.constraint(equalToConstant: 80)
        ])
        return container
    }
    
    
    func setupBindings() {
        viewModel.onStateChanged = { [weak self] in
            guard let self = self else { return }
            
            let targetCurrency = self.isShowingPEN ? "PEN" : "USD"
            if let wallet = self.viewModel.wallets.first(where: { $0.currency == targetCurrency }) {
                self.walletCard.configure(
                    currency: wallet.currency,
                    balance: wallet.balance,
                    walletNumber: wallet.walletNumber,
                    animated: false
                )
            }
            
            self.walletsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
            
            for wallet in self.viewModel.wallets {
                let isPen = wallet.currency == "PEN"
                let currencySymbol = isPen ? "S/" : "$"
                let name = isPen ? "Cuenta Soles" : "Cuenta Dólares"
                
                let view = self.createWalletRow(
                    name: name,
                    balance: "\(currencySymbol) \(String(format: "%.2f", wallet.balance))",
                    walletNumber: wallet.walletNumber,
                    isPen: isPen
                )
                self.walletsStack.addArrangedSubview(view)
            }
            
        }
        
        viewModel.onError = { message in
            print("Error: \(message)")
        }
    }
    
    func createWalletRow(name: String, balance: String, walletNumber: String, isPen: Bool) -> UIView {
        let view = UIView()
        view.backgroundColor = Theme.Colors.surface
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let iconContainer = UIView()
        iconContainer.backgroundColor = isPen ? Theme.Colors.primary.withAlphaComponent(0.2) : UIColor.systemGreen.withAlphaComponent(0.2)
        iconContainer.layer.cornerRadius = 12
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let iconView = UIImageView()
        iconView.image = UIImage(systemName: "banknote")
        iconView.tintColor = isPen ? Theme.Colors.primary : .systemGreen
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        iconContainer.addSubview(iconView)
        
        let nameLabel = UILabel()
        nameLabel.text = name
        nameLabel.font = Theme.Fonts.bodyMedium
        nameLabel.textColor = Theme.Colors.textPrimary
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let numberLabel = UILabel()
        numberLabel.text = walletNumber
        numberLabel.font = Theme.Fonts.small
        numberLabel.textColor = Theme.Colors.textSecondary
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let balanceLabel = UILabel()
        balanceLabel.text = balance
        balanceLabel.font = Theme.Fonts.headline
        balanceLabel.textColor = Theme.Colors.textPrimary
        balanceLabel.textAlignment = .right
        balanceLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(iconContainer)
        view.addSubview(nameLabel)
        view.addSubview(numberLabel)
        view.addSubview(balanceLabel)
        
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 72),
            
            iconContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            iconContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 44),
            iconContainer.heightAnchor.constraint(equalToConstant: 44),
            
            iconView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 22),
            iconView.heightAnchor.constraint(equalToConstant: 22),
            
            nameLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 12),
            
            numberLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            numberLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            
            balanceLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            balanceLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
        return view
    }
    
    @objc func didTapProfile() {
        let profileViewModel = ProfileViewModel()
        let profileVC = ProfileViewController(viewModel: profileViewModel)
        navigationController?.pushViewController(profileVC, animated: true)
    }
    @objc func didTapCurrencyConversion() {
        let conversionVM = CurrencyConversionViewModel()
        
        let selectedCurrency = viewModel.getSelectedCurrency()
        conversionVM.isUsdToPen = (selectedCurrency == "USD")
        
        let vc = CurrencyConversionViewController(viewModel: conversionVM)
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc func didTapDeposit() {
        let depositVC = DepositViewController(currency: "PEN")
        navigationController?.pushViewController(depositVC, animated: true)
    }
    
    @objc func didTapTransfer() {
        let wallets = viewModel.wallets
        guard !wallets.isEmpty else {
            showError("Carga tus wallets primero")
            return
        }
        
        Task {
            guard let userId = await SessionManager.shared.currentUserId() else {
                showError("Sesión no encontrada")
                return
            }
            
            await MainActor.run {
                let transactionsVM = TransactionsViewModel()
                transactionsVM.currentUserId = userId
                
                let selectedCurrency = self.viewModel.getSelectedCurrency()
                
                if let walletPEN = wallets.first(where: { $0.currency == "PEN" }) {
                    transactionsVM.walletIdPEN = walletPEN.id
                    transactionsVM.balancePEN = walletPEN.balance
                }
                
                if let walletUSD = wallets.first(where: { $0.currency == "USD" }) {
                    transactionsVM.walletIdUSD = walletUSD.id
                    transactionsVM.balanceUSD = walletUSD.balance
                }
                
                if selectedCurrency == "USD", let walletUSD = wallets.first(where: { $0.currency == "USD" }) {
                    transactionsVM.currentWalletId = walletUSD.id
                    transactionsVM.currentWalletNumber = walletUSD.walletNumber
                    transactionsVM.currentCurrency = "USD"
                    transactionsVM.currentBalance = walletUSD.balance
                } else if let walletPEN = wallets.first(where: { $0.currency == "PEN" }) {
                    transactionsVM.currentWalletId = walletPEN.id
                    transactionsVM.currentWalletNumber = walletPEN.walletNumber
                    transactionsVM.currentCurrency = "PEN"
                    transactionsVM.currentBalance = walletPEN.balance
                }
                
                let transferVC = TransferViewController(viewModel: transactionsVM)
                navigationController?.pushViewController(transferVC, animated: true)
            }
        }
    }
    
    @objc func didTapWithdraw() {
        let withdrawVC = WithdrawViewController(currency: "PEN")
        navigationController?.pushViewController(withdrawVC, animated: true)
    }
    
    @objc func didTapHistory() {
        guard let mainWallet = viewModel.mainWallet else {
            showError("Carga tus wallets primero")
            return
        }
        
        Task {
            guard let userId = await SessionManager.shared.currentUserId() else {
                showError("Sesión no encontrada")
                return
            }
            
            await MainActor.run {
                let transactionsVM = TransactionsViewModel()
                transactionsVM.currentUserId = userId
                transactionsVM.currentWalletId = mainWallet.id
                transactionsVM.currentCurrency = mainWallet.currency
                transactionsVM.currentBalance = mainWallet.balance
                
                let historyVC = TransactionHistoryViewController(viewModel: transactionsVM)
                navigationController?.pushViewController(historyVC, animated: true)
            }
        }
    }
    
    private func showComingSoon(_ feature: String) {
        let alert = UIAlertController(
            title: "Próximamente",
            message: "\(feature) estará disponible pronto.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    func didTapMainCard() {
        viewModel.toggleCurrency()
        
        isShowingPEN = viewModel.isShowingPEN
        
        guard let wallet = viewModel.currentWallet else {
            return
        }
        
        walletCard.configure(
            currency: wallet.currency,
            balance: wallet.balance,
            walletNumber: wallet.walletNumber,
            animated: true
        )
    }
}
