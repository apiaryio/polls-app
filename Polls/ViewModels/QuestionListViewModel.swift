//
//  QuestionListViewModel.swift
//  Polls
//
//  Created by Kyle Fuller on 01/04/2015.
//  Copyright (c) 2015 Apiary. All rights reserved.
//

import Foundation


class QuestionListViewModel {
  func numberOfQuestions() -> Int {
    return 5
  }

  func question(index:Int) -> String {
    return "Question \(index + 1)"
  }

  func canDeleteQuestion(index:Int) -> Bool {
    return true
  }

  func delete(index:Int, completion:(() -> ())) {
    completion()
  }

  func questionDetailViewModel(index:Int) -> QuestionDetailViewModel {
    return QuestionDetailViewModel()
  }
}
