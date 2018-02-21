//
//  NSDate+RelativeDate.swift
//  horoscopeclient1
//
//  Created by OD2 on 19/02/2018.
//  Copyright © 2018 rightmeow. All rights reserved.
//

import Foundation

extension Date {
    
    func toRelativeDay() -> Int {
        let secondsAgo = Int(Date().timeIntervalSince(self))
        let minutesAgo = secondsAgo / 60
        let hoursAgo = minutesAgo / 60
        let daysAgo = hoursAgo / 24
        return daysAgo
    }
    
}
