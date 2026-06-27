//
//  HomeView.swift
//  Trackr
//
//  Created by Dylan Choukalos on 5/30/26.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var context
    @Binding var activeWorkout: WorkoutSession?
    @Binding var showingWorkout: Bool
    
    @State private var viewModel = HomeViewModel()
    @State private var showingQuickStart = false
    @Query(sort: \WorkoutTemplate.createdAt, order: .reverse)
    private var templates: [WorkoutTemplate]
    
    var body: some View {
        NavigationStack {
            ZStack {
                TrackrDesign.Colors.background.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Header
                        headerSection
                            .padding(.horizontal, TrackrDesign.Spacing.md)
                            .padding(.top, TrackrDesign.Spacing.lg)
                        
                        // Weekly Summary
                        weeklySummarySection
                            .padding(.top, TrackrDesign.Spacing.lg)
                        
                        // Quick Start
                        startWorkoutSection
                            .padding(.top, TrackrDesign.Spacing.lg)
                            .padding(.horizontal, TrackrDesign.Spacing.md)
                        
                        // Recent workouts
                        recentWorkoutsSection
                            .padding(.top, TrackrDesign.Spacing.lg)
                        
                        Spacer(minLength: 100)
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear { viewModel.load(context: context) }
        }
    }
    
    // MARK: - Header
    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(greetingText)
                    .font(TrackrDesign.Font.body(15, weight: .medium))
                    .foregroundStyle(TrackrDesign.Colors.textSecondary)
                
                Text("Trackr")
                    .font(TrackrDesign.Font.display(34))
                    .foregroundStyle(TrackrDesign.Colors.textPrimary)
            }
            
            Spacer()
            
            // Streak badge
            VStack(spacing: 2) {
                Text("🔥")
                    .font(.system(size: 22))
                Text("\(viewModel.streak)")
                    .font(TrackrDesign.Font.display(20))
                    .foregroundStyle(TrackrDesign.Colors.orange)
                Text("streak")
                    .font(TrackrDesign.Font.body(10, weight: .medium))
                    .foregroundStyle(TrackrDesign.Colors.textTertiary)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 14)
            .background(
                RoundedRectangle(cornerRadius: TrackrDesign.Radius.md)
                    .fill(TrackrDesign.Colors.surfaceElevated)
                    .overlay(
                        RoundedRectangle(cornerRadius: TrackrDesign.Radius.md)
                            .stroke(TrackrDesign.Colors.border)
                    )
            )
        }
    }
    
    // MARK: - Weekly Summary
    private var weeklySummarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("This Week")
                    .font(TrackrDesign.Font.display(17))
                    .foregroundStyle(TrackrDesign.Colors.textPrimary)
                Spacer()
                let count = viewModel.weeklyWorkouts.filter(\.hasWorkout).count
                Text("\(count)/7 days")
                    .font(TrackrDesign.Font.body(13, weight: .medium))
                    .foregroundStyle(TrackrDesign.Colors.textSecondary)
            }
            .padding(.horizontal, TrackrDesign.Spacing.md)
            
            WeeklyBarChart(data: viewModel.weeklyWorkouts)
        }
    }
    
    // MARK: - Start Workout
    private var startWorkoutSection: some View {
        VStack(spacing: 12) {
            // Primary CTA
            Button {
                startBlankWorkout()
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 22, weight: .semibold))
                    Text("Start Workout")
                        .font(TrackrDesign.Font.display(18))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(TrackrDesign.Colors.accentLight.opacity(0.6))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 18)
                .background(
                    RoundedRectangle(cornerRadius: TrackrDesign.Radius.lg)
                        .fill(
                            LinearGradient(
                                colors: [TrackrDesign.Colors.accent, Color(hex: "4A3FC7")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: TrackrDesign.Colors.accentGlow, radius: 20, y: 8)
                )
            }
            .buttonStyle(.plain)
            
            // Quick templates row
            if !templates.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(templates.prefix(4)) { template in
                            QuickTemplateChip(template: template) {
                                startFromTemplate(template)
                            }
                        }
                    }
                    .padding(.horizontal, TrackrDesign.Spacing.md)
                }
                .padding(.horizontal, -TrackrDesign.Spacing.md)
            }
        }
    }
    
    // MARK: - Recent Workouts
    private var recentWorkoutsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent")
                    .font(TrackrDesign.Font.display(17))
                    .foregroundStyle(TrackrDesign.Colors.textPrimary)
                Spacer()
            }
            .padding(.horizontal, TrackrDesign.Spacing.md)
            
            if viewModel.recentWorkouts.isEmpty {
                EmptyStateCard(
                    icon: "dumbbell",
                    message: "No workouts yet.\nTap Start Workout to begin."
                )
                .padding(.horizontal, TrackrDesign.Spacing.md)
            } else {
                VStack(spacing: 8) {
                    ForEach(viewModel.recentWorkouts) { workout in
                        RecentWorkoutRow(workout: workout)
                            .padding(.horizontal, TrackrDesign.Spacing.md)
                    }
                }
            }
        }
    }

    // MARK: - Actions
    private func startBlankWorkout() {
        let session = viewModel.startNewWorkout(context: context)
        activeWorkout = session
        showingWorkout = true
    }

    private func startFromTemplate(_ template: WorkoutTemplate) {
        let session = viewModel.startWorkoutFromTemplate(template, context: context)
        activeWorkout = session
        showingWorkout = true
    }

    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning 👋"
        case 12..<17: return "Good afternoon 👋"
        case 17..<21: return "Good evening 👋"
        default: return "Hey night owl 🦉"
        }
    }
}


// MARK: - Quick Template Chip
struct QuickTemplateChip: View {
    let template: WorkoutTemplate
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(TrackrDesign.Colors.accent)
                Text(template.name)
                    .font(TrackrDesign.Font.body(13, weight: .semibold))
                    .foregroundStyle(TrackrDesign.Colors.textPrimary)
                    .lineLimit(1)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: TrackrDesign.Radius.pill)
                    .fill(TrackrDesign.Colors.surfaceElevated)
                    .overlay(
                        RoundedRectangle(cornerRadius: TrackrDesign.Radius.pill)
                            .stroke(TrackrDesign.Colors.border)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Recent Workout Row
struct RecentWorkoutRow: View {
    let workout: WorkoutSession
    @State private var showingEdit = false

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(TrackrDesign.Colors.accentGlow)
                    .frame(width: 44, height: 44)
                Image(systemName: "dumbbell.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(TrackrDesign.Colors.accentLight)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(workout.name)
                    .font(TrackrDesign.Font.body(15, weight: .semibold))
                    .foregroundStyle(TrackrDesign.Colors.textPrimary)

                HStack(spacing: 10) {
                    Label(workout.durationFormatted, systemImage: "clock")
                    Label("\(workout.exercises.count) exercises", systemImage: "list.bullet")
                    Label("\(workout.totalSets) sets", systemImage: "square.stack")
                }
                .font(TrackrDesign.Font.body(12))
                .foregroundStyle(TrackrDesign.Colors.textSecondary)
                .labelStyle(.titleAndIcon)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 6) {
                Text(relativeDate(workout.startDate))
                    .font(TrackrDesign.Font.body(12))
                    .foregroundStyle(TrackrDesign.Colors.textTertiary)

                if EditWorkoutView.canEdit(workout) {
                    Button { showingEdit = true } label: {
                        Image(systemName: "pencil")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(TrackrDesign.Colors.accent)
                            .padding(6)
                            .background(Circle().fill(TrackrDesign.Colors.accentGlow))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: TrackrDesign.Radius.md)
                .fill(TrackrDesign.Colors.surface)
                .overlay(RoundedRectangle(cornerRadius: TrackrDesign.Radius.md).stroke(TrackrDesign.Colors.border))
        )
        .sheet(isPresented: $showingEdit) {
            EditWorkoutView(workout: workout)
        }
    }

    private func relativeDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) { return "Today" }
        if calendar.isDateInYesterday(date) { return "Yesterday" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}

// MARK: - Weekly Bar Chart
struct WeeklyBarChart: View {
    let data: [DayWorkoutData]
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            ForEach(data) { day in
                VStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(day.hasWorkout
                              ? LinearGradient(colors: [TrackrDesign.Colors.accentLight, TrackrDesign.Colors.accent], startPoint: .top, endPoint: .bottom)
                              : LinearGradient(colors: [TrackrDesign.Colors.surfaceElevated, TrackrDesign.Colors.surfaceElevated], startPoint: .top, endPoint: .bottom))
                        .frame(width: 28, height: day.hasWorkout ? 40 : 14)
                        .animation(TrackrDesign.Animation.spring, value: day.hasWorkout)
                    
                    Text(String(day.day.prefix(1)))
                        .font(TrackrDesign.Font.body(11, weight: .medium))
                        .foregroundStyle(day.hasWorkout
                                         ? TrackrDesign.Colors.accentLight
                                         : TrackrDesign.Colors.textTertiary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, TrackrDesign.Spacing.md)
        .padding(.vertical, TrackrDesign.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: TrackrDesign.Radius.lg)
                .fill(TrackrDesign.Colors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: TrackrDesign.Radius.lg)
                        .stroke(TrackrDesign.Colors.border)
                )
        )
        .padding(.horizontal, TrackrDesign.Spacing.md)
    }
}

// MARK: - Empty State
struct EmptyStateCard: View {
    let icon: String
    let message: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 36, weight: .light))
                .foregroundStyle(TrackrDesign.Colors.textTertiary)
            
            Text(message)
                .font(TrackrDesign.Font.body(14))
                .foregroundStyle(TrackrDesign.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, TrackrDesign.Spacing.xl)
        .background(
            RoundedRectangle(cornerRadius: TrackrDesign.Radius.lg)
                .fill(TrackrDesign.Colors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: TrackrDesign.Radius.lg)
                        .stroke(TrackrDesign.Colors.border)
                )
        )
    }
}
