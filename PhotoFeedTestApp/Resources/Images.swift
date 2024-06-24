//
//  Images.swift
//  PhotoFeedTestApp
//
//  Created by Alexander Ermichev on 24.06.2024.
//

import SwiftUI
import UIKit

enum Images {
    static let roundedCorner = ImageHolder(named: "rounded_corner")
    static let retry = ImageHolder(system: "arrow.clockwise")
    static let close = ImageHolder(system: "xmark.circle.fill")
    static let openExternal = ImageHolder(system: "arrow.up.forward.app")
}

// -

struct ImageHolder {
    let uiImage: UIImage
    let image: Image

    init(_ image: UIImage) {
        self.uiImage = image
        self.image = Image(uiImage: image)
    }

    init(named name: String) {
        self.uiImage = UIImage(named: name)!
        self.image = Image(uiImage: uiImage)
    }

    init(system name: String) {
        self.uiImage = UIImage(systemName: name)!
        self.image = Image(systemName: name)
    }
}
