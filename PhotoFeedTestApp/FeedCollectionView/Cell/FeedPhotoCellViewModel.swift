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

    enum ImageState: Equatable {
        case loading
        case image(UIImage)
        case error
    }

    // MARK: - Public properties

    let title: String?
    let averageColor: UIColor?

    var imageState: AnyPublisher<ImageState, Never> {
        imageStateImpl.distinctValues()
    }

    // MARK: - Constructors

    init(author: String?, averageColor: UIColor?, imageRequest: AnyPublisher<UIImage, Error>?) {
        self.title = author
        self.averageColor = averageColor

        imageRequest?
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { [weak self] in
                    guard case .failure = $0 else { return }
                    self?.imageStateImpl.send(.error)
                },
                receiveValue: { [weak self] in
                    self?.imageStateImpl.send(.image($0))
                }
            )
            .store(in: &bag)
    }

    static func placeholder() -> Self {
        Self.init(author: nil, averageColor: nil, imageRequest: nil)
    }

    // MARK: - Public properties

    private let imageStateImpl = CurrentValueSubject<ImageState, Never>(.loading)
    private var bag = Set<AnyCancellable>()

}
