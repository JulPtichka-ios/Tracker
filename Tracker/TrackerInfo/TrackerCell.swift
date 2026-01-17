//
//  TrackerCell.swift
//  Tracker
//
//  Created by Воробьева Юлия on 14.01.2026.
//

import UIKit

final class TrackerCell: UICollectionViewCell {
    static let identifier = "TrackerCell"

    var completionHandler: ((Bool) -> Void)?

    private let topContainer = UIView()
    private let bottomContainer = UIView()

    private let emojiLabel = UILabel()
    private let emojiBackgroundView = UIView()
    private let titleLabel = UILabel()
    private let counterLabel = UILabel()
    private let completeButton = UIButton(type: .custom)

    private var tracker: Tracker?
    private var isCompleted = false
    private var completionCount = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = false
    }

    // MARK: - Public

    func configure(
        with tracker: Tracker,
        isCompleted: Bool,
        isFutureDate: Bool,
        completionCount: Int
    ) {
        self.tracker = tracker
        self.isCompleted = isCompleted
        self.completionCount = completionCount

        let color = UIColor(named: tracker.color) ?? .systemBlue
        topContainer.backgroundColor = color

        emojiLabel.text = tracker.emoji

        titleLabel.text = tracker.title

        let word = daysText(for: completionCount)
        counterLabel.text = "\(completionCount) \(word)"

        updateButtonAppearance()

        completeButton.isEnabled = !isFutureDate
        contentView.alpha = isFutureDate ? 0.5 : 1.0
    }

    // MARK: - Private

    private func setupUI() {
        contentView.backgroundColor = .clear

        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = false
        contentView.layer.shadowColor = nil
        contentView.layer.shadowOpacity = 0
        contentView.layer.shadowRadius = 0
        contentView.layer.shadowOffset = .zero

        topContainer.layer.cornerRadius = 16
        topContainer.layer.maskedCorners = [
            .layerMinXMinYCorner,
            .layerMaxXMinYCorner,
            .layerMinXMaxYCorner,
            .layerMaxXMaxYCorner
        ]
        topContainer.clipsToBounds = true

        bottomContainer.backgroundColor = .white
        bottomContainer.layer.cornerRadius = 16
        bottomContainer.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        bottomContainer.clipsToBounds = true

        // Настройка лейбла с эмодзи
        emojiLabel.font = UIFont.systemFont(ofSize: 32, weight: .medium)
        emojiLabel.textColor = UIColor(named: "ypBlack") ?? .black
        emojiLabel.textAlignment = .left
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false

        // Настройка подложки под эмодзи
        emojiBackgroundView.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        emojiBackgroundView.layer.cornerRadius = 22
        emojiBackgroundView.clipsToBounds = true
        emojiBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        emojiBackgroundView.addSubview(emojiLabel)

        NSLayoutConstraint.activate([
            // Размер самой подложки
            emojiBackgroundView.widthAnchor.constraint(equalToConstant: 44),
            emojiBackgroundView.heightAnchor.constraint(equalToConstant: 44),

            // Позиционирование эмодзи внутри подложки
            emojiLabel.centerXAnchor.constraint(equalTo: emojiBackgroundView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiBackgroundView.centerYAnchor)
        ])

        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        counterLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        counterLabel.textColor = UIColor(named: "ypBlack") ?? .label
        counterLabel.textAlignment = .left
        counterLabel.translatesAutoresizingMaskIntoConstraints = false

        completeButton.backgroundColor = UIColor(named: tracker?.color ?? "ypGreen") ?? .systemGreen
        completeButton.layer.cornerRadius = 17
        completeButton.layer.borderWidth = 0
        completeButton.tintColor = UIColor(named: "ypWhite") ?? .white
        completeButton.translatesAutoresizingMaskIntoConstraints = false
        completeButton.widthAnchor.constraint(equalToConstant: 34).isActive = true
        completeButton.heightAnchor.constraint(equalToConstant: 34).isActive = true
        completeButton.addTarget(self, action: #selector(didTapComplete), for: .touchUpInside)

        // Верхний стек: подложка с эмодзи + заголовок
        let topStack = UIStackView(arrangedSubviews: [emojiBackgroundView, titleLabel])
        topStack.axis = .vertical
        topStack.spacing = 8
        topStack.alignment = .leading
        topStack.layoutMargins = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        topStack.isLayoutMarginsRelativeArrangement = true
        topStack.translatesAutoresizingMaskIntoConstraints = false

        topContainer.addSubview(topStack)

        // Нижний стек: счётчик + кнопка
        let bottomStack = UIStackView(arrangedSubviews: [counterLabel, completeButton])
        bottomStack.axis = .horizontal
        bottomStack.alignment = .center
        bottomStack.distribution = .fill
        bottomStack.spacing = 8
        bottomStack.layoutMargins = UIEdgeInsets(top: 8, left: 12, bottom: 12, right: 12)
        bottomStack.isLayoutMarginsRelativeArrangement = true
        bottomStack.translatesAutoresizingMaskIntoConstraints = false

        bottomContainer.addSubview(bottomStack)

        // Главный стек
        let mainStack = UIStackView(arrangedSubviews: [topContainer, bottomContainer])
        mainStack.axis = .vertical
        mainStack.spacing = 0
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            topStack.topAnchor.constraint(equalTo: topContainer.topAnchor),
            topStack.leadingAnchor.constraint(equalTo: topContainer.leadingAnchor),
            topStack.trailingAnchor.constraint(equalTo: topContainer.trailingAnchor),
            topStack.bottomAnchor.constraint(equalTo: topContainer.bottomAnchor),

            bottomStack.topAnchor.constraint(equalTo: bottomContainer.topAnchor),
            bottomStack.leadingAnchor.constraint(equalTo: bottomContainer.leadingAnchor),
            bottomStack.trailingAnchor.constraint(equalTo: bottomContainer.trailingAnchor),
            bottomStack.bottomAnchor.constraint(equalTo: bottomContainer.bottomAnchor),
        ])
    }

    private func updateButtonAppearance() {
        let imageName = isCompleted ? "checkmark" : "plus"
        completeButton.setImage(UIImage(systemName: imageName), for: .normal)

        if let colorName = tracker?.color {
            let buttonColor = UIColor(named: colorName) ?? .systemGreen

            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) {
                self.completeButton.backgroundColor = self.isCompleted
                    ? buttonColor.withAlphaComponent(0.4)
                    : buttonColor
            }
        }
    }

    private func daysText(for count: Int) -> String {
        let lastTwo = count % 100
        let last = count % 10

        if lastTwo >= 11 && lastTwo <= 14 {
            return "дней"
        }

        switch last {
        case 1:
            return "день"
        case 2, 3, 4:
            return "дня"
        default:
            return "дней"
        }
    }

    @objc
    private func didTapComplete() {
        guard tracker != nil else { return }
        isCompleted.toggle()
        updateButtonAppearance()
        completionHandler?(isCompleted)
    }
}
