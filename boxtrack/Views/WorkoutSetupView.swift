//
//  WorkoutSetupView.swift
//  boxtrack
//
//  Created by Karan Bassi on 2025-12-02.
//
import SwiftUI
import FirebaseAuth

struct WorkoutSetupView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var showActiveWorkout: Bool
    @StateObject private var viewModel = WorkoutSetupViewModel()
    @State private var selectedDate = Date()
    @State private var selectedWorkoutBook: WorkoutBook?
    @State private var selectedGym: String = ""
    @State private var isFreestyle = true
    @State private var showAddGymSheet = false
    @State private var newGymName = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Title
                    Text("Workout Setup")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.top, 20)
                    
                    // Date
                    Text(formattedDate)
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    // Select Workout
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Select Workout")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                        
                        Menu {
                            Button(action: {
                                isFreestyle = true
                                selectedWorkoutBook = nil
                            }) {
                                HStack {
                                    Text("Freestyle")
                                    if isFreestyle {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                            
                            if !viewModel.workoutBooks.isEmpty {
                                Divider()
                                
                                ForEach(viewModel.workoutBooks) { book in
                                    Button(action: {
                                        isFreestyle = false
                                        selectedWorkoutBook = book
                                    }) {
                                        HStack {
                                            Text(book.name)
                                            if selectedWorkoutBook?.id == book.id {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                Text(selectedWorkoutBook?.name ?? "Freestyle")
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal, 30)
                    
                    // Select Gym
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Select Gym")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                        
                        Menu {
                            // None option
                            Button(action: {
                                selectedGym = ""
                            }) {
                                HStack {
                                    Text("None")
                                    if selectedGym.isEmpty {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                            
                            // Available gyms
                            if !viewModel.availableGyms.isEmpty {
                                Divider()
                                
                                ForEach(viewModel.availableGyms, id: \.self) { gym in
                                    Button(action: {
                                        selectedGym = gym
                                    }) {
                                        HStack {
                                            Text(gym)
                                            if selectedGym == gym {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            }
                            
                            // Add new gym
                            Divider()
                            
                            Button(action: {
                                showAddGymSheet = true
                            }) {
                                Label("Add New Gym...", systemImage: "plus")
                            }
                            
                        } label: {
                            HStack {
                                Text(selectedGym.isEmpty ? "None" : selectedGym)
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer()
                    
                    // START Button
                    Button(action: {
                        startWorkout()
                    }) {
                        if viewModel.isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("START")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.black)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.white)
                    .cornerRadius(10)
                    .padding(.horizontal, 30)
                    .padding(.bottom, 40)
                    .disabled(viewModel.isLoading)
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
            .onAppear {
                Task {
                    await viewModel.loadData()
                    // set default gym to hom gym after data loads
                    selectedGym = viewModel.homeGym ?? ""
                }
            }
            .alert("Add New Gym", isPresented: $showAddGymSheet) {
                TextField("Gym Name", text: $newGymName)
                Button("Cancel", role: .cancel) {
                    newGymName = ""
                }
                Button("Add") {
                    if !newGymName.isEmpty {
                        selectedGym = newGymName
                        Task {
                            await viewModel.addNewGym(newGymName)
                        }
                        newGymName = ""
                    }
                }
            } message: {
                Text("Enter the name of your gym")
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: selectedDate)
    }
    
    private func startWorkout() {
        Task {
            let success = await viewModel.startWorkout(
                workoutBook: selectedWorkoutBook,
                gym: selectedGym.isEmpty ? nil : selectedGym
            )
            
            if success {
                dismiss()
                // Small delay to let setup modal dismiss
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showActiveWorkout = true
                }
            }
        }
    }
}

#Preview {
    WorkoutSetupView(showActiveWorkout: .constant(false))
}
