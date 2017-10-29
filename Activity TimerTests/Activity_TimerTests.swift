//
//  Activity_TimerTests.swift
//  Activity TimerTests
//
//  Created by Allan Lykke Christensen on 07/10/2017.
//  Copyright © 2017 Allan Lykke Christensen. All rights reserved.
//

import XCTest
@testable import Activity_Timer

class Activity_TimerTests: XCTestCase {
    
    var systemUnderTest: ActivityTimerModel!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        systemUnderTest = ActivityTimerModel()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        systemUnderTest = nil
    }
    
    func testActivityTimer_inited_isStoppedTrue() {
        // 1. Given
        
        // 2. When
        let isStopped = systemUnderTest.isStopped
        
        // 3. Then
        XCTAssertTrue(isStopped, "Timer should be stopped")
    }
    
    func testActivityTimer_started_isStoppedFalse() {
        // 1. Given
        systemUnderTest.startTimer()
        
        // 2. When
        let isStopped = systemUnderTest.isStopped
        
        // 3. Then
        XCTAssertFalse(isStopped, "Timer should not be stopped")
    }
    
    func testActivityTimer_stopped_isPausedTrue() {
        // 1. Given
        systemUnderTest.startTimer()
        systemUnderTest.stopTimer()
        
        // 2. When
        let isPaused = systemUnderTest.isPaused
        
        // 3. Then
        XCTAssertTrue(isPaused, "Timer should be paused")
    }

}
