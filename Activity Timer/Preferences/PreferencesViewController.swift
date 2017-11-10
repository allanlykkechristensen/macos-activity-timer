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
    @IBOutlet weak var durationHours: NSPopUpButton!
    @IBOutlet weak var durationMinutes: NSPopUpButton!
    @IBOutlet weak var durationSeconds: NSPopUpButton!
    @IBOutlet weak var alarmSoundUrl: NSTextField!
    @IBOutlet weak var durationHoursInput: NSTextField!
    @IBOutlet weak var appearance: NSPopUpButton!
    
    var prefs = PreferencesModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        populateDuration()
        loadPreferences(
        )
    }
    
    // MARK: Event Handlers
    
    @IBAction func hoursStepper(_ sender: NSStepper) {
        durationHoursInput.stringValue = sender.stringValue
    }
    
    @IBAction func alarmSoundSelectClicked(_ sender: Any) {
        guard let window = view.window else { return }
        
        let dialog = NSOpenPanel()
        dialog.title = "Choose the sound file to play when time is up"
        dialog.canChooseDirectories = false
        dialog.allowsMultipleSelection = false
        dialog.allowedFileTypes = ["wav", "mp3", "aac", "adts", "ac3", "aif", "aiff", "aifc", "caf", "mp4", "m4a", "snd", "au", "sd2"]
        
        dialog.beginSheetModal(for: window) { (result) in
            if result == .OK {
                self.alarmSoundUrl.stringValue = (dialog.url?.absoluteString)!
            }
        }
    }
    
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
        alarmSoundUrl.stringValue = prefs.selectedAlarmSound
        appearance.selectItem(withTag: prefs.selectedAppearance)
    }
    
    func savePreferences() {
        let totalTime = durationSeconds.selectedItem!.tag + (durationMinutes.selectedItem!.tag * 60) + (durationHours.selectedItem!.tag * 60 * 60)
        prefs.selectedTime = Double(totalTime)
        prefs.selectedAlarmSound = alarmSoundUrl.stringValue
        prefs.selectedAppearance = appearance.selectedItem!.tag

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
