//
//  FeedPhotoCellView.swift
//  PhotoFeedTestApp
//
//  Created by Alexander Ermichev on 12.06.2024.
//

import Combine
import SwiftUI
import UIKit

final class FeedPhotoCellView: UICollectionViewCell {

    // MARK: - Constructors

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupMainContentViews()
        setupAuthorLabelViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public methods

    override func layoutSubviews() {
        super.layoutSubviews()

        layer.shadowPath = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: Layout.outerCornerRadius
        ).cgPath
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }
        layer.shadowColor = Colors.shadow.uiColor.resolvedColor(with: traitCollection).cgColor
    }

    override func prepareForReuse() {
        bag.removeAll()
        imageView.image = nil
    }

    // -

    func bind(to viewModel: PhotoCellViewModel) {
        self.viewModel = viewModel

        authorLabel.text = viewModel.title
        imageView.backgroundColor = viewModel.averageColor ?? Colors.fill.secondary.uiColor

        viewModel.imageState
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] state in
                switch state {
                case .loading:
                    self?.imageView.image = nil
                    self?.loader.startAnimating()
                    self?.retry.isHidden = true
                    self?.setAuthorLabelVisible(false)
                case .image(let image):
                    self?.imageView.image = image
                    self?.loader.stopAnimating()
                    self?.retry.isHidden = true
                    self?.setAuthorLabelVisible(true)
                case .error:
                    self?.imageView.image = nil
                    self?.loader.stopAnimating()
                    self?.retry.isHidden = false
                    self?.setAuthorLabelVisible(false)
                }
            })
            .store(in: &bag)
    }

    // MARK: - Private properties

    private let imageView = UIImageView()
    private let loader = UIActivityIndicatorView()
    private let retry = UIButton(type: .system)

    private let authorLabelBlockGuide = UILayoutGuide()
    private let authorLabelContainer = UIView()
    private let authorLabel = UILabel()
    private let authorLeftCorner = UIImageView()
    private let authorTopCorner = UIImageView()

    private var viewModel: PhotoCellViewModel?
    private var bag = Set<AnyCancellable>()

}

private extension FeedPhotoCellView {

    // MARK: - Private nested types

    private enum Layout {
        static let outerCornerRadius = 16.0
        static let innerCornerRadius = 10.0
        static let borderWidth = 8.0
        static let authorLabelInsets = UIEdgeInsets(top: 4.0, left: 8.0, bottom: 2.0, right: -4.0)
    }

    private enum Static {
        static let cellBaseColor = Colors.bg.secondary.uiColor
    }

    // MARK: - Private methods

    private func setupMainContentViews() {
        
        // setup views

        layer.masksToBounds = false
        layer.shadowOffset = .init(width: 1.0, height: 2.0)
        layer.shadowColor = Colors.shadow.uiColor.resolvedColor(with: traitCollection).cgColor
        layer.shadowRadius = 4.0
        layer.shadowOpacity = 0.5

        contentView.layer.cornerRadius = Layout.outerCornerRadius
        contentView.backgroundColor = Static.cellBaseColor

        contentView.addSubview(imageView)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = Layout.innerCornerRadius

        imageView.addSubview(loader)

        imageView.addSubview(retry)
        retry.setImage(Images.retry.uiImage, for: .normal)
        retry.setTitleColor(.secondaryLabel, for: .normal)

        // setup constraints

        [imageView, loader, retry]
            .forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Layout.borderWidth),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Layout.borderWidth),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Layout.borderWidth),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Layout.borderWidth)
        ])

        NSLayoutConstraint.activate([
            loader.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            loader.centerXAnchor.constraint(equalTo: imageView.centerXAnchor)
        ])

        NSLayoutConstraint.activate([
            retry.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            retry.centerXAnchor.constraint(equalTo: imageView.centerXAnchor)
        ])
    }

    private func setupAuthorLabelViews() {

        // setup views

        contentView.addLayoutGuide(authorLabelBlockGuide)
        
        contentView.addSubview(authorLabelContainer)
        authorLabelContainer.backgroundColor = Static.cellBaseColor
        authorLabelContainer.layer.cornerRadius = Layout.innerCornerRadius
        authorLabelContainer.layer.maskedCorners = isRTL ? .layerMaxXMinYCorner : .layerMinXMinYCorner

        authorLabelContainer.addSubview(authorLabel)
        authorLabel.font = .systemFont(ofSize: 14.0, weight: .medium)
        authorLabel.textColor = UIColor.label

        contentView.addSubview(authorLeftCorner)
        authorLeftCorner.image = Images.roundedCorner.uiImage.withRenderingMode(.alwaysTemplate)
        authorLeftCorner.tintColor = Static.cellBaseColor
        authorLeftCorner.transform = authorLeftCorner.transform.rotated(by: -.pi / 2.0)

        contentView.addSubview(authorTopCorner)
        authorTopCorner.image = Images.roundedCorner.uiImage.withRenderingMode(.alwaysTemplate)
        authorTopCorner.tintColor = Static.cellBaseColor
        authorTopCorner.transform = authorTopCorner.transform.rotated(by: -.pi / 2.0)

        // setup constraints

        [authorLabelContainer, authorLabel, authorLeftCorner, authorTopCorner]
            .forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        NSLayoutConstraint.activate([
            authorLabelBlockGuide.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
            authorLabelBlockGuide.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
            authorLabelBlockGuide.leadingAnchor
                .constraint(
                    greaterThanOrEqualTo: imageView.leadingAnchor,
                    constant: Layout.innerCornerRadius // Offset to ensure smooth corners transitions
                ),
        ])

        NSLayoutConstraint.activate([
            authorLabelContainer.trailingAnchor.constraint(equalTo: authorLabelBlockGuide.trailingAnchor),
            authorLabelContainer.bottomAnchor.constraint(equalTo: authorLabelBlockGuide.bottomAnchor),
        ])

        NSLayoutConstraint.activate([
            authorLabel.leadingAnchor
                .constraint(
                    equalTo: authorLabelContainer.leadingAnchor,
                    constant: Layout.authorLabelInsets.left
                ),
            authorLabel.topAnchor
                .constraint(
                    equalTo: authorLabelContainer.topAnchor,
                    constant: Layout.authorLabelInsets.top
                ),
            authorLabel.trailingAnchor
                .constraint(
                    equalTo: authorLabelContainer.trailingAnchor,
                    constant: Layout.authorLabelInsets.right
                ),
            authorLabel.bottomAnchor
                .constraint(
                    equalTo: authorLabelContainer.bottomAnchor,
                    constant: Layout.authorLabelInsets.bottom
                ),
        ])

        NSLayoutConstraint.activate([
            authorLeftCorner.trailingAnchor.constraint(equalTo: authorLabelContainer.leadingAnchor),
            authorLeftCorner.leadingAnchor.constraint(equalTo: authorLabelBlockGuide.leadingAnchor),
            authorLeftCorner.bottomAnchor.constraint(equalTo: authorLabelBlockGuide.bottomAnchor),
        ])

        NSLayoutConstraint.activate([
            authorTopCorner.bottomAnchor.constraint(equalTo: authorLabelContainer.topAnchor),
            authorTopCorner.topAnchor.constraint(equalTo: authorLabelBlockGuide.topAnchor),
            authorTopCorner.trailingAnchor.constraint(equalTo: authorLabelBlockGuide.trailingAnchor),
        ])
    }

    private func setAuthorLabelVisible(_ visible: Bool) {
        authorLabelContainer.isHidden = !visible
        authorTopCorner.isHidden = !visible
        authorLeftCorner.isHidden = !visible
    }

}
