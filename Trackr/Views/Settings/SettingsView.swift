//
//  SettingsView.swift
//  Trackr
//
//  Created by Dylan Choukalos on 5/30/26.
//

import SwiftUI

struct SettingsView: View {
    @State private var prefs = UserPreferences.shared
    @State private var showingPro = false

    var body: some View {
        NavigationStack {
            ZStack {
                TrackrDesign.Colors.background.ignoresSafeArea()

                List {
                    Section {
                        ProBannerCell { showingPro = true }
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets())
                    }

                    Section {
                        WeightUnitRow(useMetric: $prefs.useMetric)
                        ToggleRow(
                            icon: "waveform",
                            iconColor: TrackrDesign.Colors.green,
                            title: "Haptic Feedback",
                            isOn: $prefs.hapticEnabled
                        )
                    } header: {
                        sectionHeader("Preferences")
                    }
                    .listRowBackground(TrackrDesign.Colors.surface)
                    .listRowSeparatorTint(TrackrDesign.Colors.border)

                    Section {
                        ProFeatureRow(icon: "timer",         title: "Rest Timer",          desc: "Auto-start after each set")
                        ProFeatureRow(icon: "chart.bar",     title: "Advanced Analytics",  desc: "Volume, trends & more")
                        ProFeatureRow(icon: "icloud",        title: "Cloud Sync",           desc: "Sync across your devices")
                    } header: {
                        sectionHeader("Trackr Pro Features")
                    }
                    .listRowBackground(TrackrDesign.Colors.surface)
                    .listRowSeparatorTint(TrackrDesign.Colors.border)

                    Section {
                        IconRow(icon: "info.circle",  iconColor: TrackrDesign.Colors.textTertiary, title: "Version",        value: "1.0.0")
                        Link(destination: URL(string: "https://trackrapp.com/privacy")!) {
                            IconRow(icon: "lock.shield", iconColor: TrackrDesign.Colors.textTertiary, title: "Privacy Policy", value: "")
                        }
                    } header: {
                        sectionHeader("About")
                    }
                    .listRowBackground(TrackrDesign.Colors.surface)
                    .listRowSeparatorTint(TrackrDesign.Colors.border)
                }
                .scrollContentBackground(.hidden)
                .background(TrackrDesign.Colors.background)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(TrackrDesign.Colors.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .sheet(isPresented: $showingPro) {
                TrackrProView()
            }
        }
    }

    private func sectionHeader(_ text: String) -> some View {
        Text(text)
            .font(TrackrDesign.Font.body(12, weight: .semibold))
            .foregroundStyle(TrackrDesign.Colors.textTertiary)
            .textCase(nil)
            .padding(.bottom, 4)
    }
}

// MARK: - Weight Unit Row
struct WeightUnitRow: View {
    @Binding var useMetric: Bool

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(TrackrDesign.Colors.blue.opacity(0.15))
                    .frame(width: 34, height: 34)
                Image(systemName: "scalemass.fill")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(TrackrDesign.Colors.blue)
            }

            Text("Weight Unit")
                .font(TrackrDesign.Font.body(15))
                .foregroundStyle(TrackrDesign.Colors.textPrimary)

            Spacer()

            HStack(spacing: 0) {
                ForEach([("kg", true), ("lbs", false)], id: \.0) { label, isMetric in
                    Button {
                        withAnimation(TrackrDesign.Animation.snappy) { useMetric = isMetric }
                    } label: {
                        Text(label)
                            .font(TrackrDesign.Font.body(13, weight: .semibold))
                            .foregroundStyle(useMetric == isMetric ? .white : TrackrDesign.Colors.textSecondary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(useMetric == isMetric ? TrackrDesign.Colors.accent : Color.clear)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(3)
            .background(RoundedRectangle(cornerRadius: 10).fill(TrackrDesign.Colors.surfaceHigh))
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Pro Feature Row
struct ProFeatureRow: View {
    let icon: String
    let title: String
    let desc: String

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(hex: "F59E0B").opacity(0.12))
                    .frame(width: 34, height: 34)
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color(hex: "F59E0B").opacity(0.7))
            }

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(TrackrDesign.Font.body(15))
                    .foregroundStyle(TrackrDesign.Colors.textSecondary)
                Text(desc)
                    .font(TrackrDesign.Font.body(12))
                    .foregroundStyle(TrackrDesign.Colors.textTertiary)
            }

            Spacer()

            HStack(spacing: 4) {
                Image(systemName: "crown.fill")
                    .font(.system(size: 9, weight: .bold))
                Text("PRO")
                    .font(TrackrDesign.Font.body(9, weight: .bold))
            }
            .foregroundStyle(Color(hex: "F59E0B"))
            .padding(.horizontal, 7)
            .padding(.vertical, 4)
            .background(Capsule().fill(Color(hex: "F59E0B").opacity(0.15)))
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Pro Banner
struct ProBannerCell: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(LinearGradient(
                            colors: [Color(hex: "F59E0B"), Color(hex: "EF4444")],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ))
                        .frame(width: 48, height: 48)
                    Image(systemName: "crown.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text("Trackr Pro")
                            .font(TrackrDesign.Font.display(17))
                            .foregroundStyle(TrackrDesign.Colors.textPrimary)
                        Text("COMING SOON")
                            .font(TrackrDesign.Font.body(9, weight: .bold))
                            .foregroundStyle(Color(hex: "F59E0B"))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(Color(hex: "F59E0B").opacity(0.15)))
                    }
                    Text("Rest timer, analytics & more")
                        .font(TrackrDesign.Font.body(12))
                        .foregroundStyle(TrackrDesign.Colors.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(TrackrDesign.Colors.textTertiary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: TrackrDesign.Radius.lg)
                    .fill(TrackrDesign.Colors.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: TrackrDesign.Radius.lg)
                            .stroke(LinearGradient(
                                colors: [Color(hex: "F59E0B").opacity(0.4), Color(hex: "EF4444").opacity(0.2)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ))
                    )
            )
        }
        .buttonStyle(.plain)
        .padding(.horizontal, TrackrDesign.Spacing.md)
        .padding(.vertical, 4)
    }
}

// MARK: - Trackr Pro Sheet
struct TrackrProView: View {
    @Environment(\.dismiss) private var dismiss

    let features: [(String, String, String)] = [
        ("timer",               "Rest Timer",          "Auto-start between every set"),
        ("chart.bar.xaxis",    "Advanced Analytics",  "Volume, 1RM estimates & trends"),
        ("paintbrush.fill",    "Custom Themes",       "Personalise your app look"),
        ("square.and.arrow.up","Export Data",          "Export workouts as CSV or PDF"),
        ("icloud.fill",        "Cloud Sync",           "Back up and sync across devices"),
    ]

    var body: some View {
        ZStack {
            TrackrDesign.Colors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(
                                colors: [Color(hex: "F59E0B"), Color(hex: "EF4444")],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ))
                            .frame(width: 80, height: 80)
                        Image(systemName: "crown.fill")
                            .font(.system(size: 36, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                    .shadow(color: Color(hex: "F59E0B").opacity(0.4), radius: 20, y: 8)

                    VStack(spacing: 6) {
                        Text("Trackr Pro")
                            .font(TrackrDesign.Font.display(30))
                            .foregroundStyle(TrackrDesign.Colors.textPrimary)
                        Text("Coming soon — leave your email to be first.")
                            .font(TrackrDesign.Font.body(15))
                            .foregroundStyle(TrackrDesign.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.top, 48)
                .padding(.horizontal, TrackrDesign.Spacing.xl)

                VStack(spacing: 0) {
                    ForEach(features, id: \.0) { icon, title, desc in
                        HStack(spacing: 16) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(hex: "F59E0B").opacity(0.15))
                                    .frame(width: 44, height: 44)
                                Image(systemName: icon)
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(Color(hex: "F59E0B"))
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text(title)
                                    .font(TrackrDesign.Font.body(15, weight: .semibold))
                                    .foregroundStyle(TrackrDesign.Colors.textPrimary)
                                Text(desc)
                                    .font(TrackrDesign.Font.body(13))
                                    .foregroundStyle(TrackrDesign.Colors.textSecondary)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 14)
                        .overlay(Rectangle().fill(TrackrDesign.Colors.border).frame(height: 1), alignment: .bottom)
                    }
                }
                .padding(.horizontal, TrackrDesign.Spacing.md)
                .padding(.top, 28)

                Spacer()

                VStack(spacing: 12) {
                    Button { dismiss() } label: {
                        Text("Notify Me at Launch")
                            .font(TrackrDesign.Font.display(17))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                RoundedRectangle(cornerRadius: TrackrDesign.Radius.lg)
                                    .fill(LinearGradient(
                                        colors: [Color(hex: "F59E0B"), Color(hex: "EF4444")],
                                        startPoint: .leading, endPoint: .trailing
                                    ))
                            )
                    }
                    .buttonStyle(.plain)

                    Button("Not Now") { dismiss() }
                        .font(TrackrDesign.Font.body(15))
                        .foregroundStyle(TrackrDesign.Colors.textSecondary)
                }
                .padding(.horizontal, TrackrDesign.Spacing.md)
                .padding(.bottom, 40)
            }
        }
    }
}

// MARK: - Shared row components
struct ToggleRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 34, height: 34)
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(iconColor)
            }
            Text(title)
                .font(TrackrDesign.Font.body(15))
                .foregroundStyle(TrackrDesign.Colors.textPrimary)
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(TrackrDesign.Colors.accent)
        }
        .padding(.vertical, 4)
    }
}

struct IconRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 34, height: 34)
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(iconColor)
            }
            Text(title)
                .font(TrackrDesign.Font.body(15))
                .foregroundStyle(TrackrDesign.Colors.textPrimary)
            Spacer()
            if !value.isEmpty {
                Text(value)
                    .font(TrackrDesign.Font.body(14))
                    .foregroundStyle(TrackrDesign.Colors.textSecondary)
            }
        }
        .padding(.vertical, 4)
    }
}
