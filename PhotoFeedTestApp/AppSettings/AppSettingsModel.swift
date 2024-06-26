//
//  AppSettingsModel.swift
//  PhotoFeedTestApp
//
//  Created by Alexander Ermichev on 26.06.2024.
//

import SwiftUI

struct AppSettingsModel: Equatable {
    var apiKey: String
    var pageSize: Int
    var mockServiceEnabled: Bool
    var mockServiceFailHalfRequests: Bool
}

struct AppSettingsEnvironmentKey: EnvironmentKey {
    static var defaultValue: AppSettingsModel = {
        let apiKey = ProcessInfo.processInfo.environment["API_KEY"] ?? ""
        return AppSettingsModel(
            apiKey: apiKey,
            pageSize: 20,
            mockServiceEnabled: apiKey.isEmpty,
            mockServiceFailHalfRequests: false
        )
    }()
}

extension EnvironmentValues {
    var appSettings: AppSettingsModel {
        get { self[AppSettingsEnvironmentKey.self] }
        set { self[AppSettingsEnvironmentKey.self] = newValue }
    }
}
