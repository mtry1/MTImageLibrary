//
//  MTImageLibraryDetailsCell.swift
//  MTImageOperationDemo
//
//  Created by zhourongqing on 2017/1/17.
//  Copyright © 2017年 mtry. All rights reserved.
//

import UIKit
import Photos

protocol MTImageLibraryDetailsCellDelegate: NSObjectProtocol {
    func didSelectImage(cell: MTImageLibraryDetailsCell, select: Bool)
}

class MTImageLibraryDetailsCell: UICollectionViewCell {
    
    weak var delegate: MTImageLibraryDetailsCellDelegate?
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    lazy var selectButton: UIButton = {
        let button = UIButton()
        button.imageEdgeInsets = UIEdgeInsetsMake(-5, 5, 5, -5)
        button.addTarget(self, action: #selector(touchUpInsideSelectButton(_:)), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.backgroundColor = UIColor.white
        self.contentView.addSubview(self.imageView)
        self.contentView.addSubview(self.selectButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.imageView.frame = self.contentView.bounds
        
        var frame: CGRect = .zero
        frame.size = CGSize(width: 40, height: 40)
        frame.origin.x = self.contentView.bounds.width - frame.width
        frame.origin.y = 0
        self.selectButton.frame = frame
    }
    
    func touchUpInsideSelectButton(_ button: UIButton) {
        button.isSelected = !button.isSelected
        self.delegate?.didSelectImage(cell: self, select: button.isSelected)
    }
    
    func reload(asset: PHAsset) {
        var size: CGSize = .zero
        size.width = self.contentView.frame.height * UIScreen.main.scale
        size.height = size.width
        asset.image(size: size) { (image) in
            self.imageView.image = image
        }
    }
    
    func reload(select: Bool, hidden: Bool) {
        let image = UIImage(named: (select ? "imagePicker_select_" : "imagePicker_select"))
        self.selectButton.setImage(image, for: .normal)
        self.selectButton.isHidden = hidden
        self.selectButton.isSelected = select
    }
}
