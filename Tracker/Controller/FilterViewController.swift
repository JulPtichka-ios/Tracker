//
//  FilterViewController.swift
//  Tracker
//
//  Created by Воробьева Юлия on 04.03.2026.
//


import UIKit

protocol FilterViewControllerDelegate: AnyObject {
    func didSelectFilter(_ filter: FilterOption)
}

final class FilterViewController: UIViewController {
    
    // MARK: - Properties
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let filters = FilterOption.allCases
    private var selectedFilter: FilterOption
    
    weak var delegate: FilterViewControllerDelegate?
    
    // MARK: - Initialization
    init(selectedFilter: FilterOption) {
        self.selectedFilter = selectedFilter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = LocalizableKeys.filterTitle
        view.backgroundColor = UIColor(resource: .ypWhite)
        
        setupTableView()
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(resource: .ypWhite)
        appearance.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: UIColor(resource: .ypBlack)
        ]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor(resource: .ypWhite)
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.separatorColor = UIColor(resource: .ypGray).withAlphaComponent(0.3)
        tableView.rowHeight = 75
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "FilterCell")
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

// MARK: - UITableViewDataSource
extension FilterViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell", for: indexPath)
        let filter = filters[indexPath.row]
        
        cell.textLabel?.text = filter.title
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        cell.textLabel?.textColor = UIColor(resource: .ypBlack)
        cell.backgroundColor = UIColor(resource: .ypBackground)
        cell.selectionStyle = .none
        
        if !filter.isResetFilter && filter == selectedFilter {
            cell.accessoryType = .checkmark
            cell.tintColor = UIColor(resource: .ypBlue)
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension FilterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedFilter = filters[indexPath.row]
        
        AnalyticsService.shared.reportClick(screen: .filter, item: .filterOption)

        delegate?.didSelectFilter(selectedFilter)
        dismiss(animated: true)
    }
}
