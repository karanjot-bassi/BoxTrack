//
//  WorkoutBookListView.swift
//  boxtrack
//
//  Created by Karan Bassi on 2025-12-04.
//

import SwiftUI

struct WorkoutBookListView: View {
    @StateObject private var viewModel = WorkoutBookViewModel()
    @State private var showCreateBook = false
    @State private var selectedBook: WorkoutBook?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                if viewModel.isLoading && viewModel.workoutBooks.isEmpty {
                    ProgressView()
                        .tint(.white)
                } else if viewModel.workoutBooks.isEmpty {
                    // Empty State
                    VStack(spacing: 20) {
                        Image(systemName: "book.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No Workout Books Yet")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text("Create your first template to\nquickly start workouts")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                        
                        Button(action: {
                            showCreateBook = true
                        }) {
                            Text("Create Workout Book")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                                .frame(width: 220, height: 50)
                                .background(Color.white)
                                .cornerRadius(25)
                        }
                        .padding(.top, 20)
                    }
                } else {
                    // Workout Books List
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(viewModel.workoutBooks) { book in
                                WorkoutBookCard(book: book)
                                    .onTapGesture {
                                        selectedBook = book
                                    }
                                    .contextMenu {
                                        Button(action: {
                                            selectedBook = book
                                        }) {
                                            Label("View Details", systemImage: "eye")
                                        }
                                        
                                        Button(role: .destructive, action: {
                                            Task {
                                                if let bookId = book.id {
                                                    _ = await viewModel.deleteWorkoutBook(bookId: bookId)
                                                }
                                            }
                                        }) {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                            }
                            
                            Spacer()
                                .frame(height: 100) // Space for tab bar
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    }
                    .refreshable {
                        await viewModel.loadWorkoutBooks()
                    }
                }
            }
            .navigationTitle("Workout Books")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showCreateBook = true
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                    }
                }
            }
            .sheet(isPresented: $showCreateBook) {
                CreateWorkoutBookView { book in
                    Task {
                        let success = await viewModel.createWorkoutBook(book)
                        if success {
                            showCreateBook = false
                        }
                    }
                }
            }
            .sheet(item: $selectedBook) { book in
                WorkoutBookDetailView(book: book) { updatedBook in
                    Task {
                        _ = await viewModel.updateWorkoutBook(updatedBook)
                    }
                } onDelete: {
                    Task {
                        if let bookId = book.id {
                            let success = await viewModel.deleteWorkoutBook(bookId: bookId)
                            if success {
                                selectedBook = nil
                            }
                        }
                    }
                }
            }
            .onAppear {
                Task {
                    await viewModel.loadWorkoutBooks()
                }
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
}

// MARK: - Workout Book Card
struct WorkoutBookCard: View {
    let book: WorkoutBook
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            Image(systemName: "book.fill")
                .font(.system(size: 30))
                .foregroundColor(.white)
                .frame(width: 50)
            
            // Info
            VStack(alignment: .leading, spacing: 6) {
                Text(book.name)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                
                HStack(spacing: 12) {
                    Text("\(book.exercises.count) exercises")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    if let duration = book.estimatedDuration {
                        Text("•")
                            .foregroundColor(.gray)
                        Text("~\(duration) min")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                }
            }
            
            Spacer()
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
        .padding(20)
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

#Preview {
    WorkoutBookListView()
}
