//
//  ActiveWorkoutViewModel.swift
//  boxtrack
//
//  Created by Karan Bassi on 2025-12-02.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

@MainActor
class ActiveWorkoutViewModel: ObservableObject {
    @Published var exercises: [ExerciseLog] = []
    @Published var workoutName: String = "Freestyle Workout"
    @Published var workoutDuration: String = "0:00"
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    
    var hasLoadedWorkout = false
    
    private var workoutSession: WorkoutSession?
    private var startTime: Date?
    private var timer: Timer?
    
    private let workoutService = WorkoutService.shared
    private let userService = UserService.shared
    
    // MARK: - Load Workout

    func loadActiveWorkout() async {
        guard let sessionId = UserDefaults.standard.string(forKey: "activeWorkoutSessionId") else {
            print("❌ No session ID found")
            return
        }
        
        print("🔍 Loading session: \(sessionId)")
        
        isLoading = true
        
        do {
            // Fetch the session directly by ID
            let db = Firestore.firestore()
            let document = try await db.collection("workoutSessions")
                .document(sessionId)
                .getDocument()
            
            guard let session = try? document.data(as: WorkoutSession.self) else {
                print("❌ Session not found or couldn't decode")
                isLoading = false
                return
            }
            
            print("✅ Session found!")
            print("📊 Exercises in session: \(session.exercises.count)")
            
            // Load the exercises from the session
            exercises = session.exercises
            workoutName = session.workoutBookName ?? "Freestyle Workout"
            workoutSession = session
            
            print("✅ Loaded \(exercises.count) exercises into ViewModel")
            exercises.forEach { ex in
                print("  - \(ex.name) (\(ex.category.rawValue))")
            }
            
            // Only reset timer if this is a fresh workout (no logged sets yet)
            let hasLoggedSets = exercises.contains { !$0.sets.isEmpty }
            if !hasLoggedSets {
                BoxingTimerManager.shared.resetForWorkout()
            }
            
            startWorkoutTimer()
            hasLoadedWorkout = true
            
        } catch {
            print("❌ Error loading workout: \(error)")
            showErrorAlert("Failed to load workout: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    // MARK: - Workout Duration Timer
    
    func startWorkoutTimer() {
        guard startTime == nil else { return } // Don't restart if already running
        
        startTime = Date()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateWorkoutDuration()
            }
        }
    }
    
    private func updateWorkoutDuration() {
        guard let startTime = startTime else { return }
        
        let elapsed = Date().timeIntervalSince(startTime)
        let hours = Int(elapsed) / 3600
        let minutes = (Int(elapsed) % 3600) / 60
        let seconds = Int(elapsed) % 60
        
        if hours > 0 {
            workoutDuration = String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            workoutDuration = String(format: "%d:%02d", minutes, seconds)
        }
    }
    
    // MARK: - Exercise Management
    
    func addExercise(_ exercise: ExerciseLog) {
        exercises.append(exercise)
    }
    
    func deleteExercise(at index: Int) {
        guard index < exercises.count else { return }
        exercises.remove(at: index)
    }
    
    // MARK: - Manual Logging Functions
    
    // Log a set for weights exercises
    func logSet(for exerciseIndex: Int, reps: Int, weight: Double) {
        guard exerciseIndex < exercises.count else { return }
        
        let setNumber = exercises[exerciseIndex].sets.count + 1
        let newSet = SetLog(
            setNumber: setNumber,
            reps: reps,
            weight: weight
        )
        
        exercises[exerciseIndex].sets.append(newSet)
    }
    
    // Log a round for boxing/cardio exercises
    func logRound(for exerciseIndex: Int) {
        guard exerciseIndex < exercises.count else { return }
        
        let roundNumber = exercises[exerciseIndex].sets.count + 1
        let newRound = SetLog(
            setNumber: roundNumber,
            duration: nil // Could add duration later if needed
        )
        
        exercises[exerciseIndex].sets.append(newRound)
    }
    
    // Check if exercise is complete (all planned sets/rounds done)
    func isExerciseComplete(at index: Int) -> Bool {
        guard index < exercises.count else { return false }
        
        let exercise = exercises[index]
        // TODO: Compare against planned sets/rounds from workout book
        // For now, just return false (user manually marks complete)
        return false
    }
    
    // Mark exercise as manually completed
    func markExerciseComplete(at index: Int) {
        guard index < exercises.count else { return }
        exercises[index].completed = true
    }
    
    
    func finishWorkout() async -> Bool {
        timer?.invalidate()
        timer = nil
        
        guard let sessionId = UserDefaults.standard.string(forKey: "activeWorkoutSessionId") else {
            showErrorAlert("No active workout found")
            return false
        }
        
        // Calculate total rounds from all exercises
        let totalRounds = exercises.reduce(0) { $0 + $1.sets.count }
        
        do {
            // 1. Save workout to Firebase (sets endTime, duration, exercises)
            try await workoutService.completeWorkoutSession(
                sessionId: sessionId,
                exercises: exercises
            )
            
            // 2. Update basic user stats
            guard let userId = AuthService.shared.currentUser?.uid else {
                throw NSError(domain: "WorkoutViewModel", code: 3, userInfo: [NSLocalizedDescriptionKey: "No user ID"])
            }
            
            var user = try await userService.getUser(userId: userId)
            
            // Just update counts - no streak logic
            user.stats.totalWorkouts += 1
            user.stats.totalRounds += totalRounds
            user.stats.lastWorkoutDate = Date()
            
            try await userService.updateUser(user)
            
            // 3. Clear active workout
            UserDefaults.standard.removeObject(forKey: "activeWorkoutSessionId")
            
            // 4. Reset local state
            exercises = []
            workoutDuration = "0:00"
            startTime = nil
            hasLoadedWorkout = false
            
            return true
            
        } catch {
            showErrorAlert("Failed to save workout: \(error.localizedDescription)")
            return false
        }
    }
    
    // MARK: - Delete Workout
    
    func deleteWorkout() async -> Bool {
        timer?.invalidate()
        timer = nil
        
        guard let sessionId = UserDefaults.standard.string(forKey: "activeWorkoutSessionId") else {
            return false
        }
        
        do {
            try await workoutService.deleteWorkoutSession(sessionId: sessionId)
            UserDefaults.standard.removeObject(forKey: "activeWorkoutSessionId")
            
            // Reset state
            exercises = []
            workoutDuration = "0:00"
            startTime = nil
            hasLoadedWorkout = false
            
            return true
        } catch {
            showErrorAlert("Failed to delete workout")
            return false
        }
    }
    
    private func showErrorAlert(_ message: String) {
        errorMessage = message
        showError = true
    }
    
    deinit {
        timer?.invalidate()
    }
}
