//
//  ExerciseCard.swift
//  Trackr
//
//  Created by Dylan Choukalos on 5/30/26.
//

import SwiftUI
import SwiftData

struct ExerciseCard: View {
    @Bindable var exercise: Exercise
    let viewModel: WorkoutViewModel
    let onAddSet: () -> Void
    let onDelete: () -> Void
    
    @State private var isExpanded = true
    
    var body: some View {
        VStack(spacing: 0) {
            exerciseHeader
            
            if isExpanded {
                VStack(spacing: 0) {
                    columnHeaders
                    
                    ForEach(exercise.sortedSets) { set in
                        let idx = exercise.sortedSets.firstIndex(where: { $0.id == set.id }) ?? 0
                        SetRow(
                            set: set,
                            index: idx,
                            onComplete: { viewModel.completeSet(set) },
                            onDelete: { viewModel.removeSet(set, from: exercise) }
                        )
                        .padding(.horizontal, 14)
                        
                        if set.id != exercise.sortedSets.last?.id {
                            Divider()
                                .background(TrackrDesign.Colors.border)
                                .padding(.horizontal, 14)
                        }
                    }
                    
                    // Add Set button
                    Button(action: onAddSet) {
                        HStack(spacing: 6) {
                            Image(systemName: "plus")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(TrackrDesign.Colors.accent)
                            Text("Add Set")
                                .font(TrackrDesign.Font.body(13, weight: .semibold))
                                .foregroundStyle(TrackrDesign.Colors.accent)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                    }
                    .buttonStyle(.plain)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: TrackrDesign.Radius.lg)
                .fill(TrackrDesign.Colors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: TrackrDesign.Radius.lg)
                        .stroke(TrackrDesign.Colors.border)
                )
        )
        .animation(TrackrDesign.Animation.snappy, value: isExpanded)
    }
    
    // MARK: - Header
    private var exerciseHeader: some View {
        HStack(spacing: 12) {
            Button {
                withAnimation(TrackrDesign.Animation.snappy) {
                    isExpanded.toggle()
                }
            } label: {
                Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(TrackrDesign.Colors.textTertiary)
                    .frame(width: 20)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(exercise.name)
                    .font(TrackrDesign.Font.body(16, weight: .semibold))
                    .foregroundStyle(TrackrDesign.Colors.textPrimary)
                
                let completedCount = exercise.sets.filter(\.isCompleted).count
                Text("\(completedCount)/\(exercise.sets.count) sets")
                    .font(TrackrDesign.Font.body(12))
                    .foregroundStyle(TrackrDesign.Colors.textSecondary)
            }
            
            Spacer()
            
            if exercise.totalVolume > 0 {
                Text("\(Int(exercise.totalVolume)) vol")
                    .font(TrackrDesign.Font.mono(11, weight: .medium))
                    .foregroundStyle(TrackrDesign.Colors.textTertiary)
                    .padding(.trailing, 4)
            }
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.system(size: 14))
                    .foregroundStyle(TrackrDesign.Colors.textTertiary)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
    }
    
    // MARK: - Column Headers
    private var columnHeaders: some View {
        HStack(spacing: 0) {
            Text("SET")
                .frame(width: 40, alignment: .leading)
            Text("PREV")
                .frame(maxWidth: .infinity, alignment: .center)
            Text("KG")
                .frame(width: 80, alignment: .center)
            Text("REPS")
                .frame(width: 70, alignment: .center)
            Text("")
                .frame(width: 44)
        }
        .font(TrackrDesign.Font.body(10, weight: .semibold))
        .foregroundStyle(TrackrDesign.Colors.textTertiary)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(TrackrDesign.Colors.surfaceElevated)
    }
}

// MARK: - Set Row
struct SetRow: View {
    @Bindable var set: WorkoutSet
    let index: Int
    let onComplete: () -> Void
    let onDelete: (() -> Void)?
    
    @State private var weightText: String
    @State private var repsText: String
    
    init(
        set: WorkoutSet,
        index: Int,
        onComplete: @escaping () -> Void,
        onDelete: (() -> Void)? = nil
    ) {
        self.set = set
        self.index = index
        self.onComplete = onComplete
        self.onDelete = onDelete
        _weightText = State(initialValue: set.weight > 0 ? Self.formatValue(set.weight) : "")
        _repsText   = State(initialValue: set.reps   > 0 ? "\(set.reps)" : "")
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // Set number
            Text("\(index + 1)")
                .font(TrackrDesign.Font.mono(14, weight: .semibold))
                .foregroundStyle(set.isCompleted
                                 ? TrackrDesign.Colors.green
                                 : TrackrDesign.Colors.textTertiary)
                .frame(width: 40, alignment: .leading)
            
            // Previous (placeholder for future history)
            Text("—")
                .font(TrackrDesign.Font.body(13))
                .foregroundStyle(TrackrDesign.Colors.textTertiary)
                .frame(maxWidth: .infinity, alignment: .center)
            
            // Weight field
            numericField(text: $weightText, placeholder: "0") {
                if let val = Double(weightText) { set.weight = val }
            }
            .frame(width: 80)
            
            // Reps field
            numericField(text: $repsText, placeholder: "0") {
                if let val = Int(repsText) { set.reps = val }
            }
            .frame(width: 70)
            
            // Complete button
            Button {
                if let w = Double(weightText) { set.weight = w }
                if let r = Int(repsText)      { set.reps   = r }
                onComplete()
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(set.isCompleted
                              ? TrackrDesign.Colors.green
                              : TrackrDesign.Colors.surfaceHigh)
                        .frame(width: 36, height: 36)
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(set.isCompleted ? .white : TrackrDesign.Colors.textTertiary)
                }
            }
            .frame(width: 44)
            .animation(TrackrDesign.Animation.snappy, value: set.isCompleted)
        }
        .padding(.vertical, 10)
        .background(set.isCompleted ? TrackrDesign.Colors.greenDim.opacity(0.5) : .clear)
        .animation(TrackrDesign.Animation.smooth, value: set.isCompleted)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            if let onDelete {
                Button(role: .destructive, action: onDelete) {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
    }
    
    @ViewBuilder
    private func numericField(
        text: Binding<String>,
        placeholder: String,
        onChange: @escaping () -> Void
    ) -> some View {
        TextField(placeholder, text: text)
            .font(TrackrDesign.Font.mono(16, weight: .semibold))
            .foregroundStyle(TrackrDesign.Colors.textPrimary)
            .multilineTextAlignment(.center)
            .keyboardType(.decimalPad)
            .padding(.horizontal, 4)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(TrackrDesign.Colors.surfaceElevated)
            )
            .padding(.horizontal, 4)
            .onChange(of: text.wrappedValue) { _, _ in onChange() }
    }
    
    static func formatValue(_ v: Double) -> String {
        v.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", v)
            : String(format: "%.1f", v)
    }
}
