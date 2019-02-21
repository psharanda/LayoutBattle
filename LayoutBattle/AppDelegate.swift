//
//  AppDelegate.swift
//  LayoutBattle
//
//  Created by Pavel Sharanda on 25.02.17.
//  Copyright © 2017 psharanda. All rights reserved.
//

import UIKit
import Atributika
import GDPerformanceView

struct SampleModel {
    let title: NSAttributedString
    let details: NSAttributedString
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let tbc = UITabBarController()
        
        let vc1 = AutoLayoutViewController()
        
        let vc2 = LayoutOpsViewController()
    
        tbc.viewControllers = [UINavigationController(rootViewController: vc1), UINavigationController(rootViewController: vc2)]
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = tbc
        window?.makeKeyAndVisible()
        
        
        PerformanceMonitor.shared().start()
        
        return true
    }

}

