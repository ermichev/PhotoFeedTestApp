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
            ZStack(alignment: .topTrailing) {
                HStack(spacing: 16.0) {
                    imageContentView
                        .aspectRatio(viewModel.imageAspectRatio, contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 16.0))
                        .padding(.vertical, 16.0)
                        .frame(maxHeight: .infinity)
                        .layoutPriority(1)

                    details
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .layoutPriority(0)
                }

                closeButton
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

                Spacer().frame(height: 16.0)

                details
                    .padding(.horizontal, 16.0)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .layoutPriority(0)
            }
        }
    }

    private var closeButton: some View {
        Button(
            action: { viewModel.onCloseTap() },
            label: { Images.close.image.resizable() }
        )
        .foregroundStyle(Colors.label.tertiary.color)
        .frame(width: 24.0, height: 24.0)
        .padding(16.0)
    }

    private var imageContentView: some View {
        Group {
            switch viewModel.imageState {
            case .loading:
                ZStack {
                    Color(viewModel.imageAvgColor)
                    ProgressView()
                }
            case .lowResImage(let uIImage), .hiResImage(let uIImage):
                ZStack(alignment: .bottomTrailing) {
                    Image(uiImage: uIImage).resizable()
                    downloadButton
                }
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

    private var downloadButton: some View {
        Button(
            action: { viewModel.onDownloadFullTap() },
            label: {
                ZStack {
                    Circle()
                        .foregroundStyle(Color.white.opacity(0.9))
                    switch viewModel.downloadState {
                    case .idle:
                        Images.download.image.resizable()
                            .foregroundStyle(Color.accentColor)
                            .padding(4.0)
                    case .loading:
                        ProgressView()
                            .environment(\.colorScheme, .light)
                    case .error:
                        Images.retry.image.resizable()
                            .foregroundColor(Colors.error.color)
                            .padding(4.0)
                    }

                }
                .frame(width: 32.0, height: 32.0)
                .padding(16.0)
            }
        )
    }

    private var details: some View {
        VStack(alignment: .leading, spacing: 24.0) {
            author
            if !viewModel.altText.isEmpty { altText }
        }
    }

    private var author: some View {
        HStack(spacing: 8.0) {
            Text("Author:")
                .font(.body)
                .foregroundStyle(Colors.label.secondary.color)
            Button(
                action: { viewModel.onAuthorPageTap() },
                label: {
                    (Text(viewModel.author).underline() + Text(" ") + Text(Images.openExternal.image))
                        .font(.body)
                        .foregroundStyle(Color.accentColor)
                }
            )
            .foregroundStyle(Colors.label.primary.color)
        }
    }

    private var altText: some View {
        Text(viewModel.altText)
            .font(.body)
            .foregroundStyle(Colors.label.secondary.color)
    }

}
