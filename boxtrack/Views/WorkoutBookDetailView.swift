//
//  WorkoutBookDetailView.swift
//  boxtrack
//
//  Created by Karan Bassi on 2025-12-04.
//

import SwiftUI

struct WorkoutBookDetailView: View {
    @Environment(\.dismiss) var dismiss
    let book: WorkoutBook
    let onUpdate: (WorkoutBook) -> Void
    let onDelete: () -> Void
    
    @State private var showEditBook = false
    @State private var showDeleteAlert = false
    @State private var showStartWorkout = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Header Info
                        VStack(spacing: 16) {
                            // Workout Name
                            Text(book.name)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                            
                            // Stats
                            HStack(spacing: 20) {
                                // Exercise Count
                                VStack(spacing: 4) {
                                    Text("\(book.exercises.count)")
                                        .font(.system(size: 24, weight: .semibold))
                                        .foregroundColor(.white)
                                    Text("Exercises")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                }
                                
                                // Divider
                                Rectangle()
                                    .fill(Color.white.opacity(0.2))
                                    .frame(width: 1, height: 40)
                                
                                // Duration
                                VStack(spacing: 4) {
                                    Text(book.estimatedDuration != nil ? "~\(book.estimatedDuration!)m" : "-")
                                        .font(.system(size: 24, weight: .semibold))
                                        .foregroundColor(.white)
                                    Text("Duration")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.05))
                            )
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        // Exercises List
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Exercises")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                            
                            ForEach(Array(book.exercises.enumerated()), id: \.element.id) { index, exercise in
                                WorkoutBookExerciseCard(
                                    exercise: exercise,
                                    number: index + 1
                                )
                                .padding(.horizontal, 20)
                            }
                        }
                        
                        Spacer()
                            .frame(height: 150) // Space for bottom buttons
                    }
                }
                
                // Bottom Action Buttons
                VStack {
                    Spacer()
                    
                    VStack(spacing: 12) {
                        // Start Workout Button
                        Button(action: {
                            showStartWorkout = true
                        }) {
                            Text("Start Workout")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color.white)
                                .cornerRadius(10)
                        }
                        
                        // Edit & Delete Buttons
                        HStack(spacing: 12) {
                            Button(action: {
                                showEditBook = true
                            }) {
                                Text("Edit")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(10)
                            }
                            
                            Button(action: {
                                showDeleteAlert = true
                            }) {
                                Text("Delete")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.red)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(10)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                    .background(
                        LinearGradient(
                            colors: [Color.black.opacity(0), Color.black],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 180)
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
                }
            }
            .sheet(isPresented: $showEditBook) {
                CreateWorkoutBookView(
                    onSave: { updatedBook in
                        onUpdate(updatedBook)
                        showEditBook = false
                    },
                    existingBook: book
                )
            }
            .fullScreenCover(isPresented: $showStartWorkout) {
                NavigationStack {
                    WorkoutSetupViewWrapper(book: book)
                }
            }
            .alert("Delete Workout Book", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    onDelete()
                    dismiss()
                }
            } message: {
                Text("Are you sure you want to delete \"\(book.name)\"? This cannot be undone.")
            }
        }
    }
}

// MARK: - Wrapper to Handle Navigation
struct WorkoutSetupViewWrapper: View {
    @Environment(\.dismiss) var dismiss
    let book: WorkoutBook
    @State private var showActiveWorkout = false
    
    var body: some View {
        WorkoutSetupView(
            showActiveWorkout: $showActiveWorkout,
            preSelectedBook: book
        )
        .sheet(isPresented: $showActiveWorkout) {
            ActiveWorkoutView(viewModel: ActiveWorkoutViewModel())
        }
        .onChange(of: showActiveWorkout) { _, newValue in
            if newValue {
                dismiss() // Close setup when active workout opens
            }
        }
    }
}

// MARK: - Workout Book Exercise Card
struct WorkoutBookExerciseCard: View {
    let exercise: WorkoutExercise
    let number: Int
    
    var body: some View {
        HStack(spacing: 12) {
            // Number badge
            Text("#\(number)")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(Color.gray)
                .cornerRadius(20)
            
            // Exercise details
            VStack(alignment: .leading, spacing: 6) {
                Text(exercise.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(exerciseDetails)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                
                if let notes = exercise.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .italic()
                }
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
    
    private var exerciseDetails: String {
        var details = exercise.category.rawValue
        
        if exercise.type == .setsAndReps {
            if let sets = exercise.sets, let reps = exercise.reps {
                details += " • \(sets) sets × \(reps) reps"
            }
            if let weight = exercise.weight {
                details += " @ \(Int(weight)) lbs"
            }
        } else {
            if let rounds = exercise.rounds {
                details += " • \(rounds) rounds"
            }
        }
        
        return details
    }
}

#Preview {
    WorkoutBookDetailView(
        book: WorkoutBook(
            userId: "test",
            name: "Upper Body Day",
            exercises: [
                WorkoutExercise(
                    name: "Bench Press",
                    category: .weights,
                    type: .setsAndReps,
                    sets: 3,
                    reps: 12,
                    weight: 150
                ),
                WorkoutExercise(
                    name: "Heavy Bag",
                    category: .boxing,
                    type: .rounds,
                    rounds: 3
                )
            ]
        ),
        onUpdate: { _ in },
        onDelete: {}
    )
}
