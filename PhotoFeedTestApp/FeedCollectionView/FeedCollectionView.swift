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

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
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

    class Coordinator: NSObject, PhotoDetailsRouter {

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
            interactor.onClose = { [weak self] in
                self?.parent.presentedPhotoDetails = nil
            }
            parent.presentedPhotoDetails = interactor
        }

    }

}

#Preview {
    FeedCollectionView(presentedPhotoDetails: .constant(.init(wrappedValue: nil)))
}
