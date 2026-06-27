//
//  WorkoutModels.swift
//  Trackr
//
//  Created by Dylan Choukalos on 5/30/26.
//

import Foundation
import SwiftData

// MARK: - WorkoutSession
@Model
final class WorkoutSession {
    var id: UUID
    var name: String
    var startDate: Date
    var endDate: Date?
    var notes: String
    var templateID: UUID?
    
    @Relationship(deleteRule: .cascade, inverse: \Exercise.session)
    var exercises: [Exercise]
    
    init(name: String = "Workout", templateID: UUID? = nil) {
        self.id = UUID()
        self.name = name
        self.startDate = Date()
        self.endDate = nil
        self.notes = ""
        self.templateID = templateID
        self.exercises = []
    }
    
    var duration: TimeInterval {
        guard let end = endDate else { return Date().timeIntervalSince(startDate) }
        return end.timeIntervalSince(startDate)
    }
    
    var durationFormatted: String {
        let d = duration
        let h = Int(d) / 3600
        let m = Int(d) % 3600 / 60
        let s = Int(d) % 60
        if h > 0 {
            return String(format: "%d:%02d:%02d", h, m, s)
        }
        return String(format: "%d:%02d", m, s)
    }
    
    var totalSets: Int {
        exercises.reduce(0) { $0 + $1.sets.count }
    }
    
    var totalVolume: Double {
        exercises.reduce(0) { session, exercise in
            session + exercise.sets.reduce(0) { $0 + ($1.weight * Double($1.reps)) }
        }
    }
    
    var isCompleted: Bool { endDate != nil }
}

// MARK: - Exercise
@Model
final class Exercise {
    var id: UUID
    var name: String
    var category: String
    var muscleGroup: String
    var orderIndex: Int
    var notes: String
    
    var session: WorkoutSession?
    
    @Relationship(deleteRule: .cascade, inverse: \WorkoutSet.exercise)
    var sets: [WorkoutSet]
    
    init(name: String, category: String = "Strength", muscleGroup: String = "", orderIndex: Int = 0) {
        self.id = UUID()
        self.name = name
        self.category = category
        self.muscleGroup = muscleGroup
        self.orderIndex = orderIndex
        self.notes = ""
        self.sets = []
    }
    
    var sortedSets: [WorkoutSet] {
        sets.sorted { $0.orderIndex < $1.orderIndex }
    }
    
    var bestSet: WorkoutSet? {
        sets.max { $0.weight < $1.weight }
    }
    
    var totalVolume: Double {
        sets.reduce(0) { $0 + ($1.weight * Double($1.reps)) }
    }
}

// MARK: - WorkoutSet
@Model
final class WorkoutSet {
    var id: UUID
    var reps: Int
    var weight: Double
    var isCompleted: Bool
    var orderIndex: Int
    var setType: SetType
    var rpe: Double?
    var completedAt: Date?
    
    var exercise: Exercise?
    
    init(reps: Int = 10, weight: Double = 0, orderIndex: Int = 0, setType: SetType = .normal) {
        self.id = UUID()
        self.reps = reps
        self.weight = weight
        self.isCompleted = false
        self.orderIndex = orderIndex
        self.setType = setType
        self.rpe = nil
        self.completedAt = nil
    }
    
    var volume: Double { weight * Double(reps) }
}

enum SetType: String, Codable, CaseIterable {
    case warmup = "W"
    case normal = "N"
    case dropSet = "D"
    case failureSet = "F"
    
    var label: String { rawValue }
    
    var color: String {
        switch self {
        case .warmup: return "orange"
        case .normal: return "accent"
        case .dropSet: return "blue"
        case .failureSet: return "red"
        }
    }
}

// MARK: - WorkoutTemplate
@Model
final class WorkoutTemplate {
    var id: UUID
    var name: String
    var createdAt: Date
    var lastUsed: Date?
    var usageCount: Int
    var notes: String
    
    @Relationship(deleteRule: .cascade, inverse: \TemplateExercise.template)
    var exercises: [TemplateExercise]
    
    init(name: String) {
        self.id = UUID()
        self.name = name
        self.createdAt = Date()
        self.lastUsed = nil
        self.usageCount = 0
        self.notes = ""
        self.exercises = []
    }
    
    var sortedExercises: [TemplateExercise] {
        exercises.sorted { $0.orderIndex < $1.orderIndex }
    }
}

// MARK: - TemplateExercise
@Model
final class TemplateExercise {
    var id: UUID
    var name: String
    var targetSets: Int
    var targetReps: Int
    var targetRepsMax: Int  // > 0 means rep range is active (Pro)
    var targetWeight: Double
    var orderIndex: Int
    var muscleGroup: String
    var restSeconds: Int

    var template: WorkoutTemplate?

    var useRepRange: Bool { targetRepsMax > 0 }

    var repsDisplay: String {
        useRepRange ? "\(targetReps)–\(targetRepsMax)" : "\(targetReps)"
    }

    init(name: String, targetSets: Int = 3, targetReps: Int = 10, targetRepsMax: Int = 0, targetWeight: Double = 0, orderIndex: Int = 0, muscleGroup: String = "") {
        self.id = UUID()
        self.name = name
        self.targetSets = targetSets
        self.targetReps = targetReps
        self.targetRepsMax = targetRepsMax
        self.targetWeight = targetWeight
        self.orderIndex = orderIndex
        self.muscleGroup = muscleGroup
        self.restSeconds = 90
    }
}

// MARK: - CustomExercise
@Model
final class CustomExercise {
    var id: UUID
    var name: String
    var category: String
    var muscleGroup: String
    var createdAt: Date

    init(name: String, category: String = "Custom", muscleGroup: String = "") {
        self.id = UUID()
        self.name = name
        self.category = category
        self.muscleGroup = muscleGroup
        self.createdAt = Date()
    }
}
