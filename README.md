# GXBanner
一个基于UICollectionView易用易扩展的banner。
备注：开发这一些列分类皆在于提高开发的效率以及改善代码的可读性和重用性，以此献上共勉！

# 喜欢就给个star哦，QQ：279694479。没工作无聊写点东西玩儿！

先上个效果图
--

![image](https://github.com/gsyhei/GXBanner/blob/master/GXBanner.gif)

Requirements
--
- iOS 9.0 or later
- Xcode 10.0 or later
- Swift 5

Usage in you Podfile:
--

```
pod 'GXBanner'
```

使用方法
--
首先import GXBanner，然后直接使用扩展方法就行，是不是很简单😁。

```objc

// 创建
private var banner: GXBanner = {
    let width = UIScreen.main.bounds.size.width
    let frame: CGRect = CGRect(x: 0, y: 100, width: width, height: 120)
    return GXBanner(frame: frame, margin: 60, minScale: 0.8)
}()

// 设置
self.view.addSubview(self.banner)
self.banner.backgroundColor = UIColor.green
self.banner.autoTimeInterval = 2.0
self.banner.dataSource = self
self.banner.delegate = self
self.banner.register(classCellType: GXBannerTestCell.self)
self.banner.reloadData()

// 代理
protocol GXBannerDataSource: NSObjectProtocol {
    func numberOfItems() -> Int
    func banner(_ banner: GXBanner, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
}

@objc protocol GXBannerDelegate: NSObjectProtocol {
    @objc optional func banner(_ banner: GXBanner, didSelectItemAt indexPath: IndexPath)
    @objc optional func pageControl(currentPage page: Int)
}

```

License
--
MIT
