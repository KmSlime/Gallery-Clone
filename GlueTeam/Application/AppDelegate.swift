//
//  AppDelegate.swift
//  GlueTeam
//
//  Created by LIEMNH on 11/10/2023.
//

import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var window: UIWindow?
    static let share = AppDelegate()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UINavigationController(rootViewController: BaseViewController.shared)
        window?.makeKeyAndVisible()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) { }

    func applicationDidEnterBackground(_ application: UIApplication) { }
    
    func applicationWillEnterForeground(_ application: UIApplication) { }
    
    func applicationDidBecomeActive(_ application: UIApplication) { }
    
    func applicationWillTerminate(_ application: UIApplication) { }
}

extension AppDelegate {
    
}

enum Device {
    static let widthBasedOnDesign: CGFloat =  375.0
    static let screenWidth: CGFloat = UIScreen.main.bounds.size.width
    static let screenHeight: CGFloat = UIScreen.main.bounds.size.height
    static let systemVersion = Float(UIDevice.current.systemVersion) ?? 12.0
    static let displayScale = screenWidth / widthBasedOnDesign
    static let deviceType: Int = 1
}
