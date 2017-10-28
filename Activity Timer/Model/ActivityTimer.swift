//
//  ActivityTimer.swift
//  Activity Timer
//
//  Created by Allan Lykke Christensen on 07/10/2017.
//  Copyright © 2017 Allan Lykke Christensen. All rights reserved.
//

import Foundation

/// Model representing the actual timer contain the start time, duration and elapsed time. It also contains notifies the delegates when the timer has finished and when it is updated.
class ActivityTimer {

    var delegate: ActivityTimerProtocol?
    var timer: Timer? = nil
    var startTime: Date?
    var duration: TimeInterval = 360
    var elapsedTime: TimeInterval = 0
    
    /// Read-only property determining if the timer has finished counting down
    var isStopped: Bool {
        return timer == nil && elapsedTime == 0
    }
    
    /// Read-only property determining if the user has paused the timer during count down
    var isPaused: Bool {
        return timer == nil && elapsedTime > 0
    }
    
    @objc dynamic func timerAction() {
        guard let startTime = startTime else {
            return
        }
        
        elapsedTime = -startTime.timeIntervalSinceNow
        
        let secondsRemaining = (duration - elapsedTime).rounded()
        
        if secondsRemaining <= 0 {
            resetTimer()
            delegate?.timerHasFinished(self)
        } else {
            delegate?.timeRemainingOnTimer(self, timeRemaining: secondsRemaining)
        }
    }
    
    func startTimer() {
        startTime = Date()
        elapsedTime = 0
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        timerAction()
    }
    
    func resumeTimer() {
        startTime = Date(timeIntervalSinceNow: -elapsedTime)
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        timerAction()
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        
        timerAction()
    }
    
    func resetTimer() {
        timer?.invalidate();
        timer = nil
        startTime = nil
        duration = 360
        elapsedTime = 0
        
        timerAction()
    }
}

protocol ActivityTimerProtocol {
    func timeRemainingOnTimer(_ timer: ActivityTimer, timeRemaining: TimeInterval)
    func timerHasFinished(_ timer: ActivityTimer)
}
