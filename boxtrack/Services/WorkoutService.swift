//
//  WorkoutService.swift
//  boxtrack
//
//  Created by Karan Bassi on 2025-12-02.
//


import Foundation
import FirebaseFirestore

class WorkoutService {
    static let shared = WorkoutService()
    private init() {}
    
    private let db = Firestore.firestore()
    private let workoutSessionsCollection = "workoutSessions"
    private let workoutBooksCollection = "workoutBooks"
    
    // MARK: - Workout Sessions
    
    // Create new workout session
    func createWorkoutSession(_ session: WorkoutSession) async throws -> String {
        let docRef = try db.collection(workoutSessionsCollection).addDocument(from: session)
        return docRef.documentID
    }
    
    // update existing workout session
    func updateWorkoutSession(_ session: WorkoutSession) async throws {
        guard let sessionId = session.id else {
            throw NSError(domain: "WorkoutService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Session ID is required"])
        }
        
        try db.collection(workoutSessionsCollection)
            .document(sessionId)
            .setData(from: session, merge: true)
    }
    
    // Get users workouts sessions
    func getUserWorkoutSessions(userId: String, limit: Int = 20) async throws -> [WorkoutSession] {
        let snapshot = try await db.collection(workoutSessionsCollection)
            .whereField("userId", isEqualTo: userId)
            .whereField("endTime", isNotEqualTo: NSNull())
            .order(by: "endTime", descending: true)
            .limit(to: limit)
            .getDocuments()
        return snapshot.documents.compactMap { doc in try? doc.data(as: WorkoutSession.self)}
    }
    
    // Get active workout session
    func getActiveWorkoutSession(userId: String) async throws -> WorkoutSession? {
        let snapshot = try await db.collection(workoutSessionsCollection)
            .whereField("userId", isEqualTo: userId)
            .whereField("endTime", isEqualTo: NSNull())
            .limit(to: 1)
            .getDocuments()
        
        return snapshot.documents.compactMap { doc in try? doc.data(as: WorkoutSession.self)}.first
    }
    
    // Complete workout session
    func completeWorkoutSession(sessionId: String, exercises: [ExerciseLog]) async throws {
        let endTime = Date()
        
        // Calculate duration
        let sessionDoc = try await db.collection(workoutSessionsCollection)
            .document(sessionId)
            .getDocument()
        
        guard let session = try? sessionDoc.data(as: WorkoutSession.self) else {
            throw NSError(domain: "WorkoutService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Session not found"])
        }
        
        let duration = endTime.timeIntervalSince(session.startTime)
        
        try await db.collection(workoutSessionsCollection)
            .document(sessionId)
            .updateData([
                "endTime": endTime,
                "duration": duration,
                "exercises": exercises.map { try Firestore.Encoder().encode($0) }
            ])
    }
    
    // Delete workout session
    func deleteWorkoutSession(sessionId: String) async throws {
        try await db.collection(workoutSessionsCollection)
            .document(sessionId)
            .delete()
    }

    
    
    // MARK: - Workout books
    
    // Create workout book
    func createWorkoutBook(_ book: WorkoutBook) async throws -> String {
        let docRef = try db.collection(workoutBooksCollection).addDocument(from: book)
        return docRef.documentID
    }
    
    // Update workout book
    func updateWorkoutBook(_ book: WorkoutBook) async throws {
        guard let bookId = book.id else {
            throw NSError(domain: "WorkoutService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Book ID is required"])
        }
        
        try db.collection(workoutBooksCollection)
            .document(bookId)
            .setData(from: book, merge: true)
    }
    
    // get users workout books
    func getUserWorkoutBooks(userId: String) async throws -> [WorkoutBook] {
        let snapshot = try await db.collection(workoutBooksCollection)
            .whereField("userId", isEqualTo: userId)
            .order(by: "createAt", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { doc in
            try? doc.data(as: WorkoutBook.self)
        }
    }
    
    // get specific workout book
    func getWorkoutBook(bookId: String) async throws -> WorkoutBook {
        let document = try await db.collection(workoutBooksCollection)
            .document(bookId)
            .getDocument()
        
        guard let book = try? document.data(as: WorkoutBook.self) else {
            throw NSError(domain: "WorkoutService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Workout book not found"])
        }
        
        return book
    }
    
    // Delete workout book
    func deleteWorkoutBook(bookId: String) async throws {
        try await db.collection(workoutBooksCollection)
            .document(bookId)
            .delete()
    }
    
}
