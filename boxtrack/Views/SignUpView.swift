//
//  SignUpView.swift
//  boxtrack
//
//  Created by Karan Bassi on 2025-11-16.
//

import SwiftUI

struct SignUpView: View {
    @StateObject private var viewModel = AuthViewModel()
    @State private var email = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    
    var body: some View {
        ZStack {
            //black background
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 3) {
                Spacer()
                
                // Title
                Text("Getting Started")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
                
                // Form Fields
                VStack(spacing: 10) {
                    //email
                    CustomTextField(
                        placeholder: "email",
                        text: $email
                    )
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    
                    //password
                    CustomSecureField(
                        placeholder: "password",
                        text: $password
                    )
                    //confrim password
                    CustomSecureField(
                        placeholder: "confirm password",
                        text: $confirmPassword
                    )
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                // create account button
                Button(action: {
                    Task {
                        await viewModel.signUp(
                            email: email,
                            password: password,
                            confirmPassword: confirmPassword
                        )
                    }
                }) {
                    Text("create account")
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
                
                // Login Link
                NavigationLink(destination: SignInView()) {
                    Text("Login")
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


// Custom text field to match design
struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        VStack(spacing: 0) {
            TextField("", text: $text)
                .foregroundColor(.white)
                .font(.system(size: 16))
                .placeholder(when: text.isEmpty) {
                    Text(placeholder)
                        .foregroundColor(.gray)
                        .font(.system(size: 16))
                }
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.white)
        }
    }
}


// Custom secure field
struct CustomSecureField: View {
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        VStack(spacing: 0) {
            SecureField("", text: $text)
                .foregroundColor(.white)
                .font(.system(size: 16))
                .placeholder(when: text.isEmpty) {
                    Text(placeholder)
                        .foregroundColor(.gray)
                        .font(.system(size: 16))
                }
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.white)
        }
    }
}

// Custom back button
struct BackButton: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Button(action: {
            dismiss()
        }) {
            Image(systemName: "chevron.left")
                .foregroundColor(.white)
                .imageScale(.large)
        }
    }
}

// Helper for placeholder
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
        
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

#Preview {
    NavigationStack {
        SignUpView()
    }
}
