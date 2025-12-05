//
//  WorkoutSummaryView.swift
//  boxtrack
//
//  Created by Karan Bassi on 2025-12-04.
//

import SwiftUI

struct WorkoutSummaryView: View {
    @Environment(\.dismiss) var dismiss
    let exercises: [ExerciseLog]
    let duration: String
    let gym: String?
    let onConfirm: () -> Void
    
    @State private var isConfirming = false
    
    var totalSets: Int {
        exercises.reduce(0) { $0 + $1.sets.count }
    }
    
    var totalVolume: Double {
        exercises.reduce(0.0) { total, exercise in
            total + exercise.sets.reduce(0.0) { setTotal, set in
                setTotal + (Double(set.reps ?? 0) * (set.weight ?? 0))
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Header
                        VStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.green)
                            
                            Text("Workout Summary")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding(.top, 20)
                        
                        // Stats Cards
                        VStack(spacing: 16) {
                            // Duration
                            StatCard(
                                icon: "clock.fill",
                                title: "Duration",
                                value: duration
                            )
                            
                            // Exercises
                            StatCard(
                                icon: "figure.boxing",
                                title: "Exercises",
                                value: "\(exercises.count)"
                            )
                            
                            // Total Sets/Rounds
                            StatCard(
                                icon: "repeat",
                                title: "Total Sets/Rounds",
                                value: "\(totalSets)"
                            )
                            
                            // Gym
                            if let gym = gym {
                                StatCard(
                                    icon: "location.fill",
                                    title: "Gym",
                                    value: gym
                                )
                            }
                            
                            // Total Volume (if any weight exercises)
                            if totalVolume > 0 {
                                StatCard(
                                    icon: "scalemass.fill",
                                    title: "Total Volume",
                                    value: "\(Int(totalVolume)) lbs"
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Exercise Breakdown
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Exercises")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                            
                            ForEach(Array(exercises.enumerated()), id: \.offset) { index, exercise in
                                ExerciseSummaryCard(
                                    exercise: exercise,
                                    number: index + 1
                                )
                                .padding(.horizontal, 20)
                            }
                        }
                        .padding(.top, 20)
                        
                        Spacer()
                            .frame(height: 120) // Space for buttons
                    }
                }
                
                // Bottom Buttons
                VStack {
                    Spacer()
                    
                    VStack(spacing: 12) {
                        // Save Workout Button
                        Button(action: {
                            isConfirming = true
                            onConfirm()
                        }) {
                            if isConfirming {
                                ProgressView()
                                    .tint(.black)
                            } else {
                                Text("Save Workout")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.black)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.white)
                        .cornerRadius(10)
                        .disabled(isConfirming)
                        
                        // Continue Workout Button
                        Button(action: {
                            dismiss()
                        }) {
                            Text("Continue Workout")
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                        }
                        .disabled(isConfirming)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                    .background(
                        LinearGradient(
                            colors: [Color.black.opacity(0), Color.black],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 150)
                    )
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                    }
                    .disabled(isConfirming)
                }
            }
        }
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.white)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                
                Text(value)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: - Exercise Summary Card
struct ExerciseSummaryCard: View {
    let exercise: ExerciseLog
    let number: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Exercise name with number
            HStack {
                Text("#\(number)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.gray)
                    .cornerRadius(12)
                
                Text(exercise.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(exercise.category.rawValue)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            
            // Sets/Rounds details
            if !exercise.sets.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(exercise.sets) { set in
                        HStack {
                            if exercise.type == .setsAndReps {
                                Text("Set \(set.setNumber): \(set.reps ?? 0) reps × \(Int(set.weight ?? 0)) lbs")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                            } else {
                                Text("Round \(set.setNumber)")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.green)
                        }
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

#Preview {
    WorkoutSummaryView(
        exercises: [
            ExerciseLog(name: "Heavy Bag", category: .boxing, type: .rounds, order: 0),
            ExerciseLog(name: "Bench Press", category: .weights, type: .setsAndReps, order: 1)
        ],
        duration: "45:23",
        gym: "Home Gym",
        onConfirm: {}
    )
}
