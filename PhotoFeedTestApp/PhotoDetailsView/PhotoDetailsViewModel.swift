//
//  PhotoDetailsViewModel.swift
//  PhotoFeedTestApp
//
//  Created by Alexander Ermichev on 24.06.2024.
//

import SwiftUI

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

    func onAuthorPageTap() {
        interactor.handleShowAuthorPage()
    }

    private let interactor: PhotoDetailsInteractor

}
