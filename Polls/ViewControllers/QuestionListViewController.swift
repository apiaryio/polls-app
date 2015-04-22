//
//  QuestionListViewController.swift
//  Polls
//
//  Created by Kyle Fuller on 01/04/2015.
//  Copyright (c) 2015 Apiary. All rights reserved.
//

import UIKit
import SVProgressHUD


/// A view controller for showing a list of questions
class QuestionListViewController : UITableViewController, QuestionDetailViewControllerDelegate {
  /// The view model backing this view controller
  var viewModel:QuestionListViewModel?

  // MARK: View life-cycle

  override func viewDidLoad() {
    super.viewDidLoad()
    title = NSLocalizedString("QUESTION_LIST_TITLE", comment: "")

    refreshControl = UIRefreshControl()
    refreshControl!.addTarget(self, action:Selector("loadData"), forControlEvents:.ValueChanged)
    loadData()
  }

  // MARK: Other

  func loadData() {
    refreshControl!.beginRefreshing()

    viewModel?.loadData {
      self.refreshControl!.endRefreshing()
      self.reloadInterface()

      if self.viewModel?.canCreateQuestion ?? false {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "createQuestion:")
      } else {
        self.navigationItem.rightBarButtonItem = nil
      }
    }
  }

  func reloadInterface() {
    tableView.reloadData()
  }

  func createQuestion(sender:AnyObject) {
    if let viewModel = viewModel?.createQuestionViewModel() {
      let viewController = CreateQuestionViewController(style: .Grouped)
      viewController.delegate = self
      viewController.viewModel = viewModel

      presentViewController(UINavigationController(rootViewController: viewController), animated: true, completion: nil)
    }
  }

  // MARK: UITableViewDelegate

  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel?.numberOfQuestions() ?? 0
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as? UITableViewCell ?? UITableViewCell(style: .Default, reuseIdentifier: "Cell")
    cell.textLabel?.text = viewModel?.question(indexPath.row)
    return cell
  }

  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if let viewModel = self.viewModel?.questionDetailViewModel(indexPath.row) {
      let viewController = QuestionDetailViewController(style: .Grouped)
      viewController.viewModel = viewModel
      navigationController?.pushViewController(viewController, animated: true)
    }
  }

  override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return viewModel?.canDeleteQuestion(indexPath.row) ?? false
  }

  override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    switch editingStyle {
      case .Delete:
        SVProgressHUD.showWithStatus(NSLocalizedString("QUESTION_LIST_QUESTION_DELETING", comment: ""), maskType: .Gradient)
        viewModel?.delete(indexPath.row) {
          SVProgressHUD.dismiss()
          tableView.reloadData()
        }
        break
      case .Insert:
        break
      case .None:
        break
    }
  }

  // MARK: QuestionDetailViewControllerDelegate

  func didCreateQuestion(viewController:CreateQuestionViewController) {
    loadData()
  }
}
