//
//  Workout.swift
//  boxtrack
//
//  Created by Karan Bassi on 2025-12-01.
//



import Foundation
import FirebaseFirestore

// MARK: - Workout book (pre-made template)
struct WorkoutBook: Codable, Identifiable {
    @DocumentID var id: String?
    var userId: String
    var name: String
    var exercises: [WorkoutExercise]
    var createdAt: Date
    var estimatedDuration: Int? // in minutes
    
    init(userId: String, name: String, exercises: [WorkoutExercise]) {
        self.userId = userId
        self.name = name
        self.exercises = exercises
        self.createdAt = Date()
        self.estimatedDuration = nil
    }
}

// MARK: - Workout Session (active or completed workout)
struct WorkoutSession: Codable, Identifiable {
    @DocumentID var id: String?
    var userId: String
    var workoutBookId: String? // nil if freestyle
    var workoutBookName: String? // store name for history
    var gym: String?
    var startTime: Date
    var endTime: Date?
    var duration: TimeInterval? // in seconds
    var exercises: [ExerciseLog]
    var wasModified: Bool // true if user changed exercise from orignal book
    var date: Date
    
    var isActive: Bool {
        return endTime == nil
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }
    
    var formattedDuration: String {
        guard let duration = duration else { return "0m" }
            
            let hours = Int(duration) / 3600
            let minutes = (Int(duration) % 3600) / 60
        
            if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    init(userId: String, workoutBookId: String? = nil, workoutBookName: String? = nil, gym: String? = nil) {
        self.userId = userId
        self.workoutBookId = workoutBookId
        self.workoutBookName = workoutBookName
        self.gym = gym
        self.startTime = Date()
        self.date = Date()
        self.exercises = []
        self.wasModified = false
    }
}


// MARK: - Workout Exercise (in a workoutbook template)
struct WorkoutExercise: Codable, Identifiable {
    var id: String = UUID().uuidString
    var name: String
    var category: ExerciseCategory
    var type: ExerciseType
    var sets: Int?
    var reps: Int?
    var weight: Double?
    var rounds: Int?
    var duration: Int? // in seconds
    var isSuperSet: Bool
    var supersetGroup: Int? // group number for super set
    var notes: String?
    
    init(name: String, category: ExerciseCategory, type: ExerciseType, sets: Int? = nil, reps: Int? = nil, weight: Double? = nil, rounds: Int? = nil, isSuperset: Bool = false, supersetGroup: Int? = nil) {
        self.name = name
        self.category = category
        self.type = type
        self.sets = sets
        self.reps = reps
        self.weight = weight
        self.rounds = rounds
        self.isSuperSet = isSuperset
        self.supersetGroup = supersetGroup
    }
}

// MARK: - Exercise log (Completed exercises in a session)
struct ExerciseLog: Codable, Identifiable {
    var id: String = UUID().uuidString
    var exerciseId: String? // Links to workoutExercise id from a book
    var name: String
    var category: ExerciseCategory
    var type: ExerciseType
    var sets: [SetLog]
    var completed: Bool
    var isSuperset: Bool
    var supersetGroup: Int?
    var notes: String?
    var order: Int // postion in workout
    
    init(from exercise: WorkoutExercise, order: Int) {
        self.exerciseId = exercise.id
        self.name = exercise.name
        self.category = exercise.category
        self.type = exercise.type
        self.sets = []
        self.completed = false
        self.isSuperset = exercise.isSuperSet
        self.supersetGroup = exercise.supersetGroup
        self.notes = exercise.notes
        self.order = order
    }
    
    init(name: String, category: ExerciseCategory, type: ExerciseType, order: Int) {
        self.name = name
        self.category = category
        self.type = type
        self.sets = []
        self.completed = false
        self.isSuperset = false
        self.order = order
    }
}

// MARK: - Set log (individual set within an exercise)
struct SetLog: Codable, Identifiable {
    var id: String = UUID().uuidString
    var setNumber: Int
    var reps: Int?
    var weight: Double?
    var duration: Int? // in seconds
    var completed: Bool
    var completedAt: Date?
    
    init(setNumber: Int, reps: Int? = nil, weight: Double? = nil, duration: Int? = nil) {
        self.setNumber = setNumber
        self.reps = reps
        self.weight = weight
        self.duration = duration
        self.completed = false
    }
}

// MARK: - Exercise Category
enum ExerciseCategory: String, Codable, CaseIterable {
    case weights = "Weights"
    case boxing = "Boxing"
    case roadwork = "Roadwork"
    case plyometrics = "Plyometrics"
    
    var subcategories: [String] {
        switch self {
        case .weights:
            return ["Squats", "Bench Press", "Deadlifts", "Overhead Press", "Pull-Ups", "Dumbbell Rows", "Bent-Over Rows", "Lunges", "Leg Press", "Calf Raises"]
        case .boxing:
            return ["Heavy Bag", "Speed Bag", "Double Eng Bag", "Shadow Boxing", "Mitts", "Sparring"]
        case .roadwork:
            return ["Road Work", "Skipping", "Bike"]
        case .plyometrics:
            return ["Box Jumps", "Burpees", "Jump Squats", "Plyo Push-ups"]
        }
    }
}

enum ExerciseType: String, Codable {
    case setsAndReps = "Sets & Reps"
    case rounds = "Rounds"
    case duration = "Duration"
}
