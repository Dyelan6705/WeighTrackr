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
        TrackrApp.configureNavigationBarAppearance()

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

    private static func configureNavigationBarAppearance() {
        let bg = UIColor(red: 0x11/255, green: 0x11/255, blue: 0x18/255, alpha: 1)

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = bg
        appearance.shadowColor = UIColor(white: 1, alpha: 0.06)

        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]

        UINavigationBar.appearance().standardAppearance   = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance    = appearance
        UINavigationBar.appearance().tintColor = UIColor(
            red: 0x6B/255, green: 0x5C/255, blue: 0xE7/255, alpha: 1
        )
    }
}
