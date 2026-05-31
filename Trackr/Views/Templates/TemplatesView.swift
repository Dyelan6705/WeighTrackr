//
//  TemplatesView.swift
//  Trackr
//
//  Created by Dylan Choukalos on 5/30/26.
//

import SwiftUI
import SwiftData

struct TemplatesView: View {
    @Environment(\.modelContext) private var context
    @Binding var activeWorkout: WorkoutSession?
    @Binding var showingWorkout: Bool
    
    @Query(sort: \WorkoutTemplate.createdAt, order: .reverse)
    private var templates: [WorkoutTemplate]
    
    @State private var showingCreate = false
    @State private var templateToEdit: WorkoutTemplate?
    
    var body: some View {
        NavigationStack {
            ZStack {
                TrackrDesign.Colors.background.ignoresSafeArea()
                
                Group {
                    if templates.isEmpty {
                        emptyState
                    } else {
                        templateList
                    }
                }
            }
            .navigationTitle("Templates")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingCreate = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(TrackrDesign.Colors.accent)
                    }
                }
            }
            .toolbarBackground(TrackrDesign.Colors.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .sheet(isPresented: $showingCreate) {
                CreateTemplateView()
            }
            .sheet(item: $templateToEdit) { template in
                EditTemplateView(template: template)
            }
        }
    }
    
    private var templateList: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 12) {
                ForEach(templates) { template in
                    TemplateCard(template: template) {
                        startFromTemplate(template)
                    } onEdit: {
                        templateToEdit = template
                    } onDelete: {
                        context.delete(template)
                    }
                }
            }
            .padding(.horizontal, TrackrDesign.Spacing.md)
            .padding(.top, TrackrDesign.Spacing.md)
            .padding(.bottom, 100)
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 24) {
            Image(systemName: "list.bullet.rectangle")
                .font(.system(size: 64, weight: .light))
                .foregroundStyle(TrackrDesign.Colors.textTertiary)
            
            VStack(spacing: 8) {
                Text("No Templates")
                    .font(TrackrDesign.Font.display(24))
                    .foregroundStyle(TrackrDesign.Colors.textPrimary)
                Text("Create reusable workout templates\nto start sessions quickly.")
                    .font(TrackrDesign.Font.body(15))
                    .foregroundStyle(TrackrDesign.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            
            Button {
                showingCreate = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                    Text("Create Template")
                }
                .font(TrackrDesign.Font.body(16, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 28)
                .padding(.vertical, 16)
                .background(
                    Capsule().fill(TrackrDesign.Colors.accent)
                )
            }
            .buttonStyle(.plain)
        }
        .padding(TrackrDesign.Spacing.xl)
    }
    
    private func startFromTemplate(_ template: WorkoutTemplate) {
        let session = WorkoutSession(name: template.name, templateID: template.id)
        context.insert(session)
        
        for (index, templateExercise) in template.sortedExercises.enumerated() {
            let exercise = Exercise(name: templateExercise.name, muscleGroup: templateExercise.muscleGroup, orderIndex: index)
            context.insert(exercise)
            exercise.session = session
            session.exercises.append(exercise)
            
            for setIndex in 0..<templateExercise.targetSets {
                let set = WorkoutSet(reps: templateExercise.targetReps, weight: templateExercise.targetWeight, orderIndex: setIndex)
                context.insert(set)
                set.exercise = exercise
                exercise.sets.append(set)
            }
        }
        
        template.usageCount += 1
        template.lastUsed = Date()
        
        activeWorkout = session
        showingWorkout = true
    }
}

// MARK: - Template Card
struct TemplateCard: View {
    let template: WorkoutTemplate
    let onStart: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(template.name)
                        .font(TrackrDesign.Font.display(18))
                        .foregroundStyle(TrackrDesign.Colors.textPrimary)
                    
                    HStack(spacing: 10) {
                        Label("\(template.exercises.count) exercises", systemImage: "list.bullet")
                        if template.usageCount > 0 {
                            Label("\(template.usageCount)x used", systemImage: "arrow.clockwise")
                        }
                    }
                    .font(TrackrDesign.Font.body(12))
                    .foregroundStyle(TrackrDesign.Colors.textSecondary)
                    .labelStyle(.titleAndIcon)
                }
                
                Spacer()
                
                Menu {
                    Button("Edit", systemImage: "pencil", action: onEdit)
                    Button("Delete", systemImage: "trash", role: .destructive, action: onDelete)
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(TrackrDesign.Colors.textSecondary)
                        .frame(width: 32, height: 32)
                }
            }
            
            // Exercise chips
            if !template.sortedExercises.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(template.sortedExercises) { ex in
                            Text(ex.name)
                                .font(TrackrDesign.Font.body(12, weight: .medium))
                                .foregroundStyle(TrackrDesign.Colors.textSecondary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule().fill(TrackrDesign.Colors.surfaceHigh)
                                )
                        }
                    }
                }
                .padding(.horizontal, -2)
            }
            
            // Start button
            Button(action: onStart) {
                HStack(spacing: 8) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Start Workout")
                        .font(TrackrDesign.Font.body(15, weight: .semibold))
                }
                .foregroundStyle(TrackrDesign.Colors.accent)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .background(
                    RoundedRectangle(cornerRadius: TrackrDesign.Radius.md)
                        .fill(TrackrDesign.Colors.accentGlow)
                        .overlay(
                            RoundedRectangle(cornerRadius: TrackrDesign.Radius.md)
                                .stroke(TrackrDesign.Colors.accent.opacity(0.3))
                        )
                )
            }
            .buttonStyle(.plain)
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
}
