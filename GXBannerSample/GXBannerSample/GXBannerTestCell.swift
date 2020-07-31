//
//  GXBannerTestCell.swift
//  GXBannerSample
//
//  Created by Gin on 2020/7/24.
//  Copyright © 2020 gin. All rights reserved.
//

import UIKit

class GXBannerTestCell: UICollectionViewCell {
    
    lazy var iconIView: UIImageView = {
        return UIImageView()
    }()
    
    lazy var textLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 40)
        return label
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.iconIView.frame = self.bounds
        self.textLabel.frame = self.bounds
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(self.iconIView)
        self.contentView.addSubview(self.textLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
