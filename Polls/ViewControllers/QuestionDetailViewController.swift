//
//  QuestionDetailViewController.swift
//  Polls
//
//  Created by Kyle Fuller on 01/04/2015.
//  Copyright (c) 2015 Apiary. All rights reserved.
//

import UIKit
import SVProgressHUD


class QuestionDetailViewController : UITableViewController {
  var viewModel:QuestionDetailViewModel? {
    didSet {
      if isViewLoaded() {
        tableView.reloadData()
      }
    }
  }

  // MARK: View life-cycle

  override func viewDidLoad() {
    super.viewDidLoad()
    title = NSLocalizedString("QUESTION_DETAIL_TITLE", comment: "")
  }

  // MARK: UITableViewDelegate

  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 2
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return 1
    }

    return viewModel?.numberOfChoices() ?? 0
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as? UITableViewCell ?? UITableViewCell(style: .Value1, reuseIdentifier: "Cell")

    if indexPath.section == 0 {
      cell.textLabel?.text = viewModel?.question
      cell.detailTextLabel?.text = nil
      cell.accessoryType = .None
    } else {
      cell.textLabel?.text = viewModel?.choice(indexPath.row)
      cell.detailTextLabel?.text = viewModel?.votes(indexPath.row).description

      if viewModel!.canVote(indexPath.row) {
        cell.accessoryType = .DisclosureIndicator
      } else {
        cell.accessoryType = .None
      }
    }

    return cell
  }

  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if indexPath.section == 1 && viewModel!.canVote(indexPath.row) {
      SVProgressHUD.showWithStatus(NSLocalizedString("QUESTION_DETAIL_CHOICE_VOTING", comment: ""), maskType: .Gradient)
      viewModel?.vote(indexPath.row) {
        SVProgressHUD.dismiss()
        tableView.reloadData()
      }
    } else {
      tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
  }

  override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if section == 0 {
      return NSLocalizedString("QUESTION_DETAIL_QUESTION_TITLE", comment: "")
    }

    return NSLocalizedString("QUESTION_DETAIL_CHOICE_LIST_TITLE", comment: "")
  }
}
