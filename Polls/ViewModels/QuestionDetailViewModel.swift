//
//  QuestionListViewModel.swift
//  Polls
//
//  Created by Kyle Fuller on 01/04/2015.
//  Copyright (c) 2015 Apiary. All rights reserved.
//

import Foundation


class QuestionDetailViewModel {
  var question = "Is this awesome?"

  func numberOfChoices() -> Int {
    return 3
  }

  func choice(index:Int) -> String {
    return "Choice \(index)"
  }

  func votes(index:Int) -> Int {
    return 5
  }

  func canVote(index:Int) -> Bool {
    return false
  }

  func vote(index:Int, completion:(() -> ())) {
    completion()
  }
}
