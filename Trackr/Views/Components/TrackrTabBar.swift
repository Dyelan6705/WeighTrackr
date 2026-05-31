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
                TabBarButton(
                    tab: tab,
                    isSelected: selectedTab == tab
                ) {
                    withAnimation(TrackrDesign.Animation.snappy) {
                        selectedTab = tab
                    }
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 12)
        .padding(.bottom, 4)
        .background(
            ZStack {
                // Blur background
                RoundedRectangle(cornerRadius: TrackrDesign.Radius.xl)
                    .fill(TrackrDesign.Colors.surface.opacity(0.95))
                
                // Border
                RoundedRectangle(cornerRadius: TrackrDesign.Radius.xl)
                    .stroke(TrackrDesign.Colors.borderMedium, lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.4), radius: 20, y: 8)
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
    }
}

struct TabBarButton: View {
    let tab: Tab
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: tab.rawValue)
                    .font(.system(size: isSelected ? 22 : 20, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? TrackrDesign.Colors.accent : TrackrDesign.Colors.textTertiary)
                    .scaleEffect(isSelected ? 1.0 : 0.9)
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
