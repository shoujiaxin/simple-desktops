//
//  OptionsTests.swift
//  SimpleDesktopsTests
//
//  Created by Jiaxin Shou on 2021/10/30.
//

@testable import Simple_Desktops

import XCTest

class OptionsTests: XCTestCase {
    private var userDefaults: UserDefaults!

    override func setUp() {
        super.setUp()

        let identifier = Bundle(for: type(of: self)).bundleIdentifier!
        userDefaults = UserDefaults(suiteName: identifier)
        userDefaults.removePersistentDomain(forName: identifier)
    }

    func testInitWithDefaultValue() throws {
        let options = Options(from: userDefaults)

        XCTAssertTrue(options.autoChange)
        XCTAssertEqual(options.changeInterval, .everyHour)
    }

    func testInitFromUserDefaults() throws {
        userDefaults.set(false, forKey: "autoChange")
        userDefaults.set(ChangeInterval.whenWakingFromSleep.rawValue, forKey: "changeInterval")

        let options = Options(from: userDefaults)

        XCTAssertFalse(options.autoChange)
        XCTAssertEqual(options.changeInterval, .whenWakingFromSleep)
    }

    func testSave() throws {
        var options = Options(from: userDefaults)
        options.autoChange = true
        options.changeInterval = .whenWakingFromSleep

        XCTAssertFalse(userDefaults.bool(forKey: "autoChange"))
        XCTAssertNil(userDefaults.string(forKey: "changeInterval"))

        options.save(to: userDefaults)

        XCTAssertTrue(userDefaults.bool(forKey: "autoChange"))
        XCTAssertEqual(
            userDefaults.string(forKey: "changeInterval"),
            ChangeInterval.whenWakingFromSleep.rawValue
        )
    }
}
