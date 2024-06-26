//
//  CloseButtonView.swift
//  PhotoFeedTestApp
//
//  Created by Alexander Ermichev on 26.06.2024.
//

import SwiftUI

struct CloseButtonView: View {

    let onTap: () -> Void

    var body: some View {
        Button(
            action: onTap,
            label: { Images.close.image.resizable() }
        )
        .foregroundStyle(Colors.label.tertiary.color)
        .frame(width: 24.0, height: 24.0)
        .padding(16.0)
    }

}
