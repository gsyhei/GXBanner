//
//  GXBannerFlowLayout.swift
//  GXBannerSample
//
//  Created by Gin on 2020/7/23.
//  Copyright © 2020 gin. All rights reserved.
//

import UIKit

class GXBannerFlowLayout: UICollectionViewFlowLayout {
    var margin: CGFloat = 0
    var lineSpacing: CGFloat = 0
    var minScale: CGFloat = 0.9

    required init(margin: CGFloat = 0, lineSpacing: CGFloat = 0, minScale: CGFloat = 0.9) {
        super.init()
        self.margin = margin
        self.lineSpacing = lineSpacing
        self.minScale = minScale
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepare() {
        super.prepare()
        self.scrollDirection = .horizontal
        self.minimumInteritemSpacing = 0
        self.minimumLineSpacing = self.lineSpacing
        self.itemSize = self.itemSize()
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let layoutArray: [UICollectionViewLayoutAttributes] = super.layoutAttributesForElements(in: rect) ?? []
        var attributesArrayCopy = [UICollectionViewLayoutAttributes]()
        for attributes in layoutArray {
            let itemAttributesCopy = attributes.copy() as! UICollectionViewLayoutAttributes
            attributesArrayCopy.append(itemAttributesCopy)
        }
        let centerX = self.collectionView!.contentOffset.x + self.collectionView!.frame.size.width * 0.5
        let maxDistance = self.itemSize.width + self.minimumLineSpacing
        for attributes in attributesArrayCopy {
            let distance = abs(attributes.center.x - centerX)
            let scale = distance/maxDistance * (self.minScale - 1) + 1
            attributes.zIndex = (distance >= maxDistance) ? 1 : 0
            if attributesArrayCopy.count == 1 {
                attributes.center = CGPoint(x: centerX, y: attributes.center.y)
            }
            else if scale < 1.0 {
                attributes.transform3D = CATransform3DMakeScale(scale, scale, 1.0)
            }
        }
        return attributesArrayCopy
    }

    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        return proposedContentOffset
    }
}

fileprivate extension GXBannerFlowLayout {
    func itemSize() -> CGSize {
        let width: CGFloat = self.collectionView!.frame.size.width - self.margin * 2
        let height: CGFloat = self.collectionView!.frame.size.height
        return CGSize(width: width, height: height)
    }
}

