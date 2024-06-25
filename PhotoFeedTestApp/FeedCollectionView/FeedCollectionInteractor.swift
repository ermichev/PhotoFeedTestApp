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
            .map { [weak self] sessionState -> FeedViewState in
                guard let self else { return .notStarted }
                let hasNextPage = session.hasNextPage
                let loadingState = sessionState.loadingState

                if let lastSessionModels, loadingState == .notStarted || loadingState == .fetching {
                    // Keeping last session photos on the screen until refreshed content is arrived
                    return .started(state: .refreshing, fetched: .init(models: lastSessionModels, hasNextPage: false))
                }

                switch sessionState {
                case (.notStarted, _):
                    return .notStarted
                case (.fetching, let photos):
                    return .started(state: .fetching, fetched: .init(models: photos, hasNextPage: hasNextPage))
                case (.idle, let photos):
                    return .started(state: .idle, fetched: .init(models: photos, hasNextPage: hasNextPage))
                case (.error, let photos):
                    return .started(state: .error, fetched: .init(models: photos, hasNextPage: hasNextPage))
                }
            }
            .subscribe(stateImpl)
            .store(in: &bag)
    }

    // MARK: - Public methods

    func fetchFeedPhoto(with index: Int) -> AnyPublisher<UIImage, Error> {
        guard index < fetchedModels.count else {
            return Fail(error: Errors.incorrectIndex).eraseToAnyPublisher()
        }

        return deps.photoLoadingService.loadPhoto(fetchedModels[index], size: .medium)
    }
    
    func startFetching() {
        session.start()
    }
    
    func fetchNextPage() {
        session.fetchNextPage()
    }
    
    func reload() {
        lastSessionModels = fetchedModels
        session.clear()
        session.start()
    }

    // MARK: - Private properties

    private let deps: Deps
    private let session: PhotosFeedSession

    private let stateImpl = CurrentValueSubject<FeedViewState, Never>(.notStarted)
    private var bag = Set<AnyCancellable>()

    private var lastSessionModels: [PhotoModel]? = nil

    private var fetchedModels: [PhotoModel] {
        switch stateImpl.value {
        case .notStarted: []
        case .started(_, let fetched): fetched.models
        }
    }

}
