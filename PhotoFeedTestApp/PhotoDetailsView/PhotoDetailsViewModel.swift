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

    @Published var imageState: PhotoDetailsImageState = .loading

    init(interactor: PhotoDetailsInteractor) {
        self.interactor = interactor
        
        imageAvgColor = interactor.imageAvgColor
        imageAspectRatio = CGFloat(interactor.imageSize.width) / CGFloat(interactor.imageSize.height)
        author = interactor.author

        interactor.imageState
            .receive(on: RunLoop.main)
            .assign(to: &$imageState)
    }

    func onCloseTap() {
        interactor.handleCloseScreen()
    }

    func onAuthorPageTap() {
        interactor.handleShowAuthorPage()
    }

    private let interactor: PhotoDetailsInteractor

}
