//
//  PhotoDetailsViewModel.swift
//  PhotoFeedTestApp
//
//  Created by Alexander Ermichev on 24.06.2024.
//

import Combine
import SwiftUI

enum PhotoDetailsImageState: Equatable {
    case loading
    case lowResImage(UIImage)
    case hiResImage(UIImage)
    case error(lowResImage: UIImage?)
}

enum PhotoDetailsDownloadState: Equatable {
    case idle
    case loading
    case error
}

protocol PhotoDetailsInteractor: AnyObject {
    var imageAvgColor: UIColor { get }
    var imageSize: (width: Int, height: Int) { get }
    var author: String { get }
    var altText: String { get }

    var imageState: AnyPublisher<PhotoDetailsImageState, Never> { get }
    var downloadState: AnyPublisher<PhotoDetailsDownloadState, Never> { get }

    func handleGetFullImage()
    func handleShowAuthorPage()
    func handleCloseScreen()
}

// -

final class PhotoDetailsViewModel: ObservableObject {

    let imageAvgColor: UIColor
    let imageAspectRatio: CGFloat
    let author: String
    let altText: String

    @Published var imageState: PhotoDetailsImageState = .loading
    @Published var downloadState: PhotoDetailsDownloadState = .idle

    init(interactor: PhotoDetailsInteractor) {
        self.interactor = interactor
        
        imageAvgColor = interactor.imageAvgColor
        imageAspectRatio = CGFloat(interactor.imageSize.width) / CGFloat(interactor.imageSize.height)
        author = interactor.author
        altText = interactor.altText

        interactor.imageState
            .receive(on: RunLoop.main)
            .assign(to: &$imageState)

        interactor.downloadState
            .receive(on: RunLoop.main)
            .assign(to: &$downloadState)
    }

    func onCloseTap() {
        interactor.handleCloseScreen()
    }

    func onAuthorPageTap() {
        interactor.handleShowAuthorPage()
    }

    func onDownloadFullTap() {
        guard downloadState != .loading else { return }
        interactor.handleGetFullImage()
    }

    private let interactor: PhotoDetailsInteractor

}
