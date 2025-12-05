//
//  QuickActionMenuView.swift
//  boxtrack
//
//  Created by Karan Bassi on 2025-12-02.
//

import SwiftUI

struct QuickActionMenuView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var showStartWorkout: Bool
    @Binding var showUpdateWeight: Bool
    @Binding var showLogPrevious: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Handle bar for dragging
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.gray.opacity(0.5))
                .frame(width: 40, height: 5)
                .padding(.top, 12)
                .padding(.bottom, 20)
            
            // Menu Options
            VStack(spacing: 0) {
                QuickActionButton(
                    icon: "figure.boxing",
                    title: "Start Workout",
                    action: {
                        dismiss()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            showStartWorkout = true
                        }
                    }
                )
                
                Divider()
                    .background(Color.white.opacity(0.1))
                    .padding(.horizontal, 20)
                
                QuickActionButton(
                    icon: "scalemass",
                    title: "Update Weight",
                    action: {
                        dismiss()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            showUpdateWeight = true
                        }
                    }
                )
                
                Divider()
                    .background(Color.white.opacity(0.1))
                    .padding(.horizontal, 20)
                
                QuickActionButton(
                    icon: "calendar.badge.plus",
                    title: "Log Previous Workout",
                    action: {
                        dismiss()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            showLogPrevious = true
                        }
                    }
                )
            }
            .padding(.bottom, 40)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color.black)
        .presentationDetents([.height(280)])
        .presentationDragIndicator(.hidden)
    }
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .frame(width: 32)
                
                Text(title)
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
        }
    }
}

#Preview {
    QuickActionMenuView(
        showStartWorkout: .constant(false),
        showUpdateWeight: .constant(false),
        showLogPrevious: .constant(false)
    )
}
