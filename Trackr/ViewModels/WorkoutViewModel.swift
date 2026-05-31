//
//  WorkoutViewModel.swift
//  Trackr
//
//  Created by Dylan Choukalos on 5/30/26.
//

import Foundation
import SwiftData
import SwiftUI
import Combine

@MainActor
@Observable
final class WorkoutViewModel {
    var workout: WorkoutSession
    var elapsedTime: TimeInterval = 0
    var restTimeRemaining: Int = 0
    var isRestTimerActive = false
    var restTimerTotal: Int = 90
    var showingAddExercise = false
    var showingFinishConfirm = false
    var selectedExercise: Exercise?
    
    @ObservationIgnored nonisolated(unsafe) private var timer: Timer?
    @ObservationIgnored nonisolated(unsafe) private var restTimer: Timer?

    init(workout: WorkoutSession) {
        self.workout = workout
        startTimer()
    }

    deinit {
        timer?.invalidate()
        restTimer?.invalidate()
    }

    // MARK: - Timer
    private func startTimer() {
        elapsedTime = Date().timeIntervalSince(workout.startDate)
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else { return }
                elapsedTime = Date().timeIntervalSince(workout.startDate)
            }
        }
    }
    
    var elapsedFormatted: String {
        let h = Int(elapsedTime) / 3600
        let m = Int(elapsedTime) % 3600 / 60
        let s = Int(elapsedTime) % 60
        if h > 0 { return String(format: "%d:%02d:%02d", h, m, s) }
        return String(format: "%02d:%02d", m, s)
    }
    
    // MARK: - Rest Timer
    func startRestTimer(seconds: Int = 90) {
        restTimer?.invalidate()
        restTimerTotal = seconds
        restTimeRemaining = seconds
        isRestTimerActive = true
        
        restTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else { return }
                if restTimeRemaining > 0 {
                    restTimeRemaining -= 1
                } else {
                    stopRestTimer()
                    triggerHaptic(.success)
                }
            }
        }
    }
    
    func stopRestTimer() {
        restTimer?.invalidate()
        isRestTimerActive = false
        restTimeRemaining = 0
    }
    
    var restProgress: Double {
        guard restTimerTotal > 0 else { return 0 }
        return Double(restTimeRemaining) / Double(restTimerTotal)
    }
    
    var restFormatted: String {
        String(format: "%d:%02d", restTimeRemaining / 60, restTimeRemaining % 60)
    }
    
    // MARK: - Exercise Management
    func addExercise(name: String, context: ModelContext) {
        let count = workout.exercises.count
        let exercise = Exercise(name: name, orderIndex: count)
        context.insert(exercise)
        exercise.session = workout
        workout.exercises.append(exercise)
        
        // Auto-add first set
        addSet(to: exercise, context: context)
        selectedExercise = exercise
        triggerHaptic(.medium)
    }
    
    func removeExercise(_ exercise: Exercise, context: ModelContext) {
        workout.exercises.removeAll { $0.id == exercise.id }
        context.delete(exercise)
        triggerHaptic(.medium)
    }
    
    func moveExercise(from source: IndexSet, to destination: Int) {
        var sorted = sortedExercises
        sorted.move(fromOffsets: source, toOffset: destination)
        for (index, exercise) in sorted.enumerated() {
            exercise.orderIndex = index
        }
        triggerHaptic(.light)
    }
    
    var sortedExercises: [Exercise] {
        workout.exercises.sorted { $0.orderIndex < $1.orderIndex }
    }
    
    // MARK: - Set Management
    func addSet(to exercise: Exercise, context: ModelContext) {
        let lastSet = exercise.sortedSets.last
        let newSet = WorkoutSet(
            reps: lastSet?.reps ?? 10,
            weight: lastSet?.weight ?? 0,
            orderIndex: exercise.sets.count
        )
        context.insert(newSet)
        newSet.exercise = exercise
        exercise.sets.append(newSet)
        triggerHaptic(.light)
    }
    
    func removeSet(_ set: WorkoutSet, from exercise: Exercise, context: ModelContext) {
        exercise.sets.removeAll { $0.id == set.id }
        context.delete(set)
        for (index, s) in exercise.sortedSets.enumerated() {
            s.orderIndex = index
        }
        triggerHaptic(.medium)
    }
    
    /// Context-free overload used by ExerciseCard (SwiftData auto-tracks orphan deletion)
    func removeSet(_ set: WorkoutSet, from exercise: Exercise) {
        exercise.sets.removeAll { $0.id == set.id }
        for (index, s) in exercise.sortedSets.enumerated() {
            s.orderIndex = index
        }
        triggerHaptic(.medium)
    }
    
    func completeSet(_ set: WorkoutSet) {
        set.isCompleted.toggle()
        if set.isCompleted {
            set.completedAt = Date()
            startRestTimer()
            triggerHaptic(.success)
        } else {
            set.completedAt = nil
        }
    }
    
    // MARK: - Workout Management
    func finishWorkout(context: ModelContext) {
        workout.endDate = Date()
        timer?.invalidate()
        restTimer?.invalidate()
        
        // Clean up incomplete sets
        for exercise in workout.exercises {
            for set in exercise.sets where !set.isCompleted {
                exercise.sets.removeAll { $0.id == set.id }
                context.delete(set)
            }
        }
        
        // Remove empty exercises
        for exercise in workout.exercises where exercise.sets.isEmpty {
            workout.exercises.removeAll { $0.id == exercise.id }
            context.delete(exercise)
        }
        
        try? context.save()
        triggerHaptic(.success)
    }
    
    func discardWorkout(context: ModelContext) {
        timer?.invalidate()
        restTimer?.invalidate()
        context.delete(workout)
        try? context.save()
    }
    
    var completedSetsCount: Int {
        workout.exercises.reduce(0) { $0 + $1.sets.filter(\.isCompleted).count }
    }
    
    var totalSetsCount: Int {
        workout.exercises.reduce(0) { $0 + $1.sets.count }
    }
    
    // MARK: - Haptics
    func triggerHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    func triggerHaptic(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
}
