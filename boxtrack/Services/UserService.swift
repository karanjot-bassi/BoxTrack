//
//  UserService.swift
//  boxtrack
//
//  Created by Karan Bassi on 2025-11-22.
//

import Foundation
import FirebaseFirestore

class UserService {
    static let shared = UserService()
    private init() {}
    
    private let db = Firestore.firestore()
    private let usersCollection = "users"
    
    // Create new user profile
    func createUser(_ user: User) async throws {
        guard let userId = user.id else {
            throw NSError(domain: "UserService", code: 1, userInfo: [NSLocalizedDescriptionKey: "User ID is required"])
        }
        
        try db.collection(usersCollection)
            .document(userId)
            .setData(from: user)
    }
    
    // Get user profile
    func getUser(userId: String) async throws -> User {
        let document = try await db.collection(usersCollection)
            .document(userId)
            .getDocument()
        
        guard let user = try? document.data(as: User.self) else {
            throw NSError(domain: "UserService", code: 2, userInfo: [NSLocalizedDescriptionKey: "User not found"])
        }
        
        return user
    }
    
    // Update user profile
    func updateUser(_ user: User) async throws {
        guard let userId = user.id else {
            throw NSError(domain: "UserService", code: 1, userInfo: [NSLocalizedDescriptionKey: "User ID is required"])
        }
        
        try db.collection(usersCollection)
            .document(userId)
            .setData(from: user, merge: true)
    }
    
    // Update specific field
    func updateUserField(userId: String, field: String, value: Any) async throws {
        try await db.collection(usersCollection)
            .document(userId)
            .updateData([field: value])
    }
    
    // Update user stats
    func updateStats(userId: String, stats: UserStats) async throws {
        let statsData: [String: Any] = [
            "stats.totalWorkouts": stats.totalWorkouts,
            "stats.currentStreak": stats.currentStreak,
            "stats.lastWorkoutDate": stats.lastWorkoutDate as Any,
            "stats.totalRounds": stats.totalRounds,
            "stats.currentWeight": stats.currentWeight,
            "stats.targetWeight": stats.targetWeight as Any
        ]
        
        try await db.collection(usersCollection)
            .document(userId)
            .updateData(statsData)
    }
    
    // Check if fighter name is available (unique)
    func isFighterNameAvailable(_ fighterName: String) async throws -> Bool {
        let snapshot = try await db.collection(usersCollection)
            .whereField("fighterName", isEqualTo: fighterName)
            .limit(to: 1)
            .getDocuments()
        
        return snapshot.documents.isEmpty
    }
}
