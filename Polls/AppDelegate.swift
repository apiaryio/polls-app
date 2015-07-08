//
//  AppDelegate.swift
//  Polls
//
//  Created by Kyle Fuller on 01/04/2015.
//  Copyright (c) 2015 Apiary. All rights reserved.
//

import UIKit
#if SNAPSHOT
import SimulatorStatusMagic
#endif

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    if let splitViewControler = window?.rootViewController as? UISplitViewController,
        navigationController = splitViewControler.viewControllers.first as? UINavigationController,
        viewController = navigationController.topViewController as? QuestionListViewController
    {
      splitViewControler.delegate = viewController
    }

#if SNAPSHOT
    let statusBarManager = SDStatusBarManager.sharedInstance()
    statusBarManager.carrierName = "Apiary"
    statusBarManager.enableOverrides()
#endif

    return true
  }
}
