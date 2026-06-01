//
//  TrackrTabBar.swift
//  Trackr
//
//  Created by Dylan Choukalos on 5/30/26.
//

import SwiftUI

struct TrackrTabBar: View {
    @Binding var selectedTab: Tab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.self) { tab in
                TabBarButton(tab: tab, isSelected: selectedTab == tab) {
                    withAnimation(TrackrDesign.Animation.snappy) {
                        selectedTab = tab
                    }
                    if UserPreferences.shared.hapticEnabled {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }
                }
            }
        }
        .padding(.top, 12)
        .padding(.bottom, 10)
        .padding(.horizontal, 8)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 28)
                    .fill(TrackrDesign.Colors.surfaceElevated)
                RoundedRectangle(cornerRadius: 28)
                    .stroke(TrackrDesign.Colors.borderMedium, lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.4), radius: 28, y: 8)
        )
        .padding(.horizontal, 22)
        .padding(.bottom, 28)  // clears the home indicator on all devices
    }
}

private struct TabBarButton: View {
    let tab: Tab
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: tab.rawValue)
                    .font(.system(size: 20, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? TrackrDesign.Colors.accent : TrackrDesign.Colors.textTertiary)
                    .scaleEffect(isSelected ? 1.0 : 0.92)
                    .animation(TrackrDesign.Animation.snappy, value: isSelected)

                Text(tab.label)
                    .font(TrackrDesign.Font.body(10, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? TrackrDesign.Colors.accent : TrackrDesign.Colors.textTertiary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}
