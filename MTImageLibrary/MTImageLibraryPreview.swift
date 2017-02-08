//
//  MTImageLibraryPreview.swift
//  SwiftDemo
//
//  Created by zhourongqing on 2017/1/11.
//  Copyright © 2017年 mtry. All rights reserved.
//

import UIKit
import Photos

protocol MTImageLibraryPreviewDelegate: NSObjectProtocol {
    func updateSelect(isSelect: Bool, asset: PHAsset)
    func previewFinished()
}

fileprivate class MTImageLibraryPreviewCell: UICollectionViewCell {
    
    lazy var zoomView: MTImageLibraryZoomView = {
        let zoomView = MTImageLibraryZoomView()
        return zoomView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.backgroundColor = UIColor.clear
        self.contentView.addSubview(self.zoomView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.zoomView.frame = UIScreen.main.bounds
    }
    
    func reload(asset: PHAsset) {
        asset.image(size: PHImageManagerMaximumSize) { (image) in
            if let image = image {
                self.zoomView.reload(image: image)
                self.setNeedsLayout()
            }
        }
    }
}

class MTImageLibraryPreview: UIViewController {
    
    fileprivate lazy var topBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0x28/0xff, green: 0x28/0xff, blue: 0x28/0xff, alpha: 0.8)
        return view
    }()
    
    fileprivate lazy var bottomBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0x28/0xff, green: 0x28/0xff, blue: 0x28/0xff, alpha: 0.8)
        return view
    }()
    
    fileprivate lazy var backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named:"image_back"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 5)
        button.addTarget(self, action: #selector(touchUpInsideBackButton(_:)), for: .touchUpInside)
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
    
    fileprivate lazy var selectButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(touchUpInsideSelectButton(_:)), for: .touchUpInside)
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
    
    fileprivate lazy var collectionView: UICollectionView = {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = UIColor.clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(MTImageLibraryPreviewCell.self, forCellWithReuseIdentifier: "MTImageLibraryPreviewIdentifier")
        return collectionView
    }()
    
    weak var delegate: MTImageLibraryPreviewDelegate?
    
    fileprivate let showAssets:Array<PHAsset>
    fileprivate var selectAssets:Array<PHAsset>
    fileprivate var showIndex: Int
    init(showAssets: Array<PHAsset>, selectAssets: Array<PHAsset>, showIndex: Int) {
        self.showAssets = showAssets
        self.selectAssets = selectAssets
        self.showIndex = showIndex
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        
        self.view.addSubview(self.collectionView)
        self.view.addSubview(self.topBackgroundView)
        self.view.addSubview(self.bottomBackgroundView)
        self.topBackgroundView.addSubview(self.backButton)
        self.topBackgroundView.addSubview(self.selectButton)
        self.bottomBackgroundView.addSubview(self.numberLabel)
        self.bottomBackgroundView.addSubview(self.finishButton)
        
        self.collectionView.reloadData()
        self.reloadAllStatus()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.invalidateLayout()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        var frame: CGRect = self.view.bounds
        frame.size.height = ((UI_USER_INTERFACE_IDIOM() == .phone && (UIApplication.shared.statusBarOrientation == .landscapeLeft || UIApplication.shared.statusBarOrientation == .landscapeRight)) ? 30 : 64)
        self.topBackgroundView.frame = frame
        
        frame.size.height = ((UI_USER_INTERFACE_IDIOM() == .phone && (UIApplication.shared.statusBarOrientation == .landscapeLeft || UIApplication.shared.statusBarOrientation == .landscapeRight)) ? 30 : 44)
        frame.origin.y = self.view.frame.height - frame.height
        self.bottomBackgroundView.frame = frame
        
        frame.size.width = 50
        frame.size.height = self.topBackgroundView.frame.height - UIApplication.shared.statusBarFrame.height
        frame.origin.x = 0
        frame.origin.y = ((UI_USER_INTERFACE_IDIOM() == .phone && (UIApplication.shared.statusBarOrientation == .landscapeLeft || UIApplication.shared.statusBarOrientation == .landscapeRight)) ? 0 : 0)
        self.backButton.frame = frame
        
        frame.origin.x = self.topBackgroundView.frame.width - frame.width
        self.selectButton.frame = frame
        
        frame = self.bottomBackgroundView.bounds
        frame.size.width = 50
        frame.origin.x = self.bottomBackgroundView.frame.width - frame.width
        self.finishButton.frame = frame
        
        frame.size = CGSize(width: 20, height: 20)
        frame.origin.y = self.bottomBackgroundView.frame.height / 2 - frame.height / 2
        frame.origin.x = self.finishButton.frame.minX - frame.width + 5
        self.numberLabel.frame = frame
        self.numberLabel.layer.cornerRadius = frame.height / 2
        
        frame = self.view.bounds
        frame.size.width += 10
        self.collectionView.frame = frame
        
        self.collectionView.scrollToItem(at: IndexPath(row: self.showIndex, section: 0), at: .left, animated: false)
    }
    
    fileprivate func relaodCurrentSelectImage() {
        let asset = self.showAssets[self.showIndex]
        let select = self.selectAssets.contains(asset)
        let imageName = select ? "imagePicker_select_" : "imagePicker_select"
        self.selectButton.setImage(UIImage(named: imageName), for: .normal)
    }
    
    fileprivate func reloadAllStatus() {
        self.numberLabel.text = "\(self.selectAssets.count)"
        self.finishButton.isEnabled = self.selectAssets.count > 0
        self.relaodCurrentSelectImage()
    }
    
    func touchUpInsideBackButton(_ button: UIButton) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func touchUpInsideSelectButton(_ button: UIButton) {
        let asset = self.showAssets[self.showIndex]
        if self.selectAssets.contains(asset) {
            if let index = self.selectAssets.index(of: asset) {
                self.selectAssets.remove(at: index)
                self.delegate?.updateSelect(isSelect: false, asset: asset)
            }
        } else {
            let maxSelectNumber = MTImageLibrary.sharedInstance.maxSelectNumber
            if self.selectAssets.count >= maxSelectNumber {
                let alertController = UIAlertController(title: "最多只能选择\(maxSelectNumber)张图片", message: nil, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "知道了", style: .default))
                self.present(alertController, animated: true)
                return
            } else {
                self.selectAssets.append(asset)
                self.delegate?.updateSelect(isSelect: true, asset: asset)
            }
        }
        self.reloadAllStatus()
    }
    
    func touchUpInsideFinishButton(_ button: UIButton) {
        self.delegate?.previewFinished()
    }
}

extension MTImageLibraryPreview: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
}

extension MTImageLibraryPreview: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.showAssets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MTImageLibraryPreviewIdentifier", for: indexPath) as! MTImageLibraryPreviewCell
        cell.reload(asset: self.showAssets[indexPath.row])
        cell.zoomView.delegate = self
        return cell
    }
}

extension MTImageLibraryPreview: MTImageZoomViewScrollViewDelegate {
    
    func didSingleTouch() {
        let alpha: CGFloat = self.topBackgroundView.alpha == 0 ? 1 : 0
        UIView.animate(withDuration: 0.2) {
            self.topBackgroundView.alpha = alpha
            self.bottomBackgroundView.alpha = alpha
        }
    }
}

extension MTImageLibraryPreview: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.showIndex = Int(scrollView.contentOffset.x / self.collectionView.frame.width)
        self.relaodCurrentSelectImage()
    }
}
