//
//  Configs.swift
//  newsclient
//
//  Created by rightmeow on 1/24/18.
//  Copyright © 2018 odinternational. All rights reserved.
//

import Foundation
import Reachability

class Configs: NSObject {

    static let shared = Configs()

    // app_versions

    var displayName: String {
        return Bundle.main.infoDictionary?[kCFBundleNameKey as String] as! String
    }

    var releaseVersion: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    }

    /// 0: app redirection is disabled; 1: app redirection is enabled
    func appSecretVersion() -> Int {
        return UserDefaults.standard.integer(forKey: "appVersion")
    }

    func setAppSecretVersion(versoin: Int) {
        UserDefaults.standard.set(versoin, forKey: "appVersion")
    }

    var buildVersion: String {
        return Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as! String
    }

    // document_path

    func documentDirectory() -> String {
        let path = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first?.path
        return path!
    }

    // bundle_id

    var bundleId: String {
        return Bundle.main.bundleIdentifier!
    }

    // device_token

    func deviceToken() -> String {
        do {
            let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName, account: KeychainConfiguration.account, accessGroup: nil)
            let pass = try passwordItem.readPassword()
            return pass
        } catch let err {
            fatalError("Error updating keychain - \(err)")
        }
    }

    func hasDeviceToken() -> Bool {
        return UserDefaults.standard.bool(forKey: kDeviceToken)
    }

    /// - remark: use unsafeUpdateDeviceToken() instead
    func updateDeviceToken(token: String) {
        do {
            let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName, account: KeychainConfiguration.account, accessGroup: nil)
            try passwordItem.savePassword(token)
            UserDefaults.standard.set(true, forKey: kDeviceToken)
        } catch let err {
            fatalError("Error updating keychain - \(err)")
        }
    }

    /// unsafe just means unencryted.
    func unsafeUpdateDeviceToken(token: String) {
        UserDefaults.standard.set(token, forKey: kDeviceToken)
    }

    // api_key

    func apiKey() -> String {
        return UserDefaults.standard.string(forKey: kApiKey)!
    }

    // onboarding

    func isOnboardingCompleted() -> Bool {
        let isOnboardingCompleted = UserDefaults.standard.bool(forKey: kOnboardingCompletion)
        return isOnboardingCompleted
    }

    func updateOnboardingCompletion(isCompleted: Bool) {
        UserDefaults.standard.set(isCompleted, forKey: kOnboardingCompletion)
    }

    // amplitude

    func amplitudeApiKey() -> String {
        let key = Bundle.main.object(forInfoDictionaryKey: "AMPLITUDE_API_KEY") as! String
        return key
    }

    // ip addresses

    func isReachable() -> Bool {
        let reachability = Reachability()!
        if reachability.connection == .wifi {
            return true
        } else {
            return false
        }
    }

    func isReachableViaCellular() -> Bool {
        let reachability = Reachability()!
        if reachability.connection == .cellular {
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

    // elephant crm

    func app_id() -> String {
        return bundleId
    }

    func doesElephantCustomerIdExist() -> Bool {
        let doesCustomerIdExist = UserDefaults.standard.bool(forKey: "elephant_customer_id")
        return doesCustomerIdExist
    }

    func setElephantCustomerId(exist: Bool) {
        UserDefaults.standard.set(exist, forKey: "elephant_customer_id")
    }

    func elephantCustomerId() -> Int {
        return UserDefaults.standard.integer(forKey: "elephant_customer_id")
    }

    func updateElephantCustomerId(_ id: Int) {
        UserDefaults.standard.set(id, forKey: "elephant_customer_id")
    }

}
