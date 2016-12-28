//
//  IKAppUsageTrackerTests.swift
//  IKAppUsageTrackerTests
//
//  Created by Ilya Kharabet on 17.05.16.
//  Copyright © 2016 Ilya Kharabet. All rights reserved.
//

import XCTest
@testable import IKAppUsageTracker

class IKAppUsageTrackerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    
    func testMaxValue() {
        let tracker = IKTracker(key: "testTracker", condition: IKTrackerCondition.every(2))
        let val = UInt.max - 1
        UserDefaults.standard.set(val, forKey: "IKAppUsageTracker.IKTrackertestTrackerusagesCount")
        UserDefaults.standard.synchronize()
        for _ in 0..<10 {
            tracker.commit()
        }
        XCTAssert(tracker.enabled == false)
    }
    
    func testDrop() {
        let tracker = IKTracker(key: "testTracker1", condition: IKTrackerCondition.every(2))
        let val = 5
        UserDefaults.standard.set(val, forKey: "IKAppUsageTracker.IKTrackertestTracker1usagesCount")
        UserDefaults.standard.synchronize()
        XCTAssert(tracker.usagesCount == 5)
        tracker.drop()
        XCTAssert(tracker.usagesCount == 0, "Usages count = \(tracker.usagesCount)")
    }
    
    func testSatisfiesCondition() {
        let targetPower: UInt = 2
        let tracker = IKTracker(key: "testTracker2", condition: IKTrackerCondition.quadratic(targetPower))
        tracker.checkpoint = {
            let power = log(Double(tracker.usagesCount)) / log(Double(targetPower))
            XCTAssert(floor(power) == power && power != 0, "Usages count = \(tracker.usagesCount), Power = \(power)")
        }
    }
    
}
