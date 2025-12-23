//
//  ProfileDetailViewController.swift
//  enone
//
//  Created by Asbel on 18/12/25.
//

import UIKit

final class ProfileDetailViewController: UIViewController {

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
        label.text = "Mi Información Personal"
        label.font = Theme.Fonts.title
        label.textColor = Theme.Colors.textPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let infoStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.distribution = .fill
        sv.spacing = 12
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = Theme.Colors.primary
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private let viewModel: ProfileViewModel

    init(viewModel: ProfileViewModel) {
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
        viewModel.loadProfile()
    }
}

private extension ProfileDetailViewController {
    
    func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(backButton)
        contentView.addSubview(titleLabel)
        contentView.addSubview(infoStack)
        contentView.addSubview(activityIndicator)
        
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
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Theme.Layout.padding),
            
            infoStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 32),
            infoStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.Layout.padding),
            infoStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Theme.Layout.padding),
            infoStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    func setupActions() {
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
    }
    
    func setupBindings() {
        viewModel.onLoadingChange = { [weak self] isLoading in
            DispatchQueue.main.async {
                if isLoading {
                    self?.activityIndicator.startAnimating()
                } else {
                    self?.activityIndicator.stopAnimating()
                }
            }
        }
        
        viewModel.onError = { [weak self] message in
            DispatchQueue.main.async {
                self?.showError(message)
            }
        }
        
        viewModel.onProfileLoaded = { [weak self] profile in
            DispatchQueue.main.async {
                self?.populateInfo(with: profile)
            }
        }
    }
    
    func populateInfo(with profile: Profile) {
        infoStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        infoStack.addArrangedSubview(createInfoCard(
            icon: "person.fill",
            title: "Nombre completo",
            value: profile.fullName ?? "No especificado"
        ))
        
        infoStack.addArrangedSubview(createInfoCard(
            icon: "phone.fill",
            title: "Celular",
            value: profile.phone ?? "No especificado"
        ))
        
        infoStack.addArrangedSubview(createInfoCard(
            icon: "envelope.fill",
            title: "Correo electrónico",
            value: profile.email ?? "No especificado"
        ))
        
        infoStack.addArrangedSubview(createInfoCard(
            icon: "person.crop.circle",
            title: "Género",
            value: viewModel.getFormattedGender()
        ))
    }
    
    func createInfoCard(icon: String, title: String, value: String) -> UIView {
        let container = UIView()
        container.backgroundColor = .white
        container.layer.cornerRadius = 16
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOffset = CGSize(width: 0, height: 2)
        container.layer.shadowRadius = 8
        container.layer.shadowOpacity = 0.08
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let iconContainer = UIView()
        iconContainer.backgroundColor = Theme.Colors.primary.withAlphaComponent(0.1)
        iconContainer.layer.cornerRadius = 12
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let iconView = UIImageView()
        iconView.image = UIImage(systemName: icon)
        iconView.tintColor = Theme.Colors.primary
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        iconContainer.addSubview(iconView)
        
        let textStack = UIStackView()
        textStack.axis = .vertical
        textStack.spacing = 4
        textStack.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = Theme.Fonts.caption
        titleLabel.textColor = Theme.Colors.textSecondary
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = Theme.Fonts.bodyMedium
        valueLabel.textColor = Theme.Colors.textPrimary
        valueLabel.numberOfLines = 0
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        textStack.addArrangedSubview(titleLabel)
        textStack.addArrangedSubview(valueLabel)
        
        container.addSubview(iconContainer)
        container.addSubview(textStack)
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(greaterThanOrEqualToConstant: 72),
            
            iconContainer.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            iconContainer.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 44),
            iconContainer.heightAnchor.constraint(equalToConstant: 44),
            
            iconView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24),
            
            textStack.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 16),
            textStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            textStack.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            textStack.topAnchor.constraint(greaterThanOrEqualTo: container.topAnchor, constant: 16),
            textStack.bottomAnchor.constraint(lessThanOrEqualTo: container.bottomAnchor, constant: -16)
        ])
        
        return container
    }
    
    @objc func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
    
    func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
