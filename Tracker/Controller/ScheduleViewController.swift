//
// ScheduleViewController.swift
// Tracker
//
// Created by Воробьева Юлия on 14.01.2026.
//

import UIKit

final class ScheduleViewController: UIViewController {
    private let contentView = UIView()
    private let tableView = UITableView()
    private let doneButton = UIButton(type: .system)

    var selectedDays: [WeekDay] = []
    var onSave: (([WeekDay]) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Расписание"
        view.backgroundColor = UIColor(named: "ypWhite") ?? .white
        setupLayout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData() 
        updateDoneButtonState()
    }

    private func setupLayout() {
        contentView.backgroundColor = UIColor(named: "ypBackground") ?? .systemGray6
        contentView.layer.cornerRadius = 16
        contentView.translatesAutoresizingMaskIntoConstraints = false

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ScheduleCell.self, forCellReuseIdentifier: ScheduleCell.identifier)
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 70, bottom: 0, right: 20)
        tableView.backgroundColor = .clear
        tableView.isScrollEnabled = false
        tableView.translatesAutoresizingMaskIntoConstraints = false

        doneButton.setTitle("Готово", for: .normal)
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        doneButton.backgroundColor = UIColor(named: "ypGray")
        doneButton.layer.cornerRadius = 16
        doneButton.addTarget(self, action: #selector(didTapDone), for: .touchUpInside)
        doneButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(contentView)
        contentView.addSubview(tableView)
        view.addSubview(doneButton)

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            contentView.heightAnchor.constraint(equalToConstant: 390),

            tableView.topAnchor.constraint(equalTo: contentView.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    private func updateDoneButtonState() {
        let hasSelectedDays = !selectedDays.isEmpty
        doneButton.isEnabled = hasSelectedDays
        doneButton.backgroundColor = hasSelectedDays ? UIColor(named: "ypBlack") : UIColor(named: "ypGray")
    }

    @objc private func didTapDone() {
        onSave?(selectedDays)
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Cell

final class ScheduleCell: UITableViewCell {
    static let identifier = "ScheduleCell"

    let dayLabel = UILabel()
    let daySwitch = UISwitch()

    var onToggle: ((Bool) -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        dayLabel.font = UIFont.systemFont(ofSize: 17)
        dayLabel.textColor = UIColor(named: "ypBlack") ?? .label
        dayLabel.translatesAutoresizingMaskIntoConstraints = false

        daySwitch.onTintColor = UIColor(named: "ypBlue") ?? .systemBlue
        daySwitch.addTarget(self, action: #selector(switchToggled), for: .valueChanged)
        daySwitch.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(dayLabel)
        contentView.addSubview(daySwitch)

        NSLayoutConstraint.activate([
            dayLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            dayLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            daySwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            daySwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])

        selectionStyle = .none
        backgroundColor = .clear
    }

    @objc private func switchToggled() {
        onToggle?(daySwitch.isOn)
    }
}

// MARK: - UITableViewDataSource

extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        WeekDay.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleCell.identifier,
                                                       for: indexPath) as? ScheduleCell else {
            return UITableViewCell()
        }

        let day = WeekDay.allCases[indexPath.row]
        cell.dayLabel.text = day.title
        cell.daySwitch.isOn = selectedDays.contains(day)
        cell.onToggle = { [weak self] isOn in
            guard let self = self else { return }
            if isOn {
                if !self.selectedDays.contains(day) {
                    self.selectedDays.append(day)
                }
            } else {
                self.selectedDays.removeAll { $0 == day }
            }
            self.tableView.reloadData()
            self.updateDoneButtonState()
        }

        return cell
    }
}

// MARK: - UITableViewDelegate

extension ScheduleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        56
    }
}
