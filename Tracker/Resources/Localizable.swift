//
//  Localizable.swift
//  Tracker
//
//  Created by Воробьева Юлия on 03.03.2026.
//


import Foundation

extension String {
    func localized() -> String {
        return NSLocalizedString(self, comment: "")
    }
    
    func localized(with arguments: CVarArg...) -> String {
        return String(format: self.localized(), arguments: arguments)
    }
}

enum LocalizableKeys {
    // MARK: - Common
    static let cancel = "common.cancel".localized()
    static let done = "common.done".localized()
    static let save = "common.save".localized()
    static let delete = "common.delete".localized()
    static let edit = "common.edit".localized()
    static let add = "common.add".localized()
    static let ok = "common.ok".localized()
    static let error = "common.error".localized()
    static let limit = "common.error.limit".localized()
    
    // MARK: - Tab Bar
    static let tabTrackers = "tab.trackers".localized()
    static let tabStatistics = "tab.statistics".localized()
    
    // MARK: - Trackers Screen
    static let trackersTitle = "trackers.title".localized()
    static let trackersSearchPlaceholder = "trackers.search.placeholder".localized()
    static let trackersEmptyPlaceholder = "trackers.empty.placeholder".localized()
    static let trackersAddTracker = "trackers.add.tracker".localized()
    static let trackersPin = "trackers.pin".localized()
    static let trackersUnpin = "trackers.unpin".localized()
    
    // MARK: - Statistics Screen
    static let statisticsTitle = "statistics.title".localized()
    static let statisticsEmptyPlaceholder = "statistics.empty.placeholder".localized()
    static let statisticsCompleted = "statistics.completed".localized()
    static let statisticsBestPeriod = "statistics.best.period".localized()
    
    // MARK: - New Habit Screen
    static let newHabitTitle = "newhabit.title".localized()
    static let newHabitCategory = "newhabit.category".localized()
    static let newHabitSchedule = "newhabit.schedule".localized()
    static let newHabitEnterName = "newhabit.enter.name".localized()
    static let newHabitEmoji = "newhabit.emoji".localized()
    static let newHabitColor = "newhabit.color".localized()
    static let newHabitCreate = "newhabit.create".localized()
    
    // MARK: - Category Screen
    static let categoryTitle = "category.title".localized()
    static let categoryAdd = "category.add".localized()
    static let categoryNew = "category.new".localized()
    static let categoryEdit = "category.edit".localized()
    static let categoryEnterName = "category.enter.name".localized()
    static let categoryEmptyPlaceholder = "category.empty.placeholder".localized()
    static let categoryDeleteConfirm = "category.delete.confirm".localized()
    
    // MARK: - Schedule Screen
    static let scheduleTitle = "schedule.title".localized()
    static let scheduleEveryday = "schedule.everyday".localized()
    
    // MARK: - Onboarding
    static let onboardingPage1Title = "onboarding.page1.title".localized()
    static let onboardingPage2Title = "onboarding.page2.title".localized()
    static let onboardingButton = "onboarding.button".localized()
    
    // MARK: - Week Days
    static func weekday(_ day: WeekDay) -> String {
        switch day {
        case .monday: return "weekday.monday".localized()
        case .tuesday: return "weekday.tuesday".localized()
        case .wednesday: return "weekday.wednesday".localized()
        case .thursday: return "weekday.thursday".localized()
        case .friday: return "weekday.friday".localized()
        case .saturday: return "weekday.saturday".localized()
        case .sunday: return "weekday.sunday".localized()
        }
    }
    
    static func weekdayShort(_ day: WeekDay) -> String {
        switch day {
        case .monday: return "weekday.monday.short".localized()
        case .tuesday: return "weekday.tuesday.short".localized()
        case .wednesday: return "weekday.wednesday.short".localized()
        case .thursday: return "weekday.thursday.short".localized()
        case .friday: return "weekday.friday.short".localized()
        case .saturday: return "weekday.saturday.short".localized()
        case .sunday: return "weekday.sunday.short".localized()
        }
    }
    
    // MARK: - Days Pluralization
    static func daysCount(_ count: Int) -> String {
        return String(format: NSLocalizedString("days.count", comment: ""), count)
    }
    
    // MARK: - Context Menu
    static let contextEdit = "context.edit".localized()
    static let contextDelete = "context.delete".localized()
    static let contextDeleteTitle = "context.delete.title".localized()
    static let contextDeleteMessage = "context.delete.message".localized()
    static let contextDeleteError = "context.delete.error".localized()
    
    // MARK: - Filter
    static let filterButton = "filter.button".localized()
    static let filterTitle = "filter.title".localized()
    static let filterAll = "filter.all".localized()
    static let filterToday = "filter.today".localized()
    static let filterCompleted = "filter.completed".localized()
    static let filterUncompleted = "filter.uncompleted".localized()
    static let filterEmpty = "filter.empty".localized()
    
}
