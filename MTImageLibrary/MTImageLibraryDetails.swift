//
//  MTImageLibraryDetails.swift
//  SwiftDemo
//
//  Created by zhourongqing on 2017/1/11.
//  Copyright © 2017年 mtry. All rights reserved.
//

import UIKit
import Photos

class MTImageLibraryDetails: UIViewController {
    
    fileprivate var selectedIndexPaths = [IndexPath]()
    fileprivate let bottomHeight:CGFloat = 45.0
    fileprivate var imageSizeWH:CGFloat {
        get {
            let minScreenSize = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
            let rowCount:CGFloat = (UI_USER_INTERFACE_IDIOM() == .pad) ? 5 : 4
            let itemSize = minScreenSize / rowCount - ((UI_USER_INTERFACE_IDIOM() == .pad) ? 5 : 3)
            return floor(itemSize)
        }
    }
    
    fileprivate lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: self.imageSizeWH, height: self.imageSizeWH)
        
        let collectionView:UICollectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.white
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(MTImageLibraryDetailsCell.self, forCellWithReuseIdentifier: "MTImageReuseIdentifier")
        return collectionView
    }()
    
    fileprivate lazy var toolBar: MTImageLibraryDetailsToolBar = {
        let bar = MTImageLibraryDetailsToolBar()
        bar.delegate = self
        return bar
    }()
    
    fileprivate var assets = [PHAsset]()
    fileprivate let assetCollection: PHAssetCollection
    init(collection: PHAssetCollection) {
        self.assetCollection = collection
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "取消", style: .done, target: self, action: #selector(touchUpInsideRightBarButtonItem))
        
        self.view.addSubview(self.collectionView)
        if !MTImageLibrary.sharedInstance.allowsCroping {
            self.view.addSubview(self.toolBar)
        }
        
        self.assets += self.assetCollection.assets()
        self.collectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.collectionView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !MTImageLibrary.sharedInstance.allowsCroping {
            var frame: CGRect = self.view.bounds
            frame.size.height = ((UI_USER_INTERFACE_IDIOM() == .phone && (UIApplication.shared.statusBarOrientation == .landscapeLeft || UIApplication.shared.statusBarOrientation == .landscapeRight)) ? 30 : 44)
            frame.origin.y = self.view.bounds.height - frame.height
            self.toolBar.frame = frame
            
            frame = self.view.bounds
            frame.size.height = self.view.bounds.height - self.toolBar.frame.height
            self.collectionView.frame = frame
        }
        
        if self.collectionView.contentOffset.y > self.collectionView.contentSize.height {
            let indexPath = IndexPath(row: self.assets.count - 1, section: 0)
            self.collectionView.scrollToItem(at: indexPath, at: .bottom, animated: false)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.invalidateLayout()
        }
    }
    
    func touchUpInsideRightBarButtonItem() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension MTImageLibraryDetails: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if MTImageLibrary.sharedInstance.allowsCroping {
            let asset = self.assets[indexPath.row]
            let controller = MTImageLibraryCrop(asset: asset)
            self.navigationController?.pushViewController(controller, animated: true)
        } else {
            let controller = MTImageLibraryPreview(showAssets: self.allAssets(), selectAssets: self.selectedAssets(), showIndex: indexPath.row)
            controller.delegate = self
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}

extension MTImageLibraryDetails: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.assets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MTImageReuseIdentifier", for: indexPath)
        if let cell = (cell as? MTImageLibraryDetailsCell), let asset = self.assetAtIndex(indexPath.row) {
            cell.delegate = self
            cell.reload(asset: asset)
            cell.reload(select: self.selectedIndexPaths.contains(indexPath), hidden: MTImageLibrary.sharedInstance.allowsCroping)
        }
        return cell
    }
}

extension MTImageLibraryDetails: UICollectionViewDelegateFlowLayout {
    
    private func space() -> CGFloat {
        let rows = floor(collectionView.frame.width / self.imageSizeWH)
        return (collectionView.frame.width - rows * self.imageSizeWH) / (rows + 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let space = self.space()
        return UIEdgeInsetsMake(space, space, space, space)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return self.space()
    }
}

extension MTImageLibraryDetails: MTImageLibraryDetailsCellDelegate {
    
    func didSelectImage(cell: MTImageLibraryDetailsCell, select: Bool) {
        if let indexPath = self.collectionView.indexPath(for: cell) {
            var isSelect = select
            if isSelect {
                let maxSelectNumber = MTImageLibrary.sharedInstance.maxSelectNumber
                if self.selectedIndexPaths.count >= maxSelectNumber {
                    isSelect = !isSelect
                    
                    let alertController = UIAlertController(title: "最多只能选择\(maxSelectNumber)张图片", message: nil, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "知道了", style: .default))
                    self.present(alertController, animated: true)
                } else {
                    self.selectedIndexPaths.append(indexPath)
                }
            } else {
                if let index = self.selectedIndexPaths.index(of: indexPath) {
                    self.selectedIndexPaths.remove(at: index)
                }
            }
            cell.reload(select: isSelect, hidden: false)
        }
        
        self.toolBar.reload(number: self.selectedIndexPaths.count)
    }
}

extension MTImageLibraryDetails: MTImageLibraryDetailsToolBarDelegate {
    
    func preview() {
        let controller = MTImageLibraryPreview(showAssets: self.selectedAssets(), selectAssets: self.selectedAssets(), showIndex: 0)
        controller.delegate = self
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func finish() {
        MTImageLibrary.sharedInstance.pickerComplete?(self.selectedAssets())
        self.navigationController?.dismiss(animated: true)
    }
}

extension MTImageLibraryDetails: MTImageLibraryPreviewDelegate {
    
    func updateSelect(isSelect: Bool, asset: PHAsset) {
        if let index = self.assets.index(of: asset) {
            let indexPath = IndexPath(row: index, section: 0)
            if isSelect {
                if !self.selectedIndexPaths.contains(indexPath) {
                    self.selectedIndexPaths.append(indexPath)
                }
            } else {
                if let index = self.selectedIndexPaths.index(of: indexPath) {
                    self.selectedIndexPaths.remove(at: index)
                }
            }
        }
        
        self.toolBar.reload(number: self.selectedIndexPaths.count)
    }
    
    func previewFinished() {
        self.finish()
    }
}

extension MTImageLibraryDetails {
    
    func assetAtIndex(_ index: Int) -> PHAsset? {
        if index < self.assets.count {
            return self.assets[index]
        }
        return nil
    }
    
    func allAssets() -> Array<PHAsset> {
        return self.assets
    }
    
    func selectedAssets() -> Array<PHAsset> {
        var array = [PHAsset]()
        for indexPath in self.selectedIndexPaths {
            array.append(self.assets[indexPath.row])
        }
        return array
    }
}
