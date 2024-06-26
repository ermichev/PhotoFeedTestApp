//
//  FeedCollectionViewController.swift
//  PhotoFeedTestApp
//
//  Created by Alexander Ermichev on 08.06.2024.
//

import Combine
import UIKit

protocol FeedScreenRouter {
    func showDetails(for model: PhotoModel)
    func showAppSettings()
}

protocol FeedCollectionViewControllerDeps:
    FeedCollectionInteractorImplDeps
{ 
    var appSettingsProvider: AppSettingsProvider { get }
}

final class FeedCollectionViewController: UIViewController {

    // MARK: - Public nested types

    typealias Deps = FeedCollectionViewControllerDeps

    // MARK: - Public properties

    var router: FeedScreenRouter?

    // MARK: - Constructors

    init(deps: Deps) {
        self.deps = deps

        self.estimatedItemWidth = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height) / 2.0
        // Request larger photos for bigger screens
        let feedPhotoSize: PhotoSize = estimatedItemWidth > 350.0 ? .large : .medium

        let pageSize = deps.appSettingsProvider.appSettings.settings.pageSize
        let interactor = FeedCollectionInteractorImpl(deps: deps, pageSize: pageSize, feedPhotoSize: feedPhotoSize)
        self.viewModel = FeedCollectionViewModel(interactor: interactor)

        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public methods

    override func viewDidLoad() {
        let layout = FeedCollectionWaterfallLayout()
        layout.estimatedColumnWidth = estimatedItemWidth

        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        self.collectionView = collection

        view.addSubview(collection)
        collection.contentInset.top = 16.0
        collection.alwaysBounceVertical = true
        collection.backgroundColor = Colors.bg.primary.uiColor

        viewModel.setup(for: collection)

        viewModel.viewUpdateRequests
            .sink { [weak self] in
                self?.collectionView?.reloadData()
                self?.triggerNextPageIfNeeded()
            }
            .store(in: &bag)

        viewModel.cellTaps
            .sink { [weak self] in self?.router?.showDetails(for: $0) }
            .store(in: &bag)

        // -

        view.addSubview(settingsButton)
        settingsButton.setImage(Images.settings.uiImage, for: .normal)
        settingsButton.setTitleColor(Colors.label.primary.uiColor, for: .normal)
        settingsButton.backgroundColor = Colors.bg.primary.uiColor.withAlphaComponent(0.8)
        settingsButton.layer.cornerRadius = 16.0
        settingsButton.addTarget(self, action: #selector(settingsTap), for: .touchUpInside)

        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            settingsButton.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -32.0
            ),
            settingsButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -32.0
            ),
            settingsButton.heightAnchor.constraint(equalToConstant: 48.0),
            settingsButton.widthAnchor.constraint(equalToConstant: 48.0)
        ])
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView?.frame = view.bounds
    }

    // MARK: - Private properties

    private let deps: Deps
    private let viewModel: FeedCollectionViewModel
    private let estimatedItemWidth: CGFloat

    private var collectionView: UICollectionView?
    private var settingsButton = UIButton(type: .system)

    private var bag = Set<AnyCancellable>()

}

private extension FeedCollectionViewController {

    // MARK: - Private methods

    @objc private func settingsTap() {
        router?.showAppSettings()
    }

    // This is a dirty hack for an annoying problem I don't have time to deal properly.
    // Basically, if first page of photos is smaller than screen size - prefetch for the next page will not be called
    // until collection is scrolled. In all other cases fetching next page through `prefetchItemsAt` works as
    // intended, so I just forcefully trigger prefetch for that specific case.

    private func triggerNextPageIfNeeded() {
        guard let collectionView else { return }
        let viewHeight = collectionView.bounds.height
        let maxContentItemIndexPath = IndexPath(item: viewModel.fetchedPhotoCellsCount - 1, section: 0)
        let contentMaxY = collectionView.layoutAttributesForItem(at: maxContentItemIndexPath)?.frame.maxY ?? 0.0

        if contentMaxY < viewHeight {
            let pageSize = deps.appSettingsProvider.appSettings.settings.pageSize
            let nextPageIndexPath = IndexPath(item: maxContentItemIndexPath.item + pageSize, section: 0)
            Logger.log.debug("Forcing prefetch of item at \(nextPageIndexPath.item)")
            viewModel.collectionView(collectionView, prefetchItemsAt: [nextPageIndexPath])
        }
    }

}
