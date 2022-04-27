//
//  AppDelegate.swift
//  SwiftPushTest
//
//  Created by Matthew Podwysocki on 4/27/22.
//

import UIKit
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var deviceToken: String?
    var notificationPresentationCompletionHandler: ((UNNotificationPresentationOptions) -> Void)?
    var notificationResponseCompletionHandler: (() -> Void)?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if (granted) {
                print("Push notifications granted")
            } else {
                print("Push notifications not granted")
            }
            
            if (error != nil) {
                print("requestAuthorization error: \(error!.localizedDescription)")
            }
        }
        
        UIApplication.shared.registerForRemoteNotifications()
        
        return true
    }
    
    

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: UIApplicationDelegate
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        self.deviceToken = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("didRegisterForRemoteNotificationsWithDeviceToken: \(self.deviceToken!)")
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("didFailToRegisterForRemoteNotificationsWithError: \(error.localizedDescription)")
    }

    func application(_ application: UIApplication,
    didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if (UIApplication.shared.applicationState == .background) {
            print("Notification received in the background")
        }
        
        if (notificationResponseCompletionHandler != nil) {
            print("Tapped Notification")
        } else {
            print("Notification received in the foreground")
        }
        
        // Call notification completion handlers.
        if (notificationResponseCompletionHandler != nil) {
            (notificationResponseCompletionHandler!)()
            notificationResponseCompletionHandler = nil
        }
        if (notificationPresentationCompletionHandler != nil) {
            (notificationPresentationCompletionHandler!)([])
            notificationPresentationCompletionHandler = nil
        }
        
        completionHandler(.noData)
    }
    
    // MARK: UNUserNotificationCenterDelegate
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        self.notificationResponseCompletionHandler = completionHandler
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                             willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        self.notificationPresentationCompletionHandler = completionHandler
        
        if (UIApplication.shared.applicationState == .background) {
            print("Notification received in the background")
        }
        
        if (notificationResponseCompletionHandler != nil) {
            print("Tapped Notification")
        } else {
            print("Notification received in the foreground")
        }
        
        if (self.notificationPresentationCompletionHandler != nil) {
            (self.notificationPresentationCompletionHandler!)([.badge, .sound])
            self.notificationPresentationCompletionHandler = nil
        }
    }
}

