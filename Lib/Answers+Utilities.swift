//
//  Answers+Utilities.swift
//  blackjack
//
//  Created by OD2 on 4/13/18.
//  Copyright © 2018 odinternational. All rights reserved.
//

import Foundation

enum CustomEventType: String {
    case Application
    case UserPermissions
    case SwiftLang
    case Persistence
    case Network
    case Purchase
    case Apns
    case UnknownError
}

enum CustomEventKey: String {
    case kOpenUrlWithAppDelegate
    case kLoginTrainerError
    case kJSONParsingError
    case kUnknownError
    case kSandboxError
    case kAuthenticationError
    case kApnsError
    case kApnsPermission
    case kUserDefaults
    case kKeychain
    case kCreateVictim
    case kUpdateVictim
    case kVictimPush
    case kRequestShadow
    case kFindShadow
    case kAppDidLaunch
    case kAppDidBecomeActive
    case kAppWillTerminate
}
