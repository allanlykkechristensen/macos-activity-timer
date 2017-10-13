//
//  PrefsViewController.swift
//  Activity Timer
//
//  Created by Allan Lykke Christensen on 07/10/2017.
//  Copyright © 2017 Allan Lykke Christensen. All rights reserved.
//

import Cocoa

class PrefsViewController: NSViewController {

    @IBOutlet weak var customTimingLabel: NSTextField!
    @IBOutlet weak var presetPopup: NSPopUpButton!
    @IBOutlet weak var customTimingsSlider: NSSlider!
    var prefs = Preferences()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        showExistingPrefs()
    }
    
    @IBAction func popupValueChanged(_ sender: NSPopUpButton) {
        if sender.selectedItem?.title == "Custom" {
            customTimingsSlider.isEnabled = true
            return
        }
        
        let newTimerDuration = sender.selectedTag()
        customTimingsSlider.integerValue = newTimerDuration
        showSliderValuesAsText()
        customTimingsSlider.isEnabled = false
    }
    @IBAction func customTimingChanged(_ sender: NSSlider) {
        showSliderValuesAsText()
    }
    @IBAction func cancelClicked(_ sender: Any) {
        view.window?.close()
    }
    @IBAction func okClicked(_ sender: Any) {
        saveNewPrefs();
        view.window?.close()
    }
    
    func showExistingPrefs() {
        let selectedTimeInMinutes = Int(prefs.selectedTime) / 60
        presetPopup.selectItem(withTitle: "Custom")
        customTimingsSlider.isEnabled = true
        
        for item in presetPopup.itemArray {
            if item.tag == selectedTimeInMinutes {
                presetPopup.select(item)
                customTimingsSlider.isEnabled = false
                break
            }
        }
        
        customTimingsSlider.integerValue = selectedTimeInMinutes
        showSliderValuesAsText()
    }
    
    func showSliderValuesAsText() {
        let newTimerDuration = customTimingsSlider.integerValue
        let minutesDescription = (newTimerDuration == 1) ? "minute" : "minutes"
        customTimingLabel.stringValue = "\(newTimerDuration) \(minutesDescription)"
    }
    
    func saveNewPrefs() {
        prefs.selectedTime = customTimingsSlider.doubleValue * 60
        NotificationCenter.default.post(name: Notification.Name(rawValue: "PrefsChanged") , object: nil)
    }
}
