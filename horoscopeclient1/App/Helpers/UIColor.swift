//
//  Color.swift
//  newsclient
//
//  Created by rightmeow on 1/29/18.
//  Copyright © 2018 odinternational. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {

    class func hex(_ hexString: NSString, alpha: CGFloat) -> UIColor {
        var hexStr = hexString
        hexStr = hexStr.replacingOccurrences(of: "#", with: "") as NSString
        let scanner = Scanner(string: hexStr as String)
        var color: UInt32 = 0
        if scanner.scanHexInt32(&color) {
            let r = CGFloat((color & 0xFF0000) >> 16) / 255.0
            let g = CGFloat((color & 0x00FF00) >> 8) / 255.0
            let b = CGFloat(color & 0x000FFF) / 255.0
            return UIColor(red: r, green: g, blue: b, alpha: alpha)
        } else {
            print("Invalid hex string", terminator: "")
            return UIColor.white
        }
    }

}
