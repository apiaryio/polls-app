//
//  CreateQuestionViewController.swift
//  Polls
//
//  Created by Kyle Fuller on 02/04/2015.
//  Copyright (c) 2015 Apiary. All rights reserved.
//

import UIKit
import SVProgressHUD


protocol QuestionDetailViewControllerDelegate {
  func didCreateQuestion(viewController:CreateQuestionViewController)
}


class CreateQuestionViewController : UITableViewController {
  var viewModel:CreateQuestionViewModel?
  var delegate:QuestionDetailViewControllerDelegate?

  var question = ""
  var choices = [""]

  override func viewDidLoad() {
    title = NSLocalizedString("QUESTION_CREATE_TITLE", comment: "")
    navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "close:")
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: "save:")
  }

  func close(sender:AnyObject) {
    dismissViewControllerAnimated(true, completion: nil)
  }

  func save(sender:AnyObject) {
    SVProgressHUD.showInfoWithStatus(NSLocalizedString("QUESTION_CREATE_CREATING", comment: ""), maskType: .Gradient)

    func nonEmpty(choice:String) -> Bool {
      return countElements(choice) > 0
    }

    viewModel?.create(question, choices: filter(choices, nonEmpty)) {
      SVProgressHUD.dismiss()

      if let delegate = self.delegate {
        delegate.didCreateQuestion(self)
      }

      self.dismissViewControllerAnimated(true, completion: nil)
    }
  }

  // MARK: UITableViewDelegate/Source

  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 2
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return 1
    }

    return choices.count + 1
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    switch (indexPath.section, indexPath.row) {
    case (0, let row):
      return questionCell()
    case (1, choices.count):
      return addChoiceCell()
    case (1, let row):
      return choiceCell(row)
    default:
      fatalError("Unhandled Index")
    }
  }

  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)

    if indexPath.section == 1 && indexPath.row == choices.count {
      choices.append("")
      tableView.reloadData()
    }
  }

  override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if section == 1 {
      return NSLocalizedString("QUESTION_CREATE_CHOICES", comment: "")
    }

    return nil
  }

  // MARK: Fields

  func questionCell() -> UITableViewCell {
    let cell = TableTextViewCell(style: .Default, reuseIdentifier: "Question")
    cell.textLabel?.text = NSLocalizedString("QUESTION_CREATE_QUESTION", comment: "")
    cell.textField.text = question
    cell.block = {[unowned self] in
      self.question = cell.textField.text
    }
    return cell
  }

  func choiceCell(index:Int) -> UITableViewCell {
    let cell = TableTextViewCell(style: .Default, reuseIdentifier: "Choice")
    cell.textLabel?.text = "\(index + 1)"
    cell.textField?.text = choices[index]
    cell.block = {[unowned self] in
      self.choices[index] = cell.textField.text
    }
    return cell
  }

  func addChoiceCell() -> UITableViewCell {
    let cell = UITableViewCell(style: .Default, reuseIdentifier: "Add")
    cell.textLabel?.text = NSLocalizedString("QUESTION_CREATE_CHOICE_ADD", comment: "")
    return cell
  }
}
