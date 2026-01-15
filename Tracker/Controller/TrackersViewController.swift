//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Воробьева Юлия on 13.01.2026.
//

import UIKit

class TrackersViewController: UIViewController {
    
    // MARK: - Properties
    private var categories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    
    private var selectedDate: Date = Date()
    
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
    private let placeholderView: UIView = {
        // Твой код заглушки с emptyCry
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
            color: UIColor(named: "ypGray") ?? .systemGray
        )
        label.textAlignment = .center
        label.numberOfLines = 0
        
        stack.addArrangedSubview(starImage)
        stack.addArrangedSubview(label)
        return stack
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("✅ TrackersViewController: viewDidLoad")
        
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
                schedule: [.monday, .wednesday, .friday]
            ),
            Tracker(
                id: UUID(),
                title: "Спорт",
                color: "ColorSelection7",
                emoji: "🏃‍♂️",
                schedule: [.tuesday, .thursday, .saturday]
            ),
            Tracker(
                id: UUID(),
                title: "Медитация",
                color: "ColorSelection17",
                emoji: "🧘‍♀️",
                schedule: WeekDay.allCases
            )
        ]
        
        print("✅ Created \(testTrackers.count) trackers")
        
        let testCategory = TrackerCategory(
            id: UUID(),
            title: "Полезные привычки",
            trackers: testTrackers
        )
        
        categories = [testCategory]
        print("✅ categories = [\(testCategory.title)] with \(testTrackers.count) trackers")
    }


    
    // MARK: - Layout
    private static func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { _, _ in
            
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
            
            section.contentInsets = NSDirectionalEdgeInsets(
                top: 200,
                leading: 12,
                bottom: 16,
                trailing: 12
            )
            
            return section
        }
        return layout
    }

    
    // MARK: - Setup UI
    private func setupNavigationBar() {
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
    }
    
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
        datePicker.date = selectedDate
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }
    
    private func setupCollectionView() {
        collectionView.backgroundColor = UIColor(named: "ypWhite")
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.contentInsetAdjustmentBehavior = .never
        
        view.addSubview(collectionView)
         view.addSubview(placeholderView)
         
         NSLayoutConstraint.activate([
             collectionView.topAnchor.constraint(equalTo: view.topAnchor),
             collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
             collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
             collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
             
             placeholderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
             placeholderView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
             placeholderView.widthAnchor.constraint(lessThanOrEqualToConstant: 120),
             placeholderView.heightAnchor.constraint(lessThanOrEqualToConstant: 120)
         ])
     }
    
    // MARK: - Actions
    @objc private func dateChanged(_ sender: UIDatePicker) {
        selectedDate = sender.date
        if selectedDate > Date() {
            selectedDate = Date()
            sender.date = selectedDate
        }
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
        let trackers = getVisibleTrackers()
        print("📱 Showing \(trackers.count) trackers")
        
        collectionView.isHidden = trackers.isEmpty
        placeholderView.isHidden = !trackers.isEmpty
        collectionView.reloadData()
    }
    
    private func getVisibleTrackers() -> [Tracker] {
        print("🔍 DEBUG getVisibleTrackers()")
        print("📁 categories: \(categories.count)")
        
        let allTrackers = categories.flatMap { category -> [Tracker] in
            print("📂 Category '\(category.title)': \(category.trackers.count) trackers")
            return category.trackers
        }
        
        print("✅ TOTAL trackers: \(allTrackers.count)")
        return allTrackers
    }
    
    // MARK: - Data methods
    func addTracker(_ tracker: Tracker, to categoryTitle: String) {
        let updatedCategories = categories.map { category in
            if category.title == categoryTitle {
                return TrackerCategory(
                    id: category.id,
                    title: category.title,
                    trackers: category.trackers + [tracker]
                )
            }
            return category
        }
        categories = updatedCategories
        updateUI()
    }
    
    func completeTracker(_ trackerId: UUID, date: Date) {
        let record = TrackerRecord(id: UUID(), trackerId: trackerId, date: date)
        completedTrackers.append(record)
    }
    
    func uncompleteTracker(trackerId: UUID, date: Date) {
        completedTrackers.removeAll { record in
            record.trackerId == trackerId && Calendar.current.isDate(record.date, inSameDayAs: date)
        }
    }
}

// MARK: - UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = getVisibleTrackers().count
        print("🔢 numberOfItemsInSection: \(count)")
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("🔍 cellForItemAt: \(indexPath.item)")
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCell.identifier,
            for: indexPath
        ) as? TrackerCell else {
            print("❌ Cannot dequeue TrackerCell")
            return UICollectionViewCell()
        }
        
        let trackers = getVisibleTrackers()
        let tracker = trackers[indexPath.item]
        print("📦 Tracker: \(tracker.title)")
        
        let isCompletedToday = completedTrackers.contains { record in
            record.trackerId == tracker.id && Calendar.current.isDate(record.date, inSameDayAs: selectedDate)
        }
        let totalCompletions = completedTrackers.filter { $0.trackerId == tracker.id }.count
        
        cell.configure(
            with: tracker,
            isCompleted: isCompletedToday,
            isFutureDate: selectedDate > Date(),
            completionCount: totalCompletions
        )
        
        cell.completionHandler = { [weak self] isCompletedNew in
            if isCompletedNew {
                self?.completeTracker(tracker.id, date: self?.selectedDate ?? Date())
            } else {
                self?.uncompleteTracker(trackerId: tracker.id, date: self?.selectedDate ?? Date())
            }
            collectionView.reloadItems(at: [indexPath])
        }
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension TrackersViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return false
    }
}
