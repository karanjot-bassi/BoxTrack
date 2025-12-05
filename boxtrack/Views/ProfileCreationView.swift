//
//  ProfileCreationView.swift
//  boxtrack
//
//  Created by Karan Bassi on 2025-11-22.
//

import SwiftUI

struct ProfileCreationView: View {
    @StateObject private var viewModel = ProfileCreationViewModel()
    @State private var currentStep = 0
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            TabView(selection: $currentStep) {
                // Step 1: Fighter Name & Age
                FighterNameView(viewModel: viewModel, onNext: {
                    withAnimation {
                        currentStep = 1
                    }
                })
                .tag(0)
                
                // Step 2: Height & Weight
                HeightWeightView(viewModel: viewModel, onNext: {
                    withAnimation {
                        currentStep = 2
                    }
                }, onBack: {
                    withAnimation {
                        currentStep = 0
                    }
                })
                .tag(1)
                
                // Step 3: Level
                LevelView(viewModel: viewModel, onNext: {
                    withAnimation {
                        currentStep = 3
                    }
                }, onBack: {
                    withAnimation {
                        currentStep = 1
                    }
                })
                .tag(2)

                // Step 4: Gym
                GymView(viewModel: viewModel, onNext: {
                    withAnimation {
                        currentStep = 4
                    }
                }, onBack: {
                    withAnimation {
                        currentStep = 2
                    }
                })
                .tag(3)

                // Step 5: Timer Settings
                TimerSettingsView(viewModel: viewModel, onNext: {
                    withAnimation {
                        currentStep = 5
                    }
                }, onBack: {
                    withAnimation {
                        currentStep = 3
                    }
                })
                .tag(4)

                // Step 6: Avatar & Record
                AvatarRecordView(viewModel: viewModel, onBack: {
                    withAnimation {
                        currentStep = 4
                    }
                })
                .tag(5)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
    }
}

// MARK: - Step 1: Fighter Name & Age
struct FighterNameView: View {
    @ObservedObject var viewModel: ProfileCreationViewModel
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Title
            Text("Finish Profile")
                .font(.system(size: 32, weight: .semibold))
                .foregroundColor(.white)
                .padding(.bottom, 60)
            
            // Fighter Name
            VStack(alignment: .leading, spacing: 8) {
                Text("fighter name")
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                
                TextField("name", text: $viewModel.fighterName)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.white)
                
                if viewModel.isCheckingFighterName {
                    HStack(spacing: 8) {
                        ProgressView()
                            .scaleEffect(0.8)
                            .tint(.gray)
                        Text("Checking availability...")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 4)
                } else if !viewModel.fighterName.isEmpty && viewModel.fighterNameTaken {
                    Text("⚠️ This name is already taken")
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.top, 4)
                } else if !viewModel.fighterName.isEmpty && !viewModel.fighterNameTaken {
                    Text("✓ Available")
                        .font(.caption)
                        .foregroundColor(.green)
                        .padding(.top, 4)
                }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 30)
            
            // Age
            VStack(alignment: .leading, spacing: 8) {
                Text("fighter age")
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                
                TextField("00", text: $viewModel.ageText)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .keyboardType(.numberPad)
                    .padding(.vertical, 8)
                
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 40)
            
            Spacer()
            
            // Next Button
            Button(action: onNext) {
                Text("next")
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(Color.white, lineWidth: 2)
                    )
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 60)
            .disabled(!viewModel.canProceedFromStep1)
        }
        .onChange(of: viewModel.fighterName) { _ in
            viewModel.checkFighterNameDebounced()
        }
    }
}

// MARK: - Step 2: Height & Weight
struct HeightWeightView: View {
    @ObservedObject var viewModel: ProfileCreationViewModel
    let onNext: () -> Void
    let onBack: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Title
            Text("Finish Profile")
                .font(.system(size: 32, weight: .semibold))
                .foregroundColor(.white)
                .padding(.bottom, 60)
            
            // Height
            VStack(alignment: .leading, spacing: 8) {
                Text("fighter height")
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                
                HStack(spacing: 20) {
                    // Feet
                    HStack {
                        TextField("0", text: $viewModel.heightFeetText)
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.center)
                            .frame(width: 40)
                        
                        Text("ft")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                    }
                    
                    // Inches
                    HStack {
                        TextField("0", text: $viewModel.heightInchesText)
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.center)
                            .frame(width: 40)
                        
                        Text("in")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                    }
                }
                .padding(.vertical, 8)
                
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 30)
            
            // Weight
            VStack(alignment: .leading, spacing: 8) {
                Text("fighter weight")
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                
                HStack {
                    TextField("0", text: $viewModel.weightText)
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .keyboardType(.decimalPad)
                        .frame(width: 60)
                    
                    Text("lbs")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 8)
                
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 40)
            
            Spacer()
            
            // Next Button
            Button(action: onNext) {
                Text("next")
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(Color.white, lineWidth: 2)
                    )
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 60)
            .disabled(!viewModel.canProceedFromStep2)
        }
    }
}


// MARK: - Step 3: Level
struct LevelView: View {
    @ObservedObject var viewModel: ProfileCreationViewModel
    let onNext: () -> Void
    let onBack: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            Text("Finish Profile")
                .font(.system(size: 32, weight: .semibold))
                .foregroundColor(.white)
                .padding(.bottom, 60)
            
            Text("level")
                .font(.system(size: 16))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 40)
                .padding(.bottom, 20)
            
            VStack(spacing: 15) {
                LevelButton(title: "training", isSelected: viewModel.selectedLevel == .training) {
                    viewModel.selectedLevel = .training
                }
                
                LevelButton(title: "amateur", isSelected: viewModel.selectedLevel == .amateur) {
                    viewModel.selectedLevel = .amateur
                }
                
                LevelButton(title: "pro", isSelected: viewModel.selectedLevel == .pro) {
                    viewModel.selectedLevel = .pro
                }
            }
            .padding(.horizontal, 40)
            
            Spacer()
            
            Button(action: onNext) {
                Text("next")
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(Color.white, lineWidth: 2)
                    )
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 60)
        }
    }
}

struct LevelButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 18))
                .foregroundColor(isSelected ? .black : .white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 28)
                        .fill(isSelected ? Color.white : Color.clear)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(Color.white, lineWidth: 2)
                )
        }
    }
}

// MARK: - Step 4: Gym
struct GymView: View {
    @ObservedObject var viewModel: ProfileCreationViewModel
    let onNext: () -> Void
    let onBack: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            Text("Finish Profile")
                .font(.system(size: 32, weight: .semibold))
                .foregroundColor(.white)
                .padding(.bottom, 60)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("home gym")
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                
                TextField("gym name", text: $viewModel.gymName)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 40)
            
            Button(action: onNext) {
                Text("skip")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
            }
            .padding(.top, 20)
            
            Spacer()
            
            Button(action: onNext) {
                Text("next")
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(Color.white, lineWidth: 2)
                    )
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 60)
        }
    }
}

// MARK: - Step 5: Timer Settings
struct TimerSettingsView: View {
    @ObservedObject var viewModel: ProfileCreationViewModel
    let onNext: () -> Void
    let onBack: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            Text("Finish Profile")
                .font(.system(size: 32, weight: .semibold))
                .foregroundColor(.white)
                .padding(.bottom, 60)
            
            Text("timer settings")
                .font(.system(size: 16))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 40)
                .padding(.bottom, 30)
            
            // Working Time
            VStack(spacing: 15) {
                Text("working:")
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                
                Text(String(format: "%d:%02d", viewModel.workingMinutes, viewModel.workingSeconds))
                    .font(.system(size: 48, weight: .medium))
                    .foregroundColor(.white)
                
                HStack(spacing: 20) {
                    Stepper("", value: $viewModel.workingMinutes, in: 0...59)
                        .labelsHidden()
                    Stepper("", value: $viewModel.workingSeconds, in: 0...59)
                        .labelsHidden()
                }
            }
            .padding(.bottom, 40)
            
            // Rest Time
            VStack(spacing: 15) {
                Text("rest:")
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                
                Text(String(format: "%d:%02d", viewModel.restMinutes, viewModel.restSeconds))
                    .font(.system(size: 48, weight: .medium))
                    .foregroundColor(.white)
                
                HStack(spacing: 20) {
                    Stepper("", value: $viewModel.restMinutes, in: 0...59)
                        .labelsHidden()
                    Stepper("", value: $viewModel.restSeconds, in: 0...59)
                        .labelsHidden()
                }
            }
            
            Spacer()
            
            Button(action: onNext) {
                Text("complete")
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(Color.white, lineWidth: 2)
                    )
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 60)
        }
    }
}


// MARK: - Step 6: Boxer Card Preview
struct AvatarRecordView: View {
    @ObservedObject var viewModel: ProfileCreationViewModel
    let onBack: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            Text("Welcome to BoxTrack")
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(.white)
                .padding(.bottom, 20)
            
            Text("boxer card:")
                .font(.system(size: 16))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 40)
                .padding(.bottom, 20)
            
            // Boxer Card Preview
            VStack(spacing: 0) {
                // Name and Level
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(viewModel.fighterName)
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text(viewModel.selectedLevel.rawValue.capitalized)
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(8)
                    }
                    
                    if !viewModel.gymName.isEmpty {
                        Text(viewModel.gymName)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .padding(.top, 4)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                
                Divider()
                    .background(Color.gray)
                
                // Weight Stats
                HStack(spacing: 0) {
                    VStack(spacing: 4) {
                        Text(viewModel.weightText + "lbs")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                        Text("Current Weight")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    
                    Rectangle()
                        .fill(Color.gray)
                        .frame(width: 1, height: 40)
                    
                    VStack(spacing: 4) {
                        Text(viewModel.weightText + "lbs")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                        Text("Target Weight")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.vertical, 16)
                
                // Record (only show for amateur/pro)
                if viewModel.selectedLevel != .training {
                    Divider()
                        .background(Color.gray)
                    
                    VStack(spacing: 8) {
                        Text("\(viewModel.selectedLevel.rawValue.capitalized) Boxer")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        
                        Text("\(viewModel.wins) - \(viewModel.losses) - \(viewModel.draws)")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .padding(.horizontal, 40)
            
            Spacer()
            
            // Home Button
            Button(action: {
                Task {
                    await viewModel.createProfile()
                }
            }) {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("home")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(Color.white, lineWidth: 2)
            )
            .padding(.horizontal, 40)
            .padding(.bottom, 60)
            .disabled(viewModel.isLoading)
        }
    }
}

#Preview {
    ProfileCreationView()
}
