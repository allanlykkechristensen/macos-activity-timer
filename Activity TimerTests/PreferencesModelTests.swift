//
//  PreferencesModelTests.swift
//  Activity TimerTests
//
//  Created by Allan Lykke Christensen on 29/10/2017.
//  Copyright © 2017 Allan Lykke Christensen. All rights reserved.
//

import XCTest
@testable import Activity_Timer

class PreferencesModelTests: XCTestCase {

    var unitUnderTest: PreferencesModel!
    
    override func setUp() {
        super.setUp()
        unitUnderTest = PreferencesModel()
    }
    
    override func tearDown() {
        super.tearDown()
        unitUnderTest = nil
    }

    func test_reset_returnDefaultSelectedTime() {
        // Given
        unitUnderTest.reset()
        
        // When
        let time = unitUnderTest.selectedTime
        
        // Then
        XCTAssert(Double(time) == 360.0)
    }
    
    func test_reset_returnZeroHours() {
        // Given
        unitUnderTest.reset()
        
        // When
        let hours = unitUnderTest.selectedHours
        
        // Then
        XCTAssert(Double(hours) == 0)
    }
    
    func test_reset_returnSixMinutes() {
        // Given
        unitUnderTest.reset()
        
        // When
        let minutes = unitUnderTest.selectedMinutes
        
        // Then
        XCTAssert(Double(minutes) == 6)
    }

    func test_reset_returnZeroSeconds() {
        // Given
        unitUnderTest.reset()
        
        // When
        let seconds = unitUnderTest.selectedSeconds
        
        // Then
        XCTAssert(Double(seconds) == 0)
    }

    func test_setSelectedTimeOneHourTenMinutesFifteenSeconds_returnSelectedTime4215() {
        // Given
        unitUnderTest.selectedTime = (60*60)+(60*10)+(15)
        
        // When
        let time = unitUnderTest.selectedTime
        
        // Then
        XCTAssert(Double(time) == 4215.0)
    }
    
    func test_setSelectedTimeOneHourTenMinutesFifteenSeconds_return1Hour() {
        // Given
        unitUnderTest.selectedTime = (60*60)+(60*10)+(15)
        
        // When
        let hours = unitUnderTest.selectedHours
        
        // Then
        XCTAssert(hours == 1)
    }
    
    func test_setSelectedTimeOneHourTenMinutesFifteenSeconds_return10Minutes() {
        // Given
        unitUnderTest.selectedTime = (60*60)+(60*10)+(15)
        
        // When
        let minutes = unitUnderTest.selectedMinutes
        
        // Then
        XCTAssert(Double(minutes) == 10)
    }
    
    func test_setSelectedTimeOneHourTenMinutesFifteenSeconds_return15Seconds() {
        // Given
        unitUnderTest.selectedTime = (60*60)+(60*10)+(15)

        // When
        let seconds = unitUnderTest.selectedSeconds
        
        // Then
        XCTAssert(Double(seconds) == 15)
    }
}
