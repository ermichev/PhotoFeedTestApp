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
            .ignoresSafeArea(edges: .bottom)
            .sheet(
                isPresented: isDetailsPresented,
                onDismiss: { presentedDetails = nil },
                content: {
                    if let presentedDetails {
                        if #available(iOS 16.0, *) {
                            PhotoDetailsView(viewModel: PhotoDetailsViewModel(interactor: presentedDetails))
                                .presentationDetents([.large])
                        } else {
                            PhotoDetailsView(viewModel: PhotoDetailsViewModel(interactor: presentedDetails))
                        }
                    }
                }
            )
    }

    @State private var presentedDetails: PhotoDetailsInteractor?

    private var isDetailsPresented: Binding<Bool> {
        Binding<Bool>(get: { presentedDetails != nil }, set: { _ in presentedDetails = nil })
    }

}
