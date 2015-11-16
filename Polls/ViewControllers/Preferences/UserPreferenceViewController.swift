//
//  UserPreferenceViewController.swift
//  Polls
//
//  Created by Kyle Fuller on 28/04/2015.
//  Copyright (c) 2015 Apiary. All rights reserved.
//

import UIKit
import VTAcknowledgementsViewController


protocol UserPreferenceViewControllerDelegate {
  /// Called when the view controller created a new question
  func didChangePreferences(viewController:UserPreferenceViewController)
}

@objc(UserPreferenceViewController) class UserPreferenceViewController: UITableViewController {
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

    let label = UILabel()
    label.text = NSLocalizedString("USER_PREFERENCES_MIDE_TITLE", comment: "")

    textField = UITextField()
    textField.borderStyle = .RoundedRect
    textField.backgroundColor = UIColor.whiteColor()
    let segmentedItems = HyperdriveMode.allValues().map {
      $0.description
    }
    segmentedControl = UISegmentedControl(items: segmentedItems)

    textField.addTarget(self, action: "textFieldDidChange:", forControlEvents: .EditingChanged)
    segmentedControl.addTarget(self, action: "modeChanged:", forControlEvents: .ValueChanged)
    updateInterface(userDefaults.hyperdriveMode)

    let headerView = UIView()
    headerView.addSubview(label)
    headerView.addSubview(textField)
    headerView.addSubview(segmentedControl)
    label.translatesAutoresizingMaskIntoConstraints = false
    textField.translatesAutoresizingMaskIntoConstraints = false
    segmentedControl.translatesAutoresizingMaskIntoConstraints = false

    headerView.addConstraints([
      NSLayoutConstraint(item: label, attribute: .Top, relatedBy: .Equal, toItem: headerView, attribute: .Top, multiplier: 1.0, constant: 20),
      NSLayoutConstraint(item: label, attribute: .Left, relatedBy: .Equal, toItem: headerView, attribute: .Left, multiplier: 1.0, constant: 20),
      NSLayoutConstraint(item: label, attribute: .Right, relatedBy: .Equal, toItem: segmentedControl, attribute: .Right, multiplier: 1.0, constant: 20),

      NSLayoutConstraint(item: segmentedControl, attribute: .Top, relatedBy: .Equal, toItem: label, attribute: .Bottom, multiplier: 1.0, constant: 20),
      NSLayoutConstraint(item: segmentedControl, attribute: .Left, relatedBy: .Equal, toItem: headerView, attribute: .Left, multiplier: 1.0, constant: 20),
      NSLayoutConstraint(item: headerView, attribute: .Right, relatedBy: .Equal, toItem: segmentedControl, attribute: .Right, multiplier: 1.0, constant: 20),

      NSLayoutConstraint(item: textField, attribute: .Top, relatedBy: .Equal, toItem: segmentedControl, attribute: .Bottom, multiplier: 1.0, constant: 20),

      NSLayoutConstraint(item: textField, attribute: .Left, relatedBy: .Equal, toItem: headerView, attribute: .Left, multiplier: 1.0, constant: 20),
      NSLayoutConstraint(item: headerView, attribute: .Right, relatedBy: .Equal, toItem: textField, attribute: .Right, multiplier: 1.0, constant: 20),
      NSLayoutConstraint(item: headerView, attribute: .Bottom, relatedBy: .Equal, toItem: textField, attribute: .Bottom, multiplier: 1.0, constant: 0),
    ])

    headerView.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 140)

    tableView.tableHeaderView = headerView
  }

  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    textField.resignFirstResponder()
    userDefaults.synchronize()
  }

  // MARK: UI Events

  func done(sender:AnyObject!) {
    dismissViewControllerAnimated(true) {
      self.delegate?.didChangePreferences(self)
    }
  }

  func presentAcknowledgements() {
    let acknowledgementsPath = NSBundle.mainBundle().pathForResource("Pods-Polls-acknowledgements", ofType: "plist")
    let viewController = VTAcknowledgementsViewController(acknowledgementsPlistPath: acknowledgementsPath)!
    viewController.headerText = NSLocalizedString("USER_PREFERENCES_ABOUT_ACKNOWLEDGEMENTS_HEADER", comment: "")
    navigationController?.pushViewController(viewController, animated: true)
  }

  func modeChanged(sender:AnyObject!) {
    let mode = HyperdriveMode(rawValue: segmentedControl.selectedSegmentIndex)!
    updateInterface(mode)
  }

  func textFieldDidChange(sender:AnyObject!) {
    let mode = HyperdriveMode(rawValue: segmentedControl.selectedSegmentIndex)!
    switch mode {
    case .Hypermedia:
      userDefaults.hypermediaURL = textField.text ?? ""
    case .APIBlueprint:
      userDefaults.apiBlueprintURL = textField.text ?? ""
    case .Apiary:
      userDefaults.apiaryDomain = textField.text ?? ""
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

  // MARK: UITableViewDataSource

  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 2
  }

  override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return NSLocalizedString("USER_PREFERENCES_ABOUT_TITLE", comment: "")
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    switch (indexPath.section, indexPath.row) {
    case (0, 0):
      return versionCell()
    case (0, 1):
      return acknowledgementsCell()
    default:
      fatalError("Unhandled Cell")
    }
  }

  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    switch (indexPath.section, indexPath.row) {
    case (0, 1):
      presentAcknowledgements()
    default:
      break
    }
  }

  func versionCell() -> UITableViewCell {
    let cell = UITableViewCell(style: .Value1, reuseIdentifier: "VersionCell")
    let infoDictionary = NSBundle.mainBundle().infoDictionary!
    let shortVersion = infoDictionary["CFBundleShortVersionString"] as! String
    let build = infoDictionary["CFBundleVersion"] as! String
    cell.textLabel?.text = NSLocalizedString("USER_PREFERENCES_ABOUT_VERSION", comment: "")
    cell.detailTextLabel?.text = "\(shortVersion) (\(build))"
    cell.selectionStyle = .None
    return cell
  }

  func acknowledgementsCell() -> UITableViewCell {
    let cell = UITableViewCell(style: .Default, reuseIdentifier: "AcknowledgementsCell")
    cell.textLabel?.text = NSLocalizedString("USER_PREFERENCES_ABOUT_ACKNOWLEDGEMENTS", comment: "")
    cell.accessoryType = .DisclosureIndicator
    return cell
  }
}
