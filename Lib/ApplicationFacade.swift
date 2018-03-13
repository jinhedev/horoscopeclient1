//
//  Configs.swift
//  assassin_leaper_admin
//
//  Created by OD2 on 27/02/2018.
//  Copyright © 2018 od-international. All rights reserved.
//

import Foundation
import Reachability
import UserNotifications

struct ApplicationFacade {
    
    static let shared = ApplicationFacade()
    
    // bundle
    
    var displayName: String? {
        return Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String
    }
    
    var bundleName: String {
        return Bundle.main.infoDictionary?[kCFBundleNameKey as String] as! String
    }
    
    var releaseVersion: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    }
    
    var buildVersion: String {
        return Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as! String
    }
    
    var bundleId: String {
        return Bundle.main.bundleIdentifier!
    }
    
    func pathForBundle() -> String {
        return ""
    }
    
    // sandbox
    
    func documentDirectory() -> String {
        let path = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first?.path
        return path!
    }
    
    // onboarding
    
    // [0, x]
    let maxOnboardingStep: Int = 1
    private let kOnboardingStep: String = "kOnboardingStep"
    
    func currentOnboardingStep() -> Int {
        let onboardingStep = UserDefaults.standard.integer(forKey: kOnboardingStep)
        return onboardingStep
    }
    
    func saveCurrentOnboardingProgress(currentStep: Int) {
        UserDefaults.standard.set(currentStep, forKey: kOnboardingStep)
    }
    
    func isOnboardingCompleted() -> Bool {
        let currentOnboardingStep = UserDefaults.standard.integer(forKey: kOnboardingStep)
        return currentOnboardingStep >= maxOnboardingStep
    }
    
    func isFreshLaunch() -> Bool {
        let currentOnboardingStep = UserDefaults.standard.integer(forKey: kOnboardingStep)
        return currentOnboardingStep <= 0
    }
    
    // apns
    
    var isRegisterForRemoteNotifications: Bool {
        return UIApplication.shared.isRegisteredForRemoteNotifications
    }
    
    typealias BinaryCompletionHandler = (Bool) -> Void
    
    func isRemoteNotificationsGranted(completed: @escaping BinaryCompletionHandler) {
        let current = UNUserNotificationCenter.current()
        current.getNotificationSettings { (settings) in
            switch settings.authorizationStatus {
            case .authorized:
                completed(true)
            case .denied:
                completed(false)
            case .notDetermined:
                completed(false)
            }
        }
    }
    
    func deviceToken() -> String? {
        let deviceToken = UserDefaults.standard.string(forKey: "kDeviceToken")
        return deviceToken
    }
    
    func saveDeviceToken(deviceToken: String) {
        UserDefaults.standard.set(deviceToken, forKey: "kDeviceToken")
    }
    
    // ip address
    
    func isReachable() -> Bool {
        let reachability = Reachability()!
        if reachability.connection == .wifi || reachability.connection == .cellular {
            return true
        } else {
            return false
        }
    }
    
    func ipAddress() -> String? {
        var address : String?
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        guard let firstAddr = ifaddr else { return nil }
        // For each interface ...
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee
            // Check for IPv4 or IPv6 interface:
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                // Check interface name:
                let name = String(cString: interface.ifa_name)
                if  name == "en0" {
                    // Convert interface address to a human readable string:
                    var addr = interface.ifa_addr.pointee
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(&addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
        }
        freeifaddrs(ifaddr)
        return address
    }
    
}
