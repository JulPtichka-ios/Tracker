//
//  Tracker.swift
//  Tracker
//
//  Created by Воробьева Юлия on 14.01.2026.
//

import Foundation

enum WeekDay: CaseIterable {
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday
    
    var title: String {
        switch self {
        case .monday: return "Понедельник"
        case .tuesday: return "Вторник"
        case .wednesday: return "Среда"
        case .thursday: return "Четверг"
        case .friday: return "Пятница"
        case .saturday: return "Суббота"
        case .sunday: return "Воскресенье"
        }
    }
}

extension WeekDay {
    var shortTitle: String {
        switch self {
        case .monday: return "Пн"
        case .tuesday: return "Вт"
        case .wednesday: return "Ср"
        case .thursday: return "Чт"
        case .friday: return "Пт"
        case .saturday: return "Сб"
        case .sunday: return "Вс"
        }
    }
}

extension WeekDay {
    func toDate(for referenceDate: Date = Date()) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: referenceDate)
        
        let dayNumber: Int
        switch self {
        case .monday: dayNumber = 2
        case .tuesday: dayNumber = 3
        case .wednesday: dayNumber = 4
        case .thursday: dayNumber = 5
        case .friday: dayNumber = 6
        case .saturday: dayNumber = 7
        case .sunday: dayNumber = 1
        }
        
        let dayComponents = DateComponents(calendar: calendar,
                                         year: components.year,
                                         month: components.month,
                                         weekday: dayNumber)
        return calendar.date(from: dayComponents) ?? referenceDate
    }
}

struct Tracker {
    let id: UUID
    let title: String
    let color: String
    let emoji: String
    let schedule: [WeekDay]
    
    var isHabit: Bool { !schedule.isEmpty }
}
