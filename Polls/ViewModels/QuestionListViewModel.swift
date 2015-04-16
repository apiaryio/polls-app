//
//  QuestionListViewModel.swift
//  Polls
//
//  Created by Kyle Fuller on 01/04/2015.
//  Copyright (c) 2015 Apiary. All rights reserved.
//

import Foundation
import Representor
import Hyperdrive


class QuestionListViewModel {
  private var representor:Representor<HTTPTransition>?

  private var questions:[Representor<HTTPTransition>]? {
    return representor?.representors["questions"]
  }

  private var hyperdrive:Hyperdrive = Hyperdrive()

  init() {}

  func loadData(completion:(() -> ())) {
//    loadHypermedia(completion)
    loadBlueprint(completion)
  }

    // MARK: API

  func loadHypermedia(completion:(() -> ())) {
    hyperdrive.enter("https://polls.apiblueprint.org/") { result in
      switch result {
      case .Success(let representor):
        if let questions = representor.links["questions"] {
          self.loadQuestions(questions, completion: completion)
        } else {
          println("API does not support questions.")
          completion()
        }

      case .Failure(let error):
        println("Failed to retrieve root \(error)")
        completion()
      }
    }
  }

  func loadBlueprint(completion:(() -> ())) {
    // pollsdemo
    hyperdrive.enter("https://polls.apiblueprint.org/") { result in
      switch result {
      case .Success(let representor):
        if let questions = representor.links["questions"] {
          self.loadQuestions(questions, completion: completion)
        } else {
          println("API does not support questions.")
          completion()
        }

      case .Failure(let error):
        println("Failed to retrieve root \(error)")
        completion()
      }
    }
  }

  func loadQuestions(uri:String, completion:(() -> ())) {
    hyperdrive.request(uri) { result in
      switch result {
      case .Success(let representor):
        self.representor = representor
        completion()
      case .Failure(let error):
        println("Failure to retrieve questions: \(error)")
        completion()
      }
    }
  }

  // MARK: Public

  var canCreateQuestion:Bool {
    return representor?.transitions["create"] != nil
  }

  func createQuestionViewModel() -> CreateQuestionViewModel? {
    if let transition = representor?.transitions["create"] {
      return CreateQuestionViewModel(hyperdrive: hyperdrive, transition: transition)
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
      hyperdrive.request(transition) { result in
        switch result {
        case .Success(let representor):
          var questions = self.questions!
          questions.removeAtIndex(index)
          self.representor = Representor(transitions: self.representor?.transitions, representors: ["questions": questions], attributes: self.representor?.attributes)
        case .Failure(let error):
          println("Failed to delete: \(error)")
        }

        completion()
      }
    } else {
      completion()
    }
  }

  func questionDetailViewModel(index:Int) -> QuestionDetailViewModel {
    return QuestionDetailViewModel(hyperdrive: hyperdrive, representor: questions![index])
  }
}
