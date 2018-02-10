//
//  URL.swift
//  newsclient
//
//  Created by rightmeow on 1/25/18.
//  Copyright © 2018 odinternational. All rights reserved.
//

import Foundation

extension URL {

    func is_valid() -> Bool {
        let urlRegEx = "(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+"
        let urlTest = NSPredicate(format:"SELF MATCHES %@", urlRegEx)
        let result = urlTest.evaluate(with: self)
        return result
    }

}
