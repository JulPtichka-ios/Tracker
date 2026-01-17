//
//  SearchManager.swift
//  Tracker
//
//  Created by Воробьева Юлия on 17.01.2026.
//

import Foundation
import UIKit

protocol SearchManagerDelegate: AnyObject {
    func didUpdateSearchResults(_ filteredCategories: [TrackerCategory])
}

class SearchManager {
    
    weak var delegate: SearchManagerDelegate?
    private var allCategories: [TrackerCategory] = []
    
    func updateCategories(_ categories: [TrackerCategory]) {
        self.allCategories = categories
    }
    
    func filterCategories(searchText: String) {
        if searchText.isEmpty {
            delegate?.didUpdateSearchResults(allCategories)
        } else {
            let filtered = allCategories.compactMap { category -> TrackerCategory? in
                let matchingTrackers = category.trackers.filter { tracker in
                    tracker.title.lowercased().contains(searchText.lowercased())
                }
                guard !matchingTrackers.isEmpty else { return nil }
                return TrackerCategory(
                    title: category.title,
                    trackers: matchingTrackers
                )
            }
            delegate?.didUpdateSearchResults(filtered)
        }
    }
}
