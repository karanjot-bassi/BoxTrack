//
//  WelcomeView.swift
//  boxtrack
//
//  Created by Karan Bassi on 2025-11-16.
//

import SwiftUI

struct WelcomeView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                //Black Background
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    // Logo
                    Image("logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 180, height: 180)
                        .padding(.bottom, 30)
                    
                    // Tagline
                    Text("The best app for boxers to tracking, build, \nand optimize their performance.")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    Spacer()
                    
                    NavigationLink(destination: SignUpView()) {
                        Text("Get Started")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 28)
                                    .stroke(Color.white, lineWidth: 2)
                            )
                            .padding(.horizontal, 40)
                    }
                    .padding(.bottom, 20)
                    
                    // Login Button
                    NavigationLink(destination: SignInView()) {
                        Text("Login")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.bottom, 60)
                }
            }
        }
    }
}

#Preview {
    WelcomeView()
}

