//
//  UIColor+Hex.swift
//  PhotoFeedTestApp
//
//  Created by Alexander Ermichev on 08.06.2024.
//

import UIKit

extension UIColor {

    convenience init?(hexString: String) {
        var hex = hexString

        if hex.starts(with: "#") { hex.removeFirst(1) }
        if hex.count == 3 {
            let arr = Array(hex)
            let colorHexComponentCount = 2
            hex = String(repeating: arr[0], count: colorHexComponentCount)
                + String(repeating: arr[1], count: colorHexComponentCount)
                + String(repeating: arr[2], count: colorHexComponentCount)
        }

        if hex.count == 6 { hex.append("FF") }
        guard hex.count == 8 else { return nil }

        var rgba: UInt64 = 0
        guard Scanner(string: hex).scanHexInt64(&rgba) else { return nil }

        self.init(
            red:    CGFloat((rgba >> 24) & 0xff) / 255.0,
            green:  CGFloat((rgba >> 16) & 0xff) / 255.0,
            blue:   CGFloat((rgba >> 8) & 0xff) / 255.0,
            alpha:  CGFloat(rgba & 0xff) / 255.0
        )
    }

}

