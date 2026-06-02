//
//  ContentView.swift
//  Trackr
//
//  Created by Dylan Choukalos on 5/29/26.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .home
    @State private var activeWorkout: WorkoutSession?
    @State private var showingWorkout = false

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                HomeView(activeWorkout: $activeWorkout, showingWorkout: $showingWorkout)
                    .tag(Tab.home)

                TemplatesView(activeWorkout: $activeWorkout, showingWorkout: $showingWorkout)
                    .tag(Tab.templates)

                TrackrProgressView()
                    .tag(Tab.progress)

                SettingsView()
                    .tag(Tab.settings)
            }
            .toolbar(.hidden, for: .tabBar)
            .toolbarBackground(.hidden, for: .tabBar)
            .onAppear {
                UITabBar.appearance().isHidden = true  // ← nuclear option
            }

            TrackrTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(.keyboard)
        .sheet(isPresented: $showingWorkout) {
            if let workout = activeWorkout {
                WorkoutLoggingView(workout: workout) {
                    activeWorkout = nil
                    showingWorkout = false
                }
            }
        }
    }
}

enum Tab: String, CaseIterable {
    case home      = "house.fill"
    case templates = "list.bullet.rectangle.fill"
    case progress  = "chart.line.uptrend.xyaxis"
    case settings  = "gearshape.fill"

    var label: String {
        switch self {
        case .home:      return "Home"
        case .templates: return "Templates"
        case .progress:  return "Progress"
        case .settings:  return "Settings"
        }
    }
}
