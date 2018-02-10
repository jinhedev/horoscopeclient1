//
//  Color.swift
//  newsclient
//
//  Created by rightmeow on 1/24/18.
//  Copyright © 2018 odinternational. All rights reserved.
//

import Foundation
#if os(iOS)
    import UIKit
    typealias Color = UIColor
#elseif os(OSX)
    import AppKit
    typealias Color = NSColor
#endif

// MARK: - Color

extension Color {
    static var miamiBlue: Color { return #colorLiteral(red: 0, green: 0.5254901961, blue: 0.9764705882, alpha: 1) }
    static var creamWhite: Color { return #colorLiteral(red: 0.862745098, green: 0.862745098, blue: 0.862745098, alpha: 1) }
    static var specialPurple: Color { return #colorLiteral(red: 0.4980392157, green: 0.1647058824, blue: 0.9019607843, alpha: 1) }
    static var specialYellow: Color { return #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1) }
}
