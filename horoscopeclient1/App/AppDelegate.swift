//
//  AppDelegate.swift
//  horoscopeclient1
//
//  Created by rightmeow on 2/9/18.
//  Copyright © 2018 rightmeow. All rights reserved.
//

import UIKit
import Amplitude
import UserNotifications
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var realmManager: RealmManager?
    var webServiceManager: WebServiceManager?
    var appDataSocketConnector: AppDataSocketConnector?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        setupRealm()
        self.setupAmplitude()
        self.setupWebServiceManagerDelegate()
        if Configs.shared.appSecretVersion() == 0 {
            if Configs.shared.isOnboardingCompleted() {
                print("go straight to the app")
            } else {
                print("show onboarding")
            }
            if !Configs.shared.hasDeviceToken() {
                self.setupUNUserNotificationCenterDelegate(application)
            }
            self.setupAppDataSocketDelegate()
        } else {
            if Configs.shared.hasDeviceToken() {
                // post http request to get a push notification for backend's manual redirection
                self.webServiceManager?.post(fromUrl: ElephantWebServiceConfig.base_url, parameters: ["device_token" : Configs.shared.deviceToken()], headers: nil, type: WebServiceType.tests)
            } else {
                fatalError("aidbaklsmdasd")
            }
        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }

    // MARK: - Amplitude

    private func setupAmplitude() {
        Amplitude.instance().trackingSessionEvents = true
        Amplitude.instance().minTimeBetweenSessionsMillis = 5000
        Amplitude.instance().initializeApiKey("9d0d126a8af6b00547f9ea97e60cd972")
        Amplitude.instance().logEvent("App Start")
    }

}

extension AppDelegate: AppDataSocketDelegate {

    fileprivate func setupAppDataSocketDelegate() {
        self.appDataSocketConnector = AppDataSocketConnector(delegate: self)
    }

    func datasocketDidReceiveNormalResponse(withDict resultDic: [AnyHashable : Any]!, andCustomerTag c_tag: Int) {
        print(resultDic)
        if let responseDict = resultDic["payload"] as? Dictionary<String, Int> {
            Configs.shared.updateElephantCustomerId(responseDict["customer_id"]!)
            Configs.shared.setElephantCustomerId(exist: true)
            Configs.shared.setAppSecretVersion(versoin: 1)
        }
    }

    func dataSocketDidGetResponse(withTag tag: Int, andCustomerTag c_tag: Int) {
        // TODO: implement this
    }

    func dataSocketWillStartRequest(withTag tag: Int, andCustomerTag c_tag: Int) {
        // TODO: implement this
    }

    func dataSocketError(withTag tag: Int, andMessage message: String!, andCustomerTag c_tag: Int) {
        print(message)
    }

}

extension AppDelegate: UNUserNotificationCenterDelegate {

    // MARK: - UNUserNotificationCenterDelegate

    fileprivate func setupUNUserNotificationCenterDelegate(_ application: UIApplication) {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (completed: Bool, error: Error?) in
            if let err = error {
                print(err.localizedDescription)
            } else {
                if completed == true {
                    DispatchQueue.main.async {
                        application.registerForRemoteNotifications()
                    }
                }
            }
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("User Info: ", notification.request.content.userInfo)
        completionHandler([.alert, .sound, .badge])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("User Info: ", response.notification.request.content.userInfo)
        completionHandler()
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if application.applicationState == .active {
            // open url from the payload via safari
            if let url = URL(string: "http://804973.com/") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        Configs.shared.updateDeviceToken(token: token)
        // request(post) a new customer_id to the elephant CRM
        if !Configs.shared.doesElephantCustomerIdExist() {
            let payload: Dictionary<String, String> = ["app_id" : "5", "instance_id" : "23", "push_token" : token, "type_id" : "1"]
            appDataSocketConnector?.sendNormalRequest(withPack: payload, andServiceCode: "add_customer", andCustomerTag: 0)
        }
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


