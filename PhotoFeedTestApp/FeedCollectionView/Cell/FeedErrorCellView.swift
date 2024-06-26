//
//  FeedErrorCell.swift
//  PhotoFeedTestApp
//
//  Created by Alexander Ermichev on 26.06.2024.
//

import UIKit
import SDWebImage

final class FeedErrorCellView: UICollectionViewCell {

    // MARK: - Public properties

    var onRetryTap: (() -> Void)?

    // MARK: - Constructors

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public methods

    override func layoutSubviews() {
        super.layoutSubviews()

        stack.frame = contentView.bounds.insetBy(dx: 0.0, dy: 16.0)
    }

    // MARK: - Private properties

    private let stack = UIStackView()
    private let message = UILabel()
    private let retry = UIButton(type: .system)

}

private extension FeedErrorCellView {

    // MARK: - Private nested types

    private enum Static {
        static let errorImage = Images.retry.uiImage
            .sd_resizedImage(with: CGSize(width: 32.0, height: 32.0), scaleMode: .aspectFill)?
            .withTintColor(Colors.error.uiColor, renderingMode: .alwaysOriginal)
    }

    // MARK: - Private methods

    private func setupViews() {
        contentView.addSubview(stack)
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8.0

        stack.addArrangedSubview(message)
        message.text = "Error"
        message.font = .boldSystemFont(ofSize: 20.0)
        message.textColor = Colors.error.uiColor

        stack.addArrangedSubview(retry)
        retry.setImage(Static.errorImage, for: .normal)
        retry.addTarget(self, action: #selector(retryTap), for: .touchUpInside)
    }

    @objc func retryTap() {
        onRetryTap?()
    }

}
