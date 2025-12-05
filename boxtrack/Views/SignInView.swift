//
//  SignInView.swift
//  boxtrack
//
//  Created by Karan Bassi on 2025-11-16.
//
import SwiftUI

struct SignInView: View {
    @StateObject private var viewModel = AuthViewModel()
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        ZStack {
            // Black baground
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // title
                Text("Login")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                // Form fields
                VStack(spacing: 20) {
                    // Email
                    CustomTextField(
                        placeholder: "email",
                        text: $email
                    )
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    
                    // password
                    CustomSecureField(
                        placeholder: "password",
                        text: $password
                    )
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                // Sign in Button
                Button(action: {
                    Task {
                        await viewModel.signIn(email: email, password: password)
                    }
                }) {
                    Text("login")
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
                .disabled(viewModel.isLoading)
                
                // back to sign up
                Button(action: {
                    // nav handles this automatically
                }){
                    Text("create account")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                }
                .padding(.bottom, 60)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: BackButton())
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
    }
}

#Preview {
    NavigationStack {
        SignInView()
    }
}
