//
//  EditProfileView.swift
//  boxtrack
//
//  Created by Karan Bassi on 2025-12-04.
//

import SwiftUI

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    let user: User
    let onSave: (User) -> Void
    
    // Editable fields
    @State private var fighterName: String
    @State private var gym: String
    @State private var selectedLevel: User.FighterLevel
    @State private var wins: String
    @State private var losses: String
    @State private var draws: String
    @State private var currentWeight: String
    @State private var targetWeight: String
    @State private var heightFeet: String
    @State private var heightInches: String
    @State private var age: String
    
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isSaving = false
    
    init(user: User, onSave: @escaping (User) -> Void) {
        self.user = user
        self.onSave = onSave
        
        // Initialize state from user
        _fighterName = State(initialValue: user.fighterName)
        _gym = State(initialValue: user.gym ?? "")
        _selectedLevel = State(initialValue: user.level)
        _wins = State(initialValue: "\(user.record.wins)")
        _losses = State(initialValue: "\(user.record.losses)")
        _draws = State(initialValue: "\(user.record.draws)")
        _currentWeight = State(initialValue: "\(user.stats.currentWeight)")
        _targetWeight = State(initialValue: user.stats.targetWeight != nil ? "\(user.stats.targetWeight!)" : "")
        _heightFeet = State(initialValue: "\(user.heightFeet)")
        _heightInches = State(initialValue: "\(user.heightInches)")
        _age = State(initialValue: "\(user.age)")
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Basic Info Section
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Basic Info")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                            
                            // Fighter Name
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Fighter Name")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                TextField("", text: $fighterName)
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.white.opacity(0.05))
                                    )
                            }
                            
                            // Gym
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Home Gym (Optional)")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                TextField("", text: $gym)
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.white.opacity(0.05))
                                    )
                            }
                            
                            // Level
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Level")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                
                                Picker("", selection: $selectedLevel) {
                                    Text("Training").tag(User.FighterLevel.training)
                                    Text("Amateur").tag(User.FighterLevel.amateur)
                                    Text("Pro").tag(User.FighterLevel.pro)
                                }
                                .pickerStyle(.segmented)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Record Section (only if amateur/pro)
                        if selectedLevel != .training {
                            VStack(alignment: .leading, spacing: 20) {
                                Text("Fight Record")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                HStack(spacing: 16) {
                                    // Wins
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Wins")
                                            .font(.system(size: 14))
                                            .foregroundColor(.gray)
                                        TextField("0", text: $wins)
                                            .keyboardType(.numberPad)
                                            .font(.system(size: 16))
                                            .foregroundColor(.white)
                                            .multilineTextAlignment(.center)
                                            .padding()
                                            .background(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .fill(Color.white.opacity(0.05))
                                            )
                                    }
                                    
                                    // Losses
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Losses")
                                            .font(.system(size: 14))
                                            .foregroundColor(.gray)
                                        TextField("0", text: $losses)
                                            .keyboardType(.numberPad)
                                            .font(.system(size: 16))
                                            .foregroundColor(.white)
                                            .multilineTextAlignment(.center)
                                            .padding()
                                            .background(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .fill(Color.white.opacity(0.05))
                                            )
                                    }
                                    
                                    // Draws
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Draws")
                                            .font(.system(size: 14))
                                            .foregroundColor(.gray)
                                        TextField("0", text: $draws)
                                            .keyboardType(.numberPad)
                                            .font(.system(size: 16))
                                            .foregroundColor(.white)
                                            .multilineTextAlignment(.center)
                                            .padding()
                                            .background(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .fill(Color.white.opacity(0.05))
                                            )
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // Physical Stats Section
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Physical Stats")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                            
                            // Current Weight
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Current Weight (lbs)")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                TextField("0", text: $currentWeight)
                                    .keyboardType(.decimalPad)
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.white.opacity(0.05))
                                    )
                            }
                            
                            // Target Weight
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Target Weight (lbs) - Optional")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                TextField("0", text: $targetWeight)
                                    .keyboardType(.decimalPad)
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.white.opacity(0.05))
                                    )
                            }
                            
                            // Height
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Height")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                
                                HStack(spacing: 16) {
                                    HStack {
                                        TextField("0", text: $heightFeet)
                                            .keyboardType(.numberPad)
                                            .font(.system(size: 16))
                                            .foregroundColor(.white)
                                            .multilineTextAlignment(.center)
                                            .frame(width: 60)
                                        Text("ft")
                                            .font(.system(size: 16))
                                            .foregroundColor(.gray)
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.white.opacity(0.05))
                                    )
                                    
                                    HStack {
                                        TextField("0", text: $heightInches)
                                            .keyboardType(.numberPad)
                                            .font(.system(size: 16))
                                            .foregroundColor(.white)
                                            .multilineTextAlignment(.center)
                                            .frame(width: 60)
                                        Text("in")
                                            .font(.system(size: 16))
                                            .foregroundColor(.gray)
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.white.opacity(0.05))
                                    )
                                }
                            }
                            
                            // Age
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Age")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                TextField("0", text: $age)
                                    .keyboardType(.numberPad)
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.white.opacity(0.05))
                                    )
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer()
                            .frame(height: 100)
                    }
                    .padding(.top, 20)
                }
                
                // Save Button (fixed at bottom)
                VStack {
                    Spacer()
                    
                    Button(action: saveProfile) {
                        if isSaving {
                            ProgressView()
                                .tint(.black)
                        } else {
                            Text("Save Changes")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.black)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.white)
                    .cornerRadius(10)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                    .disabled(isSaving)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                    .disabled(isSaving)
                }
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
    
    // MARK: - Save Profile
    
    private func saveProfile() {
        // Validate
        guard validateFields() else { return }
        
        isSaving = true
        
        // Create updated user object
        var updatedUser = user
        
        // Update basic info
        updatedUser.fighterName = fighterName.trimmingCharacters(in: .whitespaces)
        updatedUser.gym = gym.isEmpty ? nil : gym.trimmingCharacters(in: .whitespaces)
        updatedUser.level = selectedLevel
        
        // Update record
        updatedUser.record = FightRecord(
            wins: Int(wins) ?? 0,
            losses: Int(losses) ?? 0,
            draws: Int(draws) ?? 0
        )
        
        // Update physical stats
        updatedUser.stats.currentWeight = Double(currentWeight) ?? 0
        updatedUser.stats.targetWeight = targetWeight.isEmpty ? nil : Double(targetWeight)
        updatedUser.heightFeet = Int(heightFeet) ?? 0
        updatedUser.heightInches = Int(heightInches) ?? 0
        updatedUser.age = Int(age) ?? 0
        
        // Call onSave
        onSave(updatedUser)
    }
    
    // MARK: - Validation
    
    private func validateFields() -> Bool {
        // Fighter name
        guard !fighterName.trimmingCharacters(in: .whitespaces).isEmpty else {
            showErrorAlert("Fighter name cannot be empty")
            return false
        }
        
        // Age
        guard let ageValue = Int(age), ageValue >= 13 && ageValue <= 100 else {
            showErrorAlert("Age must be between 13 and 100")
            return false
        }
        
        // Height
        guard let feet = Int(heightFeet), feet >= 3 && feet <= 8 else {
            showErrorAlert("Height (feet) must be between 3 and 8")
            return false
        }
        
        guard let inches = Int(heightInches), inches >= 0 && inches <= 11 else {
            showErrorAlert("Height (inches) must be between 0 and 11")
            return false
        }
        
        // Current weight
        guard let weight = Double(currentWeight), weight > 0 else {
            showErrorAlert("Current weight must be greater than 0")
            return false
        }
        
        // Target weight (optional)
        if !targetWeight.isEmpty {
            guard let target = Double(targetWeight), target > 0 else {
                showErrorAlert("Target weight must be greater than 0")
                return false
            }
        }
        
        // Record (if amateur/pro)
        if selectedLevel != .training {
            guard let _ = Int(wins), let _ = Int(losses), let _ = Int(draws) else {
                showErrorAlert("Record must contain valid numbers")
                return false
            }
        }
        
        return true
    }
    
    private func showErrorAlert(_ message: String) {
        errorMessage = message
        showError = true
    }
}

#Preview {
    EditProfileView(
        user: User(
            id: "test",
            email: "test@test.com",
            fighterName: "Test Fighter",
            age: 25,
            heightFeet: 5,
            heightInches: 11,
            weight: 185,
            level: .pro,
            gym: "Test Gym",
            timerSettings: TimerSettings(),
            avatarId: "default",
            record: FightRecord(wins: 10, losses: 2, draws: 1),
            createdAt: Date(),
            stats: UserStats(initialWeight: 185)
        ),
        onSave: { _ in }
    )
}
