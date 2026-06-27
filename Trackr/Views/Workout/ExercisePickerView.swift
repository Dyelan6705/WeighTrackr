//
//  ExercisePickerView.swift
//  Trackr
//
//  Created by Dylan Choukalos on 5/30/26.
//

import SwiftUI
import SwiftData

struct ExercisePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query(sort: \CustomExercise.createdAt, order: .reverse)
    private var customExercises: [CustomExercise]

    let onSelect: (String) -> Void

    @State private var searchText = ""
    @State private var selectedCategory = "All"
    @State private var showingCreate = false
    @State private var showingPro = false
    @FocusState private var searchFocused: Bool

    private var isPro: Bool { StoreKitManager.shared.isPro }
    private var atCustomLimit: Bool {
        !isPro && customExercises.count >= UserPreferences.freeCustomExerciseLimit
    }

    let categories = ["All", "Chest", "Back", "Shoulders", "Arms", "Legs", "Core", "Cardio"]

    let builtInExercises: [ExerciseLibraryItem] = [
        .init(name: "Bench Press",          category: "Chest",     muscle: "Pecs"),
        .init(name: "Incline Bench Press",  category: "Chest",     muscle: "Upper Pecs"),
        .init(name: "Dumbbell Fly",         category: "Chest",     muscle: "Pecs"),
        .init(name: "Push-Up",              category: "Chest",     muscle: "Pecs"),
        .init(name: "Cable Fly",            category: "Chest",     muscle: "Pecs"),
        .init(name: "Dips",                 category: "Chest",     muscle: "Pecs"),
        .init(name: "Deadlift",             category: "Back",      muscle: "Erectors"),
        .init(name: "Pull-Up",              category: "Back",      muscle: "Lats"),
        .init(name: "Barbell Row",          category: "Back",      muscle: "Lats"),
        .init(name: "Lat Pulldown",         category: "Back",      muscle: "Lats"),
        .init(name: "Seated Cable Row",     category: "Back",      muscle: "Mid Back"),
        .init(name: "Face Pull",            category: "Back",      muscle: "Rear Delts"),
        .init(name: "Overhead Press",       category: "Shoulders", muscle: "Delts"),
        .init(name: "Lateral Raise",        category: "Shoulders", muscle: "Side Delts"),
        .init(name: "Front Raise",          category: "Shoulders", muscle: "Front Delts"),
        .init(name: "Arnold Press",         category: "Shoulders", muscle: "Delts"),
        .init(name: "Barbell Curl",         category: "Arms",      muscle: "Biceps"),
        .init(name: "Hammer Curl",          category: "Arms",      muscle: "Biceps"),
        .init(name: "Tricep Pushdown",      category: "Arms",      muscle: "Triceps"),
        .init(name: "Skull Crusher",        category: "Arms",      muscle: "Triceps"),
        .init(name: "Preacher Curl",        category: "Arms",      muscle: "Biceps"),
        .init(name: "Squat",                category: "Legs",      muscle: "Quads"),
        .init(name: "Romanian Deadlift",    category: "Legs",      muscle: "Hamstrings"),
        .init(name: "Leg Press",            category: "Legs",      muscle: "Quads"),
        .init(name: "Lunges",               category: "Legs",      muscle: "Quads"),
        .init(name: "Leg Curl",             category: "Legs",      muscle: "Hamstrings"),
        .init(name: "Calf Raise",           category: "Legs",      muscle: "Calves"),
        .init(name: "Plank",                category: "Core",      muscle: "Abs"),
        .init(name: "Cable Crunch",         category: "Core",      muscle: "Abs"),
        .init(name: "Hanging Leg Raise",    category: "Core",      muscle: "Lower Abs"),
        .init(name: "Ab Wheel",             category: "Core",      muscle: "Abs"),
        .init(name: "Treadmill Run",        category: "Cardio",    muscle: "Full Body"),
        .init(name: "Rowing Machine",       category: "Cardio",    muscle: "Full Body"),
        .init(name: "Cycling",              category: "Cardio",    muscle: "Legs"),
    ]

    var filteredCustom: [CustomExercise] {
        let byCat = selectedCategory == "All" || selectedCategory == "Custom"
            ? customExercises
            : customExercises.filter { $0.category == selectedCategory }
        if searchText.isEmpty { return byCat }
        return byCat.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var filteredBuiltIn: [ExerciseLibraryItem] {
        let byCat = selectedCategory == "All"
            ? builtInExercises
            : builtInExercises.filter { $0.category == selectedCategory }
        if searchText.isEmpty { return byCat }
        return byCat.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                TrackrDesign.Colors.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    searchBar
                    categoryFilter
                    Divider().background(TrackrDesign.Colors.border)

                    if filteredCustom.isEmpty && filteredBuiltIn.isEmpty {
                        noResultsView
                    } else {
                        List {
                            // My Exercises section
                            if !filteredCustom.isEmpty {
                                Section {
                                    ForEach(filteredCustom) { item in
                                        Button {
                                            onSelect(item.name)
                                            dismiss()
                                        } label: {
                                            CustomExerciseRow(item: item)
                                        }
                                        .listRowBackground(TrackrDesign.Colors.surface)
                                        .listRowSeparatorTint(TrackrDesign.Colors.border)
                                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                            Button(role: .destructive) {
                                                context.delete(item)
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                    }
                                } header: {
                                    Text("My Exercises")
                                        .font(TrackrDesign.Font.body(12, weight: .semibold))
                                        .foregroundStyle(TrackrDesign.Colors.textTertiary)
                                        .textCase(nil)
                                }
                            }

                            // Built-in library
                            if !filteredBuiltIn.isEmpty {
                                Section {
                                    ForEach(filteredBuiltIn) { item in
                                        Button {
                                            onSelect(item.name)
                                            dismiss()
                                        } label: {
                                            ExerciseLibraryRow(item: item)
                                        }
                                        .listRowBackground(TrackrDesign.Colors.surface)
                                        .listRowSeparatorTint(TrackrDesign.Colors.border)
                                    }
                                } header: {
                                    Text("Exercise Library")
                                        .font(TrackrDesign.Font.body(12, weight: .semibold))
                                        .foregroundStyle(TrackrDesign.Colors.textTertiary)
                                        .textCase(nil)
                                }
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
                ToolbarItem(placement: .navigationBarTrailing) {
                    createButton
                }
            }
            .sheet(isPresented: $showingCreate) {
                CreateCustomExerciseSheet(existingCount: customExercises.count) { name, category, muscle in
                    let ex = CustomExercise(name: name, category: category, muscleGroup: muscle)
                    context.insert(ex)
                    try? context.save()
                    onSelect(name)
                    dismiss()
                }
            }
            .sheet(isPresented: $showingPro) {
                TrackrProView().environment(StoreKitManager.shared)
            }
        }
        .presentationDetents([.large])
        .presentationBackground(TrackrDesign.Colors.background)
        .onAppear { searchFocused = true }
    }

    // MARK: - Create Button
    @ViewBuilder
    private var createButton: some View {
        if atCustomLimit {
            Button {
                showingPro = true
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 10, weight: .bold))
                    Text("Create")
                        .font(TrackrDesign.Font.body(14, weight: .semibold))
                }
                .foregroundStyle(Color(hex: "F59E0B"))
            }
        } else {
            Button("Create") { showingCreate = true }
                .font(TrackrDesign.Font.body(14, weight: .semibold))
                .foregroundStyle(TrackrDesign.Colors.accent)
        }
    }

    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(TrackrDesign.Colors.textTertiary)
            TextField("Search exercises...", text: $searchText)
                .font(TrackrDesign.Font.body(16))
                .foregroundStyle(TrackrDesign.Colors.textPrimary)
                .focused($searchFocused)
            if !searchText.isEmpty {
                Button { searchText = "" } label: {
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
    }

    // MARK: - Category Filter
    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(["All"] + categories.dropFirst(), id: \.self) { cat in
                    Button { selectedCategory = cat } label: {
                        Text(cat)
                            .font(TrackrDesign.Font.body(13, weight: .semibold))
                            .foregroundStyle(selectedCategory == cat ? .white : TrackrDesign.Colors.textSecondary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Capsule().fill(selectedCategory == cat
                                                       ? TrackrDesign.Colors.accent
                                                       : TrackrDesign.Colors.surfaceElevated))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, TrackrDesign.Spacing.md)
        }
        .padding(.vertical, 10)
    }

    // MARK: - No Results
    private var noResultsView: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40, weight: .light))
                .foregroundStyle(TrackrDesign.Colors.textTertiary)
            Text("No exercises found")
                .font(TrackrDesign.Font.display(18))
                .foregroundStyle(TrackrDesign.Colors.textPrimary)
            Text("Tap Create to add \"\(searchText)\" to your library")
                .font(TrackrDesign.Font.body(14))
                .foregroundStyle(TrackrDesign.Colors.textSecondary)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding(.horizontal, TrackrDesign.Spacing.xl)
    }
}

// MARK: - Create Custom Exercise Sheet
struct CreateCustomExerciseSheet: View {
    @Environment(\.dismiss) private var dismiss
    let existingCount: Int
    let onCreate: (String, String, String) -> Void

    @State private var name = ""
    @State private var category = "Custom"
    @State private var muscleGroup = ""
    @FocusState private var nameFocused: Bool

    let categories = ["Custom", "Chest", "Back", "Shoulders", "Arms", "Legs", "Core", "Cardio"]

    var body: some View {
        NavigationStack {
            ZStack {
                TrackrDesign.Colors.background.ignoresSafeArea()
                VStack(spacing: TrackrDesign.Spacing.md) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Exercise Name")
                            .font(TrackrDesign.Font.body(13, weight: .semibold))
                            .foregroundStyle(TrackrDesign.Colors.textSecondary)
                        TextField("e.g. Cable Lateral Raise", text: $name)
                            .font(TrackrDesign.Font.display(18))
                            .foregroundStyle(TrackrDesign.Colors.textPrimary)
                            .focused($nameFocused)
                            .padding(14)
                            .background(RoundedRectangle(cornerRadius: TrackrDesign.Radius.md)
                                .fill(TrackrDesign.Colors.surface)
                                .overlay(RoundedRectangle(cornerRadius: TrackrDesign.Radius.md)
                                    .stroke(TrackrDesign.Colors.border)))
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Category")
                            .font(TrackrDesign.Font.body(13, weight: .semibold))
                            .foregroundStyle(TrackrDesign.Colors.textSecondary)
                        Picker("Category", selection: $category) {
                            ForEach(categories, id: \.self) { Text($0).tag($0) }
                        }
                        .pickerStyle(.menu)
                        .padding(14)
                        .background(RoundedRectangle(cornerRadius: TrackrDesign.Radius.md)
                            .fill(TrackrDesign.Colors.surface)
                            .overlay(RoundedRectangle(cornerRadius: TrackrDesign.Radius.md)
                                .stroke(TrackrDesign.Colors.border)))
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Muscle Group (optional)")
                            .font(TrackrDesign.Font.body(13, weight: .semibold))
                            .foregroundStyle(TrackrDesign.Colors.textSecondary)
                        TextField("e.g. Side Delts", text: $muscleGroup)
                            .font(TrackrDesign.Font.body(16))
                            .foregroundStyle(TrackrDesign.Colors.textPrimary)
                            .padding(14)
                            .background(RoundedRectangle(cornerRadius: TrackrDesign.Radius.md)
                                .fill(TrackrDesign.Colors.surface)
                                .overlay(RoundedRectangle(cornerRadius: TrackrDesign.Radius.md)
                                    .stroke(TrackrDesign.Colors.border)))
                    }

                    if !StoreKitManager.shared.isPro {
                        HStack(spacing: 6) {
                            Image(systemName: "info.circle").font(.system(size: 12))
                            Text("\(existingCount) of \(UserPreferences.freeCustomExerciseLimit) custom exercises used")
                                .font(TrackrDesign.Font.body(12))
                        }
                        .foregroundStyle(TrackrDesign.Colors.textTertiary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Spacer()
                }
                .padding(TrackrDesign.Spacing.md)
            }
            .navigationTitle("Create Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(TrackrDesign.Colors.textSecondary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onCreate(name.trimmingCharacters(in: .whitespaces), category, muscleGroup)
                    }
                    .font(TrackrDesign.Font.body(16, weight: .semibold))
                    .foregroundStyle(name.trimmingCharacters(in: .whitespaces).isEmpty
                                     ? TrackrDesign.Colors.textTertiary
                                     : TrackrDesign.Colors.accent)
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear { nameFocused = true }
        }
        .presentationBackground(TrackrDesign.Colors.background)
    }
}

// MARK: - Custom Exercise Row
struct CustomExerciseRow: View {
    let item: CustomExercise

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(TrackrDesign.Colors.accent.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: "star.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(TrackrDesign.Colors.accent)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(TrackrDesign.Font.body(15, weight: .medium))
                    .foregroundStyle(TrackrDesign.Colors.textPrimary)
                Text(item.muscleGroup.isEmpty ? item.category : item.muscleGroup)
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
}

// MARK: - Built-in Library Models
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
        case "Chest":     return TrackrDesign.Colors.red
        case "Back":      return TrackrDesign.Colors.blue
        case "Shoulders": return TrackrDesign.Colors.orange
        case "Arms":      return TrackrDesign.Colors.accentLight
        case "Legs":      return TrackrDesign.Colors.green
        case "Core":      return Color(hex: "F472B6")
        default:          return TrackrDesign.Colors.accent
        }
    }

    private var categoryIcon: String {
        switch item.category {
        case "Chest":     return "figure.strengthtraining.functional"
        case "Back":      return "figure.strengthtraining.traditional"
        case "Shoulders": return "arrow.up.circle"
        case "Arms":      return "figure.arms.open"
        case "Legs":      return "figure.run"
        case "Core":      return "figure.core.training"
        default:          return "heart.circle"
        }
    }
}
