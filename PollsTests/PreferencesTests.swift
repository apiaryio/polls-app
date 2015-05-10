//
//  PreferencesTests.swift
//  Polls
//
//  Created by Kyle Fuller on 28/04/2015.
//  Copyright (c) 2015 Apiary. All rights reserved.
//

import Foundation
import XCTest
import Polls


class UserDefaultTests : XCTestCase {
  var userDefaults:NSUserDefaults!

  override func setUp() {
    userDefaults = NSUserDefaults()

    if let bundleIndentifier = NSBundle.mainBundle().bundleIdentifier {
      userDefaults.removePersistentDomainForName(bundleIndentifier)
    }
  }

  // MARK: Hypermedia Mode property

  func testHypermediaModeByDefault() {
    XCTAssertEqual(userDefaults.hyperdriveMode.rawValue, HyperdriveMode.Hypermedia.rawValue)
  }

  func testSettingHypermediaMode() {
    userDefaults.hyperdriveMode = .Apiary
    XCTAssertEqual(userDefaults.hyperdriveMode.rawValue, HyperdriveMode.Apiary.rawValue)
  }

  // MARK: Hypermedia URL property

  func testHypermediaURLDefaultValue() {
    XCTAssertEqual(userDefaults.hypermediaURL, "https://polls.apiblueprint.org/")
  }

  func testSettingHypermediaURLDomain() {
    userDefaults.hypermediaURL = "http://localhost:8080"
    XCTAssertEqual(userDefaults.hypermediaURL, "http://localhost:8080")
  }

  // MARK: API Blueprint URL property

  func testAPIBlueprintURLDefaultValue() {
    XCTAssertEqual(userDefaults.apiBlueprintURL, "https://raw.githubusercontent.com/apiaryio/polls-app/master/apiary.apib")
  }

  func testSettingAPIBlueprintURLDomain() {
    userDefaults.apiBlueprintURL = "http://localhost:8080"
    XCTAssertEqual(userDefaults.apiBlueprintURL, "http://localhost:8080")
  }

  // MARK: Apiary domain property

  func testApiaryDomainDefaultValue() {
    XCTAssertEqual(userDefaults.apiaryDomain, "pollsapp")
  }

  func testSettingApiaryDomain() {
    userDefaults.apiaryDomain = "custom-domain"
    XCTAssertEqual(userDefaults.apiaryDomain, "custom-domain")
  }
}
