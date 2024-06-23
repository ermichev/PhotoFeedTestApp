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

final class FeedCollectionViewController: UIViewController {
    
    typealias Deps = FeedCollectionViewControllerDeps

    init(deps: Deps) {
        let interactor = FeedCollectionInteractorImpl(deps: deps, pageSize: 20)
        self.viewModel = FeedCollectionViewModel(interactor: interactor)
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        let layout = FeedCollectionWaterfallLayout()
        layout.estimatedColumnWidth = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height) / 2.0

        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        self.collectionView = collection

        view.addSubview(collection)
        collection.alwaysBounceVertical = true
        collection.backgroundColor = Colors.bg.primary.uiColor

        viewModel.setup(for: collection)

        viewModel.viewUpdateRequests
            .sink { [weak self] in self?.collectionView?.reloadData() }
            .store(in: &bag)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView?.frame = view.bounds
    }

    private let viewModel: FeedCollectionViewModel
    private var collectionView: UICollectionView?
    private var bag = Set<AnyCancellable>()

}

