//
//  FeedCollectionPhotoCell.swift
//  PhotoFeedTestApp
//
//  Created by Alexander Ermichev on 12.06.2024.
//

import Combine
import UIKit

final class FeedCollectionPhotoCell: UICollectionViewCell {

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .gray
        
        addSubview(imageView)
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor)
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

    func bind(to imageStream: AnyPublisher<UIImage, Error>) {
        imageStream
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in /* TODO: make error placeholder */ },
                receiveValue: { [weak self] in self?.imageView.image = $0 }
            )
            .store(in: &bag)
    }

    private let imageView = UIImageView()
    private var bag = Set<AnyCancellable>()

}
