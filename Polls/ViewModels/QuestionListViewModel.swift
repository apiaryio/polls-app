//
//  QuestionListViewModel.swift
//  Polls
//
//  Created by Kyle Fuller on 01/04/2015.
//  Copyright (c) 2015 Apiary. All rights reserved.
//

import Foundation
import Alamofire
import Representor


class QuestionListViewModel {
  private var representor:Representor<HTTPTransition>?

  private var questions:[Representor<HTTPTransition>]? {
    return representor?.representors["questions"]
  }

  private var manager:Client = {
    var defaultHeaders = Alamofire.Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders ?? [:]
    defaultHeaders["Accept"] = "application/vnd.siren+json"

    let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
    configuration.HTTPAdditionalHeaders =  defaultHeaders

    return Client(configuration: configuration)
  }()

  init() {}

  func loadData(completion:(() -> ())) {
    manager.request(.GET, manager.baseURL).responseRepresentor { (_, _, representor, error) in
      if let link = representor?.links["questions"] {
        self.manager.request(.GET, link).responseRepresentor { _, _, representor, error in
          if let representor = representor? {
            self.representor = representor
          } else {
            println("Failure to retrieve questions: \(error)")
          }

          completion()
        }
      } else {
        println("Failure to retrieve root: \(error)")
        completion()
      }
    }
  }

  func numberOfQuestions() -> Int {
    return questions?.count ?? 0
  }

  func question(index:Int) -> String {
    let question = questions?[index].attributes["question"] as? String
    return question ?? "Question"
  }

  func canDeleteQuestion(index:Int) -> Bool {
    return false
  }

  func delete(index:Int, completion:(() -> ())) {
    completion()
  }

  func questionDetailViewModel(index:Int) -> QuestionDetailViewModel {
    return QuestionDetailViewModel(manager: manager, representor: questions![index])
  }
}
