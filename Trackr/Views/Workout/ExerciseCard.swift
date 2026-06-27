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
    var suggestion: ProgressionSuggestion? = nil

    @State private var prefs = UserPreferences.shared
    @State private var isExpanded = true

    var body: some View {
        VStack(spacing: 0) {
            exerciseHeader

            if isExpanded {
                VStack(spacing: 0) {
                    if let s = suggestion {
                        suggestionBanner(s)
                    }
                    columnHeaders

                    ForEach(exercise.sortedSets) { set in
                        let idx = exercise.sortedSets.firstIndex(where: { $0.id == set.id }) ?? 0
                        SetRow(
                            set: set,
                            index: idx,
                            prefs: prefs,
                            onComplete: { viewModel.completeSet(set) },
                            onDelete:   { viewModel.removeSet(set, from: exercise) }
                        )
                        .padding(.horizontal, 14)

                        if set.id != exercise.sortedSets.last?.id {
                            Divider()
                                .background(TrackrDesign.Colors.border)
                                .padding(.horizontal, 14)
                        }
                    }

                    addSetButton
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
                withAnimation(TrackrDesign.Animation.snappy) { isExpanded.toggle() }
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

                let done = exercise.sets.filter(\.isCompleted).count
                Text("\(done)/\(exercise.sets.count) sets")
                    .font(TrackrDesign.Font.body(12))
                    .foregroundStyle(TrackrDesign.Colors.textSecondary)
            }

            Spacer()

            if exercise.totalVolume > 0 {
                let vol = prefs.useMetric
                    ? exercise.totalVolume
                    : exercise.totalVolume * 2.20462
                Text("\(Int(vol)) \(prefs.weightUnit)")
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

    // MARK: - Suggestion Banner
    private func suggestionBanner(_ s: ProgressionSuggestion) -> some View {
        let lastW  = prefs.useMetric ? s.lastWeight  : s.lastWeight  * 2.20462
        let sugW   = prefs.useMetric ? s.suggestedWeight : s.suggestedWeight * 2.20462
        let unit   = prefs.weightUnit
        let lastFmt = lastW.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", lastW) : String(format: "%.1f", lastW)
        let sugFmt  = sugW.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", sugW)  : String(format: "%.1f", sugW)

        return HStack(spacing: 8) {
            Image(systemName: s.allCompleted ? "arrow.up.circle.fill" : "equal.circle.fill")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(s.allCompleted ? TrackrDesign.Colors.green : TrackrDesign.Colors.textTertiary)
            Text("Last: \(s.lastSets)×\(s.lastReps) @ \(lastFmt)\(unit)")
                .foregroundStyle(TrackrDesign.Colors.textSecondary)
            if s.allCompleted {
                Text("→ Try \(sugFmt)\(unit)")
                    .foregroundStyle(TrackrDesign.Colors.green)
                    .fontWeight(.semibold)
            }
            Spacer()
        }
        .font(TrackrDesign.Font.body(12))
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(s.allCompleted
                    ? TrackrDesign.Colors.greenDim
                    : TrackrDesign.Colors.surfaceElevated)
    }

    // MARK: - Column Headers
    private var columnHeaders: some View {
        HStack(spacing: 0) {
            Text("SET")
                .frame(width: 40, alignment: .leading)
            Text("PREV")
                .frame(maxWidth: .infinity, alignment: .center)
            Text(prefs.weightUnit.uppercased())
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

    private var addSetButton: some View {
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
}

// MARK: - Set Row
struct SetRow: View {
    @Bindable var set: WorkoutSet
    let index: Int
    let prefs: UserPreferences
    let onComplete: () -> Void
    let onDelete: (() -> Void)?

    @State private var weightText: String
    @State private var repsText:   String

    init(
        set: WorkoutSet,
        index: Int,
        prefs: UserPreferences,
        onComplete: @escaping () -> Void,
        onDelete: (() -> Void)? = nil
    ) {
        self.set        = set
        self.index      = index
        self.prefs      = prefs
        self.onComplete = onComplete
        self.onDelete   = onDelete

        let display = prefs.displayWeight(set.weight)
        _weightText = State(initialValue: set.weight > 0 ? Self.fmt(display) : "")
        _repsText   = State(initialValue: set.reps   > 0 ? "\(set.reps)"     : "")
    }

    var body: some View {
        HStack(spacing: 0) {
            Text("\(index + 1)")
                .font(TrackrDesign.Font.mono(14, weight: .semibold))
                .foregroundStyle(set.isCompleted ? TrackrDesign.Colors.green : TrackrDesign.Colors.textTertiary)
                .frame(width: 40, alignment: .leading)

            Text("—")
                .font(TrackrDesign.Font.body(13))
                .foregroundStyle(TrackrDesign.Colors.textTertiary)
                .frame(maxWidth: .infinity, alignment: .center)

            numericField(text: $weightText, placeholder: "0") {
                if let v = Double(weightText) { set.weight = prefs.storageWeight(v) }
            }
            .frame(width: 80)

            numericField(text: $repsText, placeholder: "0") {
                if let v = Int(repsText) { set.reps = v }
            }
            .frame(width: 70)

            Button {
                if let v = Double(weightText) { set.weight = prefs.storageWeight(v) }
                if let v = Int(repsText)      { set.reps   = v }
                onComplete()
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(set.isCompleted ? TrackrDesign.Colors.green : TrackrDesign.Colors.surfaceHigh)
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
        .onChange(of: prefs.useMetric) { _, _ in
            let display = prefs.displayWeight(set.weight)
            weightText = set.weight > 0 ? Self.fmt(display) : ""
        }
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
            .background(RoundedRectangle(cornerRadius: 8).fill(TrackrDesign.Colors.surfaceElevated))
            .padding(.horizontal, 4)
            .onChange(of: text.wrappedValue) { _, _ in onChange() }
    }

    static func fmt(_ v: Double) -> String {
        v.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", v)
            : String(format: "%.1f", v)
    }
}
