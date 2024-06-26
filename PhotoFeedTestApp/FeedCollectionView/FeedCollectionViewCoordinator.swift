//
//  FeedCollectionViewCoordinator.swift
//  PhotoFeedTestApp
//
//  Created by Alexander Ermichev on 26.06.2024.
//

import UIKit

class FeedCollectionViewCoordinator: NSObject, FeedScreenRouter {

    var parent: FeedCollectionView
    weak var viewController: UIViewController?

    init(_ parent: FeedCollectionView) {
        self.parent = parent
    }

    func showDetails(for model: PhotoModel, loadedPreview: UIImage?) {
        let interactor = PhotoDetailsInteractorImpl(
            photoModel: model,
            loadedLowRes: loadedPreview,
            deps: parent.deps
        )
        interactor.delegate = self
        // Present sheet
        parent.presentedPhotoDetails = interactor
    }

    func showAppSettings() {
        let settings = parent.deps.appSettingsProvider.appSettings.settings
        let viewModel = AppSettingsViewModel(settings: settings)
        viewModel.delegate = self
        // Present sheet
        parent.presentedSettings = viewModel
    }

}

extension FeedCollectionViewCoordinator: PhotoDetailsInteractorDelegate {
    
    func photoDetailsInteractorWillDismiss(_ interactor: PhotoDetailsInteractor) {
        // Dismiss sheet
        parent.presentedPhotoDetails = nil
    }

}

extension FeedCollectionViewCoordinator: AppSettingsViewModelDelegate {
    
    func appSettingsViewModelWillDismiss(_ viewModel: AppSettingsViewModel) {
        // Submit new settings state to the global holder
        parent.deps.appSettingsHolder.setAppSettings(viewModel.settings)
        // Dismiss sheet
        parent.presentedSettings = nil
    }

}
