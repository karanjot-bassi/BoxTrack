//
//  WorkoutBookViewModel.swift
//  boxtrack
//
//  Created by Karan Bassi on 2025-12-04.
//

import Foundation
import SwiftUI
import Combine
import FirebaseAuth

@MainActor
class WorkoutBookViewModel: ObservableObject {
    @Published var workoutBooks: [WorkoutBook] = []
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    
    private let workoutService = WorkoutService.shared
    private let authService = AuthService.shared
    
    // MARK: - Load Workout Books
    
    func loadWorkoutBooks() async {
        guard let userId = authService.currentUser?.uid else {
            showErrorAlert("No user signed in")
            return
        }
        
        isLoading = true
        
        do {
            workoutBooks = try await workoutService.getUserWorkoutBooks(userId: userId)
        } catch {
            showErrorAlert("Failed to load workout books: \(error.localizedDescription)")
            workoutBooks = []
        }
        
        isLoading = false
    }
    
    // MARK: - Create Workout Book
    
    func createWorkoutBook(_ book: WorkoutBook) async -> Bool {
        isLoading = true
        
        do {
            _ = try await workoutService.createWorkoutBook(book)
            await loadWorkoutBooks() // Refresh list
            isLoading = false
            return true
        } catch {
            showErrorAlert("Failed to create workout book: \(error.localizedDescription)")
            isLoading = false
            return false
        }
    }
    
    // MARK: - Update Workout Book
    
    func updateWorkoutBook(_ book: WorkoutBook) async -> Bool {
        isLoading = true
        
        do {
            try await workoutService.updateWorkoutBook(book)
            await loadWorkoutBooks() // Refresh list
            isLoading = false
            return true
        } catch {
            showErrorAlert("Failed to update workout book: \(error.localizedDescription)")
            isLoading = false
            return false
        }
    }
    
    // MARK: - Delete Workout Book
    
    func deleteWorkoutBook(bookId: String) async -> Bool {
        isLoading = true
        
        do {
            try await workoutService.deleteWorkoutBook(bookId: bookId)
            await loadWorkoutBooks() // Refresh list
            isLoading = false
            return true
        } catch {
            showErrorAlert("Failed to delete workout book: \(error.localizedDescription)")
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
