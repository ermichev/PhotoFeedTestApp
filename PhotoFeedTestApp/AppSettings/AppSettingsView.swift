//
//  AppSettingsView.swift
//  PhotoFeedTestApp
//
//  Created by Alexander Ermichev on 26.06.2024.
//

import SwiftUI

struct AppSettingsView: View {

    @ObservedObject var viewModel: AppSettingsViewModel

    var pageSizeProxy: Binding<Double> {
        Binding<Double>(
            get: { Double(viewModel.settings.pageSize) },
            set: { viewModel.settings.pageSize = Int($0) }
        )
    }

    var body: some View {
        VStack(spacing: 0.0) {
            CloseButtonView { viewModel.onClose() }
                .frame(maxWidth: .infinity, alignment: .trailing)

            VStack(spacing: 16.0) {
                HStack {
                    Text("API key: ")
                    TextField("", text: $viewModel.settings.apiKey)
                        .font(.footnote)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: .infinity)
                }
                HStack {
                    Text("Page size: \(viewModel.settings.pageSize) ")
                        .frame(width: 110.0, alignment: .leading)
                    Slider(
                        value: pageSizeProxy,
                        in: 4...20,
                        step: 1
                    )
                }
                Toggle(isOn: $viewModel.settings.mockServiceEnabled) {
                    Text("Use mocked feed service")
                }
                Toggle(isOn: $viewModel.settings.mockServiceFailHalfRequests) {
                    Text("Fail 50% of mock service requests")
                }
            }
            .padding(16.0)
            .frame(maxHeight: .infinity, alignment: .top)
        }
    }

}

#Preview {
    ZStack {
        Color.cyan
        AppSettingsView(viewModel: .init(
            settings: .init(
                apiKey: "",
                pageSize: 20,
                mockServiceEnabled: true,
                mockServiceFailHalfRequests: false
            )
        ))
        .background()
    }
}
