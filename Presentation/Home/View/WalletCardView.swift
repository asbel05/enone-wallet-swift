//
//  WalletCardView.swift
//  enone
//
//  Created by Asbel on 21/12/25.
//

import UIKit

final class WalletCardView: UIView {

    var onTap: (() -> Void)?
    
    private(set) var isShowingPEN: Bool = true

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Saldo Total Soles"
        label.font = Theme.Fonts.caption
        label.textColor = UIColor.white.withAlphaComponent(0.8)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let swapIndicator: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "arrow.left.arrow.right.circle.fill")
        iv.tintColor = UIColor.white.withAlphaComponent(0.6)
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let tapHintLabel: UILabel = {
        let label = UILabel()
        label.text = "Toca para cambiar"
        label.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        label.textColor = UIColor.white.withAlphaComponent(0.5)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let balanceLabel: UILabel = {
        let label = UILabel()
        label.text = "S/ 0.00"
        label.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let walletNumberLabel: UILabel = {
        let label = UILabel()
        label.text = "**** **** **** ****"
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor.white.withAlphaComponent(0.7)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = Theme.Colors.primary
        layer.cornerRadius = 20
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(titleLabel)
        addSubview(swapIndicator)
        addSubview(tapHintLabel)
        addSubview(balanceLabel)
        addSubview(walletNumberLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            
            swapIndicator.topAnchor.constraint(equalTo: topAnchor, constant: 24),
            swapIndicator.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            swapIndicator.widthAnchor.constraint(equalToConstant: 24),
            swapIndicator.heightAnchor.constraint(equalToConstant: 24),
            
            tapHintLabel.topAnchor.constraint(equalTo: swapIndicator.bottomAnchor, constant: 4),
            tapHintLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            balanceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            balanceLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            
            walletNumberLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24),
            walletNumberLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24)
        ])
    }
    
    private func setupGesture() {
        isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
    }

    @objc private func handleTap() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        onTap?()
    }

    func configure(currency: String, balance: Double, walletNumber: String, animated: Bool = false) {
        let isPEN = currency == "PEN"
        isShowingPEN = isPEN
        
        let symbol = isPEN ? "S/" : "$"
        let title = isPEN ? "Saldo Total Soles" : "Saldo Total Dólares"
        let cardColor = isPEN ? Theme.Colors.primary : Theme.Colors.usdGreen
        
        if animated {
            UIView.transition(with: self, duration: 0.5, options: [.transitionFlipFromRight, .curveEaseInOut]) {
                self.titleLabel.text = title
                self.balanceLabel.text = "\(symbol) \(String(format: "%.2f", balance))"
                self.walletNumberLabel.text = walletNumber
                self.backgroundColor = cardColor
            } completion: { _ in
                UIView.animate(withDuration: 0.2) {
                    self.swapIndicator.transform = self.swapIndicator.transform.rotated(by: .pi)
                }
            }
        } else {
            titleLabel.text = title
            balanceLabel.text = "\(symbol) \(String(format: "%.2f", balance))"
            walletNumberLabel.text = walletNumber
            backgroundColor = cardColor
        }
    }
}
