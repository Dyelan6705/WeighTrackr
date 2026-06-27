//
//  EditWorkoutView.swift
//  Trackr
//
//  Created by Dylan Choukalos on 5/29/26.
//

import SwiftUI
import SwiftData

struct EditWorkoutView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Bindable var workout: WorkoutSession

    @State private var showingExercisePicker = false
    @State private var showingDeleteAlert = false

    private static let editWindowDays = 7

    var body: some View {
        NavigationStack {
            ZStack {
                TrackrDesign.Colors.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        // Workout name
                        TextField("Workout name", text: $workout.name)
                            .font(TrackrDesign.Font.display(20))
                            .foregroundStyle(TrackrDesign.Colors.textPrimary)
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: TrackrDesign.Radius.md)
                                    .fill(TrackrDesign.Colors.surface)
                                    .overlay(RoundedRectangle(cornerRadius: TrackrDesign.Radius.md).stroke(TrackrDesign.Colors.border))
                            )

                        ForEach(workout.exercises.sorted(by: { $0.orderIndex < $1.orderIndex })) { exercise in
                            EditExerciseCard(exercise: exercise) {
                                let newSet = WorkoutSet(
                                    reps: exercise.sortedSets.last?.reps ?? 10,
                                    weight: exercise.sortedSets.last?.weight ?? 0,
                                    orderIndex: exercise.sets.count
                                )
                                newSet.isCompleted = true
                                context.insert(newSet)
                                newSet.exercise = exercise
                                exercise.sets.append(newSet)
                            } onDelete: {
                                workout.exercises.removeAll { $0.id == exercise.id }
                                context.delete(exercise)
                            }
                        }

                        // Add exercise button
                        Button { showingExercisePicker = true } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundStyle(TrackrDesign.Colors.accent)
                                Text("Add Exercise")
                                    .foregroundStyle(TrackrDesign.Colors.textPrimary)
                            }
                            .font(TrackrDesign.Font.body(15, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                RoundedRectangle(cornerRadius: TrackrDesign.Radius.lg)
                                    .fill(TrackrDesign.Colors.surface)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: TrackrDesign.Radius.lg)
                                            .strokeBorder(TrackrDesign.Colors.accent.opacity(0.3),
                                                          style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
                                    )
                            )
                        }
                        .buttonStyle(.plain)

                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, TrackrDesign.Spacing.md)
                    .padding(.top, TrackrDesign.Spacing.md)
                }
            }
            .navigationTitle("Edit Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(TrackrDesign.Colors.textSecondary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        try? context.save()
                        dismiss()
                    }
                    .font(TrackrDesign.Font.body(16, weight: .semibold))
                    .foregroundStyle(TrackrDesign.Colors.accent)
                }
            }
            .toolbarBackground(TrackrDesign.Colors.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .sheet(isPresented: $showingExercisePicker) {
                ExercisePickerView { name in
                    let exercise = Exercise(name: name, orderIndex: workout.exercises.count)
                    context.insert(exercise)
                    exercise.session = workout
                    workout.exercises.append(exercise)
                    let set = WorkoutSet(reps: 10, weight: 0, orderIndex: 0)
                    set.isCompleted = true
                    context.insert(set)
                    set.exercise = exercise
                    exercise.sets.append(set)
                }
            }
        }
        .presentationBackground(TrackrDesign.Colors.background)
    }

    static func canEdit(_ workout: WorkoutSession) -> Bool {
        guard let end = workout.endDate else { return false }
        let cutoff = Calendar.current.date(byAdding: .day, value: -editWindowDays, to: Date()) ?? Date()
        return end >= cutoff
    }
}

// MARK: - Edit Exercise Card
struct EditExerciseCard: View {
    @Bindable var exercise: Exercise
    let onAddSet: () -> Void
    let onDelete: () -> Void

    @State private var prefs = UserPreferences.shared

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(exercise.name)
                        .font(TrackrDesign.Font.body(16, weight: .semibold))
                        .foregroundStyle(TrackrDesign.Colors.textPrimary)
                    Text("\(exercise.sets.count) sets")
                        .font(TrackrDesign.Font.body(12))
                        .foregroundStyle(TrackrDesign.Colors.textSecondary)
                }
                Spacer()
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 14))
                        .foregroundStyle(TrackrDesign.Colors.textTertiary)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)

            // Column headers
            HStack(spacing: 0) {
                Text("SET").frame(width: 40, alignment: .leading)
                Text(prefs.weightUnit.uppercased()).frame(maxWidth: .infinity, alignment: .center)
                Text("REPS").frame(width: 70, alignment: .center)
                Text("").frame(width: 44)
            }
            .font(TrackrDesign.Font.body(10, weight: .semibold))
            .foregroundStyle(TrackrDesign.Colors.textTertiary)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(TrackrDesign.Colors.surfaceElevated)

            ForEach(exercise.sortedSets) { set in
                let idx = exercise.sortedSets.firstIndex(where: { $0.id == set.id }) ?? 0
                SetRow(set: set, index: idx, prefs: prefs, onComplete: {}) { exercise.sets.removeAll { $0.id == set.id } }
                    .padding(.horizontal, 14)
                if set.id != exercise.sortedSets.last?.id {
                    Divider().background(TrackrDesign.Colors.border).padding(.horizontal, 14)
                }
            }

            // Add set
            Button(action: onAddSet) {
                HStack(spacing: 6) {
                    Image(systemName: "plus").font(.system(size: 12, weight: .bold))
                    Text("Add Set").font(TrackrDesign.Font.body(13, weight: .semibold))
                }
                .foregroundStyle(TrackrDesign.Colors.accent)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
            }
            .buttonStyle(.plain)
        }
        .background(
            RoundedRectangle(cornerRadius: TrackrDesign.Radius.lg)
                .fill(TrackrDesign.Colors.surface)
                .overlay(RoundedRectangle(cornerRadius: TrackrDesign.Radius.lg).stroke(TrackrDesign.Colors.border))
        )
    }
}
