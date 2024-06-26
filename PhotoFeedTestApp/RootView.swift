//
//  RootView.swift
//  PhotoFeedTestApp
//
//  Created by Alexander Ermichev on 24.06.2024.
//

import SwiftUI

struct RootView: View {

    var body: some View {
        FeedCollectionView(presentedPhotoDetails: $presentedDetails, presentedSettings: $presentedSettings)
            .id(appSettings.settings.id) // Recreating feed screen when service settings are changed
            .background(Colors.bg.primary.color)
            .customSheet(stateProvider: $presentedDetails) { stateProvider in
                if let stateProvider {
                    if #available(iOS 16.4, *) {
                        PhotoDetailsView(viewModel: PhotoDetailsViewModel(interactor: stateProvider))
                            .presentationDetents([.large])
                            .presentationDragIndicator(.visible)
                            .presentationCornerRadius(16.0)
                    } else {
                        PhotoDetailsView(viewModel: PhotoDetailsViewModel(interactor: stateProvider))
                    }
                }
            }
            .customSheet(stateProvider: $presentedSettings) { stateProvider in
                if let stateProvider {
                    if #available(iOS 16.4, *) {
                        AppSettingsView(viewModel: stateProvider)
                            .presentationDetents([.medium])
                            .presentationDragIndicator(.visible)
                            .presentationCornerRadius(16.0)
                    } else {
                        AppSettingsView(viewModel: stateProvider)
                    }
                }
            }

    }

    @Environment(\.applicationDeps) private var deps
    @EnvironmentObject private var appSettings: ObservableAppSettings

    @State @EquatableStore private var presentedDetails: PhotoDetailsInteractorImpl?
    @State @EquatableStore private var presentedSettings: AppSettingsViewModel?

}

extension AppSettingsModel: Identifiable {

    var id: String {
        "\(apiKey)_\(pageSize)_\(mockServiceEnabled)_\(mockServiceFailHalfRequests)"
    }

}
