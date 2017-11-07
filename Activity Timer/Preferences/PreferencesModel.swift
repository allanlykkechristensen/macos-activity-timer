//
//  Preferences.swift
//  Activity Timer
//
//  Created by Allan Lykke Christensen on 07/10/2017.
//  Copyright © 2017 Allan Lykke Christensen. All rights reserved.
//

import Foundation
import AppKit

/// PreferencesModel is a model containing the user preferences. Preferences are persisted in UserDefaults.
class PreferencesModel {
    
    let selectedTimeDefault: Double = 360.0
    let selectedTimerColorDefault = NSColor.init(red: 0.8877115846, green: 0.09418729693, blue: 0.2120215893, alpha: 1.0)
    
    enum PreferenceKey: String {
        case firstTimeLaunch = "firstTimeLaunch"
        case selectedTime = "selectedTime"
        case selectedTimerColor = "selectedTimerColor"
        case selectedAlarm = "selectedAlarm"
    }
    
    init() {
        // Initialize default preferences the first time
        if UserDefaults.standard.object(forKey: PreferenceKey.firstTimeLaunch.rawValue) == nil {
            reset()
        }
    }
    
    /// Resets the user preferences but removing all persisted preferences.
    func reset() {
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
        UserDefaults.standard.set(true, forKey: PreferenceKey.firstTimeLaunch.rawValue)
        self.selectedTimerColor = selectedTimerColorDefault
        self.selectedTime = selectedTimeDefault
    }
    
    /// Property containing the duration used by the timer in seconds.
    var selectedTime: TimeInterval {
        get {
            return UserDefaults.standard.double(forKey: PreferenceKey.selectedTime.rawValue)
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: PreferenceKey.selectedTime.rawValue)
        }
    }

    /// Property containing the duration used by the timer in seconds.
    var selectedTimerColor: NSColor {
        get {
            // Decode color from preferences
            let data = UserDefaults.standard.object(forKey: PreferenceKey.selectedTimerColor.rawValue) as? Data
            return NSKeyedUnarchiver.unarchiveObject(with: data!) as! NSColor
        }
        
        set {
            // Encode color to be savable in UserDefaults
            let data : Data = NSKeyedArchiver.archivedData(withRootObject: newValue)
            UserDefaults.standard.set(data, forKey: PreferenceKey.selectedTimerColor.rawValue)
        }
    }

    /// Property containing the URL of the Alarm sound
    var selectedAlarmSound : String {
        get {
            if let alarmSoundUrl = UserDefaults.standard.string(forKey: PreferenceKey.selectedAlarm.rawValue) {
                return alarmSoundUrl
            } else {
                if let defaultAlarmSoundUrl = Bundle.main.url(forResource: "alarm", withExtension: "wav") {
                return defaultAlarmSoundUrl.absoluteString
                } else {
                    return ""
                }
            }
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: PreferenceKey.selectedAlarm.rawValue)
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
