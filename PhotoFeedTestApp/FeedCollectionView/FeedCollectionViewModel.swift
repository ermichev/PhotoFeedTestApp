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
    var state: AnyPublisher<PhotosFeedSessionState, Never> { get }
    var loadedItemsCount: AnyPublisher<Int, Never> { get }
    func fetchPhoto(with index: Int) -> AnyPublisher<UIImage, Error>
    func startFetching()
    func fetchNextPage()
    func reload()
}

final class FeedCollectionViewModel: NSObject {

    var viewUpdateRequests: AnyPublisher<Void, Never> {
        interactor.loadedItemsCount
            .map { _ in }
            .eraseToAnyPublisher()
    }

    init(interactor: FeedCollectionInteractor) {
        self.interactor = interactor
    }

    func setup(for collectionView: UICollectionView) {
        collectionView.register(FeedCollectionPhotoCell.self, forCellWithReuseIdentifier: Ids.photoCell)
        collectionView.dataSource = self
        collectionView.delegate = self

        interactor.startFetching()

        interactor.loadedItemsCount
            .sink { [weak self] in self?.numberOfItemsInSection = $0 }
            .store(in: &bag)
    }

    private let interactor: FeedCollectionInteractor
    private var numberOfItemsInSection: Int = 0
    private var bag = Set<AnyCancellable>()

}

extension FeedCollectionViewModel: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        numberOfItemsInSection
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Ids.photoCell, for: indexPath)
        guard let cell = cell as? FeedCollectionPhotoCell else { assertionFailure(); return cell }
        cell.bind(to: interactor.fetchPhoto(with: indexPath.item))
        return cell
    }
    

}

extension FeedCollectionViewModel: UICollectionViewDelegate {

}

private extension FeedCollectionViewModel {

    private enum Ids {
        static let photoCell = "PhotoCell"
    }

}
