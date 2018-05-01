//
//  AssassinLeaperConfigs.swift
//  assassin_leaper_admin
//
//  Created by OD2 on 27/02/2018.
//  Copyright © 2018 od-international. All rights reserved.
//

import Foundation
import Alamofire

@available(*, deprecated, message: "This class is deprecated, please use AssassinLeaperManager and AssassinLeaperConfigs instead.")
struct AssassinLeaperFacade {
    
    static let shared = AssassinLeaperFacade()
    let trainerUsername = "jintrainer001"
    let trainerPasscode = "ad4e7ae18d46424eac95eb215bc4f5ed"
    let leaperToken = "14bdba05e1baec6eb68251568c25363d"
    private let baseURL = "http://ec2-34-212-24-65.us-west-2.compute.amazonaws.com"
    private let headers: [String : String] = ["Content-Type" : "application/json"]
    typealias CompletionHandler = (_ data: Any?, _ error: Error?) -> Void
    
    // trainer
    
    private enum TrainerSessionKey: String {
        case kTrainerSession
        case sessionToken
        case createdAt
        case expiredAt
    }
    
    func loginTrainer(trainerUsername: String, passcode: String, completion: @escaping CompletionHandler) {
        Alamofire.request(baseURL+"/trainer", method: HTTPMethod.post, parameters: ["service_code": "login_trainer", "payload": ["username": trainerUsername, "passcode": passcode]], encoding: JSONEncoding.default, headers: headers).responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.mutableContainers) { (response) in
            switch response.result {
            case .success(let value):
                completion(value, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
    func logoutTrainer(trainerToken: String, completion: @escaping (Bool) -> Void) {
        Alamofire.request(baseURL+"trainerdetail", method: HTTPMethod.post, parameters: ["service_code": "logout_trainer", "trainer_token": trainerToken], encoding: JSONEncoding.default, headers: headers).responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.mutableContainers) { (response) in
            switch response.result {
            case .success(let value):
                if let unwrappedValue = value as? NSDictionary, let status = unwrappedValue["status"] as? Bool {
                    completion(status)
                } else {
                    completion(false)
                }
            case .failure(let error):
                print(error.localizedDescription)
                completion(false)
            }
        }
    }
    
    func trainerToken() -> String? {
        let dictionary = UserDefaults.standard.dictionary(forKey: TrainerSessionKey.kTrainerSession.rawValue)
        let token = dictionary?[TrainerSessionKey.sessionToken.rawValue] as? String
        return token
    }
    
    func saveTrainerToken(trainerToken: String) {
        let dictionary = NSDictionary(dictionary: [TrainerSessionKey.sessionToken.rawValue: trainerToken, TrainerSessionKey.createdAt.rawValue: NSDate()])
        UserDefaults.standard.set(dictionary, forKey: TrainerSessionKey.kTrainerSession.rawValue)
    }
    
    func isTrainerTokenValid(trainerSession: NSDictionary, isValidFor days: Int) -> Bool {
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
    
    // victim
    
    private enum VictimSessionKey: String {
        case kVictimSession
        case sessionToken
    }
    
    func victimToken() -> String? {
        do {
            let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName, account: VictimSessionKey.sessionToken.rawValue, accessGroup: nil)
            let token = try passwordItem.readPassword()
            return token
        } catch let err {
            print(err.localizedDescription)
            return nil
        }
    }
    
    func createVictim(trainerToken: String, leaperToken: String, deviceToken: String, completion: @escaping CompletionHandler) {
        Alamofire.request(baseURL+"/victim", method: HTTPMethod.post, parameters: ["service_code": "victim_create", "trainer_token": trainerToken, "payload": ["leaper_token": leaperToken, "push_token": deviceToken]], encoding: JSONEncoding.default, headers: headers).responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.mutableContainers) { (response) in
            switch response.result {
            case .success(let value):
                completion(value, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
    func saveVictimToken(token: String) {
        do {
            let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName, account: VictimSessionKey.sessionToken.rawValue, accessGroup: nil)
            try passwordItem.savePassword(token)
        } catch let err {
            fatalError("Error saving victim token - \(err.localizedDescription)")
        }
    }
    
    // update victim when device token has changed
    func updateVictim(trainerToken: String, victimToken: String, deviceToken: String, completion: @escaping CompletionHandler) {
        Alamofire.request(baseURL+"/victim", method: HTTPMethod.post, parameters: ["service_code": "victim_update", "trainer_token": trainerToken, "payload": ["victim_token": victimToken, "pack": ["push_token": deviceToken]]], encoding: JSONEncoding.default, headers: headers).responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.mutableContainers) { (response) in
            switch response.result {
            case .success(let value):
                completion(value, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
    func victimPush(trainerToken: String, leaperToken: String, victimToken: String, completion: @escaping CompletionHandler) {
        Alamofire.request(baseURL+"/victim", method: HTTPMethod.post, parameters: ["service_code": "victim_push", "trainer_token": trainerToken, "payload": ["leaper_token": leaperToken, "victim_token": victimToken, "is_production": 1]], encoding: JSONEncoding.default, headers: headers).responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.mutableContainers) { (response) in
            switch response.result {
            case .success(let value):
                completion(value, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
    // shadow
    
    func requestShadow(trainerToken: String, victimToken: String, completion: @escaping CompletionHandler) {
        Alamofire.request(baseURL+"/victim", method: HTTPMethod.post, parameters: ["service_code": "request_shadow", "trainer_token": trainerToken, "payload": ["victim_token": victimToken]], encoding: JSONEncoding.default, headers: headers).responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.mutableContainers) { (response) in
            switch response.result {
            case .success(let value):
                completion(value, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
    func findShadow(trainerToken: String, leaperToken: String, completion: @escaping CompletionHandler) {
        Alamofire.request(baseURL+"/leaper", method: HTTPMethod.post, parameters: ["service_code": "find_shadow", "trainer_token": trainerToken, "payload": ["leaper_token": leaperToken]], encoding: JSONEncoding.default, headers: headers).responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.mutableContainers) { (response) in
            switch response.result {
            case .success(let value):
                completion(value, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
}


