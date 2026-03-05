//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Воробьева Юлия on 13.01.2026.
//

import UIKit

final class StatisticsViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: StatisticsViewModel
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let placeholderView = PlaceholderView()
    
    // MARK: - Initialization
    init(viewModel: StatisticsViewModel = StatisticsViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("✅ StatisticsViewController: viewDidLoad")
        
        setupUI()
        setupBindings()
        viewModel.loadStatistics()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        title = LocalizableKeys.statisticsTitle
        view.backgroundColor = UIColor(resource: .ypWhite)
        
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes = [
            .font: AppTextStyles.bold34,
            .foregroundColor: UIColor(resource: .ypBlack)
        ]
        
        setupTableView()
        setupPlaceholderView()
    }
    
    private func setupTableView() {
        tableView.backgroundColor = UIColor(resource: .ypWhite)
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(StatisticCell.self, forCellReuseIdentifier: StatisticCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isHidden = true
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupPlaceholderView() {
        placeholderView.configure(
            image: UIImage(named: "emptyCry"),
            title: LocalizableKeys.statisticsEmptyPlaceholder,
            subtitle: nil
        )
        placeholderView.translatesAutoresizingMaskIntoConstraints = false
        placeholderView.isHidden = false
        
        view.addSubview(placeholderView)
        
        NSLayoutConstraint.activate([
            placeholderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeholderView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 16),
            placeholderView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    // MARK: - Bindings
    private func setupBindings() {
        viewModel.completedCountDidChange = { [weak self] _ in
            self?.tableView.reloadData()
        }
        
        viewModel.bestPeriodDidChange = { [weak self] _ in
            self?.tableView.reloadData()
        }
        
        viewModel.isEmptyStateDidChange = { [weak self] isEmpty in
            self?.tableView.isHidden = isEmpty
            self?.placeholderView.isHidden = !isEmpty
        }
    }
}

// MARK: - UITableViewDataSource
extension StatisticsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: StatisticCell.identifier,
            for: indexPath
        ) as? StatisticCell else {
            return UITableViewCell()
        }
        
        switch indexPath.row {
        case 0:
            cell.configure(with: viewModel.completedCount, type: .completed)
        case 1:
            cell.configure(with: viewModel.bestPeriod, type: .bestPeriod)
        default:
            break
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension StatisticsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 102
    }
}
