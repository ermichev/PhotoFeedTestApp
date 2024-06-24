//
//  PhotoDetailsInteractor.swift
//  PhotoFeedTestApp
//
//  Created by Alexander Ermichev on 24.06.2024.
//

import Combine
import UIKit

enum PhotoDetailsImageState: Equatable {
    case loading
    case lowResImage(UIImage)
    case hiResImage(UIImage)
    case error(lowResImage: UIImage?)
}

protocol PhotoDetailsInteractorDeps {
    var photoLoadingService: PhotoLoadingService { get }
    var safariViewControllerRouter: SafariViewControllerRouter { get }
}

final class PhotoDetailsInteractor {

    typealias Deps = PhotoDetailsInteractorDeps

    let imageAvgColor: UIColor
    let imageSize: (width: Int, height: Int)
    let author: String

    var imageState: AnyPublisher<PhotoDetailsImageState, Never> {
        imageStateImpl.distinctValues()
    }

    var onClose: (() -> Void)?

    init?(photoModel: PhotoModel, loadedLowRes: UIImage?, deps: Deps) {
        self.deps = deps

        guard let originalImageUrl = photoModel.imageUrls[.original] else { return nil }

        imageAvgColor = photoModel.averageColor
        imageSize = photoModel.size

        author = photoModel.photographer.name
        authorUrl = photoModel.photographer.url
        fullImageUrl = originalImageUrl

        imageStateImpl = if let loadedLowRes {
            .init(.lowResImage(loadedLowRes))
        } else {
            .init(.loading)
        }

        deps.photoLoadingService.loadPhoto(photoModel, size: .large2x)
            .map { PhotoDetailsImageState.hiResImage($0) }
            .catch { [loadedLowRes] _ in Just(PhotoDetailsImageState.error(lowResImage: loadedLowRes)) }
            .subscribe(imageStateImpl)
            .store(in: &bag)
    }

    func handleGetFullImage() {

    }

    func handleShowAuthorPage() {
        deps.safariViewControllerRouter.openUrl(authorUrl)
    }

    func handleCloseScreen() {
        onClose?()
    }

    private let authorUrl: URL
    private let fullImageUrl: URL

    private let deps: Deps

    private let imageStateImpl: CurrentValueSubject<PhotoDetailsImageState, Never>
    private var bag = Set<AnyCancellable>()

}
