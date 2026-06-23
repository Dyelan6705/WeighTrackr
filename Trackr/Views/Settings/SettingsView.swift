//
//  SettingsView.swift
//  Trackr
//
//  Created by Dylan Choukalos on 5/30/26.
//

import SwiftUI
import StoreKit

struct SettingsView: View {
    @State private var prefs = UserPreferences.shared
    @Environment(StoreKitManager.self) private var store
    @State private var showingPro     = false
    @State private var showingPrivacy = false

    var body: some View {
        NavigationStack {
            ZStack {
                TrackrDesign.Colors.background.ignoresSafeArea()

                List {
                    // Pro banner
                    Section {
                        ProBannerCell { showingPro = true }
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets())
                    }

                    // Preferences
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

                    // Pro features teaser
                    Section {
                        ProFeatureRow(icon: "timer",      title: "Rest Timer",         desc: "Auto-start after each set")
                        ProFeatureRow(icon: "chart.bar",  title: "Advanced Analytics", desc: "Volume, trends & more")
                        ProFeatureRow(icon: "icloud",     title: "Cloud Sync",         desc: "Sync across your devices")
                    } header: {
                        sectionHeader("Trackr Pro Features")
                    }
                    .listRowBackground(TrackrDesign.Colors.surface)
                    .listRowSeparatorTint(TrackrDesign.Colors.border)

                    // About
                    Section {
                        IconRow(
                            icon: "info.circle",
                            iconColor: TrackrDesign.Colors.textTertiary,
                            title: "Version",
                            value: "1.0.0"
                        )

                        Button {
                            showingPrivacy = true
                        } label: {
                            IconRow(
                                icon: "lock.shield",
                                iconColor: TrackrDesign.Colors.textTertiary,
                                title: "Privacy Policy",
                                value: ""
                            )
                        }
                        .buttonStyle(.plain)
                    } header: {
                        sectionHeader("About")
                    }
                    .listRowBackground(TrackrDesign.Colors.surface)
                    .listRowSeparatorTint(TrackrDesign.Colors.border)

                    // Bottom spacer so last row clears the floating tab bar
                    Section {
                        Color.clear
                            .frame(height: 80)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                    }
                }
                .scrollContentBackground(.hidden)
                .background(TrackrDesign.Colors.background)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(TrackrDesign.Colors.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .sheet(isPresented: $showingPro)     { TrackrProView() }
            .sheet(isPresented: $showingPrivacy) { PrivacyPolicyView() }
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

// MARK: - Privacy Policy View
struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                TrackrDesign.Colors.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 28) {

                        // Header
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 12) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(TrackrDesign.Colors.accent.opacity(0.15))
                                        .frame(width: 48, height: 48)
                                    Image(systemName: "lock.shield.fill")
                                        .font(.system(size: 22, weight: .semibold))
                                        .foregroundStyle(TrackrDesign.Colors.accent)
                                }
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Privacy Policy")
                                        .font(TrackrDesign.Font.display(22))
                                        .foregroundStyle(TrackrDesign.Colors.textPrimary)
                                    Text("Last updated June 2025")
                                        .font(TrackrDesign.Font.body(13))
                                        .foregroundStyle(TrackrDesign.Colors.textTertiary)
                                }
                            }

                            // TL;DR badge
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(TrackrDesign.Colors.green)
                                Text("Your data never leaves your device. Ever.")
                                    .font(TrackrDesign.Font.body(14, weight: .semibold))
                                    .foregroundStyle(TrackrDesign.Colors.green)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: TrackrDesign.Radius.md)
                                    .fill(TrackrDesign.Colors.greenDim)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: TrackrDesign.Radius.md)
                                            .stroke(TrackrDesign.Colors.green.opacity(0.25))
                                    )
                            )
                        }

                        policySection(
                            icon: "iphone",
                            title: "Data Storage",
                            body: "All workout data — including your sessions, exercises, sets, reps, and templates — is stored exclusively on your device using Apple's SwiftData framework. Trackr has no servers and no database of its own."
                        )

                        policySection(
                            icon: "wifi.slash",
                            title: "No Internet Required",
                            body: "Trackr works entirely offline. The app makes no network requests and does not transmit any information over the internet."
                        )

                        policySection(
                            icon: "person.slash",
                            title: "No Accounts",
                            body: "Trackr does not require you to create an account, provide an email address, or share any personal information. You are anonymous to us by design."
                        )

                        policySection(
                            icon: "eye.slash",
                            title: "No Tracking or Analytics",
                            body: "Trackr contains no analytics SDKs, crash reporters, ad networks, or third-party trackers of any kind. We do not know how often you use the app, what exercises you log, or anything else about your activity."
                        )

                        policySection(
                            icon: "bell.slash",
                            title: "No Notifications",
                            body: "Trackr does not request notification permissions and will never send you push notifications."
                        )

                        policySection(
                            icon: "trash",
                            title: "Deleting Your Data",
                            body: "Because all data is stored locally on your device, you can permanently delete all Trackr data at any time by deleting the app from your iPhone. No data remains on any server because no data was ever sent to one."
                        )

                        policySection(
                            icon: "arrow.triangle.2.circlepath",
                            title: "Future Changes",
                            body: "If a future version of Trackr introduces optional cloud sync or account features, those features will be opt-in and this policy will be updated with clear notice before any such version is released."
                        )

                        policySection(
                            icon: "envelope",
                            title: "Contact",
                            body: "Questions about this policy? Reach us at privacy@trackrapp.com"
                        )

                        // Bottom spacer
                        Color.clear.frame(height: 20)
                    }
                    .padding(.horizontal, TrackrDesign.Spacing.md)
                    .padding(.top, TrackrDesign.Spacing.md)
                }
            }
            .navigationTitle("Privacy Policy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(TrackrDesign.Font.body(16, weight: .semibold))
                        .foregroundStyle(TrackrDesign.Colors.accent)
                }
            }
            .toolbarBackground(TrackrDesign.Colors.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }

    private func policySection(icon: String, title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(TrackrDesign.Colors.accent)
                    .frame(width: 20)
                Text(title)
                    .font(TrackrDesign.Font.display(15))
                    .foregroundStyle(TrackrDesign.Colors.textPrimary)
            }
            Text(body)
                .font(TrackrDesign.Font.body(14))
                .foregroundStyle(TrackrDesign.Colors.textSecondary)
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(TrackrDesign.Spacing.md)
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
                    Text("Trackr Pro")
                        .font(TrackrDesign.Font.display(17))
                        .foregroundStyle(TrackrDesign.Colors.textPrimary)
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

// MARK: - Trackr Pro Paywall
struct TrackrProView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(StoreKitManager.self) private var store

    @State private var selectedProductID: String = TrackrProduct.yearly
    @State private var isPurchasing = false

    private let features: [(String, String, String)] = [
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
                // Header
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
                        Text(store.isPro ? "You're Pro!" : "Trackr Pro")
                            .font(TrackrDesign.Font.display(30))
                            .foregroundStyle(TrackrDesign.Colors.textPrimary)
                        Text(store.isPro
                             ? "Thanks for supporting Trackr."
                             : "Unlock all features, forever.")
                            .font(TrackrDesign.Font.body(15))
                            .foregroundStyle(TrackrDesign.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.top, 48)
                .padding(.horizontal, TrackrDesign.Spacing.xl)

                // Feature list
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

                if store.isPro {
                    // Already subscribed
                    Button("Done") { dismiss() }
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
                        .buttonStyle(.plain)
                        .padding(.horizontal, TrackrDesign.Spacing.md)
                        .padding(.bottom, 40)
                } else {
                    // Plan picker + buy button
                    VStack(spacing: 16) {
                        // Plan selector
                        if store.isLoading {
                            ProgressView()
                                .tint(Color(hex: "F59E0B"))
                                .frame(height: 88)
                        } else {
                            HStack(spacing: 12) {
                                planCard(
                                    product: store.yearlyProduct,
                                    label: "Yearly",
                                    badge: "BEST VALUE",
                                    id: TrackrProduct.yearly
                                )
                                planCard(
                                    product: store.lifetimeProduct,
                                    label: "Lifetime",
                                    badge: nil,
                                    id: TrackrProduct.lifetime
                                )
                            }
                        }

                        // Error
                        if let error = store.purchaseError {
                            Text(error)
                                .font(TrackrDesign.Font.body(13))
                                .foregroundStyle(TrackrDesign.Colors.red)
                                .multilineTextAlignment(.center)
                        }

                        // CTA
                        Button {
                            Task { await buySelected() }
                        } label: {
                            Group {
                                if isPurchasing {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text(ctaLabel)
                                        .font(TrackrDesign.Font.display(17))
                                        .foregroundStyle(.white)
                                }
                            }
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
                        .disabled(isPurchasing || store.isLoading)

                        // Legal links
                        HStack(spacing: 4) {
                            Link("Privacy Policy",
                                 destination: URL(string: "https://gist.githubusercontent.com/Dyelan6705/8ede506a7cc2d4a88f2a40271ca3271d/raw/privacy-policy.md")!)
                            Text("·")
                            Link("Terms of Use",
                                 destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                        }
                        .font(TrackrDesign.Font.body(11))
                        .foregroundStyle(TrackrDesign.Colors.textTertiary)

                        HStack(spacing: 16) {
                            Button("Restore") {
                                Task {
                                    isPurchasing = true
                                    await store.restore()
                                    isPurchasing = false
                                    if store.isPro { dismiss() }
                                }
                            }
                            .font(TrackrDesign.Font.body(13))
                            .foregroundStyle(TrackrDesign.Colors.textTertiary)

                            Button("Not Now") { dismiss() }
                                .font(TrackrDesign.Font.body(13))
                                .foregroundStyle(TrackrDesign.Colors.textTertiary)
                        }
                    }
                    .padding(.horizontal, TrackrDesign.Spacing.md)
                    .padding(.bottom, 40)
                }
            }
        }
        .task { await store.loadProducts() }
    }

    // MARK: - Helpers

    private var ctaLabel: String {
        let product = selectedProductID == TrackrProduct.lifetime
            ? store.lifetimeProduct
            : store.yearlyProduct
        if let p = product {
            return "Get \(p.displayName) — \(p.displayPrice)"
        }
        return "Continue"
    }

    private func buySelected() async {
        guard let product = selectedProductID == TrackrProduct.lifetime
                ? store.lifetimeProduct
                : store.yearlyProduct
        else { return }
        isPurchasing = true
        await store.purchase(product)
        isPurchasing = false
        if store.isPro { dismiss() }
    }

    @ViewBuilder
    private func planCard(product: Product?, label: String, badge: String?, id: String) -> some View {
        let selected = selectedProductID == id
        Button { selectedProductID = id } label: {
            VStack(spacing: 6) {
                if let badge {
                    Text(badge)
                        .font(TrackrDesign.Font.body(9, weight: .bold))
                        .foregroundStyle(Color(hex: "F59E0B"))
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(Color(hex: "F59E0B").opacity(0.15)))
                } else {
                    Spacer().frame(height: 20)
                }
                Text(label)
                    .font(TrackrDesign.Font.body(14, weight: .semibold))
                    .foregroundStyle(TrackrDesign.Colors.textPrimary)
                if let p = product {
                    Text(p.displayPrice)
                        .font(TrackrDesign.Font.display(22))
                        .foregroundStyle(TrackrDesign.Colors.textPrimary)
                    Text(id == TrackrProduct.yearly ? "/ year" : "one-time")
                        .font(TrackrDesign.Font.body(12))
                        .foregroundStyle(TrackrDesign.Colors.textSecondary)
                } else {
                    ProgressView().tint(Color(hex: "F59E0B"))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: TrackrDesign.Radius.md)
                    .fill(selected
                          ? Color(hex: "F59E0B").opacity(0.12)
                          : TrackrDesign.Colors.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: TrackrDesign.Radius.md)
                            .stroke(selected
                                    ? Color(hex: "F59E0B").opacity(0.6)
                                    : TrackrDesign.Colors.border,
                                    lineWidth: selected ? 1.5 : 1)
                    )
            )
        }
        .buttonStyle(.plain)
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
