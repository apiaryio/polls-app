//
//  AppDelegate.swift
//  Polls
//
//  Created by Kyle Fuller on 01/04/2015.
//  Copyright (c) 2015 Apiary. All rights reserved.
//

import UIKit
import Alamofire
import Representor


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    window = UIWindow(frame: UIScreen.mainScreen().bounds)
    window?.rootViewController = UINavigationController(rootViewController: QuestionListViewController())
    window?.makeKeyAndVisible()
    return true
  }
}


class Client : Manager {
  let baseURL = "http://polls.apiblueprint.org/"

  override func request(method: Alamofire.Method, _ URLString: URLStringConvertible, parameters: [String : AnyObject]? = nil, encoding: ParameterEncoding = .URL) -> Request {
    let URL = NSURL(string: URLString.URLString, relativeToURL:NSURL(string: baseURL))
    return super.request(method, URL!, parameters: parameters, encoding: encoding)
  }

  func request(transition: HTTPTransition, parameters: [String : AnyObject]? = nil, attributes: [String : AnyObject]? = nil) -> Request {
    let base = NSURL(string: baseURL)
    return super.request(base, transition: transition, parameters: parameters, attributes: attributes, encoding: nil)
  }
}

extension Request {
  func responseRepresentor(completion:((request:NSURLRequest, response:NSHTTPURLResponse?, representor:Representor<HTTPTransition>?, error:NSError?) -> Void)) -> Self {
    return response { (request, response, data, error) -> Void in
      var representor:Representor<HTTPTransition>?

      if let response = response {
        if let data = data as? NSData {
          representor = HTTPDeserialization.deserialize(response, body: data)
        }
      }

      completion(request: request, response: response, representor: representor , error: error)
    }
  }
}
