//
//  PhotoDetailsView.swift
//  PhotoFeedTestApp
//
//  Created by Alexander Ermichev on 24.06.2024.
//

import SwiftUI

struct PhotoDetailsView: View {

    @ObservedObject var viewModel: PhotoDetailsViewModel

    @Environment(\.verticalSizeClass) var verticalSizeClass

    var body: some View {
        if verticalSizeClass == .compact {
            // Phone in landscape
            VStack(spacing: 0.0) {
                closeButton

                HStack {
                    imageContentView
                        .aspectRatio(viewModel.imageAspectRatio, contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 16.0))
                        .padding(16.0)
                        .frame(maxHeight: .infinity)
                    VStack {
                        Text(viewModel.author)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        } else {
            // Everything else
            VStack(spacing: 0.0) {
                closeButton

                imageContentView
                    .aspectRatio(viewModel.imageAspectRatio, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 16.0))
                    .padding(16.0)
                    .frame(maxWidth: .infinity)
                    .layoutPriority(1)
                VStack {
                    HStack(spacing: 32.0) {
                        Text(viewModel.author)
                        Button(
                            action: { viewModel.onAuthorPageTap() },
                            label: {
                                Text("Open author page")
                            }
                        )
                    }
                }
                .frame(maxHeight: .infinity)
                .layoutPriority(0)
            }
        }
    }

    private var closeButton: some View {
        Button(
            action: { viewModel.onCloseTap() },
            label: { Images.close.image.resizable() }
        )
        .foregroundStyle(Colors.fill.primary.color)
        .frame(width: 24.0, height: 24.0)
        .padding(16.0)
        .frame(maxWidth: .infinity, alignment: .trailing)
    }

    private var imageContentView: some View {
        Group {
            switch viewModel.imageState {
            case .loading:
                Color(viewModel.imageAvgColor)
            case .lowResImage(let uIImage):
                Image(uiImage: uIImage).resizable()
            case .hiResImage(let uIImage):
                Image(uiImage: uIImage).resizable()
            case .error(let image?):
                ZStack {
                    Image(uiImage: image).resizable()
                    Images.retry.image
                }
            case .error(nil):
                ZStack {
                    Color(viewModel.imageAvgColor)
                    Images.retry.image
                }
            }
        }
    }

}
