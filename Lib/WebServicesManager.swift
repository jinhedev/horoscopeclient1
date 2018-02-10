//
//  WebServiceManager.swift
//  newsclient
//
//  Created by rightmeow on 1/25/18.
//  Copyright © 2018 odinternational. All rights reserved.
//

import Foundation
import Alamofire
import UIKit

protocol WebServiceManagerDelegate: NSObjectProtocol {
    func webService(_ manager: WebServiceManager, didErr error: Error, type: WebServiceType)
    func webService(_ manager: WebServiceManager, didFetch data: Any, type: WebServiceType)
    func webService(_ manager: WebServiceManager, didPost data: Any, type: WebServiceType)
    func webService(_ manager: WebServiceManager, didPatch data: Any, type: WebServiceType)
    func webService(_ manager: WebServiceManager, didDelete data: Any, type: WebServiceType)
}

extension WebServiceManagerDelegate {
    func webService(_ manager: WebServiceManager, didFetch data: Any, type: WebServiceType) {}
    func webService(_ manager: WebServiceManager, didPost data: Any, type: WebServiceType) {}
    func webService(_ manager: WebServiceManager, didPatch data: Any, type: WebServiceType) {}
    func webService(_ manager: WebServiceManager, didDelete data: Any, type: WebServiceType) {}
}

/**
 WebServiceType is a user-define enum that specifies what type of data response the user expect to get.
 - warning: Expected response may or may not be the actual response. Be warned!
 */
enum WebServiceType {
    case tests
}

class WebServiceManager: NSObject {

    weak var delegate: WebServiceManagerDelegate?

    func fetch(fromUrl: String, parameters: [String : String]? = nil, headers: [String : String]? = nil, type: WebServiceType) {
        Alamofire.request(fromUrl, method: HTTPMethod.get, parameters: parameters, encoding: URLEncoding.default, headers: headers).responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.mutableContainers) { (response) in
            switch response.result {
            case .success(let value):
                self.delegate?.webService(self, didFetch: value, type: type)
            case .failure(let error):
                self.delegate?.webService(self, didErr: error, type: type)
            }
        }
    }

    func post(fromUrl: String, parameters: [String : Any]? = nil, headers: [String : String]? = nil, type: WebServiceType) {
        Alamofire.request(fromUrl, method: HTTPMethod.post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.mutableContainers) { (response) in
            switch response.result {
            case .success(let value):
                self.delegate?.webService(self, didPost: value, type: type)
            case .failure(let error):
                self.delegate?.webService(self, didErr: error, type: type)
            }
        }
    }

    func patch() {
        // TODO: implement this if needed
    }

    func delete() {
        // TODO: implement this if needed
    }

}
