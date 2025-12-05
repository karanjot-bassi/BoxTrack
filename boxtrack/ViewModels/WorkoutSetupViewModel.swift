//
//  WorkoutSetupViewModel.swift
//  boxtrack
//
//  Created by Karan Bassi on 2025-12-02.
//

import Foundation
import FirebaseAuth
import Combine

@MainActor
class WorkoutSetupViewModel: ObservableObject {
    @Published var workoutBooks: [WorkoutBook] = []
    @Published var availableGyms: [String] = []
    @Published var homeGym: String?
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var showAddGymAlert = false
    @Published var newGymName = ""
    @Published var workoutStarted = false
    
    private let workoutService = WorkoutService.shared
    private let userService = UserService.shared
    private let authService = AuthService.shared
    
    // Load user's workout books and gym history
    func loadData() async {
        guard let userId = authService.currentUser?.uid else {
            return
        }
    
        do {
            // Load workout books
            workoutBooks = try await workoutService.getUserWorkoutBooks(userId: userId)
            
            // Load user profile to get home gym and gym history
            let user = try await userService.getUser(userId: userId)
            homeGym = user.gym
            availableGyms = user.gymHistory ?? []
            
            // Add home gym to available gyms if not already there
            if let homeGym = homeGym, !availableGyms.contains(homeGym) {
                availableGyms.insert(homeGym, at: 0)
            }
            
        } catch {
            // Silently fail
            workoutBooks = []
            availableGyms = []
        }
    }
    
    // Add a new gym to the list
    func addNewGym(_ gymName: String) async {
        guard let userId = authService.currentUser?.uid else { return }
        guard !gymName.isEmpty else { return }
        
        // Add to local list
        if !availableGyms.contains(gymName) {
            availableGyms.append(gymName)
            
            // Save to user profile
            do {
                var user = try await userService.getUser(userId: userId)
                user.gymHistory = availableGyms
                try await userService.updateUser(user)
            } catch {
                // Silently fail - gym will still work for this session
            }
        }
    }
    
    // Start a new workout session
    func startWorkout(workoutBook: WorkoutBook?, gym: String?) async -> Bool {
        guard let userId = authService.currentUser?.uid else {
            showErrorAlert("No user signed in")
            return false
        }
        
        isLoading = true
        
        do {
            // If gym is provided and new, add it to history
            if let gym = gym, !gym.isEmpty {
                await addNewGym(gym)
            }
            
            // Create new workout session
            var session = WorkoutSession(
                userId: userId,
                workoutBookId: workoutBook?.id,
                workoutBookName: workoutBook?.name,
                gym: gym
            )
            
            // If using a workout book, pre-load exercises
            if let workoutBook = workoutBook {
                session.exercises = workoutBook.exercises.enumerated().map { index, exercise in
                    ExerciseLog(from: exercise, order: index)
                }
            }
            
            // Save to Firebase
            let sessionId = try await workoutService.createWorkoutSession(session)
            
            // Store session ID for active workout
            UserDefaults.standard.set(sessionId, forKey: "activeWorkoutSessionId")
            
            isLoading = false
            workoutStarted = true
            return true
            
        } catch {
            showErrorAlert("Failed to start workout: \(error.localizedDescription)")
            isLoading = false
            return false
        }
    }
    
    private func showErrorAlert(_ message: String) {
        errorMessage = message
        showError = true
    }
}
