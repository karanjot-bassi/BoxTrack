//
//  MainTabView.swift
//  boxtrack
//
//  Created by Karan Bassi on 2025-11-22.
//

import SwiftUI
import FirebaseAuth

struct MainTabView: View {
    @State private var selectedTab = 0
    @StateObject private var activeWorkoutViewModel = ActiveWorkoutViewModel()
    @StateObject private var timerManager = BoxingTimerManager.shared
    @State private var showQuickActionMenu = false
    @State private var showStartWorkout = false
    @State private var showUpdateWeight = false
    @State private var showLogPrevious = false
    @State private var showActiveWorkout = false
    @State private var hasActiveWorkout = false
    @State private var refreshHomeView = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.ignoresSafeArea()
            
            // Main Content
            TabView(selection: $selectedTab) {
                HomeView(refreshTrigger: refreshHomeView)
                    .tag(0)
                
                ProfileView()
                    .tag(1)
                
                // Center tab (avatar) - handled separately
                Color.clear
                    .tag(2)
                
                WorkoutBookView()
                    .tag(3)
                
                SettingsView()
                    .tag(4)
            }
            .tabViewStyle(.automatic)
            
            // Custom Tab Bar
            CustomTabBar(
                selectedTab: $selectedTab,
                showQuickActionMenu: $showQuickActionMenu,
                hasActiveWorkout: hasActiveWorkout,
                showActiveWorkout: $showActiveWorkout
            )
        }
        .sheet(isPresented: $showQuickActionMenu) {
            QuickActionMenuView(
                showStartWorkout: $showStartWorkout,
                showUpdateWeight: $showUpdateWeight,
                showLogPrevious: $showLogPrevious
            )
        }
        .sheet(isPresented: $showStartWorkout) {
            WorkoutSetupView(showActiveWorkout: $showActiveWorkout)
        }
        .sheet(isPresented: $showUpdateWeight) {
            Text("Update Weight - Coming soon!")
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black)
        }
        .sheet(isPresented: $showLogPrevious) {
            Text("Log Previous Workout - Coming soon!")
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black)
        }
        .sheet(isPresented: $showActiveWorkout) {
            ActiveWorkoutView(viewModel: activeWorkoutViewModel)
            
        }
        .onAppear {
            checkForActiveWorkout()
        }
        .onChange(of: showActiveWorkout) { oldValue, newValue in
            // When sheet closes (newValue = false), update button state
            if !newValue {
                updateActiveWorkoutState()
                refreshHomeView.toggle()
            }
        }
    }
    private func checkForActiveWorkout() {
        // Check if there's an active workout session
        if UserDefaults.standard.string(forKey: "activeWorkoutSessionId") != nil {
            hasActiveWorkout = true
            showActiveWorkout = true  // Open sheet on app launch
        } else {
            hasActiveWorkout = false
            showActiveWorkout = false
        }
    }
    private func updateActiveWorkoutState() {
        // Update button state WITHOUT reopening sheet
        hasActiveWorkout = UserDefaults.standard.string(forKey: "activeWorkoutSessionId") != nil
    }
}


struct CustomTabBar: View {
    @Binding var selectedTab: Int
    @Binding var showQuickActionMenu: Bool
    let hasActiveWorkout: Bool
    @Binding var showActiveWorkout: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            // Home
            TabBarButton(icon: "house.fill", isSelected: selectedTab == 0) {
                selectedTab = 0
            }
            
            // Profile
            TabBarButton(icon: "person.fill", isSelected: selectedTab == 1) {
                selectedTab = 1
            }
            
            // Center Button - Resume or Add
            Button(action: {
                if hasActiveWorkout {
                    // Resume active workout
                    showActiveWorkout = true
                } else {
                    // Show quick action menu
                    showQuickActionMenu = true
                }
            }) {
                if hasActiveWorkout {
                    // Green Resume Button
                    VStack(spacing: 4) {
                        Text("Resume")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .frame(width: 70, height: 60)
                    .background(Color.green)
                    .cornerRadius(30)
                    .offset(y: -10)
                } else {
                    // Regular + Button
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 60, height: 60)
                        .overlay(
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(.white)
                        )
                        .offset(y: -10)
                }
            }
            
            // Workout Book
            TabBarButton(icon: "book.fill", isSelected: selectedTab == 3) {
                selectedTab = 3
            }
            
            // Settings
            TabBarButton(icon: "ellipsis", isSelected: selectedTab == 4) {
                selectedTab = 4
            }
        }
        .frame(height: 80)
        .background(Color.black)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.white.opacity(0.1)),
            alignment: .top
        )
    }
}

struct TabBarButton: View {
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(isSelected ? .white : .gray)
                .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Placeholder Views (we'll build these properly later)

struct HomeView: View {
    @StateObject private var timerManager = BoxingTimerManager.shared
    @State private var workoutHistory: [WorkoutSession] = []
    @State private var isLoadingHistory = true
    let refreshTrigger: Bool
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Spacer for top
                Spacer()
                    .frame(height: 40)
                
                // Timer Display
                VStack(spacing: 8) {
                    Text(timerManager.timeDisplay)
                        .font(.system(size: 72, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 160)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white.opacity(0.05))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                    
                    // Working/Rest indicator
                    Text(timerManager.isWorking ? "WORKING" : "REST")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(timerManager.isWorking ? .green : .orange)
                        .padding(.top, 4)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
                
                // Workout History Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Workout History")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                    
                    if isLoadingHistory {
                        ProgressView()
                            .tint(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 40)
                    } else if workoutHistory.isEmpty {
                        // Empty state
                        VStack(spacing: 12) {
                            Image(systemName: "figure.boxing")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                            
                            Text("No workouts yet")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                            
                            Text("Start your first workout to see it here!")
                                .font(.system(size: 14))
                                .foregroundColor(.gray.opacity(0.7))
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 60)
                    } else {
                        // Workout list
                        ForEach(workoutHistory) { workout in
                            WorkoutHistoryCard(workout: workout)
                                .padding(.horizontal, 20)
                        }
                    }
                }
                .padding(.bottom, 120) // Space for tab bar
            }
        }
        .background(Color.black)
        .onAppear {
            loadWorkoutHistory()
        }
        .onChange(of: refreshTrigger) { _, _ in
            loadWorkoutHistory()
        }
    }
    
    private func loadWorkoutHistory() {
        guard let userId = Auth.auth().currentUser?.uid else {
            isLoadingHistory = false
            return
        }
        
        isLoadingHistory = true
        
        Task {
            do {
                workoutHistory = try await WorkoutService.shared.getUserWorkoutSessions(
                    userId: userId,
                    limit: 10
                )
            } catch {
                print("Failed to load workout history: \(error)")
                workoutHistory = []
            }
            isLoadingHistory = false
        }
    }
}

struct WorkoutHistoryCard: View {
    let workout: WorkoutSession
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(workout.workoutBookName ?? "Freestyle Workout")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(workout.formattedDate)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            
            HStack {
                if let gym = workout.gym {
                    Text(gym)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    Spacer()
                }
                
                Text(workout.formattedDuration)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
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

struct ProfileView: View {
    var body: some View {
        Text("Profile - Coming soon!")
            .foregroundColor(.white)
    }
}

struct WorkoutBookView: View {
    var body: some View {
        Text("Workout Book - Coming soon!")
            .foregroundColor(.white)
    }
}

struct SettingsView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 60)
                
                Text("More")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                
                VStack(spacing: 0) {
                    SettingsRow(title: "Edit Account")
                    SettingsRow(title: "Change Password")
                    SettingsRow(title: "Settings")
                    SettingsRow(title: "Terms and Conditions")
                    
                    Button(action: {
                        try? Auth.auth().signOut()
                    }) {
                        HStack {
                            Text("Log Out")
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                    }
                    
                    SettingsRow(title: "Delete Account")
                }
                
                Spacer()
                
                // Logo at bottom
                Image("logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .padding(.bottom, 100)
            }
        }
        .background(Color.black)
    }
}

struct SettingsRow: View {
    let title: String
    
    var body: some View {
        Button(action: {}) {
            HStack {
                Text(title)
                    .foregroundColor(.white)
                Spacer()
            }
            .padding()
            .background(Color.white.opacity(0.05))
        }
    }
}

#Preview {
    MainTabView()
}
