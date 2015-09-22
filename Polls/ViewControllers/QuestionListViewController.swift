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
class QuestionListViewController : UITableViewController, UISplitViewControllerDelegate, QuestionDetailViewControllerDelegate, UserPreferenceViewControllerDelegate {
  /// The view model backing this view controller
  let viewModel:QuestionListViewModel? = QuestionListViewModel()

  // MARK: View life-cycle

  override func viewDidLoad() {
    super.viewDidLoad()
    title = NSLocalizedString("QUESTION_LIST_TITLE", comment: "")

    refreshControl = UIRefreshControl()
    refreshControl!.addTarget(self, action:Selector("loadData"), forControlEvents:.ValueChanged)
    loadData()

    navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("QUESTION_LIST_PREFERENCES", comment: ""), style: .Plain, target: self, action: "changePreferences:")
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    if let selectedIndex = tableView.indexPathForSelectedRow {
      tableView.deselectRowAtIndexPath(selectedIndex, animated: animated)

      transitionCoordinator()?.notifyWhenInteractionEndsUsingBlock { context in
        if context.isCancelled() {
          self.tableView.selectRowAtIndexPath(selectedIndex, animated: false, scrollPosition: .None)
        }
      }
    }
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if let indexPath = tableView.indexPathForSelectedRow {
      if let viewModel = self.viewModel?.questionDetailViewModel(indexPath.row),
        navigationController = segue.destinationViewController as? UINavigationController,
        viewController = navigationController.topViewController as? QuestionDetailViewController
      {
        viewController.viewModel = viewModel
      }
    }
  }

  // MARK: Other

  func loadData() {
    refreshControl!.beginRefreshing()

    viewModel?.loadData { error in
      self.refreshControl!.endRefreshing()
      self.reloadInterface()

      if self.viewModel?.canCreateQuestion ?? false {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "createQuestion:")
      } else {
        self.navigationItem.rightBarButtonItem = nil
      }

      if let error = error {
        self.refreshControl!.attributedTitle = NSAttributedString(string: error.localizedDescription)
      } else {
        self.refreshControl!.attributedTitle = nil
      }

      if let navigationController = self.splitViewController?.viewControllers.last as? UINavigationController,
          viewController = navigationController.topViewController as? QuestionDetailViewController
      {
        viewController.viewModel = nil
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
      viewController.modalPresentationStyle = .FormSheet

      let navigationController = UINavigationController(rootViewController: viewController)
      navigationController.modalPresentationStyle = .FormSheet

      presentViewController(navigationController, animated: true, completion: nil)
    }
  }

  func changePreferences(sender:AnyObject) {
    let viewController = UserPreferenceViewController(style: .Grouped)
    viewController.delegate = self
    let navigationController = UINavigationController(rootViewController: viewController)
    navigationController.modalPresentationStyle = .FormSheet
    presentViewController(navigationController, animated: true, completion: nil)
  }

  // MARK: UITableViewDelegate

  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel?.numberOfQuestions() ?? 0
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell")!
    cell.textLabel?.text = viewModel?.question(indexPath.row)
    return cell
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

          if let navigationController = self.splitViewController?.viewControllers.last as? UINavigationController,
            viewController = navigationController.topViewController as? QuestionDetailViewController
          {
            viewController.viewModel = nil
          }
        }
        break
      case .Insert:
        break
      case .None:
        break
    }
  }

  // MARK: UISplitViewControllerDelegate

  func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool {
    if let navigationController = secondaryViewController as? UINavigationController,
        viewController = navigationController.topViewController as? QuestionDetailViewController
    {
      return viewController.viewModel == nil
    }

    return false
  }

  // MARK: QuestionDetailViewControllerDelegate

  func didCreateQuestion(viewController:CreateQuestionViewController) {
    tableView?.reloadData()
  }

  // MARK: UserPreferenceViewControllerDelegate

  func didChangePreferences(viewController: UserPreferenceViewController) {
    loadData()
  }
}
