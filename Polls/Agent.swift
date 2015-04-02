//
//  Agent.swift
//  Polls
//
//  Created by Kyle Fuller on 02/04/2015.
//  Copyright (c) 2015 Apiary. All rights reserved.
//

import Foundation
import Alamofire
import Representor
import URITemplate


func loadClient(url:String, completion:((Client, Representor<HTTPTransition>?) -> ())) {
  var defaultHeaders = Alamofire.Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders ?? [:]
  defaultHeaders["Accept"] = "application/vnd.siren+json"

  let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
  configuration.HTTPAdditionalHeaders =  defaultHeaders

  let client = Client(configuration: configuration, baseURL:url)

  client.request(.GET, url).responseRepresentor { request, response, representor, error in
    completion(client, representor)
  }
}


func loadBlueprintClient(baseURL:String, blueprint:String, completion:((Client?, Representor<HTTPTransition>?) -> ())) {
  let url = "https://jsapi.apiary.io/apis/\(blueprint).apib"

  request(.GET, url).response { _, _, data, _ in
    if let data = data as? NSData {
      loadBlueprintMarkdown(baseURL, data, completion)
    } else {
      completion(nil, nil)
    }
  }
}


func loadBlueprintMarkdown(baseURL:String, data:NSData, completion:((Client?, Representor<HTTPTransition>?) -> ())) {
  let encoding = ParameterEncoding.Custom { URLRequest, _ -> (NSURLRequest, NSError?) in
    var mutableURLRequest: NSMutableURLRequest! = URLRequest.URLRequest.mutableCopy() as NSMutableURLRequest
    mutableURLRequest.setValue("text/vnd.apiblueprint+markdown; version=1A", forHTTPHeaderField: "Content-Type")
    mutableURLRequest.HTTPBody = data
    return (mutableURLRequest, nil)
  }

  request(.POST, "http://api.apiblueprint.org/parser", parameters:["dummy": "because apparently custom encoding needs params"], encoding: encoding).responseJSON { _, _, data, _ in
    if let data = data as? [String: AnyObject] {
      let blueprint = Blueprint(ast: data["ast"] as [String:AnyObject]) // todo what if AST was errored?
      let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
      let client = Client(configuration: configuration, baseURL:baseURL)
      client.blueprint = blueprint
      completion(client, blueprint.rootRepresentor())
    } else {
      completion(nil, nil)
    }

  }
}


class Client : Manager {
  var baseURL:String
  var blueprint:Blueprint?

  init(configuration:NSURLSessionConfiguration, baseURL:String) {
    self.baseURL = baseURL
    super.init(configuration: configuration)
  }

  required init(configuration: NSURLSessionConfiguration?) {
    fatalError("init(configuration:) has not been implemented")
  }

  override func request(method: Alamofire.Method, _ URLString: URLStringConvertible, parameters: [String : AnyObject]? = nil, encoding: ParameterEncoding = .URL) -> Request {
    let URL = NSURL(string: URLString.URLString, relativeToURL:NSURL(string: baseURL))
    return super.request(method, URL!, parameters: parameters, encoding: encoding)
  }

  func request(transition: HTTPTransition, parameters: [String : AnyObject]? = nil, attributes: [String : AnyObject]? = nil) -> Request {
    let base = NSURL(string: baseURL)
    return super.request(base, transition: transition, parameters: parameters, attributes: attributes, encoding: .JSON)
  }
}

extension Request {
  func responseRepresentor(completion:((request:NSURLRequest, response:NSHTTPURLResponse?, representor:Representor<HTTPTransition>?, error:NSError?) -> Void)) -> Self {
    return response { (request, response, data, error) in
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

extension Blueprint {
  /// Find the root resource, it's expected to be a collecton of relations
  func rootRepresentor() -> Representor<HTTPTransition>? {
    func toRepresentor(links:[String:String]) -> Representor<HTTPTransition> {
      return Representor { builder in
        for (key, value) in links {
          if key.hasSuffix("_url") {
            let relation = key.stringByReplacingOccurrencesOfString("_url", withString: "", options: NSStringCompareOptions(0), range: nil)
            builder.addLink(relation, uri: value)
          }
        }
      }
    }

    let resources = reduce(map(resourceGroups) { $0.resources }, [], +)
    let rootResources = resources.filter { $0.uriTemplate == "/" }
    let rootAction = rootResources.first?.actions.filter { $0.method == "GET" }.first

    if let example = rootAction?.examples.first {
      for response in example.responses {
        if let body = response.body {
          let contentType = response.headers.filter { (key, value) in key == "Content-Type" }.first?.value
          if let contentType = contentType {
            if contentType == "application/json" {
              if let data = NSJSONSerialization.JSONObjectWithData(body, options: NSJSONReadingOptions(0), error: nil) as? [String:String] {
                return toRepresentor(data)
              }
            }

            // TODO handle siren/hal? we can skip custom representor magic
          }
        }
      }
    }

    return nil
  }

  /// Below we have a bunch of methods for mapping resources to representors
  /// It's really tightly coupled, but a proof of concept

  func toRepresentor(request:NSURLRequest, response:NSHTTPURLResponse, data:NSData) -> Representor<HTTPTransition>? {
    let uri = response.URL!.path!

    if let resource = resourceForURI(uri) {
      return Representor { builder in
        // TOOD Use relation from AST
        if let contentType = response.allHeaderFields["Content-Type"] as? String {
          if contentType == "application/json" {
            let json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: nil)

            if let json = json as? [[String:AnyObject]] {
              for element in json {
                // sprinke on top transitions here too
                builder.addRepresentor(self.relationForURI(uri) ?? "unknown") { builder in
                  self.JSONObjectToRepresentor(element, builder: builder)
                }
              }

              self.addTransitions(uri, builder: builder)
            } else if let json = json as? [String:AnyObject] {
              self.JSONObjectToRepresentor(json, builder: builder)
            }
          }
        }

        // Sprinkle on top the transitons ;)
      }
    }

    return nil
  }

  func resourceForURI(uri:String) -> Resource? {
    let resources = reduce(map(resourceGroups) { $0.resources }, [], +)
    let sortedResources = resources.sorted { lhs, rhs in
      // This is pretty strange, but URITemplate extraction has a bug.
      // This workaround simply orders them in a way to prevent the bug from being exposed
      return lhs.uriTemplate.utf16Count > rhs.uriTemplate.utf16Count
    }
    return sortedResources.filter {
      var uriTemplate = $0.uriTemplate
      if $0.uriTemplate.hasSuffix("{?page}") {   // URITemplate has a bug and ?page exposes it...
        uriTemplate.stringByReplacingOccurrencesOfString("{?page}", withString: "", options: NSStringCompareOptions(0), range: nil)
      }

      let template = URITemplate(template: uriTemplate)
      let extract = template.extract(uri)
      return extract != nil
      }.first
  }

  func addTransitions(url:String, builder:RepresentorBuilder<HTTPTransition>) {
    if let resource = resourceForURI(url) {
      for action in resource.actions {
        if let relation = relationForURI(url, method: action.method) {
          builder.addTransition(relation, uri: url) { builder in
            builder.method = action.method
          }
        }
      }
    }
  }

  func JSONObjectToRepresentor(entity:[String:AnyObject], builder:RepresentorBuilder<HTTPTransition>) {
    if let url = entity["url"] as? String {
      addTransitions(url, builder: builder)
    }

    for (key, value) in entity {
      builder.addAttribute(key, value: value)

      if let values = value as? [[String:AnyObject]] {
        for value in values {
          if let url = value["url"] as? String {
            // we have a url so, this is an "embedded" resource

            builder.addRepresentor(key) { builder in
              self.JSONObjectToRepresentor(value, builder: builder)
            }
          }
        }
      } else if let value = value as? [String:AnyObject] {
        if let url = value["url"] as? String {
          // we have a url so, this is an "embedded" resource

          builder.addRepresentor(key) { builder in
            self.JSONObjectToRepresentor(value, builder: builder)
          }
        }
      }
    }
  }

  func relationForURI(uri:String) -> String? {
    if let relation = relationForURI(uri, method: "GET") {
      return relation
    }

    // this should come from the relation field in the blueprint, but since api.apiblueprint.org doesnt support, use our own implementation as fallback:

    let uris = [
      "/questions": "questions",
      //      "/questions/{question_id}/choices/{choice_id}": "choices",
    ]

    return filter(uris) { (key, value) in
      let template = URITemplate(template: key)
      return template.extract(uri) != nil
      }.first?.1
  }

  func relationForURI(uri:String, method:String) -> String? {
    if let resource = resourceForURI(uri) {
      let actions = resource.actions.filter { $0.method == method && $0.relation != nil && countElements($0.relation!) > 0 }
      if let action = actions.first {
        return action.relation
      }
    }

    // this should come from the relation field in the blueprint, but since api.apiblueprint.org doesnt support, use our own implementation as fallback:

    let uris = [
      "/questions": [
        "POST": "create"
      ],
      "/questions/{question_id}": [
        "DELETE": "delete"
      ],
      "/questions/{question_id}/choices/{choice_id}": [
        "POST": "vote"
      ]
    ]

    // Due to URITemplate bugs, sorting hack for least globby regex options
    let templates = uris.keys.array.sorted {
      $0.utf16Count > $1.utf16Count
    }

    for uriTemplate in templates {
      let template = URITemplate(template: uriTemplate)
      if template.extract(uri) == nil {
        continue
      }
      
      return uris[uriTemplate]?[method]
    }
    
    return nil
  }
}

