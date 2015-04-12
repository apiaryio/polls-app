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

class CreateQuestionViewModel {
  private let hyperdrive:Hyperdrive
  private var transition:HTTPTransition

  init(hyperdrive:Hyperdrive, transition:HTTPTransition) {
    self.hyperdrive = hyperdrive
    self.transition = transition
  }

  func create(question:String, choices:[String], completion:(() -> ())) {
    hyperdrive.request(transition, attributes: ["question": question, "choices": choices]) { result in
      switch result {
      case .Success(let representor):
        completion()
      case .Failure(let error):
        println("Failure \(error)")
        completion()
      }
    }
  }
}
