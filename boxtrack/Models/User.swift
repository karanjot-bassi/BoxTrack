//
//  User.swift
//  boxtrack
//
//  Created by Karan Bassi on 2025-11-22.
//

import Foundation
import FirebaseFirestore

struct User: Codable, Identifiable {
    @DocumentID var id: String?
    var email: String
    var fighterName: String
    var age: Int
    var heightFeet: Int
    var heightInches: Int
    var weight: Double
    var level: FighterLevel
    var gym: String?
    var gymHistory: [String]?
    var timerSettings: TimerSettings
    var avatarId: String
    var record: FightRecord
    var createdAt: Date
    var stats: UserStats
    
    enum FighterLevel: String, Codable {
        case training = "training"
        case amateur = "amateur"
        case pro = "pro"
    }
    
    var heightDisplay: String {
        return "\(heightFeet)'\(heightInches)\""
    }
}

struct TimerSettings: Codable {
    var workingTime: Int // in seconds (defiualt 180 = 3:00)
    var restTime: Int
    
    init(workingTime: Int = 180, restTime: Int = 30) {
        self.workingTime = workingTime
        self.restTime = restTime
    }
    
    var workingTimeDisplay: String {
        let minutes = workingTime / 60
        let seconds = workingTime % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var restTimeDisplay: String {
        let minutes = restTime / 60
        let seconds = restTime % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}


struct FightRecord: Codable {
    var wins: Int
    var losses: Int
    var draws: Int
    
    init(wins: Int = 0, losses: Int = 0, draws: Int = 0) {
        self.wins = wins
        self.losses = losses
        self.draws = draws
    }
    var displayText: String {
        return "\(wins) - \(losses) - \(draws)"
    }
}


struct UserStats: Codable {
    var totalWorkouts: Int
    var currentStreak: Int
    var lastWorkoutDate: Date?
    var totalRounds: Int
    var currentWeight: Double
    var targetWeight: Double?
    
    init(initialWeight: Double = 0) {
        self.totalWorkouts = 0
        self.currentStreak = 0
        self.lastWorkoutDate = nil
        self.totalRounds = 0
        self.currentWeight = initialWeight
    }
}
