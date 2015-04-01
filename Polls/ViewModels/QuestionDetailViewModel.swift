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


class QuestionDetailViewModel {
  var question:String {
    return representor.attributes["question"] as? String ?? "Question"
  }

  private let manager:Client
  private var representor:Representor<HTTPTransition>

  private var choices:[Representor<HTTPTransition>] {
    return representor.representors["choices"] ?? []
  }

  init(manager:Client, representor:Representor<HTTPTransition>) {
    self.manager = manager
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
      manager.request(transition).responseRepresentor { _, _, choice, _ in
        if let choice = choice {
          // 🐵 🔧 the updated representor
          var choices = self.choices
          choices[index] = choice
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

        completion()
      }
    } else {
      completion()
    }
  }
}
