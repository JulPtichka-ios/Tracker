//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Воробьева Юлия on 13.01.2026.
//

import UIKit

class TrackerCategoryHeader: UICollectionReusableView {
    static let reuseIdentifier = "CategoryHeader"

    private let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        titleLabel.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        titleLabel.textColor = UIColor(named: "ypBlack") ?? .black
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }

    func configure(with title: String) {
        titleLabel.text = title
    }
}

class TrackersViewController: UIViewController {
    
    // MARK: - Properties
    private var categories: [TrackerCategory] = []
    private var filteredCategories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    
    private var currentDate: Date = Date()
    
    private let searchManager = SearchManager()
    
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
    private let placeholderView: UIView = {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        let starImage = UIImageView(image: UIImage(named: "errorStar"))
        starImage.tintColor = UIColor(named: "ypGray")
        starImage.contentMode = .scaleAspectFit
        starImage.widthAnchor.constraint(equalToConstant: 80).isActive = true
        starImage.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        let label = UILabel()
        label.attributedText = AppTextStyles.attributed(
            "Что будем отслеживать?",
            style: AppTextStyles.medium12,
            lineHeight: 12,
            color: UIColor(named: "ypBlack") ?? .systemGray
        )
        label.textAlignment = .center
        label.numberOfLines = 1
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        let textSize = label.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: 20))
        label.widthAnchor.constraint(greaterThanOrEqualToConstant: textSize.width).isActive = true
        
        stack.addArrangedSubview(starImage)
        stack.addArrangedSubview(label)
        
        containerView.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            stack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 110),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: containerView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -16)
        ])
        
        return containerView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("✅ TrackersViewController: viewDidLoad")
        
        searchManager.delegate = self
        setupTestData()
        print("📊 categories count: \(categories.count)")
        
        title = "Трекеры"
        view.backgroundColor = UIColor(named: "ypWhite") ?? .systemBackground
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes = [
            .font: AppTextStyles.bold34,
            .foregroundColor: UIColor(named: "ypBlack") ?? .label
        ]
        
        setupPlusButton()
        setupDatePicker()
        setupSearchController()
        setupCollectionView()
        updateUI()
    }

    private func setupTestData() {
        print("🧪 Creating test data...")
        
        let testTrackers: [Tracker] = [
            Tracker(
                id: UUID(),
                title: "Вода",
                color: "ColorSelection8",
                emoji: "💧",
                schedule: [.monday]
            ),
            Tracker(
                id: UUID(),
                title: "Спорт",
                color: "ColorSelection7",
                emoji: "🏃‍♂️",
                schedule: [.tuesday]
            ),
            Tracker(
                id: UUID(),
                title: "Медитация",
                color: "ColorSelection17",
                emoji: "🧘‍♀️",
                schedule: [.monday]
            )
        ]
        
        print("✅ Created \(testTrackers.count) trackers")
        
        let testCategory = TrackerCategory(
            title: "Полезные привычки",
            trackers: testTrackers
        )
        
        categories = [testCategory]
        filteredCategories = categories
        searchManager.updateCategories(categories)
        print("✅ categories = [\(testCategory.title)] with \(testTrackers.count) trackers")
    }

    // MARK: - Layout
    private static func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.5),
                heightDimension: .absolute(148)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(148)
            )
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                repeatingSubitem: item,
                count: 2
            )
            group.interItemSpacing = .fixed(8)
            
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 12

            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(30)
            )
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            section.boundarySupplementaryItems = [header]

            section.contentInsets = NSDirectionalEdgeInsets(
                top: 4,
                leading: 12,
                bottom: 16,
                trailing: 12
            )
            
            return section
        }
        return layout
    }
    
    // MARK: - Setup UI
    private func setupPlusButton() {
        let plusButton = UIButton(type: .system)
        plusButton.setImage(UIImage(named: "plus"), for: .normal)
        plusButton.tintColor = UIColor(named: "ypBlack")
        plusButton.addTarget(self, action: #selector(didTapAdd), for: .touchUpInside)
        
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        plusButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        plusButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: plusButton)
    }
    
    private func setupDatePicker() {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        datePicker.date = currentDate
        
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.widthAnchor.constraint(equalToConstant: 100).isActive = true
        datePicker.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }
    
    private func setupSearchController() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.automaticallyShowsCancelButton = false
        searchController.searchBar.placeholder = "Поиск"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    private func setupCollectionView() {
        collectionView.backgroundColor = UIColor(named: "ypWhite")
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.identifier)
        collectionView.register(TrackerCategoryHeader.self,
                              forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                              withReuseIdentifier: TrackerCategoryHeader.reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.contentInsetAdjustmentBehavior = .scrollableAxes
        
        view.addSubview(collectionView)
        view.addSubview(placeholderView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            placeholderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeholderView.widthAnchor.constraint(lessThanOrEqualToConstant: 200),
            placeholderView.heightAnchor.constraint(lessThanOrEqualToConstant: 200)
        ])
    }
    
    // MARK: - Actions
    @objc private func dateChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
        updateUI()
    }
    
    @objc private func didTapAdd() {
        let newHabitVC = NewHabitViewController()
        newHabitVC.onSave = { [weak self] tracker in
            self?.addTracker(tracker, to: "Полезные привычки")
        }
        
        let navController = UINavigationController(rootViewController: newHabitVC)
        navController.modalPresentationStyle = .pageSheet
        present(navController, animated: true)
    }

    // MARK: - Helpers
    private func updateUI() {
        let hasVisibleCategories = filteredCategories.contains { category in
            let weekday = Calendar.current.component(.weekday, from: currentDate)
            let visibleTrackersCount = category.trackers.filter {
                $0.schedule.contains(where: { $0.calendarWeekday == weekday })
            }.count
            return visibleTrackersCount > 0
        }
        
        print("📱 Has visible categories: \(hasVisibleCategories)")
        
        collectionView.isHidden = !hasVisibleCategories
        placeholderView.isHidden = hasVisibleCategories
        
        collectionView.reloadData()
    }
    
    private func getVisibleCategories() -> [TrackerCategory] {
        let weekday = Calendar.current.component(.weekday, from: currentDate)
        return filteredCategories.filter {
            $0.trackers.contains { tracker in
                tracker.schedule.contains { $0.calendarWeekday == weekday }
            }
        }
    }
    
    private func getTrackersForToday(in category: TrackerCategory) -> [Tracker] {
        let weekday = Calendar.current.component(.weekday, from: currentDate)
        return category.trackers.filter {
            $0.schedule.contains { $0.calendarWeekday == weekday }
        }
    }
      
    // MARK: - Data methods
    func addTracker(_ tracker: Tracker, to categoryTitle: String) {
        let updatedCategories = categories.map { category in
            if category.title == categoryTitle {
                return TrackerCategory(
                    title: category.title,
                    trackers: category.trackers + [tracker]
                )
            }
            return category
        }
        categories = updatedCategories
        filteredCategories = categories
        searchManager.updateCategories(categories)
        updateUI()
    }
    
    func completeTracker(_ trackerId: UUID, date: Date) {
        let record = TrackerRecord(trackerId: trackerId, date: date)
        completedTrackers.append(record)
    }
    
    func uncompleteTracker(trackerId: UUID, date: Date) {
        completedTrackers.removeAll { record in
            record.trackerId == trackerId && Calendar.current.isDate(record.date, inSameDayAs: date)
        }
    }
}

// MARK: - SearchManagerDelegate
extension TrackersViewController: SearchManagerDelegate {
    func didUpdateSearchResults(_ filteredCategories: [TrackerCategory]) {
        self.filteredCategories = filteredCategories
        updateUI()
    }
}

// MARK: - UISearchResultsUpdating
extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        searchManager.filterCategories(searchText: searchText)
    }
}

// MARK: - Date helpers
private extension TrackersViewController {
    func isFutureDate(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let selectedDay = calendar.startOfDay(for: date)
        return selectedDay > today
    }
}

// MARK: - UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return getVisibleCategories().count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                       numberOfItemsInSection section: Int) -> Int {
        let visibleCategories = getVisibleCategories()
        guard section < visibleCategories.count else { return 0 }
        
        let category = visibleCategories[section]
        let trackersForToday = getTrackersForToday(in: category)
        return trackersForToday.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCell.identifier,
            for: indexPath
        ) as? TrackerCell else {
            return UICollectionViewCell()
        }

        let visibleCategories = getVisibleCategories()
        guard indexPath.section < visibleCategories.count else {
            return cell
        }

        let category = visibleCategories[indexPath.section]
        let trackersForToday = getTrackersForToday(in: category)
        
        guard indexPath.item < trackersForToday.count else {
            return cell
        }

        let tracker = trackersForToday[indexPath.item]

        let isCompletedForSelectedDate = completedTrackers.contains {
            $0.trackerId == tracker.id &&
            Calendar.current.isDate($0.date, inSameDayAs: currentDate)
        }

        let totalCompletions = completedTrackers.filter {
            $0.trackerId == tracker.id
        }.count

        let isFuture = isFutureDate(currentDate)

        cell.configure(
            with: tracker,
            isCompleted: isCompletedForSelectedDate,
            isFutureDate: isFuture,
            completionCount: totalCompletions
        )

        if !isFuture {
            cell.completionHandler = { [weak self] isCompletedNew in
                guard let self else { return }

                if isCompletedNew {
                    self.completeTracker(tracker.id, date: self.currentDate)
                } else {
                    self.uncompleteTracker(
                        trackerId: tracker.id,
                        date: self.currentDate
                    )
                }

                collectionView.reloadItems(at: [indexPath])
            }
        } else {
            cell.completionHandler = nil
        }

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                      viewForSupplementaryElementOfKind kind: String,
                      at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: TrackerCategoryHeader.reuseIdentifier,
            for: indexPath
        ) as! TrackerCategoryHeader
        
        let visibleCategories = getVisibleCategories()
        guard indexPath.section < visibleCategories.count else {
            header.configure(with: "")
            return header
        }
        
        header.configure(with: visibleCategories[indexPath.section].title)
        return header
    }
}

// MARK: - UICollectionViewDelegate
extension TrackersViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return false
    }
}
