import XCTest
@testable import Detect

final class DailyTaskLimitManagerTests: XCTestCase {
    func testThatDailyLimitExceedsAfter3CompletedTasks() {
        let model = DailyTaskLimitModel()
        
        model.testStarted()
        
        model.commitTaskCompletion()
        model.commitTaskCompletion()
        model.commitTaskCompletion()
        
        XCTAssertTrue(model.isDailyLimitExceeded)
    }
    
    func testThatDailyLimitBecomesNotExceededAfterIncreasingLimit() {
        let model = DailyTaskLimitModel()
        
        model.testStarted()
        
        model.commitTaskCompletion()
        model.commitTaskCompletion()
        model.commitTaskCompletion()
        
        model.increaseDailyLimit(by: 1)
        
        XCTAssertFalse(model.isDailyLimitExceeded)
    }
    
    func testThatDailyLimitIsNotExceededOnNextDay() {
        let model = DailyTaskLimitModel()
        
        model.testStarted()
        
        model.commitTaskCompletion()
        model.commitTaskCompletion()
        model.commitTaskCompletion()
        
        DailyTaskLimitModel.overriddenToday = Calendar.current.date(
            byAdding: .day,
            value: 1,
            to: Calendar.current.startOfDay(for: Date.now)
        )
        
        model.handleDayChange()
        
        XCTAssertFalse(model.isDailyLimitExceeded)
    }
}
