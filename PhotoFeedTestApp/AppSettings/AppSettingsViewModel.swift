//
//  AppSettingsViewModel.swift
//  PhotoFeedTestApp
//
//  Created by Alexander Ermichev on 26.06.2024.
//

import Foundation

protocol AppSettingsViewModelDelegate {
    func appSettingsViewModelWillDismiss(_ viewModel: AppSettingsViewModel)
}

final class AppSettingsViewModel: ObservableObject, SheetStateProvider {
   
    // MARK: - Public properties

    @Published var settings: AppSettingsModel

    var delegate: AppSettingsViewModelDelegate?

    // MARK: - Constructors

    init(settings: AppSettingsModel) {
        self.settings = settings
    }

    // MARK: - Public methods

    func onClose() {
        Logger.log.debug("AppSettingsViewModel.onClose")
        delegate?.appSettingsViewModelWillDismiss(self)
    }

}
