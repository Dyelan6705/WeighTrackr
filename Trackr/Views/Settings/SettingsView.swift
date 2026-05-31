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
                    // Pro banner
                    Section {
                        ProBannerCell {
                            showingPro = true
                        }
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets())
                    }
                    
                    // Units
                    Section("Preferences") {
                        ToggleRow(
                            icon: "scalemass.fill",
                            iconColor: TrackrDesign.Colors.blue,
                            title: "Use Metric (kg)",
                            isOn: $prefs.useMetric
                        )
                        
                        NavigationLink {
                            RestTimerSettingsView()
                        } label: {
                            IconRow(
                                icon: "timer",
                                iconColor: TrackrDesign.Colors.orange,
                                title: "Default Rest Time",
                                value: "\(prefs.defaultRestSeconds)s"
                            )
                        }
                        
                        ToggleRow(
                            icon: "waveform",
                            iconColor: TrackrDesign.Colors.green,
                            title: "Haptic Feedback",
                            isOn: $prefs.hapticEnabled
                        )
                    }
                    .listRowBackground(TrackrDesign.Colors.surface)
                    .listRowSeparatorTint(TrackrDesign.Colors.border)
                    
                    // About
                    Section("About") {
                        IconRow(icon: "info.circle", iconColor: TrackrDesign.Colors.textTertiary, title: "Version", value: "1.0.0")
                        
                        Link(destination: URL(string: "https://trackrapp.com/privacy")!) {
                            IconRow(icon: "lock.shield", iconColor: TrackrDesign.Colors.textTertiary, title: "Privacy Policy", value: "")
                        }
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
}

// MARK: - Pro Banner
struct ProBannerCell: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "F59E0B"), Color(hex: "EF4444")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
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
                            .background(
                                Capsule().fill(Color(hex: "F59E0B").opacity(0.15))
                            )
                    }
                    
                    Text("Advanced analytics, custom themes & more")
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
                            .stroke(
                                LinearGradient(
                                    colors: [Color(hex: "F59E0B").opacity(0.4), Color(hex: "EF4444").opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
            )
        }
        .buttonStyle(.plain)
        .padding(.horizontal, TrackrDesign.Spacing.md)
        .padding(.vertical, 4)
    }
}

// MARK: - Trackr Pro Placeholder
struct TrackrProView: View {
    @Environment(\.dismiss) private var dismiss
    
    let features = [
        ("chart.bar.xaxis", "Advanced Analytics", "Deeper insights into your training"),
        ("paintbrush.fill", "Custom Themes", "Personalize your experience"),
        ("square.and.arrow.up", "Export Data", "Export workouts as CSV or PDF"),
        ("icloud.fill", "Cloud Sync", "Sync across all your devices"),
        ("applewatch", "Apple Watch", "Track workouts from your wrist"),
    ]
    
    var body: some View {
        ZStack {
            TrackrDesign.Colors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "F59E0B"), Color(hex: "EF4444")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "crown.fill")
                            .font(.system(size: 36, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                    .shadow(color: Color(hex: "F59E0B").opacity(0.4), radius: 20, y: 8)
                    
                    VStack(spacing: 8) {
                        Text("Trackr Pro")
                            .font(TrackrDesign.Font.display(32))
                            .foregroundStyle(TrackrDesign.Colors.textPrimary)
                        Text("Coming soon. Get notified when it launches.")
                            .font(TrackrDesign.Font.body(15))
                            .foregroundStyle(TrackrDesign.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.top, 48)
                .padding(.horizontal, TrackrDesign.Spacing.xl)
                
                // Features list
                VStack(alignment: .leading, spacing: 0) {
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
                        .overlay(
                            Rectangle()
                                .fill(TrackrDesign.Colors.border)
                                .frame(height: 1),
                            alignment: .bottom
                        )
                    }
                }
                .padding(.horizontal, TrackrDesign.Spacing.md)
                .padding(.top, 32)
                
                Spacer()
                
                // CTA
                VStack(spacing: 12) {
                    Button {
                        // Future: notify me
                        dismiss()
                    } label: {
                        Text("Notify Me at Launch")
                            .font(TrackrDesign.Font.display(17))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                RoundedRectangle(cornerRadius: TrackrDesign.Radius.lg)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(hex: "F59E0B"), Color(hex: "EF4444")],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
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

// MARK: - Settings Row Components
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

// MARK: - Rest Timer Settings
struct RestTimerSettingsView: View {
    @State private var prefs = UserPreferences.shared
    
    let options = [30, 45, 60, 90, 120, 180, 240, 300]
    
    var body: some View {
        ZStack {
            TrackrDesign.Colors.background.ignoresSafeArea()
            
            List(options, id: \.self) { seconds in
                Button {
                    prefs.defaultRestSeconds = seconds
                } label: {
                    HStack {
                        Text(formatSeconds(seconds))
                            .font(TrackrDesign.Font.body(15))
                            .foregroundStyle(TrackrDesign.Colors.textPrimary)
                        Spacer()
                        if prefs.defaultRestSeconds == seconds {
                            Image(systemName: "checkmark")
                                .foregroundStyle(TrackrDesign.Colors.accent)
                                .font(.system(size: 14, weight: .semibold))
                        }
                    }
                }
                .listRowBackground(TrackrDesign.Colors.surface)
                .listRowSeparatorTint(TrackrDesign.Colors.border)
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Default Rest Time")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(TrackrDesign.Colors.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
    
    private func formatSeconds(_ s: Int) -> String {
        if s < 60 { return "\(s) seconds" }
        let m = s / 60
        let remaining = s % 60
        if remaining == 0 { return "\(m) minute\(m == 1 ? "" : "s")" }
        return "\(m):\(String(format: "%02d", remaining))"
    }
}
