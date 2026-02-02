//
//  TrackerData.swift
//  Tracker
//
//  Created by Воробьева Юлия on 26.01.2026.
//

import UIKit

struct TrackerData {
    static let emojis = [
        "🙂", "😻", "🌺", "🐶", "❤️", "😱",
        "😇", "😡", "🥶", "🤔", "🙌", "🍔",
        "🥦", "🏓", "🥇", "🎸", "🏝️", "😪"
    ]
    
    static let colors: [UIColor] = {
        var colors: [UIColor] = []
        for i in 1...18 {
            if let color = UIColor(named: "ColorSelection\(i)") {
                colors.append(color)
            }
        }
        return colors
    }()
    
    static func getColorName(for color: UIColor) -> String? {
        for (index, storedColor) in colors.enumerated() {
            if storedColor == color {
                return "ColorSelection\(index + 1)"
            }
        }
        return nil
    }
}
