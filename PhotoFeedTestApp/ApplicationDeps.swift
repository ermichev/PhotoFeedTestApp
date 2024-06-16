//
//  ApplicationDeps.swift
//  PhotoFeedTestApp
//
//  Created by Alexander Ermichev on 09.06.2024.
//

import Combine
import SDWebImage
import SwiftUI

final class ApplicationDeps:
    FeedCollectionViewControllerDeps
{
    lazy var photosFeedService: PhotosFeedService = PhotosFeedServiceMock()
    lazy var photoLoadingService: PhotoLoadingService = SDWebImageManager.shared
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
