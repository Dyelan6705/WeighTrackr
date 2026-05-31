//
//  CreateTemplateView.swift
//  Trackr
//
//  Created by Dylan Choukalos on 5/30/26.
//

import SwiftUI
import SwiftData

struct CreateTemplateView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var exercises: [TemplateExerciseDraft] = []
    @State private var showingExercisePicker = false
    @FocusState private var nameFocused: Bool
    
    var body: some View {
        NavigationStack {
            ZStack {
                TrackrDesign.Colors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: TrackrDesign.Spacing.md) {
                        // Name field
                        nameField
                        
                        // Exercise list
                        ForEach($exercises) { $exercise in
                            TemplateExerciseDraftRow(draft: $exercise) {
                                exercises.removeAll { $0.id == exercise.id }
                            }
                        }
                        
                        // Add exercise
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
    
    private func save() {
        let template = WorkoutTemplate(name: name)
        context.insert(template)
        
        for (index, draft) in exercises.enumerated() {
            let te = TemplateExercise(
                name: draft.name,
                targetSets: draft.sets,
                targetReps: draft.reps,
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
                    
                    Section("Exercises") {
                        ForEach(template.sortedExercises) { exercise in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(exercise.name)
                                        .font(TrackrDesign.Font.body(15, weight: .medium))
                                        .foregroundStyle(TrackrDesign.Colors.textPrimary)
                                    Text("\(exercise.targetSets) × \(exercise.targetReps)")
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
            }
            .navigationTitle("Edit Template")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(TrackrDesign.Colors.accent)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                        .foregroundStyle(TrackrDesign.Colors.textSecondary)
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

// MARK: - Draft Models
struct TemplateExerciseDraft: Identifiable {
    let id = UUID()
    var name: String
    var sets: Int = 3
    var reps: Int = 10
    var weight: Double = 0
}

struct TemplateExerciseDraftRow: View {
    @Binding var draft: TemplateExerciseDraft
    let onDelete: () -> Void
    
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
                stepper(label: "Sets", value: $draft.sets, range: 1...20)
                stepper(label: "Reps", value: $draft.reps, range: 1...100)
            }
        }
        .padding(TrackrDesign.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: TrackrDesign.Radius.lg)
                .fill(TrackrDesign.Colors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: TrackrDesign.Radius.lg)
                        .stroke(TrackrDesign.Colors.border)
                )
        )
    }
    
    private func stepper(label: String, value: Binding<Int>, range: ClosedRange<Int>) -> some View {
        VStack(spacing: 6) {
            Text(label)
                .font(TrackrDesign.Font.body(11, weight: .semibold))
                .foregroundStyle(TrackrDesign.Colors.textTertiary)
            
            HStack(spacing: 12) {
                Button {
                    if value.wrappedValue > range.lowerBound {
                        value.wrappedValue -= 1
                    }
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(TrackrDesign.Colors.textTertiary)
                }
                
                Text("\(value.wrappedValue)")
                    .font(TrackrDesign.Font.mono(18, weight: .bold))
                    .foregroundStyle(TrackrDesign.Colors.textPrimary)
                    .frame(minWidth: 30)
                
                Button {
                    if value.wrappedValue < range.upperBound {
                        value.wrappedValue += 1
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(TrackrDesign.Colors.accent)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: TrackrDesign.Radius.md)
                .fill(TrackrDesign.Colors.surfaceElevated)
        )
    }
}
