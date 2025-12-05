//
//  AddExerciseToBookView.swift
//  boxtrack
//
//  Created by Karan Bassi on 2025-12-04.
//

import SwiftUI

struct AddExerciseToBookView: View {
    @Environment(\.dismiss) var dismiss
    let onAdd: (WorkoutExercise) -> Void
    let existingExercise: WorkoutExercise?
    
    @State private var selectedCategory: ExerciseCategory = .boxing
    @State private var selectedExercise = ""
    @State private var selectedType: ExerciseType = .rounds
    @State private var sets = "3"
    @State private var reps = "12"
    @State private var weight = ""
    @State private var rounds = "3"
    @State private var notes = ""
    
    init(onAdd: @escaping (WorkoutExercise) -> Void, existingExercise: WorkoutExercise? = nil) {
        self.onAdd = onAdd
        self.existingExercise = existingExercise
        
        // Initialize with existing exercise if editing
        if let exercise = existingExercise {
            _selectedCategory = State(initialValue: exercise.category)
            _selectedExercise = State(initialValue: exercise.name)
            _selectedType = State(initialValue: exercise.type)
            _sets = State(initialValue: "\(exercise.sets ?? 3)")
            _reps = State(initialValue: "\(exercise.reps ?? 12)")
            _weight = State(initialValue: exercise.weight != nil ? "\(exercise.weight!)" : "")
            _rounds = State(initialValue: "\(exercise.rounds ?? 3)")
            _notes = State(initialValue: exercise.notes ?? "")
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Category Selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Category")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(ExerciseCategory.allCases, id: \.self) { category in
                                        CategoryButton(
                                            title: category.rawValue,
                                            isSelected: selectedCategory == category
                                        ) {
                                            selectedCategory = category
                                            selectedExercise = ""
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Exercise Selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Exercise")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                            
                            Menu {
                                ForEach(selectedCategory.subcategories, id: \.self) { exercise in
                                    Button(exercise) {
                                        selectedExercise = exercise
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(selectedExercise.isEmpty ? "Select Exercise" : selectedExercise)
                                        .foregroundColor(selectedExercise.isEmpty ? .gray : .white)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Type Selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Type")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                            
                            HStack(spacing: 12) {
                                TypeButton(
                                    title: "Sets & Reps",
                                    isSelected: selectedType == .setsAndReps
                                ) {
                                    selectedType = .setsAndReps
                                }
                                
                                TypeButton(
                                    title: "Rounds",
                                    isSelected: selectedType == .rounds
                                ) {
                                    selectedType = .rounds
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Details based on type
                        if selectedType == .setsAndReps {
                            VStack(spacing: 20) {
                                HStack(spacing: 20) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Sets")
                                            .font(.system(size: 14))
                                            .foregroundColor(.gray)
                                        TextField("3", text: $sets)
                                            .keyboardType(.numberPad)
                                            .foregroundColor(.white)
                                            .padding()
                                            .background(Color.white.opacity(0.1))
                                            .cornerRadius(10)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Reps")
                                            .font(.system(size: 14))
                                            .foregroundColor(.gray)
                                        TextField("12", text: $reps)
                                            .keyboardType(.numberPad)
                                            .foregroundColor(.white)
                                            .padding()
                                            .background(Color.white.opacity(0.1))
                                            .cornerRadius(10)
                                    }
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Weight (lbs) - Optional")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                    TextField("0", text: $weight)
                                        .keyboardType(.decimalPad)
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(Color.white.opacity(0.1))
                                        .cornerRadius(10)
                                }
                            }
                            .padding(.horizontal, 20)
                        } else {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Rounds")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                TextField("3", text: $rounds)
                                    .keyboardType(.numberPad)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(10)
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // Notes
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes (Optional)")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                            TextField("Add any notes...", text: $notes)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(10)
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer()
                            .frame(height: 100)
                    }
                    .padding(.top, 20)
                }
                
                // Add Button (fixed at bottom)
                VStack {
                    Spacer()
                    
                    Button(action: addExercise) {
                        Text(existingExercise == nil ? "Add Exercise" : "Save Changes")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                    .disabled(selectedExercise.isEmpty)
                    .opacity(selectedExercise.isEmpty ? 0.5 : 1)
                }
            }
            .navigationTitle(existingExercise == nil ? "Add Exercise" : "Edit Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
    
    private func addExercise() {
        let exercise = WorkoutExercise(
            name: selectedExercise,
            category: selectedCategory,
            type: selectedType,
            sets: selectedType == .setsAndReps ? Int(sets) : nil,
            reps: selectedType == .setsAndReps ? Int(reps) : nil,
            weight: weight.isEmpty ? nil : Double(weight),
            rounds: selectedType == .rounds ? Int(rounds) : nil,
            isSuperset: false,
            supersetGroup: nil
        )
        
        onAdd(exercise)
        dismiss()
    }
}

#Preview {
    AddExerciseToBookView(onAdd: { _ in })
}
