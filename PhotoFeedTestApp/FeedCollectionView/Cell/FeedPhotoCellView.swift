//
//  FeedPhotoCellView.swift
//  PhotoFeedTestApp
//
//  Created by Alexander Ermichev on 12.06.2024.
//

import Combine
import UIKit

final class FeedPhotoCellView: UICollectionViewCell {

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .secondarySystemBackground
        
        addSubview(imageView)
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false

        imageView.addSubview(loader)
        loader.translatesAutoresizingMaskIntoConstraints = false

        imageView.addSubview(retry)
        retry.translatesAutoresizingMaskIntoConstraints = false
        retry.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
        retry.setTitleColor(.secondaryLabel, for: .normal)
        retry.isHidden = true

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            loader.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            loader.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            retry.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            retry.centerXAnchor.constraint(equalTo: imageView.centerXAnchor)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        bag.removeAll()
        imageView.image = nil
    }

    func bind(to viewModel: PhotoCellViewModel) {
        self.viewModel = viewModel

        viewModel.viewState
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] state in
                switch state {
                case .loading:
                    self?.imageView.image = nil
                    self?.loader.startAnimating()
                    self?.retry.isHidden = true
                case .image(let image):
                    self?.imageView.image = image
                    self?.loader.stopAnimating()
                    self?.retry.isHidden = true
                case .error:
                    self?.imageView.image = nil
                    self?.loader.stopAnimating()
                    self?.retry.isHidden = false
                }
            })
            .store(in: &bag)
    }

    private let imageView = UIImageView()
    private var loader = UIActivityIndicatorView()
    private var retry = UIButton(type: .system)

    private var viewModel: PhotoCellViewModel?
    private var bag = Set<AnyCancellable>()

}
