//
//  RootView.swift
//  PhotoFeedTestApp
//
//  Created by Alexander Ermichev on 24.06.2024.
//

import SwiftUI

struct RootView: View {

    var body: some View {
        FeedView(presentedPhotoDetails: $presentedDetails)
            .ignoresSafeArea(edges: .vertical)
            .background(Colors.bg.primary.color)
            .customSheet(interactor: $presentedDetails) { interactor in
                if let interactor {
                    if #available(iOS 16.4, *) {
                        PhotoDetailsView(viewModel: PhotoDetailsViewModel(interactor: interactor))
                            .presentationDetents([.large])
                            .presentationDragIndicator(.visible)
                            .presentationCornerRadius(16.0)
                    } else {
                        PhotoDetailsView(viewModel: PhotoDetailsViewModel(interactor: interactor))
                    }
                }
            }
    }

    @State @EquatableStore private var presentedDetails: PhotoDetailsInteractorImpl?

}



