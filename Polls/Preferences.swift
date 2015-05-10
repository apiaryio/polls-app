//
//  Preferences.swift
//  Polls
//
//  Created by Kyle Fuller on 28/04/2015.
//  Copyright (c) 2015 Apiary. All rights reserved.
//

import Foundation


/// Available Hyperdrive modes that the application can be used with
public enum HyperdriveMode : Int, Printable {
  /// Straight up Hypermedia mode with Siren or HAL
  case Hypermedia

  /// Use a self-hosted API Blueprint from a URL
  case APIBlueprint

  /// Use an Apiary hosted API Blueprint via an Apiary domain
  case Apiary

  /// Returns all the available Hyperdrive modes
  static func allValues() -> [HyperdriveMode] {
    return [.Hypermedia, .APIBlueprint, .Apiary]
  }

  /// Returns a localized name for the mode
  public var description:String {
    switch self {
    case Hypermedia:
      return NSLocalizedString("USER_PREFERENCES_MODE_HYPERMEDIA", comment: "")
    case APIBlueprint:
      return NSLocalizedString("USER_PREFERENCES_MODE_API_BLUEPRINT", comment: "")
    case Apiary:
      return NSLocalizedString("USER_PREFERENCES_MODE_APIARY", comment: "")
    }
  }

  /// Returns a localized name for the mode
  public var notes:String {
    switch self {
    case Hypermedia:
      return NSLocalizedString("USER_PREFERENCES_MODE_HYPERMEDIA", comment: "")
    case APIBlueprint:
      return NSLocalizedString("USER_PREFERENCES_MODE_API_BLUEPRINT", comment: "")
    case Apiary:
      return NSLocalizedString("USER_PREFERENCES_MODE_APIARY", comment: "")
    }
  }
}

/// An extension to NSUserDefaults providing convinience methods for accessing the preferences
public extension NSUserDefaults {
  public var hyperdriveMode:HyperdriveMode {
    get {
      if let modeValue = valueForKey("HyperdriveMode") as? Int {
        if let mode = HyperdriveMode(rawValue: modeValue) {
          return mode
        }
      }

      return .Hypermedia
    }

    set {
      setValue(newValue.rawValue, forKey: "HyperdriveMode")
    }
  }

  public var hypermediaURL:String {
    get {
      if let domain = valueForKey("HypermediaURL") as? String {
        return domain
      }

      return "https://polls.apiblueprint.org/"
    }

    set {
      setValue(newValue, forKey: "HypermediaURL")
    }
  }

  public var apiBlueprintURL:String {
    get {
      if let domain = valueForKey("APIBlueprintURL") as? String {
        return domain
      }

      return "https://raw.githubusercontent.com/apiaryio/polls-app/master/apiary.apib"
    }

    set {
      setValue(newValue, forKey: "APIBlueprintURL")
    }
  }

  public var apiaryDomain:String {
    get {
      if let domain = valueForKey("ApiaryDomain") as? String {
        return domain
      }

      return "pollsapp"
    }

    set {
      setValue(newValue, forKey: "ApiaryDomain")
    }
  }
}
