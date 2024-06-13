//
//  ApplicationDeps.swift
//  PhotoFeedTestApp
//
//  Created by Alexander Ermichev on 09.06.2024.
//

import Combine
import SwiftUI

final class ApplicationDeps:
    FeedCollectionViewControllerDeps
{
    lazy var photosFeedService: PhotosFeedService = PhotosFeedServiceMock()
    lazy var photoLoadingService: PhotoLoadingService = SimplePhotoLoadingService()
}

// -

struct ApplicationDepsEnvironmentKey: EnvironmentKey {
    static var defaultValue: ApplicationDeps = ApplicationDeps()
}

extension EnvironmentValues {
    var applicationDeps: ApplicationDeps {
        get { self[ApplicationDepsEnvironmentKey.self] }
        set { self[ApplicationDepsEnvironmentKey.self] = newValue }
    }
}

// -

private class SimplePhotoLoadingService: PhotoLoadingService {
    
    func loadPhoto(_ model: PhotoModel, size: PhotoSize) -> AnyPublisher<UIImage, Error> {
        guard let url = model.imageUrls[size] else { return Empty<UIImage, Error>().eraseToAnyPublisher() }
        return URLSession.shared.dataTaskPublisher(for: url)
            .compactMap { UIImage(data: $0.data) }
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }

}
