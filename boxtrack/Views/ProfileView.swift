//
//  ProfileView.swift
//  boxtrack
//
//  Created by Karan Bassi on 2025-12-04.
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showEditProfile = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if viewModel.isLoading {
                ProgressView()
                    .tint(.white)
            } else if let user = viewModel.user {
                ScrollView {
                    VStack(spacing: 16) {
                        // Spacer for top
                        Spacer()
                            .frame(height: 20)
                        
                        // Boxer Card
                        BoxerCard(
                            user: user,
                            onEdit: {
                                showEditProfile = true
                            }
                        )
                        .padding(.horizontal, 20)
                        
                        // Weight Card
                        WeightCard(
                            currentWeight: user.stats.currentWeight,
                            targetWeight: user.stats.targetWeight
                        )
                        .padding(.horizontal, 20)
                        
                        // Stats Grid
                        StatsGrid(
                            totalWorkouts: user.stats.totalWorkouts,
                            sparringRounds: viewModel.sparringRounds,
                            height: user.heightDisplay,
                            age: user.age,
                            lastDuration: viewModel.lastWorkoutDuration,
                            lastDate: viewModel.lastWorkoutDate
                        )
                        .padding(.horizontal, 20)
                        
                        Spacer()
                            .frame(height: 120) // Space for tab bar
                    }
                }
            } else {
                Text("Failed to load profile")
                    .foregroundColor(.white)
            }
        }
        .sheet(isPresented: $showEditProfile) {
            if let user = viewModel.user {
                EditProfileView(user: user) { updatedUser in
                    Task {
                        let success = await viewModel.updateProfile(updatedUser)
                        if success {
                            showEditProfile = false
                        }
                    }
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.loadProfile()
            }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
    }
}

// MARK: - Boxer Card
struct BoxerCard: View {
    let user: User
    let onEdit: () -> Void
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 12) {
                // Fighter Name
                Text(user.fighterName)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                
                // Gym
                if let gym = user.gym {
                    Text(gym)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                    .frame(height: 20)
                
                // Level + Record
                HStack {
                    Text(levelText)
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    if user.level != .training {
                        Text(user.record.displayText)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 180)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
            
            // Edit Button
            Button(action: onEdit) {
                Text("Edit")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.1))
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    )
            }
            .padding(16)
        }
    }
    
    private var levelText: String {
        switch user.level {
        case .training:
            return "Training"
        case .amateur:
            return "Amateur Boxer"
        case .pro:
            return "Pro Boxer"
        }
    }
}

// MARK: - Weight Card
struct WeightCard: View {
    let currentWeight: Double
    let targetWeight: Double?
    
    var body: some View {
        HStack(spacing: 0) {
            // Current Weight
            VStack(spacing: 8) {
                Text("\(Int(currentWeight))lb")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundColor(.white)
                
                Text("Current Weight")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity)
            
            // Divider
            Rectangle()
                .fill(Color.white.opacity(0.1))
                .frame(width: 1, height: 60)
            
            // Target Weight
            VStack(spacing: 8) {
                Text(targetWeight != nil ? "\(Int(targetWeight!))lb" : "-")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundColor(.white)
                
                Text("Target Weight")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

// MARK: - Stats Grid
struct StatsGrid: View {
    let totalWorkouts: Int
    let sparringRounds: Int
    let height: String
    let age: Int
    let lastDuration: String
    let lastDate: String
    
    var body: some View {
        VStack(spacing: 16) {
            // Row 1: Workouts | Sparring Rounds
            HStack(spacing: 16) {
                ProfileStatCard(value: "\(totalWorkouts)", label: "Workouts")
                ProfileStatCard(value: "\(sparringRounds)", label: "Sparring Rounds")
            }

            // Row 2: Height | Age
            HStack(spacing: 16) {
                ProfileStatCard(value: height, label: "Height")
                ProfileStatCard(value: "\(age)", label: "Age")
            }

            // Row 3: Last Duration | Last Workout
            HStack(spacing: 16) {
                ProfileStatCard(value: lastDuration, label: "Last Duration")
                ProfileStatCard(value: lastDate, label: "Last Workout")
            }
        }
    }
}

// MARK: - Profile Stat Card
struct ProfileStatCard: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.system(size: 32, weight: .semibold))
                .foregroundColor(.white)
            
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 100)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

#Preview {
    ProfileView()
}
