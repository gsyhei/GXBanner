//
//  GXBannerFlowLayout.swift
//  GXBannerSample
//
//  Created by Gin on 2020/7/23.
//  Copyright © 2020 gin. All rights reserved.
//

import UIKit

public extension GXBanner {
    struct Scale {
        var scaleX: CGFloat!
        var scaleY: CGFloat!
        
        public init(scale: CGFloat) {
            self.scaleX = scale
            self.scaleY = scale
        }
        public init(sx: CGFloat = 1.0, sy: CGFloat = 1.0) {
            self.scaleX = sx
            self.scaleY = sy
        }
    }
}
public class GXBannerFlowLayout: UICollectionViewFlowLayout {
    public var margin: CGFloat = 0
    public var lineSpacing: CGFloat = 0
    public var minScale: GXBanner.Scale = GXBanner.Scale()
    
    public required init(margin: CGFloat = 0, lineSpacing: CGFloat = 0, minScale: GXBanner.Scale) {
        super.init()
        self.margin = margin
        self.lineSpacing = lineSpacing
        self.minScale = minScale
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func prepare() {
        super.prepare()
        self.scrollDirection = .horizontal
        self.minimumInteritemSpacing = 0
        self.minimumLineSpacing = self.lineSpacing
        self.itemSize = self.itemSize()
    }
    
    public override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard self.minScale.scaleX < 1 || self.minScale.scaleX != self.minScale.scaleY else {
            return super.shouldInvalidateLayout(forBoundsChange: newBounds)
        }
        return true
    }

    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard self.minScale.scaleX < 1 || self.minScale.scaleX != self.minScale.scaleY else {
            return super.layoutAttributesForElements(in: rect)
        }
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
            if self.minScale.scaleX == self.minScale.scaleY {
                let scale = distance/maxDistance * (self.minScale.scaleX - 1) + 1
                attributes.zIndex = (distance >= maxDistance) ? 1 : 0
                if attributesArrayCopy.count == 1 {
                    attributes.center = CGPoint(x: centerX, y: attributes.center.y)
                }
                else if scale < 1.0 {
                    attributes.transform = CGAffineTransform(scaleX: scale, y: scale)
                }
            }
            else {
                let scaleX = distance/maxDistance * (self.minScale.scaleX - 1) + 1
                let scaleY = distance/maxDistance * (self.minScale.scaleY - 1) + 1
                let scale = GXBanner.Scale(sx: scaleX, sy: scaleY)
                attributes.zIndex = (distance >= maxDistance) ? 1 : 0
                if attributesArrayCopy.count == 1 {
                    attributes.center = CGPoint(x: centerX, y: attributes.center.y)
                }
                else if scaleX < 1.0 {
                    let xHeight = self.itemSize.width * (1 - scale.scaleX) * 0.5
                    let yHeight = self.itemSize.height * (1 - scale.scaleY) * 0.5
                    let insets = UIEdgeInsets(top: yHeight, left: xHeight, bottom: yHeight, right: xHeight)
                    attributes.frame = attributes.frame.inset(by: insets)
                }
            }
        }
        return attributesArrayCopy
    }
}

fileprivate extension GXBannerFlowLayout {
    func itemSize() -> CGSize {
        let width: CGFloat = self.collectionView!.frame.size.width - self.margin * 2
        let height: CGFloat = self.collectionView!.frame.size.height
        return CGSize(width: width, height: height)
    }
}

