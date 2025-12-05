//
//  ActiveWorkoutView.swift
//  boxtrack
//
//  Created by Karan Bassi on 2025-12-02.
//
import SwiftUI

struct ActiveWorkoutView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: ActiveWorkoutViewModel
    @State private var selectedExerciseIndex = 0
    @State private var showAddExercise = false
    @State private var showBottomSheet = false
    @StateObject private var timerManager = BoxingTimerManager.shared
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Bar
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.black)
                            .padding()
                    }
                    
                    Spacer()
                    
                    // Workout duration timer
                    Text(viewModel.workoutDuration)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black)
                        .padding()
                }
                
                // Workout Title
                Text(viewModel.workoutName)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.top, 8)
                
                // Global Boxing Timer Display
                Text(timerManager.timeDisplay)
                    .font(.system(size: 48, weight: .medium, design: .rounded))
                    .foregroundColor(.black)
                    .padding(.vertical, 20)
                
                Spacer()
                
                // Current Exercise Display or Empty State
                if !viewModel.exercises.isEmpty && selectedExerciseIndex < viewModel.exercises.count {
                    CurrentExerciseCard(
                        exercise: viewModel.exercises[selectedExerciseIndex],
                        exerciseNumber: selectedExerciseIndex + 1,
                        onLogSet: { reps, weight in
                            viewModel.logSet(
                                for: selectedExerciseIndex,
                                reps: reps,
                                weight: weight
                            )
                        },
                        onCompleteRound: {
                            viewModel.logRound(for: selectedExerciseIndex)
                        }
                    )
                } else {
                    // Empty State
                    VStack(spacing: 20) {
                        Image(systemName: "figure.boxing")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No exercises yet")
                            .font(.system(size: 18))
                            .foregroundColor(.gray)
                        
                        Button(action: {
                            showAddExercise = true
                        }) {
                            Text("Add Exercise")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 30)
                                .padding(.vertical, 12)
                                .background(Color.black)
                                .cornerRadius(25)
                        }
                    }
                }
                
                Spacer()
                
                // Space for bottom bar
                Color.clear.frame(height: 100)
            }
            
            // Fixed Bottom Bar
            BottomNavigationBar(
                exercises: viewModel.exercises,
                currentIndex: $selectedExerciseIndex,
                onAddExercise: {
                    showAddExercise = true
                },
                onFinishWorkout: {
                    // TODO: Finish workout
                },
                onDeleteExercise: { index in
                    viewModel.deleteExercise(at: index)
                    if selectedExerciseIndex >= viewModel.exercises.count {
                        selectedExerciseIndex = max(0, viewModel.exercises.count - 1)
                    }
                }
            )
        }
        .sheet(isPresented: $showAddExercise) {
            AddExerciseView(exercises: $viewModel.exercises)
        }
        .onAppear {
            if !viewModel.hasLoadedWorkout {
                viewModel.loadActiveWorkout()
            }
        }
    }
}

// MARK: - Current Exercise Card
struct CurrentExerciseCard: View {
    let exercise: ExerciseLog
    let exerciseNumber: Int
    let onLogSet: (Int, Double) -> Void
    let onCompleteRound: () -> Void
    
    @State private var reps = ""
    @State private var weight = ""
    
    var isComplete: Bool {
        // Check if exercise has reached its planned sets/rounds
        // For now, simplified
        return false
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Exercise Number Badge
            Text("#\(exerciseNumber)")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(Color.gray)
                .cornerRadius(20)
            
            // Exercise Name
            Text(exercise.name)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.black)
                .padding(.top, 10)
            
            // Type-specific UI
            if exercise.type == .setsAndReps {
                SetsRepsView(
                    exercise: exercise,
                    reps: $reps,
                    weight: $weight,
                    onLogSet: onLogSet
                )
            } else if exercise.type == .rounds {
                RoundsView(
                    exercise: exercise,
                    onCompleteRound: onCompleteRound
                )
            }
        }
        .padding(.horizontal, 30)
        .onAppear {
            // Auto-fill from last set if available
            if let lastSet = exercise.sets.last {
                reps = "\(lastSet.reps ?? 0)"
                weight = "\(lastSet.weight ?? 0)"
            }
        }
    }
}

// MARK: - Sets & Reps View
struct SetsRepsView: View {
    let exercise: ExerciseLog
    @Binding var reps: String
    @Binding var weight: String
    let onLogSet: (Int, Double) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Current Set
            Text("Set \(exercise.sets.count + 1)")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.black)
            
            // Input Fields
            HStack(spacing: 30) {
                VStack {
                    TextField("0", text: $reps)
                        .keyboardType(.numberPad)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .frame(width: 80)
                    
                    Text("Reps")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                
                VStack {
                    TextField("0", text: $weight)
                        .keyboardType(.decimalPad)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .frame(width: 100)
                    
                    Text("Weight (lbs)")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
            }
            
            // Log Set Button
            Button(action: {
                guard let r = Int(reps), let w = Double(weight) else { return }
                onLogSet(r, w)
                // Keep values for next set (auto-fill)
            }) {
                Text("Log Set")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                    .background(Color.black)
                    .cornerRadius(25)
            }
            .disabled(reps.isEmpty || weight.isEmpty)
            
            // Logged Sets Display
            if !exercise.sets.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Logged Sets:")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                    
                    ForEach(exercise.sets) { set in
                        HStack {
                            Text("Set \(set.setNumber):")
                                .font(.system(size: 14))
                            Text("\(set.reps ?? 0) reps × \(Int(set.weight ?? 0))lbs")
                                .font(.system(size: 14, weight: .medium))
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            }
        }
    }
}

// MARK: - Rounds View
struct RoundsView: View {
    let exercise: ExerciseLog
    let onCompleteRound: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Current Round
            Text("Round \(exercise.sets.count + 1)")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.black)
            
            // Complete Round Button
            Button(action: onCompleteRound) {
                Text("Complete Round")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 220, height: 50)
                    .background(Color.black)
                    .cornerRadius(25)
            }
            
            // Completed Rounds Display
            if !exercise.sets.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Completed Rounds: \(exercise.sets.count)")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.green)
                }
                .padding()
            }
        }
    }
}

// MARK: - Bottom Navigation Bar
struct BottomNavigationBar: View {
    let exercises: [ExerciseLog]
    @Binding var currentIndex: Int
    let onAddExercise: () -> Void
    let onFinishWorkout: () -> Void
    let onDeleteExercise: (Int) -> Void
    
    @State private var isExpanded = false
    @State private var showDeleteWorkoutAlert = false
    @State private var exerciseToDelete: Int?
    
    var body: some View {
        VStack(spacing: 0) {
            // Drag Handle
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.white.opacity(0.3))
                .frame(width: 40, height: 5)
                .padding(.top, 12)
                .padding(.bottom, 8)
            
            if isExpanded {
                // EXPANDED STATE: Show all exercises + trash
                VStack(spacing: 16) {
                    // All Exercise Buttons
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(0..<exercises.count, id: \.self) { index in
                                Button(action: {
                                    currentIndex = index
                                    withAnimation {
                                        isExpanded = false
                                    }
                                }) {
                                    Text("#\(index + 1)")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.black)
                                        .frame(width: 60, height: 44)
                                        .background(Color.white)
                                        .cornerRadius(22)
                                }
                                .simultaneousGesture(
                                    LongPressGesture(minimumDuration: 0.5)
                                        .onEnded { _ in
                                            exerciseToDelete = index
                                        }
                                )
                            }
                            
                            // Add Exercise Button
                            Button(action: {
                                onAddExercise()
                                withAnimation {
                                    isExpanded = false
                                }
                            }) {
                                Image(systemName: "plus")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.black)
                                    .frame(width: 60, height: 44)
                                    .background(Color.white)
                                    .cornerRadius(22)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Bottom Actions: Trash + Finish
                    HStack(spacing: 12) {
                        // Trash Button
                        Button(action: {
                            showDeleteWorkoutAlert = true
                        }) {
                            Image(systemName: "trash")
                                .font(.system(size: 18))
                                .foregroundColor(.black)
                                .frame(width: 60, height: 50)
                                .background(Color.white)
                                .cornerRadius(25)
                        }
                        
                        // Finish Workout
                        Button(action: onFinishWorkout) {
                            Text("Finish Workout")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.white)
                                .cornerRadius(25)
                        }
                        .disabled(exercises.isEmpty)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
                
            } else {
                // COLLAPSED STATE: 3 different layouts based on position
                HStack(spacing: 12) {
                    // Previous Exercise (only if not first)
                    if currentIndex > 0 {
                        Button(action: {
                            currentIndex -= 1
                        }) {
                            Text("#\(currentIndex)")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                                .frame(width: 60, height: 50)
                                .background(Color.white)
                                .cornerRadius(25)
                        }
                    }
                    
                    // Finish Workout
                    Button(action: onFinishWorkout) {
                        Text("Finish Workout")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.white)
                            .cornerRadius(25)
                    }
                    .disabled(exercises.isEmpty)
                    
                    // Next Exercise or Add (only if exercises exist)
                    if currentIndex < exercises.count - 1 {
                        Button(action: {
                            currentIndex += 1
                        }) {
                            Text("#\(currentIndex + 2)")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                                .frame(width: 60, height: 50)
                                .background(Color.white)
                                .cornerRadius(25)
                        }
                    } else if exercises.isEmpty || currentIndex == exercises.count - 1 {
                        // Show + button if no exercises or on last exercise
                        Button(action: onAddExercise) {
                            Image(systemName: "plus")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.black)
                                .frame(width: 60, height: 50)
                                .background(Color.white)
                                .cornerRadius(25)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .background(Color.black) // BLACK BACKGROUND
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.height < -50 {
                        // Swiped up
                        withAnimation(.spring()) {
                            isExpanded = true
                        }
                    } else if value.translation.height > 50 {
                        // Swiped down
                        withAnimation(.spring()) {
                            isExpanded = false
                        }
                    }
                }
        )
        .alert("Delete Exercise", isPresented: Binding(
            get: { exerciseToDelete != nil },
            set: { if !$0 { exerciseToDelete = nil } }
        )) {
            Button("Cancel", role: .cancel) {
                exerciseToDelete = nil
            }
            Button("Delete", role: .destructive) {
                if let index = exerciseToDelete {
                    onDeleteExercise(index)
                    exerciseToDelete = nil
                }
            }
        } message: {
            if let index = exerciseToDelete, index < exercises.count {
                Text("Delete \(exercises[index].name)?")
            }
        }
        .alert("Delete Workout", isPresented: $showDeleteWorkoutAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                // TODO: Wire up delete workout
            }
        } message: {
            Text("Are you sure you want to delete this entire workout? This cannot be undone.")
        }
    }
}


#Preview {
    ActiveWorkoutView(viewModel: ActiveWorkoutViewModel())
}
