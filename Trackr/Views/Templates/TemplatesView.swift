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

    @State private var showingCreate    = false
    @State private var showingPro       = false
    @State private var templateToEdit: WorkoutTemplate?

    private var atFreeLimit: Bool { templates.count >= UserPreferences.freeTemplateLimit }

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
                        if atFreeLimit { showingPro = true }
                        else           { showingCreate = true }
                    } label: {
                        HStack(spacing: 5) {
                            if atFreeLimit {
                                Image(systemName: "crown.fill")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundStyle(Color(hex: "F59E0B"))
                            }
                            Image(systemName: "plus")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(atFreeLimit
                                                 ? TrackrDesign.Colors.textTertiary
                                                 : TrackrDesign.Colors.accent)
                        }
                    }
                }
            }
            .toolbarBackground(TrackrDesign.Colors.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .safeAreaInset(edge: .top, spacing: 0) {
                if !templates.isEmpty {
                    FreeTierBanner(used: templates.count, limit: UserPreferences.freeTemplateLimit) {
                        showingPro = true
                    }
                }
            }
            .sheet(isPresented: $showingCreate) { CreateTemplateView() }
            .sheet(item: $templateToEdit)        { EditTemplateView(template: $0) }
            .sheet(isPresented: $showingPro)     { TrackrProView() }
        }
    }

    // MARK: - List
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

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 24) {
            Image(systemName: "list.bullet.rectangle")
                .font(.system(size: 60, weight: .light))
                .foregroundStyle(TrackrDesign.Colors.textTertiary)

            VStack(spacing: 8) {
                Text("No Templates")
                    .font(TrackrDesign.Font.display(24))
                    .foregroundStyle(TrackrDesign.Colors.textPrimary)
                Text("Build reusable workout templates\nto start sessions in one tap.")
                    .font(TrackrDesign.Font.body(15))
                    .foregroundStyle(TrackrDesign.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }

            Button { showingCreate = true } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                    Text("Create Template")
                }
                .font(TrackrDesign.Font.body(16, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 28)
                .padding(.vertical, 16)
                .background(Capsule().fill(TrackrDesign.Colors.accent))
            }
            .buttonStyle(.plain)
        }
        .padding(TrackrDesign.Spacing.xl)
    }

    // MARK: - Start from template
    private func startFromTemplate(_ template: WorkoutTemplate) {
        let session = WorkoutSession(name: template.name, templateID: template.id)
        context.insert(session)
        for (i, te) in template.sortedExercises.enumerated() {
            let ex = Exercise(name: te.name, muscleGroup: te.muscleGroup, orderIndex: i)
            context.insert(ex)
            ex.session = session
            session.exercises.append(ex)
            for j in 0..<te.targetSets {
                let s = WorkoutSet(reps: te.targetReps, weight: te.targetWeight, orderIndex: j)
                context.insert(s)
                s.exercise = ex
                ex.sets.append(s)
            }
        }
        template.usageCount += 1
        template.lastUsed   = Date()
        activeWorkout  = session
        showingWorkout = true
    }
}

// MARK: - Free Tier Banner
struct FreeTierBanner: View {
    let used: Int
    let limit: Int
    let onUpgrade: () -> Void

    var body: some View {
        Button(action: onUpgrade) {
            HStack(spacing: 10) {
                HStack(spacing: 5) {
                    ForEach(0..<limit, id: \.self) { i in
                        RoundedRectangle(cornerRadius: 3)
                            .fill(i < used ? TrackrDesign.Colors.accent : TrackrDesign.Colors.surfaceHigh)
                            .frame(width: 22, height: 6)
                    }
                }

                Text("\(used)/\(limit) free templates")
                    .font(TrackrDesign.Font.body(12, weight: .medium))
                    .foregroundStyle(used >= limit
                                     ? TrackrDesign.Colors.orange
                                     : TrackrDesign.Colors.textSecondary)

                Spacer()

                if used >= limit {
                    HStack(spacing: 4) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 9, weight: .bold))
                        Text("Unlock more")
                            .font(TrackrDesign.Font.body(11, weight: .semibold))
                    }
                    .foregroundStyle(Color(hex: "F59E0B"))
                    .padding(.horizontal, 9)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color(hex: "F59E0B").opacity(0.15)))
                }
            }
            .padding(.horizontal, TrackrDesign.Spacing.md)
            .padding(.vertical, 10)
            .background(TrackrDesign.Colors.surface)
            .overlay(
                Rectangle().fill(TrackrDesign.Colors.border).frame(height: 1),
                alignment: .bottom
            )
        }
        .buttonStyle(.plain)
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
                            Label("\(template.usageCount)×", systemImage: "arrow.clockwise")
                        }
                    }
                    .font(TrackrDesign.Font.body(12))
                    .foregroundStyle(TrackrDesign.Colors.textSecondary)
                    .labelStyle(.titleAndIcon)
                }

                Spacer()

                Menu {
                    Button("Edit",   systemImage: "pencil",  action: onEdit)
                    Button("Delete", systemImage: "trash",   role: .destructive, action: onDelete)
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(TrackrDesign.Colors.textSecondary)
                        .frame(width: 32, height: 32)
                }
            }

            if !template.sortedExercises.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(template.sortedExercises) { ex in
                            Text(ex.name)
                                .font(TrackrDesign.Font.body(12, weight: .medium))
                                .foregroundStyle(TrackrDesign.Colors.textSecondary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Capsule().fill(TrackrDesign.Colors.surfaceHigh))
                        }
                    }
                }
            }

            Button(action: onStart) {
                HStack(spacing: 8) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 13, weight: .semibold))
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
