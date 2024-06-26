//
//  FeedCollectionViewModel.swift
//  PhotoFeedTestApp
//
//  Created by Alexander Ermichev on 12.06.2024.
//

import Combine
import Foundation
import UIKit

protocol FeedCollectionInteractor {
    var currentState: FeedViewState { get }
    var stateUpdates: AnyPublisher<FeedViewState, Never> { get }
    func fetchFeedPhoto(with index: Int) -> AnyPublisher<UIImage, Error>
    func fetchNextPage()
    func retry()
    func clearAndRestart()
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

    // MARK: - Public properties

    var viewUpdateRequests: AnyPublisher<Void, Never> {
        viewUpdateRequestsImpl.eraseToAnyPublisher()
    }

    var cellTaps: AnyPublisher<PhotoModel, Never> {
        cellTapsImpl.eraseToAnyPublisher()
    }

    var fetchedPhotoCellsCount: Int {
        cellViewModels.count
    }

    // MARK: - Constructors

    init(interactor: FeedCollectionInteractor) {
        self.interactor = interactor
    }

    // MARK: - Public methods

    func setup(for collectionView: UICollectionView) {
        collectionView.register(FeedPhotoCellView.self, forCellWithReuseIdentifier: Ids.photoCell)
        collectionView.register(FeedErrorCellView.self, forCellWithReuseIdentifier: Ids.errorCell)
        collectionView.dataSource = self
        collectionView.prefetchDataSource = self
        collectionView.delegate = self

        pullToRefreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        collectionView.refreshControl = pullToRefreshControl

        subscribeToStateUpdates()
        interactor.fetchNextPage()
    }

    // MARK: - Private properties

    private let interactor: FeedCollectionInteractor
    private var itemsToPrefetchCount: Int = 0

    private let pullToRefreshControl = UIRefreshControl()

    private var viewUpdateRequestsImpl = PassthroughSubject<Void, Never>()
    private var cellTapsImpl = PassthroughSubject<PhotoModel, Never>()
    private var bag = Set<AnyCancellable>()

    private var cellViewModels: [PhotoCellViewModel] = []

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
        if interactor.currentState.isError && indexPath.item == loadedPhotos.count {
            // Error cell
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Ids.errorCell, for: indexPath)
            guard let cell = cell as? FeedErrorCellView else { assertionFailure(); return cell }

            cell.onRetryTap = { [weak self] in self?.interactor.retry() }
            return cell
        } else {
            // Photo cell
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Ids.photoCell, for: indexPath)
            guard let cell = cell as? FeedPhotoCellView else { assertionFailure(); return cell }

            let viewModel = cellViewModels[safe: indexPath.item] ?? PhotoCellViewModel.placeholder()

            cell.bind(to: viewModel)
            return cell
        }
    }

}

extension FeedCollectionViewModel: UICollectionViewDataSourcePrefetching {
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let greatestRequestedIndex = indexPaths.map { $0.item }.max() ?? 0
        guard greatestRequestedIndex >= cellViewModels.count else { return }
        itemsToPrefetchCount = greatestRequestedIndex + 1
        fetchPageIfNeeded()
    }

}

extension FeedCollectionViewModel: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item < loadedPhotos.count else { return }
        cellTapsImpl.send(loadedPhotos[indexPath.item])
        // TODO: future enhancement: pass lowres image as placeholder to details screen
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
                return .zero // TODO: Less janky way to indicate error cell in layout
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
        static let errorCell = "ErrorCell"
    }

    private enum Static {
        static let nextPagePlaceholdersCount = 6
    }

    // MARK: - Private methods

    private func subscribeToStateUpdates() {
        interactor.stateUpdates
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                switch state {
                case .started(.idle, _):
                    self?.updateCells()
                    self?.viewUpdateRequestsImpl.send(())
                    self?.fetchPageIfNeeded()
                case .notStarted, .started(.error, _), .started(.fetching, _):
                    self?.viewUpdateRequestsImpl.send(())
                }
            }
            .store(in: &bag)
    }

    private func fetchPageIfNeeded() {
        guard cellViewModels.count < itemsToPrefetchCount else { return }
        guard !interactor.currentState.isLoading else { return }
        guard !interactor.currentState.isError else { return }

        interactor.fetchNextPage()
    }

    private func updateCells() {
        let currentCellsCount = cellViewModels.count
        let currentModelsCount = loadedPhotos.count

        guard currentCellsCount < currentModelsCount else { return }

        for index in currentCellsCount..<currentModelsCount {
            let model = loadedPhotos[index]
            cellViewModels.append(
                PhotoCellViewModel(
                    author: model.photographer.name,
                    averageColor: model.averageColor,
                    imageRequest: interactor.fetchFeedPhoto(with: index)
                )
            )
        }
    }

    @objc private func refresh() {
        cellViewModels = []
        itemsToPrefetchCount = 0

        interactor.clearAndRestart()

        interactor.stateUpdates
            .first { !$0.isLoading }
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.pullToRefreshControl.endRefreshing()
            }
            .store(in: &bag)
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
