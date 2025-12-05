//
//  CreateWorkoutBookView.swift
//  boxtrack
//
//  Created by Karan Bassi on 2025-12-04.
//

import SwiftUI
import FirebaseAuth

struct CreateWorkoutBookView: View {
    @Environment(\.dismiss) var dismiss
    let onSave: (WorkoutBook) -> Void
    let existingBook: WorkoutBook?
    
    @State private var step = 1
    @State private var workoutName = ""
    @State private var estimatedDuration = ""
    @State private var exercises: [WorkoutExercise] = []
    @State private var showAddExercise = false
    @State private var editingExerciseIndex: Int?
    @State private var showError = false
    @State private var errorMessage = ""
    
    init(onSave: @escaping (WorkoutBook) -> Void, existingBook: WorkoutBook? = nil) {
        self.onSave = onSave
        self.existingBook = existingBook
        
        // Initialize with existing book if editing
        if let book = existingBook {
            _workoutName = State(initialValue: book.name)
            _estimatedDuration = State(initialValue: book.estimatedDuration != nil ? "\(book.estimatedDuration!)" : "")
            _exercises = State(initialValue: book.exercises)
            _step = State(initialValue: 2) // Go straight to exercise builder
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                if step == 1 {
                    // Step 1: Basic Info
                    VStack(spacing: 30) {
                        Spacer()
                        
                        VStack(alignment: .leading, spacing: 20) {
                            // Workout Name
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Workout Name")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                
                                TextField("Upper Body Day", text: $workoutName)
                                    .font(.system(size: 18))
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(10)
                            }
                            
                            // Estimated Duration
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Estimated Duration (Optional)")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                
                                HStack {
                                    TextField("45", text: $estimatedDuration)
                                        .keyboardType(.numberPad)
                                        .font(.system(size: 18))
                                        .foregroundColor(.white)
                                        .frame(width: 80)
                                    
                                    Text("minutes")
                                        .font(.system(size: 16))
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer()
                        
                        // Continue Button
                        Button(action: {
                            step = 2
                        }) {
                            Text("Continue")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color.white)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                        .disabled(workoutName.isEmpty)
                        .opacity(workoutName.isEmpty ? 0.5 : 1)
                    }
                } else {
                    // Step 2: Exercise Builder
                    VStack(spacing: 0) {
                        if exercises.isEmpty {
                            // Empty State
                            VStack(spacing: 20) {
                                Spacer()
                                
                                Image(systemName: "figure.boxing")
                                    .font(.system(size: 60))
                                    .foregroundColor(.gray)
                                
                                Text("No exercises added yet")
                                    .font(.system(size: 18))
                                    .foregroundColor(.white)
                                
                                Text("Add exercises to build your workout")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                
                                Spacer()
                            }
                        } else {
                            // Exercise List with Drag & Drop
                            List {
                                ForEach(Array(exercises.enumerated()), id: \.element.id) { index, exercise in
                                    ExerciseRowView(
                                        exercise: exercise,
                                        number: index + 1,
                                        onEdit: {
                                            editingExerciseIndex = index
                                        }
                                    )
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                                    .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
                                }
                                .onMove { source, destination in
                                    exercises.move(fromOffsets: source, toOffset: destination)
                                }
                                .onDelete { indexSet in
                                    exercises.remove(atOffsets: indexSet)
                                }
                            }
                            .listStyle(.plain)
                            .scrollContentBackground(.hidden)
                            .environment(\.editMode, .constant(.active))
                        }
                        
                        // Add Exercise Button (fixed at bottom)
                        VStack(spacing: 12) {
                            Button(action: {
                                showAddExercise = true
                            }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 20))
                                    Text("Add Exercise")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(10)
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 10)
                        }
                    }
                }
            }
            .navigationTitle(existingBook == nil ? "New Workout Book" : "Edit Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(step == 1 ? "Cancel" : "Back") {
                        if step == 1 {
                            dismiss()
                        } else {
                            step = 1
                        }
                    }
                    .foregroundColor(.white)
                }
                
                if step == 2 {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Save") {
                            saveWorkoutBook()
                        }
                        .foregroundColor(.white)
                        .disabled(exercises.isEmpty)
                    }
                }
            }
            .sheet(isPresented: $showAddExercise) {
                AddExerciseToBookView { exercise in
                    exercises.append(exercise)
                }
            }
            .sheet(item: $editingExerciseIndex) { index in
                if index < exercises.count {
                    AddExerciseToBookView(
                        onAdd: { updatedExercise in
                            var updated = updatedExercise
                            updated.id = exercises[index].id
                            exercises[index] = updated
                        },
                        existingExercise: exercises[index]
                    )
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - Save Workout Book
    
    private func saveWorkoutBook() {
        // Validate
        guard !workoutName.isEmpty else {
            showErrorAlert("Workout name is required")
            return
        }
        
        guard !exercises.isEmpty else {
            showErrorAlert("Add at least one exercise")
            return
        }
        
        guard let userId = Auth.auth().currentUser?.uid else {
            showErrorAlert("No user signed in")
            return
        }
        
        // Create or update workout book
        let duration = estimatedDuration.isEmpty ? nil : Int(estimatedDuration)
        
        if let existingBook = existingBook {
            // Update existing
            var updatedBook = existingBook
            updatedBook.name = workoutName.trimmingCharacters(in: .whitespaces)
            updatedBook.exercises = exercises
            updatedBook.estimatedDuration = duration
            
            onSave(updatedBook)
        } else {
            // Create new
            let newBook = WorkoutBook(
                userId: userId,
                name: workoutName.trimmingCharacters(in: .whitespaces),
                exercises: exercises
            )
            var book = newBook
            book.estimatedDuration = duration
            
            onSave(book)
        }
    }
    

    
    // MARK: - Error Handling
    
    private func showErrorAlert(_ message: String) {
        errorMessage = message
        showError = true
    }
}

// MARK: - Exercise Row View
struct ExerciseRowView: View {
    let exercise: WorkoutExercise
    let number: Int
    let onEdit: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Number badge
            Text("#\(number)")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(Color.gray)
                .cornerRadius(20)
            
            // Exercise info
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(exerciseDetails)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Edit button
            Button(action: onEdit) {
                Image(systemName: "pencil")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .frame(width: 30, height: 30)
            }
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
                details += " • \(Int(weight)) lbs"
            }
        } else {
            if let rounds = exercise.rounds {
                details += " • \(rounds) rounds"
            }
        }
        
        return details
    }
}

// Extension to make Int? Identifiable for sheet binding
extension Int: Identifiable {
    public var id: Int { self }
}

#Preview {
    CreateWorkoutBookView(onSave: { _ in })
}
