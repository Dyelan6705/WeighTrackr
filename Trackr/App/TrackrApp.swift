//
//  TrackrApp.swift
//  Trackr
//
//  Created by Dylan Choukalos on 5/29/26.
//

import SwiftUI
import SwiftData

@main
struct TrackrApp: App {
    let container: ModelContainer
    
    init() {
        do {
            let schema = Schema([
                WorkoutSession.self,
                Exercise.self,
                WorkoutSet.self,
                WorkoutTemplate.self,
                TemplateExercise.self
            ])
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            container = try ModelContainer(for: schema, configurations: config)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(container)
                .preferredColorScheme(.dark)
        }
    }
}
