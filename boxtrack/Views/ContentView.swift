//
//  ContentView.swift
//  boxtrack
//
//  Created by Karan Bassi on 2025-10-08.
//

import SwiftUI
import FirebaseAuth
import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @State private var isAuthenticated = false
    @State private var hasProfile = false
    @State private var isLoading = true
    
    var body: some View {
        Group {
            if isLoading {
                // Loading screen
                ZStack {
                    Color.black.ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        Image("logo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 120, height: 120)
                        
                        ProgressView()
                            .tint(.white)
                    }
                }
            } else if !isAuthenticated {
                // Not signed in - show welcome
                WelcomeView()
            } else if !hasProfile {
                // Signed in but no profile - show profile creation
                ProfileCreationView()
            } else {
                // Signed in with profile - show main app
                MainTabView()
            }
        } 
        .onAppear {
            checkAuthStatus()		
        }
    }
    
    private func checkAuthStatus() {
        // Listen for auth state changes
        Auth.auth().addStateDidChangeListener { _, user in
            isAuthenticated = user != nil
            
            if let userId = user?.uid {
                // Check if user has completed profile
                checkProfile(userId: userId)
            } else {
                isLoading = false
            }
        }
    }
    
    private func checkProfile(userId: String) {
        Task {
            do {
                _ = try await UserService.shared.getUser(userId: userId)
                hasProfile = true
            } catch {
                hasProfile = false
            }
            isLoading = false
        }
    }
}

// Temporary main app view (we'll build this properly later)
struct MainAppView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Welcome to BoxTrack!")
                    .font(.title)
                    .foregroundColor(.white)
                
                Text("You're signed in with a complete profile! ✅")
                    .foregroundColor(.green)
                    .multilineTextAlignment(.center)
                
                if let user = Auth.auth().currentUser {
                    Text("Email: \(user.email ?? "Unknown")")
                        .foregroundColor(.gray)
                        .font(.caption)
                }
                
                Button(action: {
                    try? Auth.auth().signOut()
                }) {
                    Text("Sign Out")
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.white, lineWidth: 2)
                        )
                }
                .padding(.top, 30)
                
                Text("(We'll build the real home screen next!)")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.top, 20)
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
