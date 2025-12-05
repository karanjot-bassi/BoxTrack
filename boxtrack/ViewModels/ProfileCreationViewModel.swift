//
//  ProfileCreationViewModel.swift
//  boxtrack
//
//  Created by Karan Bassi on 2025-11-22.
//

import Foundation
import SwiftUI
import Combine
import FirebaseAuth

@MainActor
class ProfileCreationViewModel: ObservableObject {
    // Step 1: Fighter Name & Age
    @Published var fighterName = ""
    @Published var ageText = ""
    @Published var fighterNameTaken = false
    @Published var isCheckingFighterName = false
    
    // Step 2: Height & Weight
    @Published var heightFeetText = ""
    @Published var heightInchesText = ""
    @Published var weightText = ""
    
    // Step 3: Level
    @Published var selectedLevel: User.FighterLevel = .training
    
    // Step 4: Gym
    @Published var gymName = ""
    
    // Step 5: Timer Settings
    @Published var workingMinutes = 3
    @Published var workingSeconds = 0
    @Published var restMinutes = 0
    @Published var restSeconds = 30
    
    // Step 6: Avatar & Record
    @Published var selectedAvatarId = "default"
    @Published var wins = "0"
    @Published var losses = "0"
    @Published var draws = "0"
    
    // UI State
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var profileCompleted = false
    
    private let authService = AuthService.shared
    private let userService = UserService.shared
    private var debounceTask: Task<Void, Never>?
    
    // MARK: - Validation
    
    var canProceedFromStep1: Bool {
        !fighterName.isEmpty &&
        !ageText.isEmpty &&
        Int(ageText) != nil &&
        !fighterNameTaken &&
        !isCheckingFighterName
    }
    
    var canProceedFromStep2: Bool {
        !heightFeetText.isEmpty &&
        !heightInchesText.isEmpty &&
        !weightText.isEmpty &&
        Int(heightFeetText) != nil &&
        Int(heightInchesText) != nil &&
        Double(weightText) != nil
    }
    
    // MARK: - Check Fighter Name Availability
    
    func checkFighterNameDebounced() {
        // Cancel previous check
        debounceTask?.cancel()
        
        guard fighterName.count >= 3 else {
            fighterNameTaken = false
            isCheckingFighterName = false
            return
        }
        
        isCheckingFighterName = true
        
        // Debounce for 500ms
        debounceTask = Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            
            guard !Task.isCancelled else { return }
            
            await checkFighterNameAvailability()
        }
    }
    
    private func checkFighterNameAvailability() async {
        do {
            let isAvailable = try await userService.isFighterNameAvailable(fighterName)
            fighterNameTaken = !isAvailable
        } catch {
            // Silently fail - better to allow than block
            fighterNameTaken = false
        }
        isCheckingFighterName = false
    }
    
    // MARK: - Create Profile
    
    func createProfile() async {
        guard let userId = authService.currentUser?.uid else {
            showErrorAlert("No user signed in")
            return
        }
        
        guard let email = authService.currentUser?.email else {
            showErrorAlert("No email found")
            return
        }
        
        // Validate all fields
        guard let age = Int(ageText),
              let heightFeet = Int(heightFeetText),
              let heightInches = Int(heightInchesText),
              let weight = Double(weightText) else {
            showErrorAlert("Please enter valid values")
            return
        }
        
        isLoading = true
        
        // Calculate timer settings in seconds
        let workingTimeSeconds = (workingMinutes * 60) + workingSeconds
        let restTimeSeconds = (restMinutes * 60) + restSeconds
        
        // Create user object
        let user = User(
            id: userId,
            email: email,
            fighterName: fighterName.trimmingCharacters(in: .whitespaces),
            age: age,
            heightFeet: heightFeet,
            heightInches: heightInches,
            weight: weight,
            level: selectedLevel,
            gym: gymName.isEmpty ? nil : gymName.trimmingCharacters(in: .whitespaces),
            timerSettings: TimerSettings(
                workingTime: workingTimeSeconds,
                restTime: restTimeSeconds
            ),
            avatarId: selectedAvatarId,
            record: FightRecord(
                wins: Int(wins) ?? 0,
                losses: Int(losses) ?? 0,
                draws: Int(draws) ?? 0
            ),
            createdAt: Date(),
            stats: UserStats(initialWeight: weight)
        )
        
        do {
            try await userService.createUser(user)
            profileCompleted = true
            // Success - ContentView will handle navigation
        } catch {
            showErrorAlert("Failed to create profile: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    private func showErrorAlert(_ message: String) {
        errorMessage = message
        showError = true
    }
}
