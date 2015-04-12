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
import Hyperdrive


class QuestionDetailViewModel {
  var question:String {
    return representor.attributes["question"] as? String ?? "Question"
  }

  private let hyperdrive:Hyperdrive
  private var representor:Representor<HTTPTransition>

  private var choices:[Representor<HTTPTransition>] {
    return representor.representors["choices"] ?? []
  }

  init(hyperdrive:Hyperdrive, representor:Representor<HTTPTransition>) {
    self.hyperdrive = hyperdrive
    self.representor = representor
  }

  func numberOfChoices() -> Int {
    return choices.count
  }

  func choice(index:Int) -> String {
    return choices[index].attributes["choice"] as? String ?? "Choice"
  }

  func votes(index:Int) -> Int {
    return choices[index].attributes["votes"] as? Int ?? 0
  }

  func canVote(index:Int) -> Bool {
    let transition = choices[index].transitions["vote"]
    return transition != nil
  }

  func vote(index:Int, completion:(() -> ())) {
    if let transition = choices[index].transitions["vote"] {
      hyperdrive.request(transition) { result in
        switch result {
        case .Success(let representor):
          self.injectVoteResult(index, representor: representor)
        case .Failure(let error):
          println("Failed to vote \(error)")
        }

        completion()
      }
    } else {
      completion()
    }
  }

  func injectVoteResult(index:Int, representor:Representor<HTTPTransition>) {
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
