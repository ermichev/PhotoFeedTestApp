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
            HStack(spacing: 0.0) {
                imageContentView
                    .aspectRatio(viewModel.imageAspectRatio, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 16.0))
                    .padding(.vertical, 16.0)
                    .frame(maxHeight: .infinity)

                VStack {
                    Text(viewModel.author)
                }
                .frame(maxWidth: .infinity)

                closeButton
                    .frame(maxHeight: .infinity, alignment: .top)
            }
        } else {
            // Everything else
            VStack(spacing: 0.0) {
                closeButton
                    .frame(maxWidth: .infinity, alignment: .trailing)

                imageContentView
                    .aspectRatio(viewModel.imageAspectRatio, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 16.0))
                    .padding(.horizontal, 16.0)
                    .frame(maxWidth: .infinity)
                    .layoutPriority(1)

                Spacer().frame(height: 32.0)

                VStack(spacing: 8.0) {
                    HStack(spacing: 8.0) {
                        Text("Author:").font(.title2)
                        Button(
                            action: { viewModel.onAuthorPageTap() },
                            label: {
                                (Text(viewModel.author + " ") + Text(Images.openExternal.image))
                                    .font(.title2.bold())
                            }
                        )
                        .foregroundStyle(Colors.text.primary.color)
                    }
                }
                .frame(maxHeight: .infinity, alignment: .top)
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
