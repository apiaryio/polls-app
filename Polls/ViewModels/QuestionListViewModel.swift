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


/// View model for a collection of questions
class QuestionListViewModel {
  private var hyperdrive:Hyperdrive = Hyperdrive()
  private var representor:Representor<HTTPTransition>?

  private var questions:[Representor<HTTPTransition>]? {
    return representor?.representors["questions"]
  }

  init() {}

  /// Calling this method will download the questions from an API
  func loadData(completion:((NSError?) -> ())) {
    let userDefaults = NSUserDefaults.standardUserDefaults()

    switch userDefaults.hyperdriveMode {
    case .Hypermedia:
      loadHypermedia(userDefaults.hypermediaURL, completion: completion)
      break
    case .APIBlueprint:
      loadBlueprint(userDefaults.apiBlueprintURL, completion: completion)
      break
    case .Apiary:
      loadApiary(userDefaults.apiaryDomain, completion: completion)
      break
    }
  }

  // MARK: Loading data from the API

  /// Load the root API resource using Hypermedia
  private func loadHypermedia(url:String, completion:((NSError?) -> ())) {
    hyperdrive = Hyperdrive()
    hyperdrive.enter(url) { result in
      switch result {
      case .Success(let representor):
        if let questions = representor.links["questions"] {
          self.loadQuestions(questions, completion: completion)
        } else {
          println("API does not support questions.")
          completion(nil)
        }

      case .Failure(let error):
        completion(error)
      }
    }
  }

  /// Load the available API features using an API Blueprint
  private func loadBlueprint(url:String, completion:((NSError?) -> ())) {
    HyperBlueprint.enter(blueprintURL: url) { result in
      switch result {
      case .Success(let hyperdrive, let representor):
        self.hyperdrive = hyperdrive
        if let questions = representor.links["questions"] {
          self.loadQuestions(questions, completion: completion)
        } else {
          println("API does not support questions.")
          completion(nil)
        }

      case .Failure(let error):
        completion(error)
      }
    }
  }

  /// Load the available API features using an API Blueprint hosted on Apiary
  private func loadApiary(apiaryDomain:String, completion:((NSError?) -> ())) {
    HyperBlueprint.enter(apiary: apiaryDomain) { result in
      switch result {
      case .Success(let hyperdrive, let representor):
        self.hyperdrive = hyperdrive
        if let questions = representor.links["questions"] {
          self.loadQuestions(questions, completion: completion)
        } else {
          println("API does not support questions.")
          completion(nil)
        }

      case .Failure(let error):
        completion(error)
      }
    }
  }

  /// Load the questions from the given URI
  private func loadQuestions(uri:String, completion:((NSError?) -> ())) {
    hyperdrive.request(uri) { result in
      switch result {
      case .Success(let representor):
        self.representor = representor
        completion(nil)
      case .Failure(let error):
        completion(error)
      }
    }
  }

  // MARK: API for the View Model

  /// Returns whether the user may create a question
  var canCreateQuestion:Bool {
    return representor?.transitions["create"] != nil
  }

  /// Returns a view model for creating a question if the user may create a question
  func createQuestionViewModel() -> CreateQuestionViewModel? {
    if let transition = representor?.transitions["create"] {
      return CreateQuestionViewModel(hyperdrive: hyperdrive, transition: transition)
    }

    return nil
  }

  /// Returns the number of loaded questions
  func numberOfQuestions() -> Int {
    return questions?.count ?? 0
  }

  /// Returns the question text for a question index
  func question(index:Int) -> String {
    let question = questions?[index].attributes["question"] as? String
    return question ?? "Question"
  }

  /// Returns whether the user may delete the question at the given index
  func canDeleteQuestion(index:Int) -> Bool {
    let transition = questions?[index].transitions["delete"]
    return transition != nil
  }

  /** Asyncronously delete a question at the given index
  :param: index The question index
  :param: completion A completion closure to call once the operation is complete
  */
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

  /// Returns a view model for the given question index
  func questionDetailViewModel(index:Int) -> QuestionDetailViewModel {
    return QuestionDetailViewModel(hyperdrive: hyperdrive, representor: questions![index])
  }
}
