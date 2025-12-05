//
//  BoxingTimerManager.swift
//  boxtrack
//
//  Created by Karan Bassi on 2025-11-22.
//

import Foundation
import Combine
import AVFoundation

class BoxingTimerManager: ObservableObject {
    static let shared = BoxingTimerManager()
    
    @Published var currentTime: Int = 180  // 3:00 in seconds
    @Published var isWorking: Bool = true  // true = working, false = rest
    @Published var isRunning: Bool = true  // Always running
    @Published var currentRound: Int = 1
    
    // New: Publish events when rounds complete
    let roundCompleted = PassthroughSubject<Void, Never>()
    let restCompleted = PassthroughSubject<Void, Never>()
    
    private var timer: Timer?
    private var audioPlayer: AVAudioPlayer?
    
    var workingTime: Int = 180  // 3:00 default
    var restTime: Int = 30      // 0:30 default
    
    private init() {
        startTimer()
    }
    
    var timeDisplay: String {
        let minutes = currentTime / 60
        let seconds = currentTime % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    func startTimer() {
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }
    
    func stopTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    func resetTimer() {
        currentTime = workingTime
        isWorking = true
        currentRound = 1
    }
    
    // Reset timer for new workout
    func resetForWorkout() {
        currentTime = workingTime
        isWorking = true
        currentRound = 1
        playBellSound()
    }
    
    private func tick() {
        if currentTime > 0 {
            currentTime -= 1
        } else {
            // Time's up - switch between working and rest
            if isWorking {
                // Working period ended - round complete!
                playBellSound()
                roundCompleted.send()  // ← Notify listeners
                
                // Switch to rest
                isWorking = false
                currentTime = restTime
            } else {
                // Rest period ended - new round starts
                playBellSound()
                restCompleted.send()  // ← Notify listeners
                
                // Switch to working (new round)
                isWorking = true
                currentTime = workingTime
                currentRound += 1
            }
        }
    }
    
    func updateTimerSettings(working: Int, rest: Int) {
        workingTime = working
        restTime = rest
        
        // Reset to new settings
        currentTime = working
        isWorking = true
    }
    
    private func playBellSound() {
        // Play system sound (bell)
        AudioServicesPlaySystemSound(1013) // 1013 is a bell-like sound
    }
}
