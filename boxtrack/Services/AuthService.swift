//
//  AuthService.swift
//  boxtrack
//
//  Created by Karan Bassi on 2025-11-22.
//

import Foundation
import FirebaseAuth

class AuthService {
    static let shared = AuthService()
    private init() {}
    
    private let auth = Auth.auth()
    
    // Check if users is siged in
    var currentUser: FirebaseAuth.User? {
        return auth.currentUser
    }
    
    var isSignedIn: Bool {
        return currentUser != nil
    }
    
    // Sign up new user
    func signUp(email: String, password: String) async throws -> String {
        let result = try await auth.createUser(withEmail: email, password: password)
        return result.user.uid
    }
    
    // Sign in existing
    func signIn(email: String, password: String) async throws {
        try await auth.signIn(withEmail: email, password: password)
    }
    
    // Sign out
    func signOut () throws {
        try auth.signOut()
    }
    
    // Reset password
    func resetPassword(email: String) async throws {
        try await auth.sendPasswordReset(withEmail: email)
    }
}
