# GXBanner
一个基于UICollectionView易用易扩展的banner。
备注：开发这一些列分类皆在于提高开发的效率以及改善代码的可读性和重用性，以此献上共勉！

# 喜欢就给个star哦，QQ：279694479。没工作无聊写点东西玩儿！

先上个效果图
--

![](https://raw.github.com/gsyhei/GXBanner/blob/master/GXBanner.gif)
<img src="https://raw.github.com/gsyhei/GXBanner/blob/master/GXBanner.gif" width="320"><br/>


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

private var banner: GXBanner = {
    let width = UIScreen.main.bounds.size.width
    let frame: CGRect = CGRect(x: 0, y: 100, width: width, height: 120)
    return GXBanner(frame: frame, margin: 60, minScale: 0.8)
}()

self.view.addSubview(self.banner)
self.banner.backgroundColor = UIColor.green
self.banner.autoTimeInterval = 2.0
self.banner.dataSource = self
self.banner.delegate = self
self.banner.register(GXBannerTestCell.self, forCellWithReuseIdentifier: GXCellID)
self.banner.reloadData()

extension ViewController: GXBannerDataSource, GXBannerDelegate {
    func numberOfItems() -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: GXBannerTestCell = collectionView.dequeueReusableCell(withReuseIdentifier: GXCellID, for: indexPath) as! GXBannerTestCell
        cell.contentView.backgroundColor = UIColor.red
        cell.textLabel.text = String(indexPath.row)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

```

License
--
MIT
