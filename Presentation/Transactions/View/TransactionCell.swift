//
//  TransactionCell.swift
//  enone
//
//  Created by Asbel on 21/12/25.
//

import UIKit

final class TransactionCell: UITableViewCell {
    
    static let identifier = "TransactionCell"

    private let iconView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 22
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = Theme.Colors.textPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = Theme.Colors.textSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let currencyLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = Theme.Colors.textSecondary
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = Theme.Colors.background
        selectionStyle = .none
        
        contentView.addSubview(iconView)
        iconView.addSubview(iconImageView)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(amountLabel)
        contentView.addSubview(currencyLabel)
        
        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.Layout.padding),
            iconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 44),
            iconView.heightAnchor.constraint(equalToConstant: 44),
            
            iconImageView.centerXAnchor.constraint(equalTo: iconView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 20),
            iconImageView.heightAnchor.constraint(equalToConstant: 20),
            
            descriptionLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 14),
            descriptionLabel.trailingAnchor.constraint(lessThanOrEqualTo: amountLabel.leadingAnchor, constant: -12),
            
            dateLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 14),
            
            amountLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            amountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Theme.Layout.padding),
            
            currencyLabel.topAnchor.constraint(equalTo: amountLabel.bottomAnchor, constant: 2),
            currencyLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Theme.Layout.padding)
        ])
    }

    func configure(with transaction: Transaction) {
        descriptionLabel.text = transaction.shortDescription
        dateLabel.text = transaction.formattedDate
        
        let isIncoming = transaction.type.isIncoming
        let sign = isIncoming ? "+" : "-"
        amountLabel.text = "\(sign) \(String(format: "%.2f", abs(transaction.amount)))"
        currencyLabel.text = transaction.currency
        
        amountLabel.textColor = isIncoming ? Theme.Colors.success : Theme.Colors.textPrimary
        
        iconView.backgroundColor = isIncoming
            ? Theme.Colors.success.withAlphaComponent(0.12)
            : Theme.Colors.primary.withAlphaComponent(0.12)
        
        iconImageView.image = UIImage(systemName: isIncoming ? "arrow.down.left" : "arrow.up.right")
        iconImageView.tintColor = isIncoming ? Theme.Colors.success : Theme.Colors.primary
    }
}
