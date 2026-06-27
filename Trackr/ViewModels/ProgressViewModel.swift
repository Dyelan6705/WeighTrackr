//
//  ProgressViewModel.swift
//  Trackr
//
//  Created by Dylan Choukalos on 5/30/26.
//

import Foundation
import SwiftData

@Observable
final class ProgressViewModel {
    var exerciseHistory: [String: [ExerciseDataPoint]] = [:]
    var personalRecords: [PersonalRecord] = []
    var allExerciseNames: [String] = []
    var selectedExercise: String = ""
    var selectedRange: TimeRange = .month
    
    func load(context: ModelContext) {
        let descriptor = FetchDescriptor<WorkoutSession>(
            predicate: #Predicate { $0.endDate != nil },
            sortBy: [SortDescriptor(\.startDate)]
        )
        
        let sessions = (try? context.fetch(descriptor)) ?? []
        buildExerciseHistory(from: sessions)
        buildPersonalRecords(from: sessions)
    }
    
    private func buildExerciseHistory(from sessions: [WorkoutSession]) {
        var history: [String: [ExerciseDataPoint]] = [:]
        
        for session in sessions {
            for exercise in session.exercises {
                let name = exercise.name
                let bestSet = exercise.sets.max(by: { $0.weight < $1.weight })
                
                if let best = bestSet, best.weight > 0 {
                    let point = ExerciseDataPoint(
                        date: session.startDate,
                        weight: best.weight,
                        reps: best.reps,
                        volume: exercise.totalVolume
                    )
                    if history[name] == nil {
                        history[name] = []
                    }
                    history[name]?.append(point)
                }
            }
        }
        
        exerciseHistory = history
        allExerciseNames = Array(history.keys).sorted()
        if selectedExercise.isEmpty, let first = allExerciseNames.first {
            selectedExercise = first
        }
    }
    
    private func buildPersonalRecords(from sessions: [WorkoutSession]) {
        var records: [String: PersonalRecord] = [:]
        
        for session in sessions {
            for exercise in session.exercises {
                for set in exercise.sets where set.isCompleted {
                    let key = exercise.name
                    if let existing = records[key] {
                        if set.weight > existing.weight ||
                           (set.weight == existing.weight && set.reps > existing.reps) {
                            records[key] = PersonalRecord(
                                exerciseName: key,
                                weight: set.weight,
                                reps: set.reps,
                                date: session.startDate
                            )
                        }
                    } else {
                        records[key] = PersonalRecord(
                            exerciseName: key,
                            weight: set.weight,
                            reps: set.reps,
                            date: session.startDate
                        )
                    }
                }
            }
        }
        
        personalRecords = Array(records.values).sorted { $0.exerciseName < $1.exerciseName }
    }
    
    var filteredDataPoints: [ExerciseDataPoint] {
        guard !selectedExercise.isEmpty else { return [] }
        let points = exerciseHistory[selectedExercise] ?? []
        let cutoff = Calendar.current.date(byAdding: selectedRange.component, value: -selectedRange.value, to: Date()) ?? Date()
        return points.filter { $0.date >= cutoff }
    }
    
    var maxWeight: Double {
        filteredDataPoints.map(\.weight).max() ?? 0
    }
    
    var totalWorkoutsCount: Int {
        // Computed from history data
        return exerciseHistory.values.flatMap { $0 }.map(\.date).count
    }
}

struct ExerciseDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let weight: Double
    let reps: Int
    let volume: Double
}

struct PersonalRecord: Identifiable {
    let id = UUID()
    let exerciseName: String
    let weight: Double
    let reps: Int
    let date: Date

    var formattedWeight: String {
        weight.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", weight)
            : String(format: "%.1f", weight)
    }

    // Epley formula — reliable up to ~10 reps
    var estimatedOneRepMax: Double {
        guard reps > 0 else { return weight }
        if reps == 1 { return weight }
        return weight * (1 + Double(reps) / 30.0)
    }

    var formatted1RM: String {
        let v = estimatedOneRepMax
        return v.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", v)
            : String(format: "%.1f", v)
    }
}

enum TimeRange: String, CaseIterable {
    case week = "1W"
    case month = "1M"
    case threeMonths = "3M"
    case sixMonths = "6M"
    case year = "1Y"
    
    var component: Calendar.Component {
        switch self {
        case .week, .month, .threeMonths, .sixMonths, .year: return .month
        }
    }
    
    var value: Int {
        switch self {
        case .week: return 0 // use days
        case .month: return 1
        case .threeMonths: return 3
        case .sixMonths: return 6
        case .year: return 12
        }
    }
    
    var dayValue: Int {
        switch self {
        case .week: return 7
        default: return 0
        }
    }
}
