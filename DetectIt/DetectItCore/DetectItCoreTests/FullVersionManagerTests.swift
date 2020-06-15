//
//  FullVersionManagerTests.swift
//  DetectItCoreTests
//
//  Created by Илья Харабет on 05/04/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import XCTest
@testable import DetectItCore

final class FullVersionManagerTests: XCTestCase {
    
    override class func tearDown() {
        super.tearDown()
        
        FullVersionManager.reset()
    }
    
    func testThatManagerUnlocksFullVersion() {
        FullVersionManager.unlock()
        
        let state = FullVersionManager.hasBought
        
        XCTAssertEqual(state, true)
    }
    
}
