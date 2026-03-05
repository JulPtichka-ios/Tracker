//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Воробьева Юлия on 14.01.2026.
//

import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackersViewControllerSnapshotTests: XCTestCase {
    
    var sut: TrackersViewController!
    
    override func setUp() {
        super.setUp()
        sut = TrackersViewController()
        sut.view.frame = CGRect(x: 0, y: 0, width: 402, height: 874)
        sut.overrideUserInterfaceStyle = .light
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
        func testTrackersViewControllerWithSearch() {
        addTestTrackers()
        sut.loadViewIfNeeded()
        
        let searchController = sut.navigationItem.searchController
        searchController?.searchBar.text = "Вода"
        searchController?.searchResultsUpdater?.updateSearchResults(for: searchController!)
        
        sut.view.layoutIfNeeded()
        
        assertSnapshot(
            of: sut,
            as: .image(
                traits: UITraitCollection(userInterfaceStyle: .light)
            ),
            named: "TrackersViewController_search_light"
        )
    }
    
    // MARK: - Helper Methods
    
    private func addTestTrackers() {
        let categoryStore = TrackerCategoryStore()
        
        do {
            let categoryId = try categoryStore.addCategory(with: "Важное")
            
            let trackers = [
                TrackerModel(
                    id: UUID(),
                    title: "Пить воду",
                    color: "ColorSelection1",
                    emoji: "💧",
                    schedule: [.monday, .wednesday, .friday]
                ),
                TrackerModel(
                    id: UUID(),
                    title: "Зарядка",
                    color: "ColorSelection5",
                    emoji: "🏃‍♂️",
                    schedule: [.monday, .tuesday, .thursday]
                ),
                TrackerModel(
                    id: UUID(),
                    title: "Чтение",
                    color: "ColorSelection8",
                    emoji: "📚",
                    schedule: [.wednesday, .saturday]
                )
            ]
            
            let trackerStore = TrackerStore()
            for tracker in trackers {
                try trackerStore.addTracker(tracker, to: categoryId)
            }
        } catch {
            print("❌ Ошибка при добавлении тестовых трекеров: \(error)")
        }
    }
}
