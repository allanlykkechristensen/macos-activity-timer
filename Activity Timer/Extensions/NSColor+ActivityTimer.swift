//
//  NSColor+ActivityTimerColors.swift
//  Activity Timer
//
//  Created by Allan Lykke Christensen on 10/11/2017.
//  Copyright © 2017 Allan Lykke Christensen. All rights reserved.
//

import Foundation
import Cocoa


extension NSColor {
    
    static var timerRed: NSColor {
        return NSColor.init(red: 0.8877115846, green: 0.09418729693, blue: 0.2120215893, alpha: 1.0)
    }
    
    static var timerGreen: NSColor {
        return NSColor.init(red: 0.1063823178, green: 0.5104653835, blue:  0.4335432053, alpha: 1.0)
    }
    
    static var timerYellow: NSColor {
        return NSColor.init(red: 0.887315094470978, green: 0.671407163143158, blue: 0.376013815402985, alpha: 1.0)
    }
    
    static var timerBlue: NSColor {
        return NSColor.init(red: 0.264534741640091, green: 0.528173387050629, blue: 0.862399160861969, alpha: 1.0)
    }
}
