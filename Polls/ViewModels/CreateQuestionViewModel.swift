//
//  CreateQuestionViewModel.swift
//  Polls
//
//  Created by Kyle Fuller on 02/04/2015.
//  Copyright (c) 2015 Apiary. All rights reserved.
//

import Foundation
import Representor
import Hyperdrive


/// A view model for creating a question
class CreateQuestionViewModel {
  typealias DidAddCallback = (Representor<HTTPTransition>) -> ()

  private let didAddCallback:DidAddCallback?
  private let hyperdrive:Hyperdrive
  private var transition:HTTPTransition

  init(hyperdrive:Hyperdrive, transition:HTTPTransition, didAddCallback:DidAddCallback? = nil) {
    self.hyperdrive = hyperdrive
    self.transition = transition
    self.didAddCallback = didAddCallback
  }

  /// Validates if the given question is valid
  func validate(question  question:String) -> Bool {
    if let attribute = transition.attributes["question"] {
      let required = attribute.required ?? false
      if required {
        return !question.isEmpty
      }
    }

    return true
  }

  /// Asyncronously creates a question with the given choices calling a completion closure when complete
  func create(question:String, choices:[String], completion:(() -> ())) {
    hyperdrive.request(transition, attributes: ["question": question, "choices": choices]) { result in
      switch result {
      case .Success(let representor):
        self.didAddCallback?(representor)
        completion()
      case .Failure(let error):
        print("Failure \(error)")
        completion()
      }
    }
  }
}
