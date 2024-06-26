//
//  FeedCollectionView.swift
//  PhotoFeedTestApp
//
//  Created by Alexander Ermichev on 08.06.2024.
//

import SwiftUI

struct FeedCollectionView: UIViewControllerRepresentable {

    @Environment(\.applicationDeps) var deps

    @Binding @EquatableStore var presentedPhotoDetails: PhotoDetailsInteractorImpl?
    @Binding @EquatableStore var presentedSettings: AppSettingsViewModel?

    func makeCoordinator() -> FeedCollectionViewCoordinator {
        FeedCollectionViewCoordinator(self)
    }

    func makeUIViewController(context: Context) -> FeedCollectionViewController {
        let viewController = FeedCollectionViewController(deps: deps)
        viewController.router = context.coordinator
        context.coordinator.viewController = viewController
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: FeedCollectionViewController, context: Context) {
        context.coordinator.viewController = uiViewController
    }

}
