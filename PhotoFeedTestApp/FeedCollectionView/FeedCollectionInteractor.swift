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
    
    typealias Deps = FeedCollectionInteractorImplDeps

    var state: AnyPublisher<PhotosFeedSessionState, Never> {
        Just(.idle).eraseToAnyPublisher() // TODO: State
    }

    var loadedItemsCount: AnyPublisher<Int, Never> {
        loadedModels
            .map { $0.count }
            .eraseToAnyPublisher()
    }

    init(deps: Deps, pageSize: Int) {
        self.deps = deps
        self.session = deps.photosFeedService.feedSession(pageSize: pageSize)

        session.photos
            .subscribe(loadedModels)
            .store(in: &bag)
    }

    func fetchPhoto(with index: Int) -> AnyPublisher<UIImage, Error> {
        guard index < loadedModels.value.count else {
            return Fail(error: Errors.incorrectIndex).eraseToAnyPublisher()
        }

        return deps.photoLoadingService.loadPhoto(loadedModels.value[index], size: .portrait)
    }
    
    func startFetching() {
        session.start()
    }
    
    func fetchNextPage() {
        session.fetchNextPage()
    }
    
    func reload() {
        session.clear()
        session.start()
    }
    
    private let deps: Deps
    private let session: PhotosFeedSession

    private let loadedModels = CurrentValueSubject<[PhotoModel], Never>([])
    private var bag = Set<AnyCancellable>()

}
