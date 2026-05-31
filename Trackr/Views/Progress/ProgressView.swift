//
//  ProgressView.swift
//  Trackr
//
//  Created by Dylan Choukalos on 5/30/26.
//

import SwiftUI
import SwiftData
import Charts

struct TrackrProgressView: View {
    @Environment(\.modelContext) private var context
    @State private var viewModel = ProgressViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                TrackrDesign.Colors.background.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: TrackrDesign.Spacing.md) {
                        statsSummary
                        chartSection
                        personalRecordsSection
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, TrackrDesign.Spacing.md)
                    .padding(.top, TrackrDesign.Spacing.md)
                }
            }
            .navigationTitle("Progress")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(TrackrDesign.Colors.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .onAppear { viewModel.load(context: context) }
        }
    }
    
    // MARK: - Stats Summary
    private var statsSummary: some View {
        HStack(spacing: 12) {
            StatPill(
                icon: "dumbbell.fill",
                label: "Exercises",
                value: "\(viewModel.allExerciseNames.count)",
                color: TrackrDesign.Colors.accent
            )
            StatPill(
                icon: "trophy.fill",
                label: "PRs Set",
                value: "\(viewModel.personalRecords.count)",
                color: TrackrDesign.Colors.orange
            )
        }
    }
    
    // MARK: - Chart Section
    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Strength Progress")
                    .font(TrackrDesign.Font.display(17))
                    .foregroundStyle(TrackrDesign.Colors.textPrimary)
                Spacer()
            }
            
            if !viewModel.allExerciseNames.isEmpty {
                // Exercise selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(viewModel.allExerciseNames, id: \.self) { name in
                            Button {
                                viewModel.selectedExercise = name
                            } label: {
                                Text(name)
                                    .font(TrackrDesign.Font.body(12, weight: .semibold))
                                    .foregroundStyle(viewModel.selectedExercise == name
                                                     ? .white
                                                     : TrackrDesign.Colors.textSecondary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(
                                        Capsule()
                                            .fill(viewModel.selectedExercise == name
                                                  ? TrackrDesign.Colors.accent
                                                  : TrackrDesign.Colors.surfaceElevated)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                
                // Time range selector
                HStack(spacing: 6) {
                    ForEach(TimeRange.allCases, id: \.self) { range in
                        Button {
                            viewModel.selectedRange = range
                        } label: {
                            Text(range.rawValue)
                                .font(TrackrDesign.Font.mono(12, weight: .semibold))
                                .foregroundStyle(viewModel.selectedRange == range
                                                 ? TrackrDesign.Colors.accent
                                                 : TrackrDesign.Colors.textTertiary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(viewModel.selectedRange == range
                                              ? TrackrDesign.Colors.accentGlow
                                              : .clear)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                chartContent
                    .frame(height: 200)
                    .padding(.top, 4)
            } else {
                EmptyStateCard(
                    icon: "chart.line.uptrend.xyaxis",
                    message: "Complete workouts to\nsee your progress."
                )
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
    
    @ViewBuilder
    private var chartContent: some View {
        let points = viewModel.filteredDataPoints
        
        if points.isEmpty {
            VStack {
                Spacer()
                Text("No data in this range")
                    .font(TrackrDesign.Font.body(14))
                    .foregroundStyle(TrackrDesign.Colors.textTertiary)
                Spacer()
            }
        } else {
            Chart {
                ForEach(points) { point in
                    LineMark(
                        x: .value("Date", point.date),
                        y: .value("Weight", point.weight)
                    )
                    .foregroundStyle(TrackrDesign.Colors.accentLight)
                    .interpolationMethod(.catmullRom)
                    
                    AreaMark(
                        x: .value("Date", point.date),
                        y: .value("Weight", point.weight)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                TrackrDesign.Colors.accent.opacity(0.3),
                                TrackrDesign.Colors.accent.opacity(0.0)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.catmullRom)
                    
                    PointMark(
                        x: .value("Date", point.date),
                        y: .value("Weight", point.weight)
                    )
                    .foregroundStyle(TrackrDesign.Colors.accentLight)
                    .symbolSize(40)
                }
            }
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 4)) { _ in
                    AxisValueLabel()
                        .foregroundStyle(TrackrDesign.Colors.textTertiary)
                        .font(TrackrDesign.Font.body(10))
                    AxisGridLine()
                        .foregroundStyle(TrackrDesign.Colors.border)
                }
            }
            .chartYAxis {
                AxisMarks(values: .automatic(desiredCount: 4)) { _ in
                    AxisValueLabel()
                        .foregroundStyle(TrackrDesign.Colors.textTertiary)
                        .font(TrackrDesign.Font.body(10))
                    AxisGridLine()
                        .foregroundStyle(TrackrDesign.Colors.border)
                }
            }
        }
    }
    
    // MARK: - Personal Records
    private var personalRecordsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Personal Records")
                .font(TrackrDesign.Font.display(17))
                .foregroundStyle(TrackrDesign.Colors.textPrimary)
            
            if viewModel.personalRecords.isEmpty {
                EmptyStateCard(
                    icon: "trophy",
                    message: "Complete workouts to\nset personal records."
                )
            } else {
                VStack(spacing: 8) {
                    ForEach(viewModel.personalRecords) { pr in
                        PersonalRecordRow(record: pr)
                    }
                }
            }
        }
    }
}

// MARK: - Stat Pill
struct StatPill: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(color.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(TrackrDesign.Font.display(20))
                    .foregroundStyle(TrackrDesign.Colors.textPrimary)
                Text(label)
                    .font(TrackrDesign.Font.body(12))
                    .foregroundStyle(TrackrDesign.Colors.textSecondary)
            }
            
            Spacer()
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: TrackrDesign.Radius.md)
                .fill(TrackrDesign.Colors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: TrackrDesign.Radius.md)
                        .stroke(TrackrDesign.Colors.border)
                )
        )
    }
}

// MARK: - Personal Record Row
struct PersonalRecordRow: View {
    let record: PersonalRecord
    
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(TrackrDesign.Colors.orange)
                .frame(width: 36)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(record.exerciseName)
                    .font(TrackrDesign.Font.body(14, weight: .semibold))
                    .foregroundStyle(TrackrDesign.Colors.textPrimary)
                Text(formattedDate)
                    .font(TrackrDesign.Font.body(11))
                    .foregroundStyle(TrackrDesign.Colors.textTertiary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(record.formattedWeight) kg")
                    .font(TrackrDesign.Font.mono(15, weight: .bold))
                    .foregroundStyle(TrackrDesign.Colors.textPrimary)
                Text("× \(record.reps) reps")
                    .font(TrackrDesign.Font.mono(12))
                    .foregroundStyle(TrackrDesign.Colors.textSecondary)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: TrackrDesign.Radius.md)
                .fill(TrackrDesign.Colors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: TrackrDesign.Radius.md)
                        .stroke(TrackrDesign.Colors.border)
                )
        )
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: record.date)
    }
}
