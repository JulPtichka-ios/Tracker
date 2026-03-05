//
//  StatisticsViewModel.swift
//  Tracker
//
//  Created by Воробьева Юлия on 04.03.2026.
//

import Foundation

final class StatisticsViewModel {
    
    // MARK: - Bindings
    var completedCountDidChange: ((Int) -> Void)?
    var bestPeriodDidChange: ((Int) -> Void)?
    var isEmptyStateDidChange: ((Bool) -> Void)?
    
    // MARK: - Properties
    private let recordStore: TrackerRecordStore
    private(set) var completedCount: Int = 0 {
        didSet {
            completedCountDidChange?(completedCount)
            checkEmptyState()
        }
    }
    
    private(set) var bestPeriod: Int = 0 {
        didSet {
            bestPeriodDidChange?(bestPeriod)
            checkEmptyState()
        }
    }
    
    private var isEmpty: Bool {
        return completedCount == 0 && bestPeriod == 0
    }
    
    // MARK: - Initialization
    init(recordStore: TrackerRecordStore = TrackerRecordStore()) {
        self.recordStore = recordStore
        self.recordStore.delegate = self
        loadStatistics()
    }
    
    // MARK: - Public Methods
    func loadStatistics() {
        let records = recordStore.records
        
        let uniqueTrackers = Set(records.map { $0.trackerId })
        completedCount = uniqueTrackers.count
        
        bestPeriod = calculateBestPeriod(from: records)
    }
    
    func formatCompletedCount() -> String {
        return String(completedCount)
    }
    
    func formatBestPeriod() -> String {
        return String(bestPeriod)
    }
    
    // MARK: - Private Methods
    private func checkEmptyState() {
        isEmptyStateDidChange?(isEmpty)
    }
    
    private func calculateBestPeriod(from records: [TrackerRecordModel]) -> Int {
        var recordsByDay: [Date: [TrackerRecordModel]] = [:]
        
        let calendar = Calendar.current
        for record in records {
            let startOfDay = calendar.startOfDay(for: record.date)
            if recordsByDay[startOfDay] == nil {
                recordsByDay[startOfDay] = []
            }
            recordsByDay[startOfDay]?.append(record)
        }
        
        let daysWithRecords = recordsByDay.keys.sorted()
        
        guard !daysWithRecords.isEmpty else { return 0 }
        
        var bestStreak = 1
        var currentStreak = 1
        
        for i in 1..<daysWithRecords.count {
            let previousDay = daysWithRecords[i-1]
            let currentDay = daysWithRecords[i]
            
            let isNextDay = calendar.isDate(currentDay, inSameDayAs: calendar.date(byAdding: .day, value: 1, to: previousDay) ?? previousDay)
            
            if isNextDay {
                currentStreak += 1
                bestStreak = max(bestStreak, currentStreak)
            } else {
                currentStreak = 1
            }
        }
        
        return bestStreak
    }
}

// MARK: - TrackerRecordStoreDelegate
extension StatisticsViewModel: TrackerRecordStoreDelegate {
    func didUpdateRecords() {
        loadStatistics()
    }
}
