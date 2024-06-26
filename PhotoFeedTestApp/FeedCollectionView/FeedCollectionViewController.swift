//
//  FeedCollectionViewController.swift
//  PhotoFeedTestApp
//
//  Created by Alexander Ermichev on 08.06.2024.
//

import Combine
import UIKit

protocol FeedScreenRouter {
    func showDetails(for model: PhotoModel, loadedPreview: UIImage?)
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
        let pageSize = deps.appSettingsProvider.appSettings.settings.pageSize
        let interactor = FeedCollectionInteractorImpl(deps: deps, pageSize: pageSize)
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
        layout.estimatedColumnWidth = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height) / 2.0

        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        self.collectionView = collection

        view.addSubview(collection)
        collection.contentInset.top = 16.0
        collection.alwaysBounceVertical = true
        collection.backgroundColor = Colors.bg.primary.uiColor

        viewModel.setup(for: collection)

        viewModel.viewUpdateRequests
            .sink { [weak self] in self?.collectionView?.reloadData() }
            .store(in: &bag)

        viewModel.cellTaps
            .sink { [weak self] in self?.router?.showDetails(for: $0, loadedPreview: $1) }
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

    private let viewModel: FeedCollectionViewModel

    private var collectionView: UICollectionView?
    private var settingsButton = UIButton(type: .system)

    private var bag = Set<AnyCancellable>()

}

private extension FeedCollectionViewController {

    // MARK: - Private methods

    @objc private func settingsTap() {
        router?.showAppSettings()
    }

}
