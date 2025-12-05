//
//  AuthViewModel.swift
//  boxtrack
//
//  Created by Karan Bassi on 2025-11-22.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var isAuthenticated = false
    
    private let authService = AuthService.shared
    
    // Sign Up
    func signUp(email: String, password: String, confirmPassword: String) async {
        // validation
        guard !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
            showErrorAlert("Please Fill in all fields")
            return
        }
        
        guard isValidEmail(email) else {
            showErrorAlert("Please enter a valid email address")
            return
        }
        
        guard password.count >= 6 else {
            showErrorAlert("password must be at least 6 characters")
            return
        }
        
        guard password == confirmPassword else {
            showErrorAlert("Passwords don't match")
            return
        }
        
        isLoading = true
        
        do {
            _ = try await authService.signUp(email: email, password: password)
            isAuthenticated = true
            // success - user navigated to contentview
        } catch {
            showErrorAlert(getErrorMessage(from: error))
        }
        
        isLoading = false
    }
    
    // sign in
    
    func signIn(email: String, password: String) async {
        // Validation
        guard !email.isEmpty, !password.isEmpty else {
            showErrorAlert("Please fill in all fields")
            return
        }
        
        guard isValidEmail(email) else {
            showErrorAlert("please enter a valid email address")
            return
        }
        
        isLoading = true
        
        do {
            try await authService.signIn(email: email, password: password)
            isAuthenticated = true
            // success - contentview will handle navigation
        } catch {
            showErrorAlert(getErrorMessage(from: error))
        }
        
        isLoading = false
    }
    
    // helper: show error
    private func showErrorAlert(_ message: String) {
        errorMessage = message
        showError = true
    }
    
    // Helper: Validate Email
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    
    // Helper: Get user-friendly error messages
    private func getErrorMessage(from error: Error) -> String {
        let errorCode = (error as NSError).code
        
        switch errorCode {
        case 17007: // Email already in use
            return "This email is already registered"
        case 17008, 17011: // Invalid email or wrong password
            return "Invalid email or password"
        case 17009: // Wrong password
            return "Incorrect password"
        case 17020: // Network error
            return "Network error. Please check your connection"
        default:
            return error.localizedDescription
        }
    }
}
