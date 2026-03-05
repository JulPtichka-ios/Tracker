//
//  Tracker.swift
//  Tracker
//
//  Created by Воробьева Юлия on 14.01.2026.
//

import Foundation

enum WeekDay: String, CaseIterable, Codable {
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday
    
    var title: String {
        return LocalizableKeys.weekday(self)
    }
    
    var shortTitle: String {
        return LocalizableKeys.weekdayShort(self)
    }
    
    var calendarWeekday: Int {
        switch self {
        case .sunday: return 1
        case .monday: return 2
        case .tuesday: return 3
        case .wednesday: return 4
        case .thursday: return 5
        case .friday: return 6
        case .saturday: return 7
        }
    }
    
    func toDate(for referenceDate: Date = Date()) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: referenceDate)
        
        let dayNumber = calendarWeekday
        
        let dayComponents = DateComponents(calendar: calendar,
                                         year: components.year,
                                         month: components.month,
                                         weekday: dayNumber)
        return calendar.date(from: dayComponents) ?? referenceDate
    }
}

struct TrackerModel {
    let id: UUID
    let title: String
    let color: String
    let emoji: String
    let schedule: [WeekDay]
    
    var isHabit: Bool { !schedule.isEmpty }
}
