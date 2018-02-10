//
//  Sign.swift
//  horoscopeclient
//
//  Created by rightmeow on 1/29/18.
//  Copyright © 2018 odinternational. All rights reserved.
//

import Foundation

class Constellation: NSObject {

    var image_name: String
    var name: String
    var pingying: String
    var title: String?
    var subtitle: String?

    init(image_name: String, name: String, pingying: String) {
        self.image_name = image_name
        self.name = name
        self.pingying = pingying
    }

}
