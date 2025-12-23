//
//  TransactionHistoryViewController.swift
//  enone
//
//  Created by Asbel on 18/12/25.
//

import UIKit

final class TransactionHistoryViewController: UIViewController {
    
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = Theme.Colors.textPrimary
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Historial"
        label.font = Theme.Fonts.title
        label.textColor = Theme.Colors.textPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let filterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "line.3.horizontal.decrease.circle"), for: .normal)
        button.tintColor = Theme.Colors.textSecondary
        button.translatesAutoresizingMaskIntoConstraints = false
        button.showsMenuAsPrimaryAction = true
        return button
    }()
    
    private var currentFilter: TransactionFilter = .all
    
    enum TransactionFilter {
        case all
        case sent
        case received
        case exchanges
    }
    
    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = Theme.Colors.background
        tv.separatorStyle = .none
        tv.showsVerticalScrollIndicator = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    private let emptyStateView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let emptyIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "clock.arrow.circlepath"))
        iv.tintColor = Theme.Colors.primary.withAlphaComponent(0.3)
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "Sin movimientos"
        label.font = Theme.Fonts.headline
        label.textColor = Theme.Colors.textSecondary
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emptySubLabel: UILabel = {
        let label = UILabel()
        label.text = "Tus transacciones aparecerán aquí"
        label.font = Theme.Fonts.body
        label.textColor = Theme.Colors.textSecondary.withAlphaComponent(0.7)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let refreshControl = UIRefreshControl()
    private let viewModel: TransactionsViewModel
    
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
        setupUI()
        setupTableView()
        setupActions()
        setupBindings()
        setupFilterMenu()
        viewModel.loadTransactions(refresh: true)
    }
    
    private func setupUI() {
        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.addSubview(filterButton)
        view.addSubview(tableView)
        view.addSubview(emptyStateView)
        emptyStateView.addSubview(emptyIcon)
        emptyStateView.addSubview(emptyLabel)
        emptyStateView.addSubview(emptySubLabel)
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Theme.Layout.padding),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),
            
            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 8),
            
            filterButton.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            filterButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Theme.Layout.padding),
            filterButton.widthAnchor.constraint(equalToConstant: 44),
            filterButton.heightAnchor.constraint(equalToConstant: 44),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            emptyIcon.topAnchor.constraint(equalTo: emptyStateView.topAnchor),
            emptyIcon.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyIcon.widthAnchor.constraint(equalToConstant: 80),
            emptyIcon.heightAnchor.constraint(equalToConstant: 80),
            
            emptyLabel.topAnchor.constraint(equalTo: emptyIcon.bottomAnchor, constant: 20),
            emptyLabel.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            
            emptySubLabel.topAnchor.constraint(equalTo: emptyLabel.bottomAnchor, constant: 8),
            emptySubLabel.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptySubLabel.bottomAnchor.constraint(equalTo: emptyStateView.bottomAnchor)
        ])
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TransactionCell.self, forCellReuseIdentifier: TransactionCell.identifier)
        tableView.refreshControl = refreshControl
        refreshControl.tintColor = Theme.Colors.primary
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
    }
    
    private func setupActions() {
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
    }
    
    private func setupBindings() {
        viewModel.onLoadingChange = { [weak self] isLoading in
            if !isLoading {
                self?.refreshControl.endRefreshing()
            }
        }
        
        viewModel.onTransactionsLoaded = { [weak self] transactions in
            self?.emptyStateView.isHidden = !transactions.isEmpty
            self?.tableView.isHidden = transactions.isEmpty
            self?.tableView.reloadData()
        }
        
        viewModel.onError = { [weak self] message in
            self?.showError(message)
        }
    }
    
    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func didPullToRefresh() {
        viewModel.loadTransactions(refresh: true)
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func setupFilterMenu() {
        let allAction = UIAction(title: "Todos", image: UIImage(systemName: "list.bullet")) { [weak self] _ in
            self?.currentFilter = .all
            self?.applyFilter()
            self?.updateFilterButtonAppearance()
        }
        
        let sentAction = UIAction(title: "Enviados", image: UIImage(systemName: "arrow.up.circle")) { [weak self] _ in
            self?.currentFilter = .sent
            self?.applyFilter()
            self?.updateFilterButtonAppearance()
        }
        
        let receivedAction = UIAction(title: "Recibidos", image: UIImage(systemName: "arrow.down.circle")) { [weak self] _ in
            self?.currentFilter = .received
            self?.applyFilter()
            self?.updateFilterButtonAppearance()
        }
        
        let exchangesAction = UIAction(title: "Conversiones", image: UIImage(systemName: "arrow.triangle.2.circlepath")) { [weak self] _ in
            self?.currentFilter = .exchanges
            self?.applyFilter()
            self?.updateFilterButtonAppearance()
        }
        
        filterButton.menu = UIMenu(title: "Filtrar por", children: [allAction, sentAction, receivedAction, exchangesAction])
    }
    
    private func applyFilter() {
        tableView.reloadData()
        
        let hasVisibleTransactions = filteredTransactions().count > 0
        emptyStateView.isHidden = hasVisibleTransactions
        tableView.isHidden = !hasVisibleTransactions
        
        if !hasVisibleTransactions {
            emptyLabel.text = "Sin resultados"
            emptySubLabel.text = "No hay transacciones con este filtro"
        } else {
            emptyLabel.text = "Sin movimientos"
            emptySubLabel.text = "Tus transacciones aparecerán aquí"
        }
    }
    
    private func updateFilterButtonAppearance() {
        let isFiltering = currentFilter != .all
        filterButton.tintColor = isFiltering ? Theme.Colors.primary : Theme.Colors.textSecondary
        let iconName = isFiltering ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle"
        filterButton.setImage(UIImage(systemName: iconName), for: .normal)
    }
    
    private func filteredTransactions() -> [Transaction] {
        switch currentFilter {
        case .all:
            return viewModel.transactions
        case .sent:
            return viewModel.transactions.filter { $0.type == .transferOut || $0.type == .withdrawal }
        case .received:
            return viewModel.transactions.filter { $0.type == .transferIn || $0.type == .deposit }
        case .exchanges:
            return viewModel.transactions.filter { $0.type == .convertOut || $0.type == .convertIn }
        }
    }
}

extension TransactionHistoryViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredTransactions().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TransactionCell.identifier, for: indexPath) as? TransactionCell else {
            return UITableViewCell()
        }
        
        let transactions = filteredTransactions()
        let transaction = transactions[indexPath.row]
        cell.configure(with: transaction)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height - 100 {
            viewModel.loadTransactions()
        }
    }
}
