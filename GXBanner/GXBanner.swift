//
//  GXBanner.swift
//  GXBannerSample
//
//  Created by Gin on 2020/7/24.
//  Copyright © 2020 gin. All rights reserved.
//

import UIKit

public protocol GXBannerDataSource: NSObjectProtocol {
    func numberOfItems() -> Int
    func banner(_ banner: GXBanner, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
}

@objc public protocol GXBannerDelegate: NSObjectProtocol {
    @objc optional func banner(_ banner: GXBanner, didSelectItemAt indexPath: IndexPath)
    @objc optional func pageControl(currentPage page: Int)
}

private let GXInsetCount: Int = 2
public class GXBanner: UIView {
    private var currentIndex: Int = GXInsetCount
    private var collectionView: UICollectionView!
    private var flowLayout: GXBannerFlowLayout!
    public weak var dataSource: GXBannerDataSource?
    public weak var delegate: GXBannerDelegate?
    
    public var isAutoPlay: Bool = true
    public var autoTimeInterval: TimeInterval = 5.0
    public var isShowPageControl: Bool = true {
        didSet {
            self.pageControl.isHidden = !self.isShowPageControl
        }
    }
    public override var backgroundColor: UIColor? {
        didSet {
            self.collectionView.backgroundColor = self.backgroundColor
        }
    }
    
    private(set) lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.pageIndicatorTintColor = UIColor.black
        pageControl.currentPageIndicatorTintColor = UIColor.white
        pageControl.hidesForSinglePage = true
        pageControl.addTarget(self, action: #selector(self.pageControlChanged(_:)), for: .valueChanged)
        return pageControl
    }()
    
    deinit {
        self.bannerStop()
    }
    
    public required init(frame: CGRect = .zero, margin: CGFloat = 0, lineSpacing: CGFloat = 0, minScale: Scale = Scale()) {
        super.init(frame: frame)
        self.flowLayout = GXBannerFlowLayout(margin: margin, lineSpacing: lineSpacing, minScale: minScale)
        self.setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.collectionView.frame = self.bounds
        self.updatePageControl()
    }
    
    private func setupSubviews() {
        self.collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: self.flowLayout)
        self.collectionView.backgroundColor = .clear
        self.collectionView.isScrollEnabled = true
        self.collectionView.isPagingEnabled = false
        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.addSubview(self.collectionView)
        self.addSubview(self.pageControl)
    }
    
    private func updatePageControl() {
        var size = self.pageControl.size(forNumberOfPages: self.pageControl.numberOfPages)
        size.width = min(self.flowLayout.itemSize.width, size.width)
        self.pageControl.frame = CGRect(origin: .zero, size: size)
        var center = self.center
        center.y = self.flowLayout.itemSize.height - self.pageControl.frame.height * 0.5
        self.pageControl.center = center
    }
}

fileprivate extension GXBanner {
    func realNumberOfItems() -> Int {
        return self.dataSource?.numberOfItems() ?? 0
    }
    func numberOfItems() -> Int {
        let count = self.dataSource?.numberOfItems() ?? 0
        self.pageControl.numberOfPages = count
        guard count > 1 else { return count }
        return count + GXInsetCount * 2
    }
    func realIndex(index: Int) -> Int {
        let count = self.dataSource?.numberOfItems() ?? 0
        guard count > 1 else { return count }
        return (index + count - GXInsetCount) % count
    }
    func realIndexPath(index: Int) -> IndexPath {
        return IndexPath(item: self.realIndex(index: index), section: 0)
    }
    func index(realIndex: Int) -> Int {
        let count = self.dataSource?.numberOfItems() ?? 0
        guard count > 1 else { return 0 }
        return realIndex + GXInsetCount
    }
    func indexPath(realIndex: Int) -> IndexPath {
        return IndexPath(item: self.index(realIndex: realIndex), section: 0)
    }
    func setCurrentPage(_ page: Int) {
        if (delegate?.responds(to: #selector(delegate?.pageControl(currentPage:))) ?? false) {
            self.delegate?.pageControl?(currentPage: page)
        } else {
            if self.pageControl.currentPage != page {
                self.pageControl.currentPage = page
            }
        }
    }
    func checkRealOutOfBounds() {
        if self.currentIndex <= (GXInsetCount - 1) {
            self.currentIndex = self.realNumberOfItems() + GXInsetCount - 1
            self.scrollToItem(at: self.currentIndex, animated: false)
        }
        else if self.currentIndex >= (self.realNumberOfItems() + GXInsetCount) {
            self.currentIndex = GXInsetCount
            self.scrollToItem(at: self.currentIndex, animated: false)
        }
    }
    func bannerPlay() {
        self.bannerStop()
        self.perform(#selector(self.bannerScrollNext), with: nil, afterDelay: self.autoTimeInterval)
    }
    func bannerStop() {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
    }
    @objc func pageControlChanged(_ sender: UIPageControl) {
        self.bannerStop()
        self.scrollToItem(realAt: sender.currentPage, animated: true)
    }
    @objc func bannerScrollNext() {
        guard self.isAutoPlay && self.realNumberOfItems() > 1 else { return }
        self.currentIndex += 1
        self.scrollToItem(at: self.currentIndex, animated: true)
        self.perform(#selector(self.bannerScrollNext), with: nil, afterDelay: self.autoTimeInterval)
    }
}

public extension GXBanner {
    final func playStart() {
        self.isAutoPlay = true
        self.bannerPlay()
    }
    final func playStop() {
        self.isAutoPlay = false
        self.bannerStop()
    }
    final func register<T: UICollectionViewCell>(classCellType: T.Type) {
        let cellID = String(describing: classCellType)
        self.collectionView.register(classCellType, forCellWithReuseIdentifier: cellID)
    }
    final func register<T: UICollectionViewCell>(nibCellType: T.Type) {
        let cellID = String(describing: nibCellType)
        let nib = UINib.init(nibName: cellID, bundle: nil)
        self.collectionView.register(nib, forCellWithReuseIdentifier: cellID)
    }
    final func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath, cellType: T.Type = T.self) -> T {
        let cellID = String(describing: cellType)
        let bareCell = self.collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath)
        guard let cell = bareCell as? T else {
            fatalError(
                "Failed to dequeue a cell with identifier \(cellID) matching type \(cellType.self). "
                    + "Check that the reuseIdentifier is set properly in your XIB/Storyboard "
                    + "and that you registered the cell beforehand"
            )
        }
        return cell
    }
    final func reloadData() {
        let count = self.dataSource?.numberOfItems() ?? 0
        self.collectionView.isUserInteractionEnabled = count > 1
        self.collectionView.reloadData()
        self.updatePageControl()
        self.scrollToItem(realAt: 0, animated: true)
    }
    final func scrollToItem(realAt index: Int, animated: Bool) {
        let indexPath = self.indexPath(realIndex: index)
        self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
        self.setCurrentPage(index)
    }
    final func scrollToItem(at index: Int, animated: Bool) {
        let indexPath = IndexPath(item: index, section: 0)
        self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
        let page = self.realIndex(index: index)
        self.setCurrentPage(page)
    }
}

extension GXBanner: UICollectionViewDataSource, UICollectionViewDelegate {
    // MARK: - UICollectionViewDataSource
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.numberOfItems()
    }
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let realIndexPath = self.realIndexPath(index: indexPath.item)
        return self.dataSource?.banner(self, cellForItemAt: realIndexPath) ?? UICollectionViewCell()
    }
    // MARK: - UICollectionViewDelegate
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (delegate?.responds(to: #selector(delegate?.banner(_:didSelectItemAt:))) ?? false) {
            let realIndexPath = self.realIndexPath(index: indexPath.item)
            self.delegate?.banner?(self, didSelectItemAt: realIndexPath)
        }
    }
}
 
extension GXBanner: UIScrollViewDelegate {
    // MARK: - UIScrollViewDelegate
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollView.isPagingEnabled = true
        self.bannerStop()
    }
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    }
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if(velocity.x > 0) {
            self.currentIndex += 1
        }
        else if (velocity.x < 0) {
            self.currentIndex -= 1
        }
        else if (velocity.x == 0) {
            let centerX = scrollView.contentOffset.x + scrollView.frame.size.width * 0.5
            var minDistance: CGFloat = CGFloat.greatestFiniteMagnitude
            let indexPaths = self.collectionView.indexPathsForVisibleItems
            for indexPath in indexPaths {
                let attributes = self.collectionView.layoutAttributesForItem(at: indexPath)
                if let attri = attributes {
                    let distance = abs(attri.center.x - centerX)
                    if (abs(minDistance) > abs(distance)) {
                        minDistance = distance
                        self.currentIndex = attri.indexPath.row
                    }
                }
            }
        }
    }
    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        scrollView.isPagingEnabled = false
        self.scrollToItem(at: self.currentIndex, animated: true)
    }
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollView.isPagingEnabled = false
        self.checkRealOutOfBounds()
        self.bannerPlay()
    }
}
