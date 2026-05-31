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
    
    var defaultRestSeconds: Int {
        didSet { UserDefaults.standard.set(defaultRestSeconds, forKey: "defaultRestSeconds") }
    }
    
    var hapticEnabled: Bool {
        didSet { UserDefaults.standard.set(hapticEnabled, forKey: "hapticEnabled") }
    }
    
    private init() {
        self.useMetric = UserDefaults.standard.object(forKey: "useMetric") as? Bool ?? true
        self.defaultRestSeconds = UserDefaults.standard.object(forKey: "defaultRestSeconds") as? Int ?? 90
        self.hapticEnabled = UserDefaults.standard.object(forKey: "hapticEnabled") as? Bool ?? true
    }
    
    func formattedWeight(_ kg: Double) -> String {
        if useMetric {
            let val = kg.truncatingRemainder(dividingBy: 1) == 0
                ? String(format: "%.0f", kg)
                : String(format: "%.1f", kg)
            return "\(val) kg"
        } else {
            let lbs = kg * 2.20462
            let val = lbs.truncatingRemainder(dividingBy: 1) == 0
                ? String(format: "%.0f", lbs)
                : String(format: "%.1f", lbs)
            return "\(val) lbs"
        }
    }
    
    var weightUnit: String { useMetric ? "kg" : "lbs" }
}
