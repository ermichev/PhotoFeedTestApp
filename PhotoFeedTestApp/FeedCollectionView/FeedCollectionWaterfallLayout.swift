//
//  FeedCollectionWaterfallLayout.swift
//  PhotoFeedTestApp
//
//  Created by Alexander Ermichev on 12.06.2024.
//

import UIKit

/*
 Slightly simplified and refactored CHTCollectionViewWaterfallLayout:
 https://github.com/chiahsien/CHTCollectionViewWaterfallLayout
*/
final class FeedCollectionWaterfallLayout: UICollectionViewLayout {

    // MARK: - Configuration

    var estimatedColumnWidth: CGFloat = 300.0 {
        didSet { invalidateLayout() }
    }

    var contentInsets: UIEdgeInsets = .init(top: 0.0, left: 16.0, bottom: 0.0, right: 16.0) {
        didSet { invalidateLayout() }
    }

    var columnSpacing: CGFloat = 16.0 {
        didSet { invalidateLayout() }
    }

    var interitemSpacing: CGFloat = 16.0 {
        didSet { invalidateLayout() }
    }

    // MARK: - Layout

    override func prepare() {
        super.prepare()

        guard let collectionView else { return }
        
        let numberOfSections = collectionView.numberOfSections
        guard collectionView.numberOfSections > 0 else { return }

        unionRects = []
        allItemAttributes = []
        sectionItemAttributes = []

        columnCount = calculatedColumnCount()
        columnHeights = (0..<numberOfSections).map { _ in
            Array(repeating: 0.0, count: columnCount)
        }

        var attributes = UICollectionViewLayoutAttributes()

        for section in 0..<numberOfSections {
            let itemWidth = calculatedItemWidth()

            let itemCount = collectionView.numberOfItems(inSection: section)
            var itemAttributes: [UICollectionViewLayoutAttributes] = []

            // Item will be put into shortest column.
            for idx in 0..<itemCount {
                let indexPath = IndexPath(item: idx, section: section)

                let columnIndex = nextColumnIndexForItem(idx, inSection: section)
                let xOffset = contentInsets.left + (itemWidth + columnSpacing) * CGFloat(columnIndex)

                let yOffset = columnHeights[section][columnIndex]

                let itemSize = delegate?.collectionView?(
                    collectionView,
                    layout: self,
                    sizeForItemAt: indexPath
                )

                guard let itemSize, itemSize.height > 0.0, itemSize.width > 0.0 else {
                    assertionFailure("In current use case item size must always be present.")
                    continue
                }

                let itemHeight = floor(itemSize.height * itemWidth / itemSize.width)

                attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = CGRect(x: xOffset, y: yOffset, width: itemWidth, height: itemHeight)

                itemAttributes.append(attributes)
                allItemAttributes.append(attributes)
                columnHeights[section][columnIndex] = attributes.frame.maxY + interitemSpacing
            }

            sectionItemAttributes.append(itemAttributes)
        }

        var idx = 0
        let itemCounts = allItemAttributes.count
        while idx < itemCounts {
            let rect1 = allItemAttributes[idx].frame
            idx = min(idx + unionSize, itemCounts) - 1
            let rect2 = allItemAttributes[idx].frame
            unionRects.append(rect1.union(rect2))
            idx += 1
        }
    }

    override var collectionViewContentSize: CGSize {
        guard let collectionView else { return .zero }
        guard collectionView.numberOfSections > 0 else { return .zero }

        var contentSize = collectionView.bounds.size
        contentSize.width = contentWidth()

        if let height = columnHeights.last?.first {
            contentSize.height = height
            return contentSize
        }
        return .zero
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard indexPath.section < sectionItemAttributes.count else { return nil }
        let list = sectionItemAttributes[indexPath.section]
        guard indexPath.item < list.count else { return nil }
        return list[indexPath.item]
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var begin = 0, end = unionRects.count

        if let i = unionRects.firstIndex(where: { rect.intersects($0) }) {
            begin = i * unionSize
        }
        if let i = unionRects.lastIndex(where: { rect.intersects($0) }) {
            end = min((i + 1) * unionSize, allItemAttributes.count)
        }
        return allItemAttributes[begin..<end]
            .filter { rect.intersects($0.frame) }
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return newBounds.width != collectionView?.bounds.width
    }

    // MARK: - Private properties

    private var columnCount: Int = 2
    private var columnHeights: [[CGFloat]] = []
    private var allItemAttributes: [UICollectionViewLayoutAttributes] = []
    private var sectionItemAttributes: [[UICollectionViewLayoutAttributes]] = []
    private var unionRects: [CGRect] = []
    private let unionSize = 20

    // -

    private var delegate: UICollectionViewDelegateFlowLayout? {
        collectionView?.delegate as? UICollectionViewDelegateFlowLayout
    }

    private func contentWidth() -> CGFloat {
        guard let collectionView else { return .zero }
        let insets = collectionView.safeAreaInsets
        return collectionView.bounds.size.width - insets.left - insets.right
    }

    private func calculatedColumnCount() -> Int {
        // x * itemWidth + (x - 1) * spacing = avaliableWidth
        // x * (itemWidth + spacing) = avaliableWidth + spacing
        // x = (avaliableWidth + spacing) / (itemWidth + spacing)
        let avaliableWidth = contentWidth()
        let spacing = columnSpacing
        let itemWidth = estimatedColumnWidth
        return Int(round((avaliableWidth + spacing) / (itemWidth + spacing)))
    }

    private func calculatedItemWidth() -> CGFloat {
        let columnCount = calculatedColumnCount()
        let widthAvailableForItems = contentWidth()
            - (CGFloat(columnCount - 1) * columnSpacing)
            - (contentInsets.left + contentInsets.right)
        return floor(widthAvailableForItems / CGFloat(columnCount))
    }

    private func nextColumnIndexForItem(_ item: Int, inSection section: Int) -> Int {
        // Item will be added to the shortest column
        columnHeights[section].enumerated()
            .min(by: { $0.element < $1.element })?
            .offset ?? 0
    }

}
