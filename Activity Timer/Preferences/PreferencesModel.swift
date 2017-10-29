//
//  Preferences.swift
//  Activity Timer
//
//  Created by Allan Lykke Christensen on 07/10/2017.
//  Copyright © 2017 Allan Lykke Christensen. All rights reserved.
//

import Foundation
import AppKit

struct PreferencesModel {
    
    let selectedTimeDefault: Double = 360.0
    enum PreferenceKey: String {
        case selectedTime = "selectedTime"
    }
    
    /// Resets the user preferences but removing all persisted preferences.
    func reset() {
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
        UserDefaults.standard.set(selectedTimeDefault, forKey: PreferenceKey.selectedTime.rawValue)
    }
    
    /// Property containing the duration used by the timer in seconds.
    /// Uses UserDefaults for persistence.
    var selectedTime: TimeInterval {
        get {
            return UserDefaults.standard.double(forKey: PreferenceKey.selectedTime.rawValue)
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: PreferenceKey.selectedTime.rawValue)
        }
    }
    
    /// Read-only property returning the number of hours set for the timer
    var selectedHours: Int {
        get {
            return ((Int(selectedTime) / 60) / 60)
        }
    }
    
    /// Read-only property returning the number of minutes set for the timer
    var selectedMinutes: Int {
        get {
            return ((Int(selectedTime) / 60) % 60)
        }
    }
    
    /// Read-only property returning the number of seconds set for the timer
    var selectedSeconds: Int {
        get {
            return Int(selectedTime) % 60
        }
    }
}
