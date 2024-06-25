//
//  FeedCollectionViewModel.swift
//  PhotoFeedTestApp
//
//  Created by Alexander Ermichev on 12.06.2024.
//

import Combine
import Foundation
import UIKit

enum FeedViewState {
    case notStarted
    case started(state: LoadingState, fetched: FetchedPart)

    enum LoadingState {
        case idle
        case fetching
        case error
    }

    struct FetchedPart {
        let models: [PhotoModel]
        let hasNextPage: Bool
    }
}

protocol FeedCollectionInteractor {
    var currentState: FeedViewState { get }
    var stateUpdates: AnyPublisher<FeedViewState, Never> { get }
    func fetchFeedPhoto(with index: Int) -> AnyPublisher<UIImage, Error>
    func startFetching()
    func fetchNextPage()
    func reload()
}

extension FeedCollectionInteractor {

    var hasNextPage: Bool {
        switch currentState {
        case .notStarted: true
        case .started(_, let data): data.hasNextPage
        }
    }

}

// -

final class FeedCollectionViewModel: NSObject {

    var viewUpdateRequests: AnyPublisher<Void, Never> {
        interactor.stateUpdates
            .map { _ in }
            .eraseToAnyPublisher()
    }

    var cellTaps: AnyPublisher<(PhotoModel, UIImage?), Never> {
        cellTapsImpl.eraseToAnyPublisher()
    }

    init(interactor: FeedCollectionInteractor) {
        self.interactor = interactor
    }

    func setup(for collectionView: UICollectionView) {
        collectionView.register(FeedPhotoCellView.self, forCellWithReuseIdentifier: Ids.photoCell)
        collectionView.dataSource = self
        collectionView.prefetchDataSource = self
        collectionView.delegate = self

        interactor.startFetching()
    }

    private let interactor: FeedCollectionInteractor
    private var itemsToPrefetchCount: Int = 0

    private var cellTapsImpl = PassthroughSubject<(PhotoModel, UIImage?), Never>()
    private var bag = Set<AnyCancellable>()

    private var loadedPhotos: [PhotoModel] {
        switch interactor.currentState {
        case .notStarted:
            []
        case .started(_, let loaded):
            loaded.models
        }
    }

}

extension FeedCollectionViewModel: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch interactor.currentState {
        case .started(state: .error, _):
            loadedPhotos.count + 1 // Retry cell
        case .started(_, let loaded) where loaded.hasNextPage:
            loadedPhotos.count + Static.nextPagePlaceholdersCount
        default:
            loadedPhotos.count
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Ids.photoCell, for: indexPath)
        guard let cell = cell as? FeedPhotoCellView else { assertionFailure(); return cell }

        let cellViewModel = if let model = loadedPhotos[safe: indexPath.item] {
            PhotoCellViewModel(
                author: model.photographer.name,
                averageColor: model.averageColor,
                imageRequest: interactor.fetchFeedPhoto(with: indexPath.item)
            )
        } else {
            PhotoCellViewModel.placeholder()
        }

        cell.bind(to: cellViewModel)
        return cell
    }

}

extension FeedCollectionViewModel: UICollectionViewDataSourcePrefetching {
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let greatestRequestedIndex = indexPaths.map { $0.item }.max() ?? 0
        guard greatestRequestedIndex >= loadedPhotos.count else { return }
//        itemsToPrefetchCount = greatestRequestedIndex + 1
//        prefetchPageIfNeeded()
    }

}

extension FeedCollectionViewModel: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item < loadedPhotos.count else { return }
        cellTapsImpl.send((loadedPhotos[indexPath.item], nil)) // TODO: pass previews
    }

}

extension FeedCollectionViewModel: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        guard indexPath.item < loadedPhotos.count else {
            switch interactor.currentState {
            case .started(.error, _):
                return .zero // TODO
            default:
                return placeholderItemSizeAspect(for: indexPath)
            }
        }

        let model = loadedPhotos[indexPath.item]
        return CGSize(width: CGFloat(model.size.width), height: CGFloat(model.size.height))
    }

}

private extension FeedCollectionViewModel {

    // MARK: - Private nested types

    private enum Ids {
        static let photoCell = "PhotoCell"
    }

    private enum Static {
        static let nextPagePlaceholdersCount = 6
    }

    // MARK: - Private methods

    private func prefetchPageIfNeeded() {
        guard loadedPhotos.count < itemsToPrefetchCount else { return }
        guard !interactor.currentState.isFetching else { return }

        interactor.fetchNextPage()
        interactor.stateUpdates
            .first { !$0.isFetching }
            .sink { [weak self] state in
                switch state {
                case .started(.idle, _):
                    self?.prefetchPageIfNeeded()
                case .started(.error, _):
                    self?.showErrorCell()
                case .notStarted, .started(.fetching, _):
                    assertionFailure("Unexpected state")
                }
            }
            .store(in: &bag)
    }

    private func showErrorCell() {
        Logger.log.debug("TODO: show error")
    }

    // -

    private func placeholderItemSizeAspect(for indexPath: IndexPath) -> CGSize {
        switch indexPath.item % 3 {
        case 1: CGSize(width: 1.0, height: 1.5)
        case 2: CGSize(width: 1.5, height: 1.0)
        default: CGSize(width: 1.0, height: 1.0)
        }
    }

}

private extension FeedViewState {

    var isFetching: Bool {
        switch self {
        case .started(.fetching, _): true
        default: false
        }
    }

}
