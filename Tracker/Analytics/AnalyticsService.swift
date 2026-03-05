//
//  AnalyticsService.swift
//  Tracker
//
//  Created by Воробьева Юлия on 05.03.2026.
//


import Foundation
import YandexMobileMetrica

enum AnalyticsEvent: String {
    case open = "open"
    case close = "close"
    case click = "click"
}

enum AnalyticsScreen: String {
    case main = "Main"
    case filter = "Filter"
    case newHabit = "NewHabit"
    case schedule = "Schedule"
    case category = "Category"
}

enum AnalyticsItem: String {
    case addTrack = "add_track"
    case track = "track"
    case filter = "filter"
    case edit = "edit"
    case delete = "delete"
    case filterOption = "filter_option"
    case createHabit = "create_habit"
    case cancel = "cancel"
    case selectCategory = "select_category"
    case selectSchedule = "select_schedule"
}

final class AnalyticsService {
    
    static let shared = AnalyticsService()
    private init() {}
    
    private let isDebugMode = true
    
    func reportEvent(event: AnalyticsEvent, screen: AnalyticsScreen, item: AnalyticsItem? = nil) {
        var params: [String: Any] = [
            "event": event.rawValue,
            "screen": screen.rawValue
        ]
        
        if let item = item {
            params["item"] = item.rawValue
        }
        
        YMMYandexMetrica.reportEvent("EVENT", parameters: params, onFailure: { error in
            print("❌ Ошибка отправки события: \(error.localizedDescription)")
        })
        
        if isDebugMode {
            print("📊 Analytics: event=\(event.rawValue), screen=\(screen.rawValue)" + (item != nil ? ", item=\(item!.rawValue)" : ""))
        }
    }
    
    func reportOpenScreen(screen: AnalyticsScreen) {
        reportEvent(event: .open, screen: screen)
    }
    
    func reportCloseScreen(screen: AnalyticsScreen) {
        reportEvent(event: .close, screen: screen)
    }
    
    func reportClick(screen: AnalyticsScreen, item: AnalyticsItem) {
        reportEvent(event: .click, screen: screen, item: item)
    }
}
