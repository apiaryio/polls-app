//
//  QuestionListViewController.swift
//  Polls
//
//  Created by Kyle Fuller on 01/04/2015.
//  Copyright (c) 2015 Apiary. All rights reserved.
//

import UIKit


class QuestionListViewController : UITableViewController {
  var viewModel = QuestionListViewModel()

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

    viewModel.loadData {
      self.refreshControl!.endRefreshing()
      self.reloadInterface()
    }
  }

  func reloadInterface() {
    tableView.reloadData()
  }

  // MARK: UITableViewDelegate

  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.numberOfQuestions()
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as? UITableViewCell ?? UITableViewCell(style: .Default, reuseIdentifier: "Cell")
    cell.textLabel?.text = viewModel.question(indexPath.row)
    return cell
  }

  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let viewController = QuestionDetailViewController(style: .Grouped)
    viewController.viewModel = viewModel.questionDetailViewModel(indexPath.row)
    navigationController?.pushViewController(viewController, animated: true)
  }

  override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return viewModel.canDeleteQuestion(indexPath.row)
  }

  override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    switch editingStyle {
      case .Delete:
        viewModel.delete(indexPath.row) {
          tableView.reloadData()
        }
        break
      case .Insert:
        break
      case .None:
        break
    }
  }
}
