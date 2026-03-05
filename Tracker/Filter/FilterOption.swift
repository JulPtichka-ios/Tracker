//
//  FilterOption.swift
//  Tracker
//
//  Created by Воробьева Юлия on 04.03.2026.
//

import Foundation

enum FilterOption: Int, CaseIterable {
    case all = 0
    case today
    case completed
    case uncompleted
    
    var title: String {
        switch self {
        case .all:
            return LocalizableKeys.filterAll
        case .today:
            return LocalizableKeys.filterToday
        case .completed:
            return LocalizableKeys.filterCompleted
        case .uncompleted:
            return LocalizableKeys.filterUncompleted
        }
    }
    
    var isResetFilter: Bool {
        return self == .all || self == .today
    }
}
