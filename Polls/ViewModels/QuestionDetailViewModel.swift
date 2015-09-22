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
import Result


/// View model for a specific question
class QuestionDetailViewModel {
  typealias DidUpdateCallback = (Representor<HTTPTransition>) -> ()

  private let didUpdateCallback:DidUpdateCallback?
  private let hyperdrive:Hyperdrive
  private var representor:Representor<HTTPTransition>

  var canReload:Bool {
    return self.representor.transitions["self"] != nil
  }

  func reload(completion:((RepresentorResult) -> ())) {
    if let uri = self.representor.transitions["self"] {
      hyperdrive.request(uri) { result in
        switch result {
        case .Success(let representor):
          self.representor = representor
          self.didUpdateCallback?(representor)
        case .Failure:
          break
        }

        completion(result)
      }
    }
  }

  private var choices:[Representor<HTTPTransition>] {
    return representor.representors["choices"] ?? []
  }

  /// Returns the question
  var question:String {
    return representor.attributes["question"] as? String ?? "Question"
  }

  init(hyperdrive:Hyperdrive, representor:Representor<HTTPTransition>, didUpdateCallback:DidUpdateCallback? = nil) {
    self.hyperdrive = hyperdrive
    self.representor = representor
    self.didUpdateCallback = didUpdateCallback
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
  - parameter index: The question index
  - parameter completion: A completion closure to call once the operation is complete
  */
  func vote(index:Int, completion:((Bool) -> ())) {
    if let transition = choices[index].transitions["vote"] {
      hyperdrive.request(transition) { result in
        switch result {
        case .Success(let representor):
          self.update(choice: representor, index: index)
          completion(true)
        case .Failure(let error):
          print("Failed to vote \(error)")
          completion(false)
        }
      }
    } else {
      completion(false)
    }
  }

  /// Private methos for updating a choice at an index with the given representor
  private func update(choice  choice:Representor<HTTPTransition>, index:Int) {
    self.representor = self.representor.update("choices", representor: choice, index: index)
    didUpdateCallback?(self.representor)
  }
}
