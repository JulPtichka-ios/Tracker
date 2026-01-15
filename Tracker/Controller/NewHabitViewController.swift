//
//  NewHabitViewController.swift
//  Tracker
//
//  Created by Воробьева Юлия on 14.01.2026.
//

import UIKit

final class NewHabitViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let titleTextField = UITextField()
    private let categoryButton = UIButton(type: .system)
    private let scheduleButton = UIButton(type: .system)
    private let errorLabel = UILabel()
    
    private let cancelButton = UIButton(type: .system)
    private let createButton = UIButton(type: .system)
    
    private var selectedCategory: String?
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
        title = "Новая привычка"
        view.backgroundColor = UIColor(named: "ypWhite") ?? .white
        titleTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        updateCreateButtonState()
        updateScheduleButtonTitle()
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        setupScrollView()
        setupTitleTextField()
        setupCategoryButton()
        setupScheduleButton()
        setupActionButtons()
    }
    
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        ])
    }
    
    private func setupTitleTextField() {
        titleTextField.placeholder = "Введите название трекера"
        titleTextField.font = UIFont.systemFont(ofSize: 17)
        titleTextField.borderStyle = .roundedRect
        titleTextField.layer.cornerRadius = 16
        titleTextField.layer.borderWidth = 1
        titleTextField.layer.borderColor = UIColor(named: "ypGray")?.cgColor
        titleTextField.delegate = self
        
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

        titleTextField.rightView = clearButton
        titleTextField.rightViewMode = .always
        
        // Error label
        errorLabel.text = "Максимум 38 символов"
        errorLabel.font = UIFont.systemFont(ofSize: 13)
        errorLabel.textColor = .systemRed
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

    private func setupCategoryButton() {
        categoryButton.backgroundColor = UIColor(named: "ypGray")?.withAlphaComponent(0.3)
        categoryButton.layer.cornerRadius = 16
        categoryButton.addTarget(self, action: #selector(didTapCategory), for: .touchUpInside)
        
        let titleLabel = UILabel()
        titleLabel.text = "Категория"
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        titleLabel.textColor = UIColor(named: "ypBlack") ?? .black
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let arrowImageView = UIImageView(image: UIImage(named: "backButton")?.withRenderingMode(.alwaysTemplate))
        arrowImageView.tintColor = UIColor(named: "ypGray") ?? .systemGray
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, UIView(), arrowImageView])
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        categoryButton.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: categoryButton.topAnchor, constant: 22),
            stackView.leadingAnchor.constraint(equalTo: categoryButton.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: categoryButton.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: categoryButton.bottomAnchor, constant: -22),
            
            titleLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 100),
            
            arrowImageView.widthAnchor.constraint(equalToConstant: 24),
            arrowImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        categoryButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(categoryButton)

        NSLayoutConstraint.activate([
            categoryButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 24),
            categoryButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            categoryButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            categoryButton.heightAnchor.constraint(equalToConstant: 80)
        ])
    }

    private func setupScheduleButton() {
        scheduleButton.backgroundColor = UIColor(named: "ypGray")?.withAlphaComponent(0.3)
        scheduleButton.layer.cornerRadius = 16
        scheduleButton.addTarget(self, action: #selector(didTapSchedule), for: .touchUpInside)
        
        let titleLabel = UILabel()
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.preferredMaxLayoutWidth = 280
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let arrowImageView = UIImageView(image: UIImage(named: "backButton")?.withRenderingMode(.alwaysTemplate))
        arrowImageView.tintColor = UIColor(named: "ypGray") ?? .systemGray
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, UIView(), arrowImageView])
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        scheduleButton.addSubview(stackView)
        stackView.isUserInteractionEnabled = false
        
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        let spacer = stackView.arrangedSubviews[1] as? UIView
        spacer?.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        spacer?.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scheduleButton.topAnchor, constant: 22),
            stackView.leadingAnchor.constraint(equalTo: scheduleButton.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: scheduleButton.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: scheduleButton.bottomAnchor, constant: -22),
            
            titleLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 200),
            titleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),
            
            arrowImageView.widthAnchor.constraint(equalToConstant: 24),
            arrowImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        scheduleButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(scheduleButton)

        NSLayoutConstraint.activate([
            scheduleButton.topAnchor.constraint(equalTo: categoryButton.bottomAnchor, constant: 24),
            scheduleButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            scheduleButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            scheduleButton.heightAnchor.constraint(equalToConstant: 80)
        ])
        
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
        contentView.addSubview(buttonStack)
        
        NSLayoutConstraint.activate([
            buttonStack.topAnchor.constraint(equalTo: scheduleButton.bottomAnchor, constant: 48),
            buttonStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            buttonStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            buttonStack.heightAnchor.constraint(equalToConstant: 60),
            buttonStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -38)
        ])
    }
    
    // MARK: - Schedule button appearance
    private func updateScheduleButtonTitle() {
        guard let stackView = scheduleButton.subviews.first(where: { $0 is UIStackView }) as? UIStackView,
              let titleLabel = stackView.arrangedSubviews.first as? UILabel else { return }
        
        let fullText = scheduleText == "Расписание" || scheduleText.isEmpty ? "Расписание" : "Расписание\n\(scheduleText)"
        
        titleLabel.text = fullText
        titleLabel.numberOfLines = 2
        
        guard fullText.contains("\n"), let newlineIndex = fullText.firstIndex(of: "\n") else {
            titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
            titleLabel.textColor = UIColor(named: "ypBlack") ?? .black
            return
        }
        
        let lineBreakIndex = newlineIndex.utf16Offset(in: fullText)
        let secondaryLength = fullText.count - lineBreakIndex - 1
        
        let attrText = NSMutableAttributedString(string: fullText)
        attrText.addAttribute(.font, value: UIFont.systemFont(ofSize: 17, weight: .medium),
                             range: NSRange(location: 0, length: lineBreakIndex))
        attrText.addAttribute(.foregroundColor, value: UIColor(named: "ypBlack") ?? .black,
                             range: NSRange(location: 0, length: lineBreakIndex))
        
        attrText.addAttribute(.font, value: UIFont.systemFont(ofSize: 13, weight: .medium),
                             range: NSRange(location: lineBreakIndex + 1, length: secondaryLength))
        attrText.addAttribute(.foregroundColor, value: UIColor(named: "ypGray") ?? .systemGray,
                             range: NSRange(location: lineBreakIndex + 1, length: secondaryLength))
        
        titleLabel.attributedText = attrText
    }


    // MARK: - Actions
    
    @objc private func didTapCategory() {
        // TODO: экран категорий
        print("TODO: экран категорий")
    }
    
    @objc private func didTapSchedule() {
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
        // shake анимация для textField
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
        let isValid = !(titleTextField.text ?? "").isEmpty && !selectedSchedule.isEmpty
        createButton.isEnabled = isValid
        createButton.backgroundColor = isValid ? UIColor(named: "ypBlack") : UIColor(named: "ypGray")
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
