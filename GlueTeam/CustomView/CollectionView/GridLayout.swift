//
//  GridLayout.swift
//  GlueTeam
//
//  Created by Hưng Phan on 14/10/2023.
//

import UIKit

enum GridStyle {
    case oneSt
    case twoNd
    case thirdRd
}

class GridLayout: UICollectionViewFlowLayout {
    var contentBounds: CGRect = .zero
    var cachedAttributes = [UICollectionViewLayoutAttributes]()
    
    override func prepare() {
        super.prepare()
        guard let collectionView = collectionView else { return }
        
        cachedAttributes.removeAll()
        contentBounds = CGRect(origin: .zero, size: collectionView.bounds.size)
        
        let numberOfItems = collectionView.numberOfItems(inSection: 0)
        var currentRow = 0
        let collectionViewWidth = collectionView.bounds.size.width
        var lastFrame: CGRect = .zero
        let itemWidth = (collectionViewWidth / 3) - 4
        var style: GridStyle = .oneSt
        while currentRow < numberOfItems {
            var segmentFrame: CGRect = .zero
            switch style {
            case .oneSt:
                segmentFrame = CGRect(x: 1, y: lastFrame.maxY + 1.0, width: itemWidth, height: itemWidth)
            case .twoNd:
                segmentFrame = CGRect(x: itemWidth + 2, y: lastFrame.minY, width: itemWidth, height: itemWidth)
            case .thirdRd:
                segmentFrame = CGRect(x: itemWidth * 2 + 3, y: lastFrame.minY, width: itemWidth, height: itemWidth)
            }
            let attributes = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: currentRow, section: 0))
            attributes.frame = segmentFrame
            
            cachedAttributes.append(attributes)
            contentBounds = contentBounds.union(lastFrame)
            
            currentRow += 1
            lastFrame = segmentFrame
            
            switch style {
            case .oneSt:
                style = .twoNd
            case .twoNd:
                style = .thirdRd
            case .thirdRd:
                style = .oneSt
            }
        }
        
    }
    
    override var collectionViewContentSize: CGSize {
        return contentBounds.size
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let collectionView = collectionView else { return false }
        return !newBounds.size.equalTo(collectionView.bounds.size)
    }
    
    /// - Tag: LayoutAttributesForItem
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cachedAttributes[indexPath.item]
    }
    
    /// - Tag: LayoutAttributesForElements
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributesArray = [UICollectionViewLayoutAttributes]()
        
        // Find any cell that sits within the query rect.
        guard let lastIndex = cachedAttributes.indices.last,
              let firstMatchIndex = binSearch(rect, start: 0, end: lastIndex) else { return attributesArray }
        
        // Starting from the match, loop up and down through the array until all the attributes
        // have been added within the query rect.
        for attributes in cachedAttributes[..<firstMatchIndex].reversed() {
            guard attributes.frame.maxY >= rect.minY else { break }
            attributesArray.append(attributes)
        }
        
        for attributes in cachedAttributes[firstMatchIndex...] {
            guard attributes.frame.minY <= rect.maxY else { break }
            attributesArray.append(attributes)
        }
        
        return attributesArray
    }
    
    // Perform a binary search on the cached attributes array.
    func binSearch(_ rect: CGRect, start: Int, end: Int) -> Int? {
        if end < start { return nil }
        
        let mid = (start + end) / 2
        let attr = cachedAttributes[mid]
        
        if attr.frame.intersects(rect) {
            return mid
        } else {
            if attr.frame.maxY < rect.minY {
                return binSearch(rect, start: (mid + 1), end: end)
            } else {
                return binSearch(rect, start: start, end: (mid - 1))
            }
        }
    }
}
