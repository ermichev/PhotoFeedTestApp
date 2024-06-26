//
//  PhotoFeedTestAppApp.swift
//  PhotoFeedTestApp
//
//  Created by Alexander Ermichev on 08.06.2024.
//

import SwiftUI

@main
struct PhotoFeedTestApp: App {

    var body: some Scene {
        WindowGroup {
            RootView()
                .ignoresSafeArea(edges: .vertical)
                .overlay(alignment: .top) {
                    Color.clear
                        .background(.regularMaterial)
                        .ignoresSafeArea(edges: .top)
                        .frame(height: 0.0)
                }
                .environmentObject(deps.appSettingsProvider.appSettings)
        }
    }

    @Environment(\.applicationDeps) private var deps

}
