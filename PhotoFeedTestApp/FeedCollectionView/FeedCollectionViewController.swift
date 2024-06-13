//
//  FeedCollectionViewController.swift
//  PhotoFeedTestApp
//
//  Created by Alexander Ermichev on 08.06.2024.
//

import Combine
import UIKit

protocol FeedCollectionViewControllerDeps:
    FeedCollectionInteractorImplDeps
{ }

final class FeedCollectionViewController: UICollectionViewController {
    
    typealias Deps = FeedCollectionViewControllerDeps

    init(deps: Deps) {
        let interactor = FeedCollectionInteractorImpl(deps: deps, pageSize: 20)
        self.viewModel = FeedCollectionViewModel(interactor: interactor)

        let layout = UICollectionViewFlowLayout()
        super.init(collectionViewLayout: layout)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        collectionView.alwaysBounceVertical = true

        viewModel.setup(for: collectionView)

        viewModel.viewUpdateRequests
            .sink { [weak self] in self?.collectionView.reloadData() }
            .store(in: &bag)
    }

    private let viewModel: FeedCollectionViewModel
    private var bag = Set<AnyCancellable>()

}

