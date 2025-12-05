//
//  boxtrackApp.swift
//  boxtrack
//
//  Created by Karan Bassi on 2025-10-08.
//

import SwiftUI
import FirebaseCore

@main
struct boxtrackApp: App {
    
    //Initialize Firebase when app starts
    init() {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
