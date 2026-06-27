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

    let workout: WorkoutSession
    let onFinish: () -> Void

    @State private var viewModel: WorkoutViewModel
    @State private var showingExercisePicker = false
    @State private var showingDiscardAlert   = false
    @State private var showingReorder        = false
    @State private var showingPro            = false

    init(workout: WorkoutSession, onFinish: @escaping () -> Void) {
        self.workout  = workout
        self.onFinish = onFinish
        _viewModel    = State(initialValue: WorkoutViewModel(workout: workout))
    }

    private var isPro: Bool { StoreKitManager.shared.isPro }

    var body: some View {
        ZStack {
            TrackrDesign.Colors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                workoutHeader

                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.sortedExercises) { exercise in
                            ExerciseCard(
                                exercise: exercise,
                                viewModel: viewModel,
                                onAddSet: { viewModel.addSet(to: exercise, context: context) },
                                onDelete: { viewModel.removeExercise(exercise, context: context) },
                                suggestion: viewModel.progressionSuggestions[exercise.name]
                            )
                        }

                        addExerciseButton
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, TrackrDesign.Spacing.md)
                    .padding(.top, 12)
                }

                finishBar
            }
        }
        .sheet(isPresented: $showingExercisePicker) {
            ExercisePickerView { name in
                viewModel.addExercise(name: name, context: context)
            }
        }
        .sheet(isPresented: $showingReorder) {
            ReorderExercisesSheet(exercises: viewModel.sortedExercises) { reordered in
                for (index, ex) in reordered.enumerated() {
                    ex.orderIndex = index
                }
            }
        }
        .sheet(isPresented: $showingPro) { TrackrProView().environment(StoreKitManager.shared) }
        .onAppear { viewModel.loadProgressionSuggestions(context: context) }
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

    // MARK: - Header
    private var workoutHeader: some View {
        HStack(spacing: 0) {
            Button {
                showingDiscardAlert = true
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(TrackrDesign.Colors.textSecondary)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(TrackrDesign.Colors.surfaceElevated))
            }

            Spacer()

            VStack(spacing: 3) {
                Text(workout.name)
                    .font(TrackrDesign.Font.display(16))
                    .foregroundStyle(TrackrDesign.Colors.textPrimary)
                    .lineLimit(1)
                Text(viewModel.elapsedFormatted)
                    .font(TrackrDesign.Font.mono(12, weight: .medium))
                    .foregroundStyle(TrackrDesign.Colors.accent)
            }

            Spacer()

            HStack(spacing: 10) {
                // Reorder button
                if viewModel.sortedExercises.count > 1 {
                    Button {
                        showingReorder = true
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(TrackrDesign.Colors.textSecondary)
                            .frame(width: 36, height: 36)
                            .background(Circle().fill(TrackrDesign.Colors.surfaceElevated))
                    }
                }

                progressRing.frame(width: 36, height: 36)
            }
        }
        .padding(.horizontal, TrackrDesign.Spacing.md)
        .padding(.top, 8)
        .padding(.bottom, 12)
        .background(
            TrackrDesign.Colors.surface
                .shadow(color: .black.opacity(0.18), radius: 8, y: 4)
        )
        .overlay(
            Rectangle().fill(TrackrDesign.Colors.border).frame(height: 1),
            alignment: .bottom
        )
    }

    private var progressRing: some View {
        let progress: Double = viewModel.totalSetsCount > 0
            ? Double(viewModel.completedSetsCount) / Double(viewModel.totalSetsCount)
            : 0
        return ZStack {
            Circle().stroke(TrackrDesign.Colors.surfaceHigh, lineWidth: 3)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(TrackrDesign.Colors.green, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(TrackrDesign.Animation.smooth, value: progress)
            Text("\(viewModel.completedSetsCount)")
                .font(TrackrDesign.Font.mono(10, weight: .bold))
                .foregroundStyle(TrackrDesign.Colors.green)
        }
    }

    // MARK: - Add Exercise
    private var addExerciseButton: some View {
        Button {
            showingExercisePicker = true
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(TrackrDesign.Colors.accent)
                Text("Add Exercise")
                    .font(TrackrDesign.Font.body(15, weight: .semibold))
                    .foregroundStyle(TrackrDesign.Colors.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: TrackrDesign.Radius.lg)
                    .fill(TrackrDesign.Colors.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: TrackrDesign.Radius.lg)
                            .strokeBorder(TrackrDesign.Colors.accent.opacity(0.35),
                                          style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Finish Bar
    private var finishBar: some View {
        VStack(spacing: 0) {
            Rectangle().fill(TrackrDesign.Colors.border).frame(height: 1)

            Button {
                viewModel.finishWorkout(context: context)
                onFinish()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18, weight: .semibold))
                    Text("Finish Workout")
                        .font(TrackrDesign.Font.display(16))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(RoundedRectangle(cornerRadius: TrackrDesign.Radius.lg).fill(TrackrDesign.Colors.green))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, TrackrDesign.Spacing.md)
            .padding(.top, 12)
            .padding(.bottom, 28)
        }
        .background(TrackrDesign.Colors.surface.ignoresSafeArea(edges: .bottom))
    }
}

// MARK: - Reorder Sheet
struct ReorderExercisesSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var items: [Exercise]
    let onSave: ([Exercise]) -> Void

    init(exercises: [Exercise], onSave: @escaping ([Exercise]) -> Void) {
        _items = State(initialValue: exercises)
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            ZStack {
                TrackrDesign.Colors.background.ignoresSafeArea()

                List {
                    ForEach(items) { exercise in
                        HStack(spacing: 12) {
                            Image(systemName: "line.3.horizontal")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(TrackrDesign.Colors.textTertiary)
                            Text(exercise.name)
                                .font(TrackrDesign.Font.body(15, weight: .medium))
                                .foregroundStyle(TrackrDesign.Colors.textPrimary)
                        }
                        .listRowBackground(TrackrDesign.Colors.surface)
                        .listRowSeparatorTint(TrackrDesign.Colors.border)
                    }
                    .onMove { from, to in
                        items.move(fromOffsets: from, toOffset: to)
                    }
                }
                .scrollContentBackground(.hidden)
                .environment(\.editMode, .constant(.active))
            }
            .navigationTitle("Reorder Exercises")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onSave(items)
                        dismiss()
                    }
                    .font(TrackrDesign.Font.body(16, weight: .semibold))
                    .foregroundStyle(TrackrDesign.Colors.accent)
                }
            }
            .toolbarBackground(TrackrDesign.Colors.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .presentationBackground(TrackrDesign.Colors.background)
        .presentationDetents([.medium, .large])
    }
}
