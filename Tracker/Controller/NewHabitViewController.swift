//
// NewHabitViewController.swift
// Tracker
//
// Created by Воробьева Юлия on 14.01.2026.
//

import UIKit

final class NewHabitViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let titleTextField = UITextField()
    private let tabContainerView = UIView()
    private var scheduleTitleLabel: UILabel?
    private let errorLabel = UILabel()
    
    private let cancelButton = UIButton(type: .system)
    private let createButton = UIButton(type: .system)
    
    private var selectedCategory: String?
    private var categoryTitleLabel: UILabel?
    private var selectedSchedule: Set<WeekDay> = []
    
    var onSave: ((Tracker) -> Void)?
    
    // MARK: - Schedule text
    
    private var scheduleText: String {
        if selectedSchedule.count == WeekDay.allCases.count {
            return "Каждый день"
        } else if selectedSchedule.isEmpty {
            return "Расписание"
        } else {
            let order: [WeekDay] = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
            let sortedDays = order.compactMap { day in
                selectedSchedule.contains(day) ? day : nil
            }
            return sortedDays.map { $0.shortTitle }.joined(separator: ", ")
        }
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: UIColor(named: "ypBlack") ?? .black
        ]
        title = "Новая привычка"
        view.backgroundColor = UIColor(named: "ypWhite") ?? .white
        titleTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        selectedCategory = "Полезные привычки"
        updateCategoryButtonTitle()
        updateCreateButtonState()
        updateScheduleButtonTitle()
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        setupScrollView()
        setupContentView()
        setupTitleTextField()
        setupTabContainer()
        setupActionButtons()
    }
    
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.keyboardDismissMode = .onDrag
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor)
        ])
    }
    
    private func setupContentView() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = UIColor.clear
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 800)
        ])
    }
    
    private func setupTitleTextField() {
        titleTextField.placeholder = "Введите название трекера"
        titleTextField.font = UIFont.systemFont(ofSize: 17)
        titleTextField.borderStyle = .none
        titleTextField.layer.cornerRadius = 18
        titleTextField.clipsToBounds = true
        titleTextField.backgroundColor = UIColor(named: "ypBackground") ?? .systemGray6
        titleTextField.delegate = self
        
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 20))
        titleTextField.leftView = leftPaddingView
        titleTextField.leftViewMode = .always
        
        // RightView с крестиком
        let clearButton = UIButton(type: .custom)
        clearButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        clearButton.tintColor = .gray
        clearButton.imageView?.contentMode = .scaleAspectFit
        clearButton.contentHorizontalAlignment = .center
        clearButton.contentVerticalAlignment = .center
        clearButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        clearButton.addTarget(self, action: #selector(clearTextField), for: .touchUpInside)
        clearButton.isHidden = true
        clearButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 8)

        titleTextField.rightView = clearButton
        titleTextField.rightViewMode = .always
        
        // Error label
        errorLabel.text = "Ограничение 38 символов"
        errorLabel.font = UIFont.systemFont(ofSize: 17)
        errorLabel.textColor = .ypRed
        errorLabel.textAlignment = .center
        errorLabel.isHidden = true
        
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleTextField)
        contentView.addSubview(errorLabel)
        
        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 38),
            titleTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            titleTextField.heightAnchor.constraint(equalToConstant: 75),
            
            errorLabel.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 8),
            errorLabel.leadingAnchor.constraint(equalTo: titleTextField.leadingAnchor),
            errorLabel.trailingAnchor.constraint(equalTo: titleTextField.trailingAnchor),
            errorLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    // MARK: - Контейнер с кнопками
    
    private func setupTabContainer() {
        let containerBackground = UIView()
        containerBackground.backgroundColor = UIColor(named: "ypBackground") ?? .systemGray6
        containerBackground.layer.cornerRadius = 16
        containerBackground.layer.masksToBounds = true
        containerBackground.translatesAutoresizingMaskIntoConstraints = false

        let buttonStack = UIStackView()
        buttonStack.axis = .vertical
        buttonStack.spacing = 0
        buttonStack.distribution = .fillEqually
        buttonStack.translatesAutoresizingMaskIntoConstraints = false

        let categoryContainer = UIView()
        categoryContainer.backgroundColor = .clear
        categoryContainer.translatesAutoresizingMaskIntoConstraints = false
        let categoryTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapCategory))
        categoryContainer.addGestureRecognizer(categoryTapGesture)
        categoryContainer.isUserInteractionEnabled = true

        let categoryLabel = UILabel()
        categoryLabel.numberOfLines = 2
        categoryLabel.lineBreakMode = .byWordWrapping
        categoryLabel.text = "Категория"
        categoryTitleLabel = categoryLabel

        let categoryArrow = UIImageView(image: UIImage(systemName: "chevron.right")?.withRenderingMode(.alwaysTemplate))
        categoryArrow.tintColor = UIColor(named: "ypGray") ?? .systemGray
        categoryArrow.contentMode = .scaleAspectFit

        let categoryContentStack = UIStackView(arrangedSubviews: [categoryLabel, categoryArrow])
        categoryContentStack.axis = .horizontal
        categoryContentStack.spacing = 8
        categoryContentStack.alignment = .center
        categoryContentStack.distribution = .fill
        categoryContentStack.translatesAutoresizingMaskIntoConstraints = false

        categoryContainer.addSubview(categoryContentStack)

        categoryLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        categoryLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        categoryArrow.setContentCompressionResistancePriority(.required, for: .horizontal)

        let scheduleContainer = UIView()
        scheduleContainer.backgroundColor = .clear
        scheduleContainer.translatesAutoresizingMaskIntoConstraints = false
        let scheduleTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapSchedule))
        scheduleContainer.addGestureRecognizer(scheduleTapGesture)
        scheduleContainer.isUserInteractionEnabled = true

        let scheduleLabel = UILabel()
        scheduleLabel.numberOfLines = 2
        scheduleLabel.lineBreakMode = .byWordWrapping
        scheduleLabel.text = "Расписание"
        scheduleTitleLabel = scheduleLabel

        let scheduleArrow = UIImageView(image: UIImage(systemName: "chevron.right")?.withRenderingMode(.alwaysTemplate))
        scheduleArrow.tintColor = UIColor(named: "ypGray") ?? .systemGray
        scheduleArrow.contentMode = .scaleAspectFit

        let scheduleContentStack = UIStackView(arrangedSubviews: [scheduleLabel, scheduleArrow])
        scheduleContentStack.axis = .horizontal
        scheduleContentStack.spacing = 8
        scheduleContentStack.alignment = .center
        scheduleContentStack.distribution = .fill
        scheduleContentStack.translatesAutoresizingMaskIntoConstraints = false

        scheduleContainer.addSubview(scheduleContentStack)

        scheduleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        scheduleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        scheduleArrow.setContentCompressionResistancePriority(.required, for: .horizontal)

        let divider = UIView()
        divider.backgroundColor = UIColor(named: "ypBlack")?.withAlphaComponent(0.3)
        divider.translatesAutoresizingMaskIntoConstraints = false

        buttonStack.addArrangedSubview(categoryContainer)
        buttonStack.addArrangedSubview(scheduleContainer)

        buttonStack.setCustomSpacing(0.5, after: categoryContainer)

        containerBackground.addSubview(buttonStack)
        tabContainerView.addSubview(containerBackground)

        containerBackground.addSubview(divider)

        NSLayoutConstraint.activate([
            categoryContentStack.topAnchor.constraint(equalTo: categoryContainer.topAnchor, constant: 16),
            categoryContentStack.leadingAnchor.constraint(equalTo: categoryContainer.leadingAnchor, constant: 20),
            categoryContentStack.trailingAnchor.constraint(equalTo: categoryContainer.trailingAnchor, constant: -20),
            categoryContentStack.bottomAnchor.constraint(equalTo: categoryContainer.bottomAnchor, constant: -16),
            categoryArrow.widthAnchor.constraint(equalToConstant: 16),
            categoryArrow.heightAnchor.constraint(equalToConstant: 16),
            
            scheduleContentStack.topAnchor.constraint(equalTo: scheduleContainer.topAnchor, constant: 16),
            scheduleContentStack.leadingAnchor.constraint(equalTo: scheduleContainer.leadingAnchor, constant: 20),
            scheduleContentStack.trailingAnchor.constraint(equalTo: scheduleContainer.trailingAnchor, constant: -20),
            scheduleContentStack.bottomAnchor.constraint(equalTo: scheduleContainer.bottomAnchor, constant: -16),
            scheduleArrow.widthAnchor.constraint(equalToConstant: 16),
            scheduleArrow.heightAnchor.constraint(equalToConstant: 16),
            
            divider.leadingAnchor.constraint(equalTo: containerBackground.leadingAnchor, constant: 20),
            divider.trailingAnchor.constraint(equalTo: containerBackground.trailingAnchor, constant: -20),
            divider.centerYAnchor.constraint(equalTo: containerBackground.centerYAnchor),
            divider.heightAnchor.constraint(equalToConstant: 0.5),
            
            buttonStack.topAnchor.constraint(equalTo: containerBackground.topAnchor),
            buttonStack.leadingAnchor.constraint(equalTo: containerBackground.leadingAnchor),
            buttonStack.trailingAnchor.constraint(equalTo: containerBackground.trailingAnchor),
            buttonStack.bottomAnchor.constraint(equalTo: containerBackground.bottomAnchor),
            
            containerBackground.topAnchor.constraint(equalTo: tabContainerView.topAnchor),
            containerBackground.leadingAnchor.constraint(equalTo: tabContainerView.leadingAnchor),
            containerBackground.trailingAnchor.constraint(equalTo: tabContainerView.trailingAnchor),
            containerBackground.bottomAnchor.constraint(equalTo: tabContainerView.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            categoryContainer.heightAnchor.constraint(equalToConstant: 75),
            scheduleContainer.heightAnchor.constraint(equalToConstant: 75)
        ])

        tabContainerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(tabContainerView)

        NSLayoutConstraint.activate([
            tabContainerView.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 16),
            tabContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tabContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            tabContainerView.heightAnchor.constraint(equalToConstant: 150)
        ])

        updateCategoryButtonTitle()
        updateScheduleButtonTitle()
    }
    
    private func setupActionButtons() {
        var cancelConfig = UIButton.Configuration.plain()
        cancelConfig.title = "Отменить"
        cancelConfig.baseForegroundColor = UIColor(named: "ypRed") ?? .systemRed
        cancelConfig.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)

        cancelButton.configuration = cancelConfig
        cancelButton.backgroundColor = .clear
        cancelButton.layer.cornerRadius = 16
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = (UIColor(named: "ypRed") ?? .systemRed).cgColor
        cancelButton.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
        
        createButton.setTitle("Создать", for: .normal)
        createButton.setTitleColor(.white, for: .normal)
        createButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        createButton.backgroundColor = UIColor(named: "ypGray")
        createButton.layer.cornerRadius = 16
        createButton.isEnabled = false
        createButton.addTarget(self, action: #selector(didTapCreate), for: .touchUpInside)
        
        let buttonStack = UIStackView(arrangedSubviews: [cancelButton, createButton])
        buttonStack.axis = .horizontal
        buttonStack.spacing = 12
        buttonStack.distribution = .fillEqually
        
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonStack)
        
        NSLayoutConstraint.activate([
            buttonStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            buttonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonStack.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    // MARK: - Schedule button appearance
    private func updateScheduleButtonTitle() {
        guard let titleLabel = scheduleTitleLabel else { return }
        
        let fullText = scheduleText == "Расписание" || scheduleText.isEmpty ? "Расписание" : "Расписание\n\(scheduleText)"
        
        titleLabel.text = fullText
        titleLabel.numberOfLines = 2
        
        guard fullText.contains("\n"), let newlineIndex = fullText.firstIndex(of: "\n") else {
            titleLabel.font = UIFont.systemFont(ofSize: 17)
            titleLabel.textColor = UIColor(named: "ypBlack") ?? .black
            return
        }
        
        let lineBreakIndex = newlineIndex.utf16Offset(in: fullText)
        let secondaryLength = fullText.count - lineBreakIndex - 1
        
        let attrText = NSMutableAttributedString(string: fullText)
        attrText.addAttribute(.font, value: UIFont.systemFont(ofSize: 17),
                              range: NSRange(location: 0, length: lineBreakIndex))
        attrText.addAttribute(.foregroundColor, value: UIColor(named: "ypBlack") ?? .black,
                              range: NSRange(location: 0, length: lineBreakIndex))
        
        attrText.addAttribute(.font, value: UIFont.systemFont(ofSize: 13),
                              range: NSRange(location: lineBreakIndex + 1, length: secondaryLength))
        attrText.addAttribute(.foregroundColor, value: UIColor(named: "ypGray") ?? .systemGray,
                              range: NSRange(location: lineBreakIndex + 1, length: secondaryLength))
        
        titleLabel.attributedText = attrText
    }

    // MARK: - Actions
    
    @objc private func didTapCategory() {
        updateCategoryButtonTitle()
        print("TODO: экран категорий")
    }
    
    @objc private func didTapSchedule() {
        print("✅ Schedule button tapped!")
        let scheduleVC = ScheduleViewController()
        scheduleVC.selectedDays = Array(selectedSchedule)
        scheduleVC.onSave = { [weak self] days in
            guard let self = self else { return }
            self.selectedSchedule = Set(days)
            self.updateScheduleButtonTitle()
            self.updateCreateButtonState()
        }
        navigationController?.pushViewController(scheduleVC, animated: true)
    }
    
    @objc private func didTapCancel() {
        dismiss(animated: true)
    }
    
    @objc private func didTapCreate() {
        guard let title = titleTextField.text, !title.isEmpty, !selectedSchedule.isEmpty else { return }
        
        let tracker = Tracker(
            id: UUID(),
            title: title,
            color: "ColorSelection13",
            emoji: "📱",
            schedule: Array(selectedSchedule)
        )
        
        onSave?(tracker)
        dismiss(animated: true)
    }
    
    @objc private func textFieldDidChange() {
        let text = titleTextField.text ?? ""
        print("Text length: \(text.count)")
        print("RightView: \(String(describing: titleTextField.rightView))")
        
        titleTextField.rightView?.isHidden = text.isEmpty
        showError(text.count >= 38)
        updateCreateButtonState()
    }

    @objc private func clearTextField() {
        titleTextField.text = ""
        titleTextField.rightView?.isHidden = true
        showError(false)
        titleTextField.becomeFirstResponder()
    }

    private func showError(_ show: Bool) {
        errorLabel.isHidden = !show
        if show {
            let shake = CABasicAnimation(keyPath: "position")
            shake.duration = 0.1
            shake.repeatCount = 2
            shake.autoreverses = true
            shake.fromValue = NSValue(cgPoint: CGPoint(x: titleTextField.center.x - 5, y: titleTextField.center.y))
            shake.toValue = NSValue(cgPoint: CGPoint(x: titleTextField.center.x + 5, y: titleTextField.center.y))
            titleTextField.layer.add(shake, forKey: "shake")
        }
    }

    // MARK: - Validation
    
    private func updateCreateButtonState() {
        let isValid = !(titleTextField.text ?? "").isEmpty &&
                      !selectedSchedule.isEmpty &&
                      selectedCategory != nil && !selectedCategory!.isEmpty
        createButton.isEnabled = isValid
        createButton.backgroundColor = isValid ? UIColor(named: "ypBlack") : UIColor(named: "ypGray")
    }
    
    // MARK: - Category button appearance
    private func updateCategoryButtonTitle() {
        guard let titleLabel = categoryTitleLabel else { return }
        
        let fullText = selectedCategory == nil || selectedCategory?.isEmpty == true ? "Категория" : "Категория\n\(selectedCategory!)"
        
        titleLabel.text = fullText
        titleLabel.numberOfLines = 2
        
        guard fullText.contains("\n"), let newlineIndex = fullText.firstIndex(of: "\n") else {
            titleLabel.font = UIFont.systemFont(ofSize: 17)
            titleLabel.textColor = UIColor(named: "ypBlack") ?? .black
            return
        }
        
        let lineBreakIndex = newlineIndex.utf16Offset(in: fullText)
        let secondaryLength = fullText.count - lineBreakIndex - 1
        
        let attrText = NSMutableAttributedString(string: fullText)
        attrText.addAttribute(.font, value: UIFont.systemFont(ofSize: 17),
                              range: NSRange(location: 0, length: lineBreakIndex))
        attrText.addAttribute(.foregroundColor, value: UIColor(named: "ypBlack") ?? .black,
                              range: NSRange(location: 0, length: lineBreakIndex))
        
        attrText.addAttribute(.font, value: UIFont.systemFont(ofSize: 13),
                              range: NSRange(location: lineBreakIndex + 1, length: secondaryLength))
        attrText.addAttribute(.foregroundColor, value: UIColor(named: "ypGray") ?? .systemGray,
                              range: NSRange(location: lineBreakIndex + 1, length: secondaryLength))
        
        titleLabel.attributedText = attrText
    }
}

// MARK: - UITextFieldDelegate
extension NewHabitViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        showError(updatedText.count >= 38)
        updateCreateButtonState()
        
        return updatedText.count <= 38
    }
}
