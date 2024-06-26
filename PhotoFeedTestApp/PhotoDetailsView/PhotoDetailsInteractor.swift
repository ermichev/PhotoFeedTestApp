//
//  PhotoDetailsInteractor.swift
//  PhotoFeedTestApp
//
//  Created by Alexander Ermichev on 24.06.2024.
//

import Combine
import UIKit

protocol SharingScreenRouter {
    func shareImage(_ image: UIImage, sourceRect: CGRect)
}

protocol PhotoDetailsInteractorDeps {
    var photoLoadingService: PhotoLoadingService { get }
    var safariViewControllerRouter: SafariViewControllerRouter { get }
    var sharingScreenRouter: SharingScreenRouter { get }
}

final class PhotoDetailsInteractorImpl: PhotoDetailsInteractor, SheetStateProvider {

    // MARK: - Public nested types

    typealias Deps = PhotoDetailsInteractorDeps

    // MARK: - Public properties

    var imageAvgColor: UIColor { model.averageColor }
    var imageSize: (width: Int, height: Int) { model.size }
    var author: String { model.photographer.name }
    var altText: String { model.altText }

    var imageState: AnyPublisher<PhotoDetailsImageState, Never> {
        imageStateImpl.distinctValues()
    }

    var downloadState: AnyPublisher<PhotoDetailsDownloadState, Never> {
        downloadStateImpl.distinctValues()
    }

    var delegate: PhotoDetailsInteractorDelegate?

    // MARK: - Constructors

    init(photoModel: PhotoModel, deps: Deps) {
        self.model = photoModel
        self.deps = deps

        downloadStateImpl = .init(.idle)
        imageStateImpl = .init(.loading)

        retryLoadingHiRes()
    }

    // MARK: - Public methods

    func retryLoadingHiRes() {
        imageStateImpl.send(.loading)

        deps.photoLoadingService.loadPhoto(model, size: .large2x)
            .map { PhotoDetailsImageState.hiResImage($0) }
            .catch { _ in Just(PhotoDetailsImageState.error) }
            .sink { [weak self] in self?.imageStateImpl.send($0) }
            .store(in: &bag)
    }

    func handleGetFullImage(viewRect: CGRect) {
        downloadStateImpl.send(.loading)
        deps.photoLoadingService.loadPhoto(model, size: .original)
            .sink(
                receiveCompletion: { [weak self] in
                    switch $0 {
                    case .failure:
                        self?.downloadStateImpl.send(.error)
                    case .finished:
                        break
                    }
                }, 
                receiveValue: { [weak self] in
                    self?.downloadStateImpl.send(.idle)
                    self?.deps.sharingScreenRouter.shareImage($0, sourceRect: viewRect)
                }
            )
            .store(in: &bag)
    }

    func handleShowAuthorPage() {
        deps.safariViewControllerRouter.openUrl(model.photographer.url)
    }

    func onClose() {
        Logger.log.debug("PhotoDetailsInteractorImpl.onClose")
        delegate?.photoDetailsInteractorWillDismiss(self)
    }

    // MARK: - Private properties

    private let model: PhotoModel
    private let deps: Deps

    private let imageStateImpl: CurrentValueSubject<PhotoDetailsImageState, Never>
    private let downloadStateImpl: CurrentValueSubject<PhotoDetailsDownloadState, Never>
    private var bag = Set<AnyCancellable>()

}
