//
//  AppSettingsHolder.swift
//  PhotoFeedTestApp
//
//  Created by Alexander Ermichev on 26.06.2024.
//

import Combine
import Foundation

final class ObservableAppSettings: ObservableObject {
    @Published var settings: AppSettingsModel

    init(_ settings: AppSettingsModel) {
        self.settings = settings
    }
}

protocol AppSettingsProvider {
    var appSettings: ObservableAppSettings { get }
}

protocol AppSettingsHolder {
    func setAppSettings(_ appSettings: AppSettingsModel)
}

// -

final class AppSettingsHolderImpl: AppSettingsProvider, AppSettingsHolder {

    // MARK: - Public properties

    let appSettings: ObservableAppSettings

    // MARK: - Constructors

    init() {
        let apiKey = ProcessInfo.processInfo.environment["API_KEY"] ?? ""
        self.appSettings = .init(
            AppSettingsModel(
                apiKey: apiKey,
                pageSize: 20,
                mockServiceEnabled: apiKey.isEmpty,
                mockServiceFailHalfRequests: false
            )
        )
    }

    // MARK: - Public methods

    func setAppSettings(_ newValue: AppSettingsModel) {
        guard appSettings.settings != newValue else { return }
        appSettings.settings = newValue
    }

}
