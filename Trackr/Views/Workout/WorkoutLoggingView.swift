//
//  WorkoutLoggingView.swift
//  Trackr
//
//  Created by Dylan Choukalos on 5/30/26.
//

import SwiftUI
import SwiftData

struct WorkoutLoggingView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    let workout: WorkoutSession
    let onFinish: () -> Void
    
    @State private var viewModel: WorkoutViewModel
    @State private var showingExercisePicker = false
    @State private var showingDiscardAlert = false
    
    init(workout: WorkoutSession, onFinish: @escaping () -> Void) {
        self.workout = workout
        self.onFinish = onFinish
        _viewModel = State(initialValue: WorkoutViewModel(workout: workout))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                TrackrDesign.Colors.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header Bar
                    workoutHeader
                    
                    // Rest Timer (conditional)
                    if viewModel.isRestTimerActive {
                        RestTimerBanner(
                            timeRemaining: viewModel.restFormatted,
                            progress: viewModel.restProgress,
                            onSkip: { viewModel.stopRestTimer() }
                        )
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    // Exercise List
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.sortedExercises) { exercise in
                                ExerciseCard(
                                    exercise: exercise,
                                    viewModel: viewModel,
                                    onAddSet: {
                                        viewModel.addSet(to: exercise, context: context)
                                    },
                                    onDelete: {
                                        viewModel.removeExercise(exercise, context: context)
                                    }
                                )
                            }
                            
                            // Add Exercise Button
                            Button {
                                showingExercisePicker = true
                            } label: {
                                HStack(spacing: 10) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundStyle(TrackrDesign.Colors.accent)
                                    Text("Add Exercise")
                                        .font(TrackrDesign.Font.body(16, weight: .semibold))
                                        .foregroundStyle(TrackrDesign.Colors.textPrimary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(
                                    RoundedRectangle(cornerRadius: TrackrDesign.Radius.lg)
                                        .fill(TrackrDesign.Colors.surface)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: TrackrDesign.Radius.lg)
                                                .strokeBorder(
                                                    TrackrDesign.Colors.accent.opacity(0.3),
                                                    style: StrokeStyle(lineWidth: 1.5, dash: [6, 4])
                                                )
                                        )
                                )
                            }
                            .buttonStyle(.plain)
                            
                            Spacer(minLength: 40)
                        }
                        .padding(.horizontal, TrackrDesign.Spacing.md)
                        .padding(.top, 12)
                    }
                    
                    // Bottom Finish Bar
                    finishBar
                }
            }
            .navigationBarHidden(true)
            .animation(TrackrDesign.Animation.snappy, value: viewModel.isRestTimerActive)
            .sheet(isPresented: $showingExercisePicker) {
                ExercisePickerView { name in
                    viewModel.addExercise(name: name, context: context)
                }
            }
            .alert("Discard Workout?", isPresented: $showingDiscardAlert) {
                Button("Discard", role: .destructive) {
                    viewModel.discardWorkout(context: context)
                    onFinish()
                }
                Button("Keep Going", role: .cancel) {}
            } message: {
                Text("Your workout progress will be lost.")
            }
        }
    }
    
    // MARK: - Header
    private var workoutHeader: some View {
        HStack(spacing: 12) {
            Button {
                showingDiscardAlert = true
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(TrackrDesign.Colors.textSecondary)
                    .frame(width: 36, height: 36)
                    .background(
                        Circle().fill(TrackrDesign.Colors.surfaceElevated)
                    )
            }
            
            VStack(spacing: 2) {
                Text(workout.name)
                    .font(TrackrDesign.Font.display(17))
                    .foregroundStyle(TrackrDesign.Colors.textPrimary)
                    .lineLimit(1)
                
                // Live timer
                Text(viewModel.elapsedFormatted)
                    .font(TrackrDesign.Font.mono(13, weight: .medium))
                    .foregroundStyle(TrackrDesign.Colors.accent)
            }
            .frame(maxWidth: .infinity)
            
            // Progress indicator
            ZStack {
                Circle()
                    .stroke(TrackrDesign.Colors.surfaceElevated, lineWidth: 3)
                    .frame(width: 36, height: 36)
                
                Circle()
                    .trim(from: 0, to: viewModel.totalSetsCount > 0
                          ? Double(viewModel.completedSetsCount) / Double(viewModel.totalSetsCount)
                          : 0)
                    .stroke(TrackrDesign.Colors.green, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: 36, height: 36)
                    .rotationEffect(.degrees(-90))
                    .animation(TrackrDesign.Animation.smooth, value: viewModel.completedSetsCount)
                
                Text("\(viewModel.completedSetsCount)")
                    .font(TrackrDesign.Font.mono(11, weight: .bold))
                    .foregroundStyle(TrackrDesign.Colors.green)
            }
        }
        .padding(.horizontal, TrackrDesign.Spacing.md)
        .padding(.vertical, 14)
        .background(TrackrDesign.Colors.surface)
        .overlay(
            Rectangle()
                .fill(TrackrDesign.Colors.border)
                .frame(height: 1),
            alignment: .bottom
        )
    }
    
    // MARK: - Finish Bar
    private var finishBar: some View {
        VStack(spacing: 0) {
            Divider()
                .background(TrackrDesign.Colors.border)
            
            Button {
                viewModel.finishWorkout(context: context)
                onFinish()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20, weight: .semibold))
                    Text("Finish Workout")
                        .font(TrackrDesign.Font.display(17))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 17)
                .background(
                    RoundedRectangle(cornerRadius: TrackrDesign.Radius.lg)
                        .fill(TrackrDesign.Colors.green)
                )
            }
            .buttonStyle(.plain)
            .padding(.horizontal, TrackrDesign.Spacing.md)
            .padding(.top, 12)
            .padding(.bottom, 28)
        }
        .background(TrackrDesign.Colors.surface.ignoresSafeArea())
    }
}

// MARK: - Rest Timer Banner
struct RestTimerBanner: View {
    let timeRemaining: String
    let progress: Double
    let onSkip: () -> Void
    
    var body: some View {
        HStack(spacing: 14) {
            // Progress ring
            ZStack {
                Circle()
                    .stroke(TrackrDesign.Colors.surfaceHigh, lineWidth: 3)
                    .frame(width: 38, height: 38)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(TrackrDesign.Colors.blue, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: 38, height: 38)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: progress)
            }
            
            VStack(alignment: .leading, spacing: 1) {
                Text("Rest")
                    .font(TrackrDesign.Font.body(11, weight: .medium))
                    .foregroundStyle(TrackrDesign.Colors.textTertiary)
                Text(timeRemaining)
                    .font(TrackrDesign.Font.mono(20, weight: .bold))
                    .foregroundStyle(TrackrDesign.Colors.textPrimary)
            }
            
            Spacer()
            
            Button("Skip", action: onSkip)
                .font(TrackrDesign.Font.body(14, weight: .semibold))
                .foregroundStyle(TrackrDesign.Colors.textSecondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule().fill(TrackrDesign.Colors.surfaceHigh)
                )
        }
        .padding(.horizontal, TrackrDesign.Spacing.md)
        .padding(.vertical, 12)
        .background(TrackrDesign.Colors.surfaceElevated)
        .overlay(
            Rectangle().fill(TrackrDesign.Colors.border).frame(height: 1),
            alignment: .bottom
        )
    }
}
