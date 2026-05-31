//
//  ExercisePickerView.swift
//  Trackr
//
//  Created by Dylan Choukalos on 5/30/26.
//

import SwiftUI

struct ExercisePickerView: View {
    @Environment(\.dismiss) private var dismiss
    let onSelect: (String) -> Void
    
    @State private var searchText = ""
    @State private var customName = ""
    @State private var selectedCategory = "All"
    @FocusState private var searchFocused: Bool
    
    let categories = ["All", "Chest", "Back", "Shoulders", "Arms", "Legs", "Core", "Cardio"]
    
    let exercises: [ExerciseLibraryItem] = [
        // Chest
        .init(name: "Bench Press", category: "Chest", muscle: "Pecs"),
        .init(name: "Incline Bench Press", category: "Chest", muscle: "Upper Pecs"),
        .init(name: "Dumbbell Fly", category: "Chest", muscle: "Pecs"),
        .init(name: "Push-Up", category: "Chest", muscle: "Pecs"),
        .init(name: "Cable Fly", category: "Chest", muscle: "Pecs"),
        .init(name: "Dips", category: "Chest", muscle: "Pecs"),
        // Back
        .init(name: "Deadlift", category: "Back", muscle: "Erectors"),
        .init(name: "Pull-Up", category: "Back", muscle: "Lats"),
        .init(name: "Barbell Row", category: "Back", muscle: "Lats"),
        .init(name: "Lat Pulldown", category: "Back", muscle: "Lats"),
        .init(name: "Seated Cable Row", category: "Back", muscle: "Mid Back"),
        .init(name: "Face Pull", category: "Back", muscle: "Rear Delts"),
        // Shoulders
        .init(name: "Overhead Press", category: "Shoulders", muscle: "Delts"),
        .init(name: "Lateral Raise", category: "Shoulders", muscle: "Side Delts"),
        .init(name: "Front Raise", category: "Shoulders", muscle: "Front Delts"),
        .init(name: "Arnold Press", category: "Shoulders", muscle: "Delts"),
        // Arms
        .init(name: "Barbell Curl", category: "Arms", muscle: "Biceps"),
        .init(name: "Hammer Curl", category: "Arms", muscle: "Biceps"),
        .init(name: "Tricep Pushdown", category: "Arms", muscle: "Triceps"),
        .init(name: "Skull Crusher", category: "Arms", muscle: "Triceps"),
        .init(name: "Preacher Curl", category: "Arms", muscle: "Biceps"),
        // Legs
        .init(name: "Squat", category: "Legs", muscle: "Quads"),
        .init(name: "Romanian Deadlift", category: "Legs", muscle: "Hamstrings"),
        .init(name: "Leg Press", category: "Legs", muscle: "Quads"),
        .init(name: "Lunges", category: "Legs", muscle: "Quads"),
        .init(name: "Leg Curl", category: "Legs", muscle: "Hamstrings"),
        .init(name: "Calf Raise", category: "Legs", muscle: "Calves"),
        // Core
        .init(name: "Plank", category: "Core", muscle: "Abs"),
        .init(name: "Cable Crunch", category: "Core", muscle: "Abs"),
        .init(name: "Hanging Leg Raise", category: "Core", muscle: "Lower Abs"),
        .init(name: "Ab Wheel", category: "Core", muscle: "Abs"),
        // Cardio
        .init(name: "Treadmill Run", category: "Cardio", muscle: "Full Body"),
        .init(name: "Rowing Machine", category: "Cardio", muscle: "Full Body"),
        .init(name: "Cycling", category: "Cardio", muscle: "Legs"),
    ]
    
    var filteredExercises: [ExerciseLibraryItem] {
        let byCategory = selectedCategory == "All" ? exercises : exercises.filter { $0.category == selectedCategory }
        if searchText.isEmpty { return byCategory }
        return byCategory.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                TrackrDesign.Colors.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search bar
                    searchBar
                    
                    // Category filter
                    categoryFilter
                    
                    Divider().background(TrackrDesign.Colors.border)
                    
                    // Exercise list
                    if filteredExercises.isEmpty && !searchText.isEmpty {
                        customExerciseOption
                    } else {
                        List {
                            ForEach(filteredExercises) { item in
                                Button {
                                    onSelect(item.name)
                                    dismiss()
                                } label: {
                                    ExerciseLibraryRow(item: item)
                                }
                                .listRowBackground(TrackrDesign.Colors.surface)
                                .listRowSeparatorTint(TrackrDesign.Colors.border)
                            }
                        }
                        .listStyle(.plain)
                        .background(TrackrDesign.Colors.background)
                        .scrollContentBackground(.hidden)
                    }
                }
            }
            .navigationTitle("Add Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(TrackrDesign.Colors.textSecondary)
                }
                
                if !searchText.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Add \"\(searchText)\"") {
                            onSelect(searchText)
                            dismiss()
                        }
                        .font(TrackrDesign.Font.body(14, weight: .semibold))
                        .foregroundStyle(TrackrDesign.Colors.accent)
                    }
                }
            }
        }
        .presentationDetents([.large])
        .presentationBackground(TrackrDesign.Colors.background)
    }
    
    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(TrackrDesign.Colors.textTertiary)
            
            TextField("Search exercises...", text: $searchText)
                .font(TrackrDesign.Font.body(16))
                .foregroundStyle(TrackrDesign.Colors.textPrimary)
                .focused($searchFocused)
            
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(TrackrDesign.Colors.textTertiary)
                }
            }
        }
        .padding(14)
        .background(TrackrDesign.Colors.surfaceElevated)
        .cornerRadius(TrackrDesign.Radius.md)
        .padding(.horizontal, TrackrDesign.Spacing.md)
        .padding(.vertical, 12)
        .onAppear { searchFocused = true }
    }
    
    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(categories, id: \.self) { cat in
                    Button {
                        selectedCategory = cat
                    } label: {
                        Text(cat)
                            .font(TrackrDesign.Font.body(13, weight: .semibold))
                            .foregroundStyle(selectedCategory == cat ? .white : TrackrDesign.Colors.textSecondary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(selectedCategory == cat ? TrackrDesign.Colors.accent : TrackrDesign.Colors.surfaceElevated)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, TrackrDesign.Spacing.md)
        }
        .padding(.vertical, 10)
    }
    
    private var customExerciseOption: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "plus.circle.dashed")
                .font(.system(size: 48, weight: .light))
                .foregroundStyle(TrackrDesign.Colors.textTertiary)
            
            Text("No exercise found")
                .font(TrackrDesign.Font.display(20))
                .foregroundStyle(TrackrDesign.Colors.textPrimary)
            
            Button {
                onSelect(searchText)
                dismiss()
            } label: {
                Text("Add \"\(searchText)\"")
                    .font(TrackrDesign.Font.body(16, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 16)
                    .background(
                        Capsule().fill(TrackrDesign.Colors.accent)
                    )
            }
            .buttonStyle(.plain)
            
            Spacer()
        }
    }
}

struct ExerciseLibraryItem: Identifiable {
    let id = UUID()
    let name: String
    let category: String
    let muscle: String
}

struct ExerciseLibraryRow: View {
    let item: ExerciseLibraryItem
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(categoryColor.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: categoryIcon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(categoryColor)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(TrackrDesign.Font.body(15, weight: .medium))
                    .foregroundStyle(TrackrDesign.Colors.textPrimary)
                Text(item.muscle)
                    .font(TrackrDesign.Font.body(12))
                    .foregroundStyle(TrackrDesign.Colors.textSecondary)
            }
            
            Spacer()
            
            Image(systemName: "plus.circle")
                .font(.system(size: 20))
                .foregroundStyle(TrackrDesign.Colors.accent)
        }
        .padding(.vertical, 6)
    }
    
    private var categoryColor: Color {
        switch item.category {
        case "Chest": return TrackrDesign.Colors.red
        case "Back": return TrackrDesign.Colors.blue
        case "Shoulders": return TrackrDesign.Colors.orange
        case "Arms": return TrackrDesign.Colors.accentLight
        case "Legs": return TrackrDesign.Colors.green
        case "Core": return Color(hex: "F472B6")
        default: return TrackrDesign.Colors.accent
        }
    }
    
    private var categoryIcon: String {
        switch item.category {
        case "Chest": return "figure.strengthtraining.functional"
        case "Back": return "figure.strengthtraining.traditional"
        case "Shoulders": return "arrow.up.circle"
        case "Arms": return "figure.arms.open"
        case "Legs": return "figure.run"
        case "Core": return "figure.core.training"
        default: return "heart.circle"
        }
    }
}
