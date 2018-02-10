//
//  Constants.swift
//  horoscopeclient
//
//  Created by rightmeow on 1/30/18.
//  Copyright © 2018 odinternational. All rights reserved.
//

import Foundation

let kOnboardingCompletion = "kOnboardingCompletion"
let kSessionToken = "kSessionToken"
let kDeviceToken = "kDeviceToken" // whether or not a deviceToken exists in Keychain
let kApiKey = "kApiKey" // whether or not a apiKey exists in Keychain

struct KeychainConfiguration {
    static let serviceName = "horoscopeclient"
    static let account = "horoscopeclient_device_token"
    static let accessGroup: String? = Bundle.main.bundleIdentifier!
}

struct AppleDeveloper {
    static let teamId = "P35AQV2SNV"
    static let keyId = "MPGC2L77E3"
    static let appId = "com.odinternational.horoscopeclient"
    static let teamName = "Jianfang Cao"
}

enum Star: String {
    case baiyang = "baiyang"
    case jinniu = "jinniu"
    case shuangzi = "shuangzi"
    case juxie = "juxie"
    case shizi = "shizi"
    case chunv = "chunv"
    case tianping = "tianping"
    case tianjie = "tianjie"
    case sheshou = "sheshou"
    case mohe = "mohe"
    case shuiping = "shuiping"
    case shuangyu = "shuangyu"
}

struct WebServiceConfiguration {
    static let baseUrl = "https://route.showapi.com/872-1"
    static let showapi_sign = "bd2bd7f429d246f0a7770d3a48ee0165"
    static let showapi_appid = "56246"
    static let star = ""
    static let needYear = "1"
    static let needMonth = "1"
}

struct ElephantWebServiceConfig {
    static let base_url = "https://elephantcrm888.com"
    static let param = ""
}

struct Segue {
    static let ConstellationsViewControllerToDetailsViewController = "ConstellationsViewControllerToDetailsViewController"
    static let DetailsViewControllerToContainerViewOneController = "DetailsViewControllerToContainerViewOneController"
    static let DetailsViewControllerToContainerViewTwoController = "DetailsViewControllerToContainerViewTwoController"
    static let DetailsViewControllerToContainerViewThreeController = "DetailsViewControllerToContainerViewThreeController"
}
