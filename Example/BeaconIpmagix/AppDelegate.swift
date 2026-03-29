//
//  AppDelegate.swift
//  BeaconIpmagix
//
//  Created by mohamed.a.raouf@icloud.com on 03/24/2026.
//  Copyright (c) 2026 mohamed.a.raouf@icloud.com. All rights reserved.
//

import UIKit
import CoreLocation
import BeaconIpmagix

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    static var shared = AppDelegate()
    var window: UIWindow?
    var locationManager = CLLocationManager()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // ✅ Step 1: Set delegate FIRST before anything else
        UNUserNotificationCenter.current().delegate = self
        // ✅ Step 2: Request permission with all required options
        requestNotificationPermission()

        locationManager.requestAlwaysAuthorization()
        BeaconIpmagix.shared.configure(appKey: "123456-APP-KEY")
        window = UIWindow(frame: UIScreen.main.bounds)
        let rootViewController: UIViewController
        if let token = UserDefaults.standard.string(forKey: "authToken"), !token.isEmpty {
            rootViewController = HomePageViewController()
        } else {
            rootViewController = ViewController()
        }
        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()
        return true
    }
    // ✅ Step 3: Show notifications while app is in FOREGROUND
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .sound, .badge, .list])
        } else {
            completionHandler([.alert, .sound, .badge])
        }
    }

    // MARK: - Permission Request
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge, .criticalAlert]
        ) { granted, error in
            if granted {
                debugPrint("✅ Notification permission granted")
            } else if let error = error {
                debugPrint("❌ Permission error: \(error.localizedDescription)")
            } else {
                debugPrint("⚠️ Notification permission DENIED — user must enable in Settings")
            }
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}

