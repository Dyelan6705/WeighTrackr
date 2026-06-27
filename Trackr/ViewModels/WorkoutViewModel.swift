//
//  WorkoutViewModel.swift
//  Trackr
//
//  Created by Dylan Choukalos on 5/30/26.
//

import Foundation
import SwiftData
import SwiftUI

struct ProgressionSuggestion {
    let lastWeight: Double
    let lastReps: Int
    let lastSets: Int
    let allCompleted: Bool

    var suggestedWeight: Double {
        allCompleted ? lastWeight + 2.5 : lastWeight
    }
}

@Observable
final class WorkoutViewModel {
    var workout: WorkoutSession
    var elapsedTime: TimeInterval = 0
    var showingAddExercise = false
    var selectedExercise: Exercise?
    var progressionSuggestions: [String: ProgressionSuggestion] = [:]

    private var timer: Timer?

    init(workout: WorkoutSession) {
        self.workout = workout
        startTimer()
    }

    func loadProgressionSuggestions(context: ModelContext) {
        let workoutID = workout.id
        let descriptor = FetchDescriptor<WorkoutSession>(
            predicate: #Predicate { $0.endDate != nil },
            sortBy: [SortDescriptor(\.startDate, order: .reverse)]
        )
        let previous = (try? context.fetch(descriptor)) ?? []
        let exerciseNames = Set(workout.exercises.map(\.name))
        var suggestions: [String: ProgressionSuggestion] = [:]

        for session in previous {
            guard session.id != workoutID else { continue }
            for exercise in session.exercises where exerciseNames.contains(exercise.name) {
                guard suggestions[exercise.name] == nil else { continue }
                let completed = exercise.sets.filter(\.isCompleted)
                guard !completed.isEmpty else { continue }
                let best = completed.max(by: { $0.weight < $1.weight }) ?? completed[0]
                suggestions[exercise.name] = ProgressionSuggestion(
                    lastWeight: best.weight,
                    lastReps: best.reps,
                    lastSets: exercise.sets.count,
                    allCompleted: completed.count == exercise.sets.count
                )
            }
            if suggestions.count == exerciseNames.count { break }
        }
        progressionSuggestions = suggestions
    }

    deinit {
        timer?.invalidate()
    }

    // MARK: - Elapsed Timer
    private func startTimer() {
        elapsedTime = Date().timeIntervalSince(workout.startDate)
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            elapsedTime = Date().timeIntervalSince(workout.startDate)
        }
    }

    var elapsedFormatted: String {
        let h = Int(elapsedTime) / 3600
        let m = Int(elapsedTime) % 3600 / 60
        let s = Int(elapsedTime) % 60
        if h > 0 { return String(format: "%d:%02d:%02d", h, m, s) }
        return String(format: "%02d:%02d", m, s)
    }

    // MARK: - Exercise Management
    func addExercise(name: String, context: ModelContext) {
        let exercise = Exercise(name: name, orderIndex: workout.exercises.count)
        context.insert(exercise)
        exercise.session = workout
        workout.exercises.append(exercise)
        addSet(to: exercise, context: context)
        selectedExercise = exercise
        haptic(.medium)
    }

    func removeExercise(_ exercise: Exercise, context: ModelContext) {
        workout.exercises.removeAll { $0.id == exercise.id }
        context.delete(exercise)
        haptic(.medium)
    }

    var sortedExercises: [Exercise] {
        workout.exercises.sorted { $0.orderIndex < $1.orderIndex }
    }

    // MARK: - Set Management
    func addSet(to exercise: Exercise, context: ModelContext) {
        let last = exercise.sortedSets.last
        let newSet = WorkoutSet(
            reps: last?.reps ?? 10,
            weight: last?.weight ?? 0,
            orderIndex: exercise.sets.count
        )
        context.insert(newSet)
        newSet.exercise = exercise
        exercise.sets.append(newSet)
        haptic(.light)
    }

    func removeSet(_ set: WorkoutSet, from exercise: Exercise) {
        exercise.sets.removeAll { $0.id == set.id }
        for (i, s) in exercise.sortedSets.enumerated() { s.orderIndex = i }
        haptic(.medium)
    }

    func completeSet(_ set: WorkoutSet) {
        set.isCompleted.toggle()
        set.completedAt = set.isCompleted ? Date() : nil
        if set.isCompleted {
            haptic(.success as UINotificationFeedbackGenerator.FeedbackType)
        } else {
            haptic(.light as UIImpactFeedbackGenerator.FeedbackStyle)
        }
    }

    // MARK: - Workout Lifecycle
    func finishWorkout(context: ModelContext) {
        workout.endDate = Date()
        timer?.invalidate()

        for exercise in workout.exercises {
            for set in exercise.sets where !set.isCompleted {
                exercise.sets.removeAll { $0.id == set.id }
                context.delete(set)
            }
        }
        for exercise in workout.exercises where exercise.sets.isEmpty {
            workout.exercises.removeAll { $0.id == exercise.id }
            context.delete(exercise)
        }
        try? context.save()
        haptic(.success)
    }

    func discardWorkout(context: ModelContext) {
        timer?.invalidate()
        context.delete(workout)
        try? context.save()
    }

    var completedSetsCount: Int { workout.exercises.reduce(0) { $0 + $1.sets.filter(\.isCompleted).count } }
    var totalSetsCount:     Int { workout.exercises.reduce(0) { $0 + $1.sets.count } }

    // MARK: - Haptics
    func haptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        guard UserPreferences.shared.hapticEnabled else { return }
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
    func haptic(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        guard UserPreferences.shared.hapticEnabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(type)
    }
}
