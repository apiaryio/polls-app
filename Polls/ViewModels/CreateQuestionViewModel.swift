//
//  CreateQuestionViewModel.swift
//  Polls
//
//  Created by Kyle Fuller on 02/04/2015.
//  Copyright (c) 2015 Apiary. All rights reserved.
//

import Foundation
import Representor
import Representor

class CreateQuestionViewModel {
  private let manager:Client
  private var transition:HTTPTransition

  init(manager:Client, transition:HTTPTransition) {
    self.manager = manager
    self.transition = transition
  }

  func create(question:String, choices:[String], completion:(() -> ())) {
    manager.request(transition, attributes: ["question": question, "choices":choices]).response { _, response, _, error in
      completion()

      if let response = response {
        println("status code: \(response.statusCode)")
      }
      if let error = error {
        println("Failed to create \(error)")
      }
    }
  }
}
