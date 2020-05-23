//
//  MainScreenUITests.swift
//  DetectItUITests
//
//  Created by Илья Харабет on 23/05/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import XCTest

class MainScreenUITests: XCTestCase {

    override func setUp() {
        continueAfterFailure = false
    }

    func testTahtMainScreenAppears() {
        let app = XCUIApplication()
        app.launchArguments = ["onboarding_passed", "-user_alias", "test", "-user-password", "testtest"]
        app.launch()

        let isScreenShown = app.otherElements["main_screen"].waitForExistence(timeout: 10)
        
        XCTAssertTrue(isScreenShown)
    }

}
