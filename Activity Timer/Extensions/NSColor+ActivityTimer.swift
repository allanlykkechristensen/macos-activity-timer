//
//  NSColor+ActivityTimer.swift
//  Activity Timer
//
//  Created by Allan Lykke Christensen on 12/10/2017.
//  Copyright © 2017 Allan Lykke Christensen. All rights reserved.
//

import Foundation
import Cocoa

/// NSColor Extension to support colors used in to display the timer
extension NSColor {
    static var pieChartTimeRemainingFillColor: NSColor {
        return NSColor.red
    }
    
    static var pieChartTimeSpentFillColor: NSColor {
        return NSColor.white
    }
}
