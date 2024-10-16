//
//  AppDelegate.swift
//  VisionDetection
//
//  Created by zhuziyang on 2024/10/16.
//  Copyright © 2024 Willjay. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        // 主界面现在不是main.storyboard了，现在是我这里指定的viewController。
        let viewController = ViewController() // 你的主界面
        let navigationController = UINavigationController(rootViewController: viewController)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        return true
    }
}

