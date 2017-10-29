//
//  PrefsViewController.swift
//  Activity Timer
//
//  Created by Allan Lykke Christensen on 07/10/2017.
//  Copyright © 2017 Allan Lykke Christensen. All rights reserved.
//

import Cocoa

class PreferencesViewController: NSViewController {

    @IBOutlet weak var preferencesView: PreferencesView!
    @IBOutlet weak var timerColor: NSColorWell!
    @IBOutlet weak var durationHours: NSPopUpButton!
    @IBOutlet weak var durationMinutes: NSPopUpButton!
    @IBOutlet weak var durationSeconds: NSPopUpButton!
    
    var prefs = PreferencesModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        populateDuration()
        loadPreferences()
    }
    
    // MARK: Event Handlers
    
    @IBAction func cancelClicked(_ sender: Any) {
        view.window?.close()
    }
    @IBAction func okClicked(_ sender: Any) {
        savePreferences();
        view.window?.close()
    }
    @IBAction func resetClicked(_ sender: Any) {
        prefs.reset()
        loadPreferences()
    }
    
    // MARK: Helpers
    
    func loadPreferences() {
        durationHours.selectItem(withTag: prefs.selectedHours)
        durationMinutes.selectItem(withTag: prefs.selectedMinutes)
        durationSeconds.selectItem(withTag: prefs.selectedSeconds)
        timerColor.color = prefs.selectedTimerColor
    }
    
    func savePreferences() {
        let totalTime = durationSeconds.selectedItem!.tag + (durationMinutes.selectedItem!.tag * 60) + (durationHours.selectedItem!.tag * 60 * 60)
        prefs.selectedTime = Double(totalTime)
        prefs.selectedTimerColor = timerColor.color
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "PrefsChanged") , object: nil)
    }
    
    // TODO: plural/singular hack, figure out if there is a "native" way of obtaining the right localized label
    private func populateDuration() {
        for hours in 0...23 {
            var label = "s"
            if (hours == 1) {
                label = ""
            }
            durationHours.addItem(withTitle: "\(hours) hour\(label)")
            durationHours.lastItem?.tag = hours
        }
        
        for index in 0...59 {
            var label = "s"
            if (index == 1) {
                label = ""
            }
            durationMinutes.addItem(withTitle: "\(index) minute\(label)")
            durationMinutes.lastItem?.tag = index
            durationSeconds.addItem(withTitle: "\(index) second\(label)")
            durationSeconds.lastItem?.tag = index
        }
    }
}
