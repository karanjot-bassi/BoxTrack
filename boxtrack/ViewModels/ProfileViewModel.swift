//
//  ProfileViewModel.swift
//  boxtrack
//
//  Created by Karan Bassi on 2025-12-04.
//

import Foundation
import SwiftUI
import Combine
import FirebaseAuth

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var user: User?
    @Published var sparringRounds: Int = 0
    @Published var lastWorkoutDuration: String = "0m"
    @Published var lastWorkoutDate: String = "Never"
    @Published var isLoading = true
    @Published var showError = false
    @Published var errorMessage = ""
    
    private let userService = UserService.shared
    private let workoutService = WorkoutService.shared
    private let authService = AuthService.shared
    
    // MARK: - Load Profile
    
    func loadProfile() async {
        guard let userId = authService.currentUser?.uid else {
            showErrorAlert("No user signed in")
            isLoading = false
            return
        }
        
        isLoading = true
        
        do {
            // 1. Fetch user data
            user = try await userService.getUser(userId: userId)
            
            // 2. Fetch workout history
            let workouts = try await workoutService.getUserWorkoutSessions(
                userId: userId,
                limit: 50 // Get more workouts for accurate sparring count
            )
            
            // 3. Calculate sparring rounds
            sparringRounds = calculateSparringRounds(from: workouts)
            
            // 4. Get last workout info
            if let lastWorkout = workouts.first {
                lastWorkoutDuration = formatDuration(lastWorkout.duration ?? 0)
                lastWorkoutDate = formatDate(lastWorkout.date)
            } else {
                lastWorkoutDuration = "0m"
                lastWorkoutDate = "Never"
            }
            
        } catch {
            showErrorAlert("Failed to load profile: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    // MARK: - Calculate Sparring Rounds
    
    func calculateSparringRounds(from workouts: [WorkoutSession]) -> Int {
        var totalSparringRounds = 0
        
        for workout in workouts {
            for exercise in workout.exercises {
                // Check if this is a sparring exercise
                if exercise.name.lowercased() == "sparring" && exercise.category == .boxing {
                    // Count the number of completed sets (rounds)
                    totalSparringRounds += exercise.sets.count
                }
            }
        }
        
        return totalSparringRounds
    }
    
    // MARK: - Format Helpers
    
    func formatDuration(_ seconds: TimeInterval) -> String {
        let totalSeconds = Int(seconds)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else if minutes > 0 {
            return "\(minutes)m"
        } else {
            return "0m"
        }
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
    
    // MARK: - Update Profile
    
    func updateProfile(_ updatedUser: User) async -> Bool {
        isLoading = true
        
        do {
            try await userService.updateUser(updatedUser)
            user = updatedUser
            isLoading = false
            return true
        } catch {
            showErrorAlert("Failed to update profile: \(error.localizedDescription)")
            isLoading = false
            return false
        }
    }
    
    // MARK: - Error Handling
    
    private func showErrorAlert(_ message: String) {
        errorMessage = message
        showError = true
    }
}
