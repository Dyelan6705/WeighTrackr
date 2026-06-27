//
//  CreateTemplateView.swift
//  Trackr
//
//  Created by Dylan Choukalos on 5/30/26.
//

import SwiftUI
import SwiftData

// MARK: - Create Template
struct CreateTemplateView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(StoreKitManager.self) private var store

    @State private var name = ""
    @State private var exercises: [TemplateExerciseDraft] = []
    @State private var showingExercisePicker = false
    @State private var showingPro = false
    @FocusState private var nameFocused: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                TrackrDesign.Colors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: TrackrDesign.Spacing.md) {
                        nameField

                        ForEach($exercises) { $exercise in
                            TemplateExerciseDraftRow(draft: $exercise, isPro: store.isPro) {
                                exercises.removeAll { $0.id == exercise.id }
                            }
                        }

                        addExerciseButton
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, TrackrDesign.Spacing.md)
                    .padding(.top, TrackrDesign.Spacing.md)
                }
            }
            .navigationTitle("New Template")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(TrackrDesign.Colors.textSecondary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { save() }
                        .font(TrackrDesign.Font.body(16, weight: .semibold))
                        .foregroundStyle(name.isEmpty ? TrackrDesign.Colors.textTertiary : TrackrDesign.Colors.accent)
                        .disabled(name.isEmpty)
                }
            }
            .onAppear { nameFocused = true }
            .sheet(isPresented: $showingExercisePicker) {
                ExercisePickerView { exerciseName in
                    exercises.append(TemplateExerciseDraft(name: exerciseName))
                }
            }
            .sheet(isPresented: $showingPro) { TrackrProView() }
        }
        .presentationBackground(TrackrDesign.Colors.background)
    }

    private var nameField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Template Name")
                .font(TrackrDesign.Font.body(13, weight: .semibold))
                .foregroundStyle(TrackrDesign.Colors.textSecondary)
                .padding(.horizontal, 4)

            TextField("e.g. Push Day, Leg Day...", text: $name)
                .font(TrackrDesign.Font.display(20))
                .foregroundStyle(TrackrDesign.Colors.textPrimary)
                .focused($nameFocused)
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: TrackrDesign.Radius.md)
                        .fill(TrackrDesign.Colors.surface)
                        .overlay(
                            RoundedRectangle(cornerRadius: TrackrDesign.Radius.md)
                                .stroke(nameFocused ? TrackrDesign.Colors.accent.opacity(0.6) : TrackrDesign.Colors.border)
                        )
                )
                .animation(TrackrDesign.Animation.smooth, value: nameFocused)
        }
    }

    private var addExerciseButton: some View {
        Button {
            showingExercisePicker = true
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "plus.circle.fill")
                    .foregroundStyle(TrackrDesign.Colors.accent)
                Text("Add Exercise")
                    .foregroundStyle(TrackrDesign.Colors.textPrimary)
            }
            .font(TrackrDesign.Font.body(16, weight: .semibold))
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
    }

    private func save() {
        let template = WorkoutTemplate(name: name)
        context.insert(template)

        for (index, draft) in exercises.enumerated() {
            let te = TemplateExercise(
                name: draft.name,
                targetSets: draft.sets,
                targetReps: draft.repsMin,
                targetRepsMax: draft.useRepRange ? draft.repsMax : 0,
                targetWeight: draft.weight,
                orderIndex: index
            )
            context.insert(te)
            te.template = template
            template.exercises.append(te)
        }

        try? context.save()
        dismiss()
    }
}

// MARK: - Edit Template View
struct EditTemplateView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(StoreKitManager.self) private var store
    @Bindable var template: WorkoutTemplate

    @State private var showingExercisePicker = false

    var body: some View {
        NavigationStack {
            ZStack {
                TrackrDesign.Colors.background.ignoresSafeArea()

                List {
                    Section("Name") {
                        TextField("Template name", text: $template.name)
                            .foregroundStyle(TrackrDesign.Colors.textPrimary)
                            .listRowBackground(TrackrDesign.Colors.surface)
                    }

                    Section("Exercises — drag to reorder") {
                        ForEach(template.sortedExercises) { exercise in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(exercise.name)
                                        .font(TrackrDesign.Font.body(15, weight: .medium))
                                        .foregroundStyle(TrackrDesign.Colors.textPrimary)
                                    Text("\(exercise.targetSets) sets · \(exercise.repsDisplay) reps")
                                        .font(TrackrDesign.Font.body(12))
                                        .foregroundStyle(TrackrDesign.Colors.textSecondary)
                                }
                                Spacer()
                            }
                            .listRowBackground(TrackrDesign.Colors.surface)
                        }
                        .onDelete { indexSet in
                            let sorted = template.sortedExercises
                            for idx in indexSet {
                                let ex = sorted[idx]
                                template.exercises.removeAll { $0.id == ex.id }
                                context.delete(ex)
                            }
                        }
                        .onMove { from, to in
                            var sorted = template.sortedExercises
                            sorted.move(fromOffsets: from, toOffset: to)
                            for (index, ex) in sorted.enumerated() {
                                ex.orderIndex = index
                            }
                        }

                        Button {
                            showingExercisePicker = true
                        } label: {
                            Label("Add Exercise", systemImage: "plus.circle.fill")
                                .foregroundStyle(TrackrDesign.Colors.accent)
                        }
                        .listRowBackground(TrackrDesign.Colors.surface)
                    }
                }
                .scrollContentBackground(.hidden)
                .background(TrackrDesign.Colors.background)
                .environment(\.editMode, .constant(.active))
            }
            .navigationTitle("Edit Template")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(TrackrDesign.Font.body(16, weight: .semibold))
                        .foregroundStyle(TrackrDesign.Colors.accent)
                }
            }
            .sheet(isPresented: $showingExercisePicker) {
                ExercisePickerView { name in
                    let te = TemplateExercise(name: name, orderIndex: template.exercises.count)
                    context.insert(te)
                    te.template = template
                    template.exercises.append(te)
                }
            }
        }
        .presentationBackground(TrackrDesign.Colors.background)
    }
}

// MARK: - Draft Model
struct TemplateExerciseDraft: Identifiable {
    let id = UUID()
    var name: String
    var sets: Int = 3
    var repsMin: Int = 10
    var repsMax: Int = 12
    var useRepRange: Bool = false
    var weight: Double = 0
}

// MARK: - Draft Row
struct TemplateExerciseDraftRow: View {
    @Binding var draft: TemplateExerciseDraft
    let isPro: Bool
    let onDelete: () -> Void

    @State private var setsText: String = ""
    @State private var repsMinText: String = ""
    @State private var repsMaxText: String = ""
    @State private var showingProAlert = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(draft.name)
                    .font(TrackrDesign.Font.body(16, weight: .semibold))
                    .foregroundStyle(TrackrDesign.Colors.textPrimary)
                Spacer()
                Button(action: onDelete) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(TrackrDesign.Colors.textTertiary)
                }
            }

            HStack(spacing: 12) {
                inputField(label: "Sets", text: $setsText, placeholder: "3") { v in
                    draft.sets = max(1, Int(v) ?? draft.sets)
                }
                if draft.useRepRange {
                    inputField(label: "Min Reps", text: $repsMinText, placeholder: "8") { v in
                        draft.repsMin = max(1, Int(v) ?? draft.repsMin)
                    }
                    inputField(label: "Max Reps", text: $repsMaxText, placeholder: "12") { v in
                        draft.repsMax = max(draft.repsMin + 1, Int(v) ?? draft.repsMax)
                    }
                } else {
                    inputField(label: "Reps", text: $repsMinText, placeholder: "10") { v in
                        draft.repsMin = max(1, Int(v) ?? draft.repsMin)
                    }
                }
            }

            // Rep range toggle (Pro)
            Button {
                if isPro {
                    withAnimation(TrackrDesign.Animation.snappy) {
                        draft.useRepRange.toggle()
                        repsMinText = "\(draft.repsMin)"
                        repsMaxText = "\(draft.repsMax)"
                    }
                } else {
                    showingProAlert = true
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: draft.useRepRange ? "checkmark.square.fill" : "square")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(draft.useRepRange ? TrackrDesign.Colors.accent : TrackrDesign.Colors.textTertiary)
                    Text("Rep Range")
                        .font(TrackrDesign.Font.body(13))
                        .foregroundStyle(TrackrDesign.Colors.textSecondary)
                    if !isPro {
                        HStack(spacing: 3) {
                            Image(systemName: "crown.fill").font(.system(size: 8, weight: .bold))
                            Text("PRO").font(TrackrDesign.Font.body(8, weight: .bold))
                        }
                        .foregroundStyle(Color(hex: "F59E0B"))
                        .padding(.horizontal, 5).padding(.vertical, 3)
                        .background(Capsule().fill(Color(hex: "F59E0B").opacity(0.15)))
                    }
                }
            }
            .buttonStyle(.plain)
            .alert("Trackr Pro", isPresented: $showingProAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Rep ranges are a Trackr Pro feature. Upgrade in Settings to unlock them.")
            }
        }
        .padding(TrackrDesign.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: TrackrDesign.Radius.lg)
                .fill(TrackrDesign.Colors.surface)
                .overlay(RoundedRectangle(cornerRadius: TrackrDesign.Radius.lg).stroke(TrackrDesign.Colors.border))
        )
        .onAppear {
            setsText    = "\(draft.sets)"
            repsMinText = "\(draft.repsMin)"
            repsMaxText = "\(draft.repsMax)"
        }
    }

    private func inputField(label: String, text: Binding<String>, placeholder: String, onChange: @escaping (String) -> Void) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(TrackrDesign.Font.body(11, weight: .semibold))
                .foregroundStyle(TrackrDesign.Colors.textTertiary)
            TextField(placeholder, text: text)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .font(TrackrDesign.Font.mono(20, weight: .bold))
                .foregroundStyle(TrackrDesign.Colors.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(RoundedRectangle(cornerRadius: TrackrDesign.Radius.md).fill(TrackrDesign.Colors.surfaceElevated))
                .onChange(of: text.wrappedValue, { _, v in onChange(v) })
        }
    }
}
