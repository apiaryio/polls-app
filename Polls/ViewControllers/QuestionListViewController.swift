//
//  QuestionListViewController.swift
//  Polls
//
//  Created by Kyle Fuller on 01/04/2015.
//  Copyright (c) 2015 Apiary. All rights reserved.
//

import UIKit


class QuestionListViewController : UITableViewController {
  // MARK: View life-cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    title = NSLocalizedString("QUESTION_LIST_TITLE", comment: "")
    reloadInterface()
  }

  // MARK: Other

  func reloadInterface() {

  }
}
