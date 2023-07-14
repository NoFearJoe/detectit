import SwiftUI

final class DailyTaskLimitModel: ObservableObject {
    @Published private(set) var isDailyLimitExceeded = false
    
    @AppStorage("daily_played_tasks") private var dailyPlayedTasks = 0
    @AppStorage("last_play_date") private var lastPlayDate: String?
    @AppStorage("increased_daily_limit") private var increasedDailyLimit = 0
    
    private static let baseDailyLimit = 3
    private var dailyLimit: Int {
        Self.baseDailyLimit + increasedDailyLimit
    }
    
    func commitTaskCompletion() {
        handleDayChange()
        
        lastPlayDate = today.ISO8601Format(.iso8601)
        dailyPlayedTasks += 1
        
        updateDailyLimitExceeded()
    }
    
    func increaseDailyLimit(by number: Int) {
        increasedDailyLimit += number
        
        updateDailyLimitExceeded()
    }
    
    private func updateDailyLimitExceeded() {
        guard !FullVersionManager.hasBought else { return }
        
        isDailyLimitExceeded = dailyPlayedTasks >= dailyLimit
    }
    
    func handleDayChange() {
        let lastPlayDate = self.lastPlayDate.flatMap {
            let f = ISO8601DateFormatter()
            return f.date(from: $0)
        }
        
        if let lastPlayDate, today.compare(lastPlayDate) == .orderedDescending {
            dailyPlayedTasks = 0
            increasedDailyLimit = 0
            
            updateDailyLimitExceeded()
        } else {
            updateDailyLimitExceeded()
        }
    }
    
    // MARK: Testing start
    
    func testStarted() {
        dailyPlayedTasks = 0
        increasedDailyLimit = 0
        lastPlayDate = nil
    }
    
    static var overriddenToday: Date?
    
    // MARK: Testing end
    
    private var today: Date {
        Self.overriddenToday ?? Calendar.current.startOfDay(for: .now)
    }
}
