//
//  UserPreferences.swift
//  Trackr
//
//  Created by Dylan Choukalos on 5/30/26.
//

import Foundation
import SwiftUI

@Observable
final class UserPreferences {
    static let shared = UserPreferences()

    var useMetric: Bool {
        didSet { UserDefaults.standard.set(useMetric, forKey: "useMetric") }
    }

    var hapticEnabled: Bool {
        didSet { UserDefaults.standard.set(hapticEnabled, forKey: "hapticEnabled") }
    }

    static let freeTemplateLimit = 3
    static let freeExerciseLimit = 10

    private init() {
        self.useMetric     = UserDefaults.standard.object(forKey: "useMetric")     as? Bool ?? true
        self.hapticEnabled = UserDefaults.standard.object(forKey: "hapticEnabled") as? Bool ?? true
    }

    func displayWeight(_ kg: Double) -> Double {
        useMetric ? kg : kg * 2.20462
    }

    func storageWeight(_ display: Double) -> Double {
        useMetric ? display : display / 2.20462
    }

    func formatWeight(_ kg: Double) -> String {
        let val = displayWeight(kg)
        let s = val.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", val)
            : String(format: "%.1f", val)
        return "\(s) \(weightUnit)"
    }

    var weightUnit: String { useMetric ? "kg" : "lbs" }
}
