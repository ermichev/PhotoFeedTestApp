//
//  PhotoCellViewModel.swift
//  PhotoFeedTestApp
//
//  Created by Alexander Ermichev on 18.06.2024.
//

import Combine
import UIKit

final class PhotoCellViewModel {

    // MARK: - Public nested types

    enum ViewState {
        case loading
        case image(UIImage)
        case error
    }

    // MARK: - Public properties

    var viewState: AnyPublisher<ViewState, Never> {
        viewStateImpl.eraseToAnyPublisher()
    }

    // MARK: - Constructors

    init(imageRequest: AnyPublisher<UIImage, Error>?) {
        imageRequest?
            .sink(
                receiveCompletion: { [weak self] in
                    guard case .failure = $0 else { return }
                    self?.viewStateImpl.send(.error)
                },
                receiveValue: { [weak self] in
                    self?.viewStateImpl.send(.image($0))
                }
            )
            .store(in: &bag)
    }

    // MARK: - Public properties

    private let viewStateImpl = CurrentValueSubject<ViewState, Never>(ViewState.loading)
    private var bag = Set<AnyCancellable>()

}
