//
//  PaidTaskBundlesManagerTests.swift
//  DetectItCoreTests
//
//  Created by Илья Харабет on 05/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import XCTest
@testable import DetectItCore

final class PaidTaskBundlesManagerTests: XCTestCase {
    
    override class func tearDown() {
        super.tearDown()
        
        PaidTaskBundlesManager.clearAllPurchasesData()
    }
    
    func testThatManagerReturnsCorrectStateForFreeTasksBundle() {
        let bundleID = "starter"
        
        let state = PaidTaskBundlesManager.tasksBundlePurchaseState(id: bundleID)
        
        XCTAssertEqual(state, .free)
    }
    
    func testThatManagerReturnsCorrectStateForBoughtTasksBundle() {
        PaidTaskBundlesManager.clearAllPurchasesData()
        
        let bundleID = "test"
        
        PaidTaskBundlesManager.unlockBundle(id: bundleID)
        let state = PaidTaskBundlesManager.tasksBundlePurchaseState(id: bundleID)
        
        XCTAssertEqual(state, .bought)
    }
    
    func testThatManagerReturnsCorrectStateForPaidLockedTasksBundle() {
        PaidTaskBundlesManager.clearAllPurchasesData()
        
        let bundleID = "test"
        
        let state = PaidTaskBundlesManager.tasksBundlePurchaseState(id: bundleID)
        
        XCTAssertEqual(state, .paidLocked)
    }
    
}

extension TasksBundlePurchaseState: Equatable {
    
    public static func == (lhs: TasksBundlePurchaseState, rhs: TasksBundlePurchaseState) -> Bool {
        switch (lhs, rhs) {
        case (.free, .free), (.bought, .bought), (.paidLoading, .paidLoading), (.paidLocked, .paidLocked), (.paid, .paid):
            return true
        default:
            return false
        }
    }
    
}
