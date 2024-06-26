//
//  FeedCollectionInteractor.swift
//  PhotoFeedTestApp
//
//  Created by Alexander Ermichev on 12.06.2024.
//

import Combine
import UIKit

protocol FeedCollectionInteractorImplDeps {
    var photosFeedService: PhotosFeedService { get }
    var photoLoadingService: PhotoLoadingService { get }
}

final class FeedCollectionInteractorImpl: FeedCollectionInteractor {
    
    // MARK: - Public nested types

    typealias Deps = FeedCollectionInteractorImplDeps

    // MARK: - Public properties

    var currentState: FeedViewState {
        stateImpl.value
    }

    var stateUpdates: AnyPublisher<FeedViewState, Never> {
        stateImpl.eraseToAnyPublisher()
    }

    // MARK: - Constructors

    init(deps: Deps, pageSize: Int) {
        self.deps = deps
        self.session = deps.photosFeedService.feedSession(pageSize: pageSize)

        session.state
            .sink { [weak self] in self?.updateFeedState(with: $0) }
            .store(in: &bag)
    }

    // MARK: - Public methods

    func fetchFeedPhoto(with index: Int) -> AnyPublisher<UIImage, Error> {
        guard let model = fetchedModels[safe: index] else {
            return Fail(error: Errors.incorrectIndex).eraseToAnyPublisher()
        }

        return deps.photoLoadingService.loadPhoto(model, size: .medium)
    }

    func fetchNextPage() {
        if stateImpl.value.isNotStarted {
            session.start()
        } else {
            session.fetchNextPage()
        }
    }

    func retry() {
        session.retry()
    }

    func clearAndRestart() {
        session.clearAndRestart()
    }

    // MARK: - Private properties

    private let deps: Deps
    private let session: PhotosFeedSession

    private let stateImpl = CurrentValueSubject<FeedViewState, Never>(.notStarted)
    private var bag = Set<AnyCancellable>()

    private var fetchedModels: [PhotoModel] {
        switch stateImpl.value {
        case .notStarted: []
        case .started(_, let fetched): fetched.models
        }
    }

}

private extension FeedCollectionInteractorImpl {

    // MARK: - Private methods

    private func updateFeedState(with sessionState: PhotosFeedSessionState) {
        let hasNextPage = session.hasNextPage

        switch sessionState {
        case (.notStarted, _):
            stateImpl.send(.notStarted)
        case (.fetching, let photos):
            stateImpl.send(
                .started(state: .fetching, fetched: .init(models: photos, hasNextPage: hasNextPage))
            )
        case (.idle, let photos):
            stateImpl.send(
                .started(state: .idle, fetched: .init(models: photos, hasNextPage: hasNextPage))
            )
        case (.error, let photos):
            stateImpl.send(
                .started(state: .error, fetched: .init(models: photos, hasNextPage: hasNextPage))
            )
        }
    }

}
