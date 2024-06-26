//
//  CustomizablePhotoService.swift
//  PhotoFeedTestApp
//
//  Created by Alexander Ermichev on 26.06.2024.
//

import Combine
import SDWebImage
import UIKit

final class CustomizablePhotoService: PhotoLoadingService {

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

    func loadPhoto(_ model: PhotoModel, size: PhotoSize) -> AnyPublisher<UIImage, Error> {
        currentImpl.loadPhoto(model, size: size)
    }

    private var currentSettings: AppSettingsModel
    private var currentImpl: PhotoLoadingService

    private var bag = Set<AnyCancellable>()

}

private extension CustomizablePhotoService {

    private static func makeService(for settings: AppSettingsModel) -> PhotoLoadingService {
        if settings.mockServiceEnabled {
            PhotoLoadingServiceMock(failHalfRequests: settings.mockServiceFailHalfRequests)
        } else {
            SDWebImageManager.shared
        }
    }

}
