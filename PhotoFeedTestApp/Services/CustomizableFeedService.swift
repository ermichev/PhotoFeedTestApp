//
//  CustomizableFeedService.swift
//  PhotoFeedTestApp
//
//  Created by Alexander Ermichev on 26.06.2024.
//

import Combine

final class CustomizableFeedService: PhotosFeedService {

    init(settings: ObservableAppSettings) {
        self.currentSettings = settings.settings
        self.currentImpl = Self.makeService(for: currentSettings)

        settings.$settings
            .dropFirst()
            .sink { [weak self] newValue in
                self?.currentSettings = newValue
                self?.currentImpl = Self.makeService(for: newValue)
            }
            .store(in: &bag)
    }

    func feedSession(pageSize: Int) -> PhotosFeedSession {
        currentImpl.feedSession(pageSize: pageSize)
    }

    private var currentSettings: AppSettingsModel
    private var currentImpl: PhotosFeedService

    private var bag = Set<AnyCancellable>()

}

private extension CustomizableFeedService {

    private static func makeService(for settings: AppSettingsModel) -> PhotosFeedService {
        if settings.mockServiceEnabled {
            PhotosFeedServiceMock(failHalfRequests: settings.mockServiceFailHalfRequests)
        } else {
            PhotosFeedServiceImpl(apiKey: settings.apiKey)
        }
    }

}
