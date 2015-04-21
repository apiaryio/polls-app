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


/// View model for a specific question
class QuestionDetailViewModel {
  private let hyperdrive:Hyperdrive
  private var representor:Representor<HTTPTransition>

  private var choices:[Representor<HTTPTransition>] {
    return representor.representors["choices"] ?? []
  }

  /// Returns the question
  var question:String {
    return representor.attributes["question"] as? String ?? "Question"
  }

  init(hyperdrive:Hyperdrive, representor:Representor<HTTPTransition>) {
    self.hyperdrive = hyperdrive
    self.representor = representor
  }

  /// Returns the number of choices for the question
  func numberOfChoices() -> Int {
    return choices.count
  }

  /// Returns the choice for the given index
  func choice(index:Int) -> String {
    return choices[index].attributes["choice"] as? String ?? "Choice"
  }

  /// Returns the amount of votes on the given choice index
  func votes(index:Int) -> Int {
    return choices[index].attributes["votes"] as? Int ?? 0
  }

  /// Returns whether the user may vote on the given question index
  func canVote(index:Int) -> Bool {
    let transition = choices[index].transitions["vote"]
    return transition != nil
  }

  /** Asyncronously votes on a the choice at the given index
  :param: index The question index
  :param: completion A completion closure to call once the operation is complete
  */
  func vote(index:Int, completion:((Bool) -> ())) {
    if let transition = choices[index].transitions["vote"] {
      hyperdrive.request(transition) { result in
        switch result {
        case .Success(let representor):
          self.injectVoteResult(index, representor: representor)
          completion(true)
        case .Failure(let error):
          println("Failed to vote \(error)")
          completion(false)
        }
      }
    } else {
      completion(false)
    }
  }

  /// Private methos for updating a choice at an index with the given representor
  private func injectVoteResult(index:Int, representor:Representor<HTTPTransition>) {
    var choices = self.choices
    choices[index] = representor
    var representor = self.representor

    self.representor = Representor { builder in
      for (key, value) in self.representor.attributes {
        builder.addAttribute(key, value: value)
      }

      for choice in choices {
        builder.addRepresentor("choices", representor: choice)
      }
    }
  }
}
