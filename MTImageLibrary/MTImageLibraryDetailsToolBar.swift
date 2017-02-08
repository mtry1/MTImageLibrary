//
//  MTImageLibraryDetailsToolBar.swift
//  MTImageOperationDemo
//
//  Created by zhourongqing on 2017/1/17.
//  Copyright © 2017年 mtry. All rights reserved.
//

import UIKit

protocol MTImageLibraryDetailsToolBarDelegate: NSObjectProtocol {
    func preview()
    func finish()
}

class MTImageLibraryDetailsToolBar: UIView {
    
    fileprivate lazy var previewButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.setTitle("预览", for: .normal)
        button.setTitleColor(UIColor(red: 0x02/0xff, green: 0xc6/0xff, blue: 0x0c/0xff, alpha: 1), for: .normal)
        button.setTitleColor(UIColor(red: 0x02/0xff, green: 0xc6/0xff, blue: 0x0c/0xff, alpha: 0.5), for: .disabled)
        button.addTarget(self, action: #selector(touchUpInsidePreviewButton(_:)), for: .touchUpInside)
        return button
    }()
    
    fileprivate lazy var finishButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.setTitle("完成", for: .normal)
        button.setTitleColor(UIColor(red: 0x02/0xff, green: 0xc6/0xff, blue: 0x0c/0xff, alpha: 1), for: .normal)
        button.setTitleColor(UIColor(red: 0x02/0xff, green: 0xc6/0xff, blue: 0x0c/0xff, alpha: 0.5), for: .disabled)
        button.addTarget(self, action: #selector(touchUpInsideFinishButton(_:)), for: .touchUpInside)
        return button
    }()
    
    fileprivate lazy var numberLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14)
        label.backgroundColor = UIColor(red: 0x87/0xff, green: 0xce/0xff, blue: 0x20/0xff, alpha: 1)
        label.clipsToBounds = true
        return label
    }()
    
    weak var delegate:MTImageLibraryDetailsToolBarDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(red: 0xf1/0xff, green: 0xf3/0xff, blue: 0xf6/0xff, alpha: 1)
        self.addSubview(self.previewButton)
        self.addSubview(self.finishButton)
        self.addSubview(self.numberLabel)
        self.previewButton.isEnabled = false
        self.finishButton.isEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var frame: CGRect = self.bounds
        frame.size.width = 50
        self.previewButton.frame = frame
        
        frame.origin.x = self.bounds.width - frame.width
        self.finishButton.frame = frame
        
        frame.size = CGSize(width: 20, height: 20)
        frame.origin.y = self.frame.height / 2 - frame.height / 2
        frame.origin.x = self.finishButton.frame.minX - frame.width + 5
        self.numberLabel.frame = frame
        self.numberLabel.layer.cornerRadius = frame.height / 2
    }
    
    func touchUpInsidePreviewButton(_ button: UIButton) {
        self.delegate?.preview()
    }
    
    func touchUpInsideFinishButton(_ button: UIButton) {
        self.delegate?.finish()
    }
}

extension MTImageLibraryDetailsToolBar {
    
    func reload(number: Int)  {
        self.numberLabel.text = "\(number)"
        self.previewButton.isEnabled = number != 0
        self.finishButton.isEnabled = number != 0
    }
}
