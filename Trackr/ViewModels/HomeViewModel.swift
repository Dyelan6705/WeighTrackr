//
//  HomeViewModel.swift
//  Trackr
//
//  Created by Dylan Choukalos on 5/30/26.
//

import Foundation
import SwiftData
import SwiftUI

@Observable
final class HomeViewModel {
    var recentWorkouts: [WorkoutSession] = []
    var streak: Int = 0
    var weeklyWorkouts: [DayWorkoutData] = []
    var isLoading = false
    
    func load(context: ModelContext) {
        isLoading = true
        defer { isLoading = false }
        
        let descriptor = FetchDescriptor<WorkoutSession>(
            predicate: #Predicate { $0.endDate != nil },
            sortBy: [SortDescriptor(\.startDate, order: .reverse)]
        )
        
        let all = (try? context.fetch(descriptor)) ?? []
        recentWorkouts = Array(all.prefix(5))
        
        streak = calculateStreak(from: all)
        weeklyWorkouts = buildWeeklyData(from: all)
    }
    
    private func calculateStreak(from sessions: [WorkoutSession]) -> Int {
        let calendar = Calendar.current
        var streak = 0
        var checkDate = calendar.startOfDay(for: Date())
        
        let workoutDays = Set(sessions.map { calendar.startOfDay(for: $0.startDate) })
        
        // Allow today or yesterday as start
        if !workoutDays.contains(checkDate) {
            checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate
        }
        
        while workoutDays.contains(checkDate) {
            streak += 1
            checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate
        }
        
        return streak
    }
    
    private func buildWeeklyData(from sessions: [WorkoutSession]) -> [DayWorkoutData] {
        let calendar = Calendar.current
        let today = Date()
        
        return (0..<7).map { offset in
            let date = calendar.date(byAdding: .day, value: -6 + offset, to: today)!
            let dayStart = calendar.startOfDay(for: date)
            let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart)!
            
            let count = sessions.filter {
                $0.startDate >= dayStart && $0.startDate < dayEnd
            }.count
            
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE"
            let label = formatter.string(from: date)
            
            return DayWorkoutData(day: label, count: count, date: date)
        }
    }
    
    func startNewWorkout(context: ModelContext) -> WorkoutSession {
        let session = WorkoutSession(name: workoutNameForTime())
        context.insert(session)
        return session
    }
    
    func startWorkoutFromTemplate(_ template: WorkoutTemplate, context: ModelContext) -> WorkoutSession {
        let session = WorkoutSession(name: template.name, templateID: template.id)
        context.insert(session)
        
        for (index, templateExercise) in template.sortedExercises.enumerated() {
            let exercise = Exercise(
                name: templateExercise.name,
                muscleGroup: templateExercise.muscleGroup,
                orderIndex: index
            )
            context.insert(exercise)
            exercise.session = session
            session.exercises.append(exercise)
            
            for setIndex in 0..<templateExercise.targetSets {
                let set = WorkoutSet(
                    reps: templateExercise.targetReps,
                    weight: templateExercise.targetWeight,
                    orderIndex: setIndex
                )
                context.insert(set)
                set.exercise = exercise
                exercise.sets.append(set)
            }
        }
        
        template.usageCount += 1
        template.lastUsed = Date()
        
        return session
    }
    
    private func workoutNameForTime() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Morning Workout"
        case 12..<17: return "Afternoon Workout"
        case 17..<21: return "Evening Workout"
        default: return "Night Workout"
        }
    }
}

struct DayWorkoutData: Identifiable {
    let id = UUID()
    let day: String
    let count: Int
    let date: Date
    
    var hasWorkout: Bool { count > 0 }
}
