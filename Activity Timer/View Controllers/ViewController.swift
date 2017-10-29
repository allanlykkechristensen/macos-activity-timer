//
//  ViewController.swift
//  Activity Timer
//
//  Created by Allan Lykke Christensen on 07/10/2017.
//  Copyright © 2017 Allan Lykke Christensen. All rights reserved.
//

import Cocoa
import AVFoundation

class ViewController: NSViewController {

    @IBOutlet weak var timerView: TimerView!
    @IBOutlet weak var timeLeftButton: NSButton!
    
    var soundPlayer: AVAudioPlayer?
    var started = false
    /// Reference to model: Activity Timer
    var activityTimer = ActivityTimer()
    /// Reference to model: Preferences
    var prefs = PreferencesModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        activityTimer.delegate = self
        setupPrefs()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}

// MARK: - Event Handlers
extension ViewController {
    
    @IBAction func timerClicked(_ sender: NSButton) {
        if !started {
            started = true
            startTimer()
        } else {
            started = false
            stopTimer()
        }
    }
    
    @IBAction func startTimerMenuItemSelected(_ sender: Any) {
        started = true
        startTimer()
    }
    
    @IBAction func stopTimerMenuItemSelected(_ sender: Any) {
        started = false
        stopTimer()
    }
    
    @IBAction func resetTimerMenuItemSelected(_ sender: Any) {
        started = false
        resetTimer()
    }
    
}

// MARK: - Activity Timer Methods
extension ViewController {
    
    func startTimer() {
        timerView.started = true
        if activityTimer.isPaused {
            activityTimer.resumeTimer()
        } else {
            activityTimer.duration = prefs.selectedTime
            activityTimer.startTimer()
        }
        configureButtonsAndMenus()
        prepareSound()
    }
    
    func stopTimer() {
        timerView.started = false
        activityTimer.stopTimer()
        configureButtonsAndMenus()
    }
    
    func resetTimer() {
        timerView.started = false
        activityTimer.resetTimer()
        updateDisplay(for: prefs.selectedTime)
        configureButtonsAndMenus()
    }
}


// MARK: - Model Notify: Activity Timer Protocol
extension ViewController : ActivityTimerProtocol {
    func timeRemainingOnTimer(_ timer: ActivityTimer, timeRemaining: TimeInterval) {
        updateDisplay(for: timeRemaining)
    }
    
    func timerHasFinished(_ timer: ActivityTimer) {
        timerView.started = false
        updateDisplay(for: 0)
        playSound()
    }
}

extension ViewController {
    func updateDisplay(for timeRemaining: TimeInterval) {
        
        // FIXME: Don't like to have the font values here - at least store them as a constant somewhere.
        timeLeftButton.attributedTitle = NSAttributedString(string: textToDisplay(for: timeRemaining), attributes: [ NSAttributedStringKey.foregroundColor : NSColor.red, NSAttributedStringKey.font: NSFont(name: "Arial Rounded MT Bold", size: 16)!])
        
        timerView.totalTime = prefs.selectedTime
        timerView.timeRemaining = timeRemaining / prefs.selectedTime
    }
    
    func configureButtonsAndMenus() {
        let enableStart: Bool
        let enableStop: Bool
        let enableReset: Bool
        
        if activityTimer.isStopped {
            enableStart = true
            enableStop = false
            enableReset = false
        } else if activityTimer.isPaused {
            enableStart = true
            enableStop = false
            enableReset = true
        } else {
            enableStart = false
            enableStop = true
            enableReset = false
        }
        
        
        if let appDel = NSApplication.shared.delegate as? AppDelegate {
            appDel.enableMenus(start: enableStart, stop: enableStop, reset: enableReset)
        }
        
    }
    
    private func textToDisplay(for timeRemaining: TimeInterval) -> String {        
        let minutesRemaining = floor(timeRemaining / 60)
        let secondsRemaining = timeRemaining - (minutesRemaining * 60)
        let secondsDisplay = String(format: "%02d", Int(secondsRemaining))
        let timeRemainingDisplay = "\(Int(minutesRemaining)):\(secondsDisplay)"
        
        return timeRemainingDisplay
    }
}

// MARK: - Preferences
extension ViewController {
    func setupPrefs() {
        updateDisplay(for: prefs.selectedTime)
        
        let notificationName = Notification.Name(rawValue: "PrefsChanged")
        NotificationCenter.default.addObserver(forName: notificationName, object: nil, queue: nil) {
            (notification) in self.checkForResetAfterPrefsChange()
        }
    }
    
    func updateFromPrefs() {
        self.activityTimer.duration = self.prefs.selectedTime
        resetTimer()
    }
    
    func checkForResetAfterPrefsChange() {
        if activityTimer.isStopped || activityTimer.isPaused {
            updateFromPrefs()
        } else {
            let alert = NSAlert()
            alert.messageText = "Reset timer with the new settings?"
            alert.informativeText = "This will stop your current timer!"
            alert.alertStyle = .warning
            
            alert.addButton(withTitle: "Reset")
            alert.addButton(withTitle: "Cancel")
            
            let response = alert.runModal()
            if response == NSApplication.ModalResponse.alertFirstButtonReturn {
                self.updateFromPrefs()
            }
        }
    }
}

// MARK: - Sound
extension ViewController {
    
    func prepareSound() {
        guard let audioFileUrl = Bundle.main.url(forResource: "alarm", withExtension: "wav") else {
            return
        }
        
        do {
            soundPlayer = try AVAudioPlayer(contentsOf: audioFileUrl)
            soundPlayer?.prepareToPlay()
        } catch {
            print("Sound player not available: \(error)")
        }
    }
    
    func playSound() {
        soundPlayer?.play()
    }
}
