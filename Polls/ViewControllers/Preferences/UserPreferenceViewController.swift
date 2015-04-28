//
//  UserPreferenceViewController.swift
//  Polls
//
//  Created by Kyle Fuller on 28/04/2015.
//  Copyright (c) 2015 Apiary. All rights reserved.
//

import UIKit


protocol UserPreferenceViewControllerDelegate {
  /// Called when the view controller created a new question
  func didChangePreferences(viewController:UserPreferenceViewController)
}

@objc(UserPreferenceViewController) class UserPreferenceViewController: UIViewController {
  /** The user preferences view controllers delegate
  The delegate object is informed when the view controller changes preferences
  */
  var delegate:UserPreferenceViewControllerDelegate?

  @IBOutlet var segmentedControl:UISegmentedControl!
  @IBOutlet var textField:UITextField!

  var userDefaults:NSUserDefaults {
    return NSUserDefaults.standardUserDefaults()
  }

  // MARK: View lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    title = NSLocalizedString("USER_PREFERENCES_TITLE", comment: "")
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "done:")

    segmentedControl.removeAllSegments()
    for value in HyperdriveMode.allValues() {
      segmentedControl.insertSegmentWithTitle(value.description, atIndex: value.rawValue, animated: false)
    }

    textField.addTarget(self, action: "textFieldDidChange:", forControlEvents: .EditingChanged)
    segmentedControl.addTarget(self, action: "modeChanged:", forControlEvents: .ValueChanged)
    updateInterface(userDefaults.hyperdriveMode)
  }

  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    textField.resignFirstResponder()
    userDefaults.synchronize()
  }

  // MARK: UI Events

  func done(sender:AnyObject!) {
    dismissViewControllerAnimated(true) {
      delegate?.didChangePreferences(self)
    }
  }

  func modeChanged(sender:AnyObject!) {
    let mode = HyperdriveMode(rawValue: segmentedControl.selectedSegmentIndex)!
    updateInterface(mode)
  }

  func textFieldDidChange(sender:AnyObject!) {
    let mode = HyperdriveMode(rawValue: segmentedControl.selectedSegmentIndex)!
    switch mode {
    case .Hypermedia:
      userDefaults.hypermediaURL = textField.text
    case .APIBlueprint:
      userDefaults.apiBlueprintURL = textField.text
    case .Apiary:
      userDefaults.apiaryDomain = textField.text
    }
  }

  @IBAction func resetPrefereces(sender:AnyObject!) {
    if let bundleIndentifier = NSBundle.mainBundle().bundleIdentifier {
      userDefaults.removePersistentDomainForName(bundleIndentifier)
    }

    modeChanged(sender)
  }

  // MARK: Other

  func updateInterface(mode:HyperdriveMode) {
    func configureForURLField(textField:UITextField) {
      textField.keyboardType = .URL
    }

    func configureForSubDomainField(textField:UITextField) {
      textField.keyboardType = .ASCIICapable
    }

    textField.resignFirstResponder()

    switch mode {
    case .Hypermedia:
      textField.text = userDefaults.hypermediaURL
      configureForURLField(textField)
    case .APIBlueprint:
      textField.text = userDefaults.apiBlueprintURL
      configureForURLField(textField)
    case .Apiary:
      textField.text = userDefaults.apiaryDomain
      configureForSubDomainField(textField)
    }

    textField.becomeFirstResponder()
    segmentedControl.selectedSegmentIndex = mode.rawValue
    userDefaults.hyperdriveMode = mode
  }
}
