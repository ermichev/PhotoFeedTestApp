//
//  Colors.swift
//  PhotoFeedTestApp
//
//  Created by Alexander Ermichev on 24.06.2024.
//

import SwiftUI
import UIKit

enum Colors {

    enum bg {
        static let primary = ColorHolder(.secondarySystemBackground)
        static let secondary = ColorHolder(
            light: .systemBackground,
            dark: .tertiarySystemBackground
        )
    }

    enum fill {
        static let primary = ColorHolder(.systemFill)
        static let secondary = ColorHolder(.secondarySystemFill)
    }

    static let error = ColorHolder(.systemRed)
    static let shadow = ColorHolder(light: .separator, dark: .black)

    enum label {
        static let primary = ColorHolder(.label)
        static let secondary = ColorHolder(.secondaryLabel)
        static let tertiary = ColorHolder(.tertiaryLabel)
    }

}

// -

struct ColorHolder {
    let uiColor: UIColor
    let color: Color

    init(_ color: UIColor) {
        self.uiColor = color
        self.color = Color(uiColor: color)
    }

    init(light: UIColor, dark: UIColor) {
        self.init(UIColor { $0.userInterfaceStyle == .dark ? dark : light })
    }
}
