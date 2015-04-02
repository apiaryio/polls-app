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

  // MARK: -

  var canCreateQuestion:Bool {
    return representor?.transitions["create"] != nil
  }

  func createQuestionViewModel() -> CreateQuestionViewModel? {
    if let transition = representor?.transitions["create"] {
      return CreateQuestionViewModel(manager: manager, transition: transition)
    }

    return nil
  }

  func numberOfQuestions() -> Int {
    return questions?.count ?? 0
  }

  func question(index:Int) -> String {
    let question = questions?[index].attributes["question"] as? String
    return question ?? "Question"
  }

  func canDeleteQuestion(index:Int) -> Bool {
    let transition = questions?[index].transitions["delete"]
    return transition != nil
  }

  func delete(index:Int, completion:(() -> ())) {
    if let transition = questions?[index].transitions["delete"] {
      manager.request(transition).response { _, response, _, _ in
        if response?.statusCode >= 200 && response?.statusCode < 400 {
          // 🐵 🔧 the updated representor
          var questions = self.questions!
          questions.removeAtIndex(index)
          self.representor = Representor(transitions: self.representor?.transitions, representors: ["questions": questions], attributes: self.representor?.attributes)
        }

        completion()
      }
    } else {
      completion()
    }
  }

  func questionDetailViewModel(index:Int) -> QuestionDetailViewModel {
    return QuestionDetailViewModel(manager: manager, representor: questions![index])
  }
}
