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
    @IBOutlet weak var timeLeftField: NSTextField!
    var activityTimer = ActivityTimer()
    var prefs = Preferences()
    var soundPlayer: AVAudioPlayer?
    
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

    // MARK: - Button Actions
    @IBAction func timerClicked(_ sender: NSButton) {
        if sender.title == "||" {
        sender.title = ">"
            startTimer()
        } else {
        sender.title = "||"
            stopTimer()
        }
    }
    
    // MARK: - Menu Selection
    @IBAction func startTimerMenuItemSelected(_ sender: Any) {
        startTimer()
    }
    
    @IBAction func stopTimerMenuItemSelected(_ sender: Any) {
        stopTimer()
    }
    
    @IBAction func resetTimerMenuItemSelected(_ sender: Any) {
        resetTimer()
    }
    
}

// MARK: - Activity Timer Methods
extension ViewController {
    
    func startTimer() {
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
        activityTimer.stopTimer()
        configureButtonsAndMenus()
    }
    
    func resetTimer() {
        activityTimer.resetTimer()
        updateDisplay(for: prefs.selectedTime)
        configureButtonsAndMenus()
    }
}


// MARK: - Activity Timer Protocol
extension ViewController : ActivityTimerProtocol {
    func timeRemainingOnTimer(_ timer: ActivityTimer, timeRemaining: TimeInterval) {
        updateDisplay(for: timeRemaining)
    }
    
    func timerHasFinished(_ timer: ActivityTimer) {
        updateDisplay(for: 0)
        playSound()
    }
}

extension ViewController {
    func updateDisplay(for timeRemaining: TimeInterval) {
        timeLeftField.stringValue = textToDisplay(for: timeRemaining)
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
            enableStart = true
            enableStop = true
            enableReset = false
        }
        
        
        if let appDel = NSApplication.shared.delegate as? AppDelegate {
            appDel.enableMenus(start: enableStart, stop: enableStop, reset: enableReset)
        }
        
    }
    
    private func textToDisplay(for timeRemaining: TimeInterval) -> String {
        if timeRemaining == 0 {
            return "Time is up!!"
        }
        
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