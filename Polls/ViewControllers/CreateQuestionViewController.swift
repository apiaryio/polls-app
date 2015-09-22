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
  /// Called when the view controller created a new question
  func didCreateQuestion(viewController:CreateQuestionViewController)
}


/// A view controller for creating a new question
class CreateQuestionViewController : UITableViewController {
  /// The view model backing this view controller
  var viewModel:CreateQuestionViewModel?

  /** The question view controllers delegate
  The delegate object is informed when the view controller did create a new question
  */
  var delegate:QuestionDetailViewControllerDelegate?

  private var question = ""
  private var choices = [""]

  override func viewDidLoad() {
    title = NSLocalizedString("QUESTION_CREATE_TITLE", comment: "")
    navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "close:")
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: "save:")
    validate()
  }

  func close(sender:AnyObject) {
    dismissViewControllerAnimated(true, completion: nil)
  }

  func save(sender:AnyObject) {
    SVProgressHUD.showInfoWithStatus(NSLocalizedString("QUESTION_CREATE_CREATING", comment: ""), maskType: .Gradient)

    func nonEmpty(choice:String) -> Bool {
      return !choice.characters.isEmpty
    }

    viewModel?.create(question, choices: choices.filter(nonEmpty)) {
      SVProgressHUD.dismiss()

      if let delegate = self.delegate {
        delegate.didCreateQuestion(self)
      }

      self.dismissViewControllerAnimated(true, completion: nil)
    }
  }

  /// Validate the question with the view model and update the save button state
  private func validate() {
    let valid = viewModel?.validate(question: question) ?? false
    navigationItem.rightBarButtonItem?.enabled = valid
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
      validate()
    }
  }

  override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if section == 1 {
      return NSLocalizedString("QUESTION_CREATE_CHOICES", comment: "")
    }

    return nil
  }

  // MARK: Fields

  /// Returns a table view cell for editing the question text
  private func questionCell() -> UITableViewCell {
    let cell = TableTextViewCell(style: .Default, reuseIdentifier: "Question")
    cell.textLabel?.text = NSLocalizedString("QUESTION_CREATE_QUESTION", comment: "")
    cell.textField?.text = question
    cell.block = {[unowned self] in
      self.question = cell.textField?.text ?? ""
      self.validate()
    }
    return cell
  }

  /// Returns a table view cell for editing a choice at the given index
  private func choiceCell(index:Int) -> UITableViewCell {
    let cell = TableTextViewCell(style: .Default, reuseIdentifier: "Choice")
    cell.textLabel?.text = "\(index + 1)"
    cell.textField?.text = choices[index]
    cell.block = {[unowned self] in
      self.choices[index] = cell.textField?.text ?? ""
    }
    return cell
  }

  /// Returns a cell for creating a new choice
  private func addChoiceCell() -> UITableViewCell {
    let cell = UITableViewCell(style: .Default, reuseIdentifier: "Add")
    cell.textLabel?.text = NSLocalizedString("QUESTION_CREATE_CHOICE_ADD", comment: "")
    return cell
  }
}
