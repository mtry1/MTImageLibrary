//
//  MTImageLibraryCrop.swift
//  MTImageOperationDemo
//
//  Created by zhourongqing on 2017/1/23.
//  Copyright © 2017年 mtry. All rights reserved.
//

import UIKit
import Photos

class MTImageLibraryCrop: UIViewController {
    
    fileprivate lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.clipsToBounds = false
        view.delegate = self
        view.maximumZoomScale = 5
        view.minimumZoomScale = 1
        return view
    }()
    
    fileprivate lazy var imageView: UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    fileprivate lazy var maskView: MTImageLibraryCropMaskView = {
        let view = MTImageLibraryCropMaskView()
        return view
    }()
    
    fileprivate lazy var bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0x28/0xff, green: 0x28/0xff, blue: 0x28/0xff, alpha: 0.8)
        return view
    }()
    
    fileprivate lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.setTitle("取消", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.addTarget(self, action: #selector(touchUpInsideCancelButton(_:)), for: .touchUpInside)
        return button
    }()
    
    fileprivate lazy var finishButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.setTitle("完成", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.addTarget(self, action: #selector(touchUpInsideFinishButton(_:)), for: .touchUpInside)
        return button
    }()
    
    fileprivate let asset: PHAsset
    init(asset: PHAsset) {
        self.asset = asset
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        self.view.clipsToBounds = true
        
        self.scrollView.addSubview(self.imageView)
        self.view.addSubview(self.scrollView)
        self.view.addSubview(self.maskView)
        self.view.addSubview(self.bottomView)
        self.bottomView.addSubview(self.cancelButton)
        self.bottomView.addSubview(self.finishButton)
        
        self.asset.image(size: PHImageManagerMaximumSize) { (image) in
            self.imageView.image = image
            self.view.setNeedsLayout()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        var frame: CGRect = self.view.bounds
        frame.size.height = ((UI_USER_INTERFACE_IDIOM() == .phone && (UIApplication.shared.statusBarOrientation == .landscapeLeft || UIApplication.shared.statusBarOrientation == .landscapeRight)) ? 30 : 44)
        frame.origin.y = self.view.frame.height - frame.height
        self.bottomView.frame = frame
        
        frame = self.bottomView.bounds
        frame.size.width = 50
        self.cancelButton.frame = frame
        
        frame.origin.x = self.bottomView.frame.width - frame.width
        self.finishButton.frame = frame
        
        let sizeWH = ((UIApplication.shared.statusBarOrientation == .portrait || UIApplication.shared.statusBarOrientation == .portraitUpsideDown) ? self.view.frame.width : self.view.frame.height - self.bottomView.frame.height - UIApplication.shared.statusBarFrame.height)
        frame.size = CGSize(width: sizeWH, height: sizeWH)
        frame.origin.x = (self.view.frame.width - frame.width) / 2
        frame.origin.y = (UIApplication.shared.statusBarOrientation == .landscapeLeft || UIApplication.shared.statusBarOrientation == .landscapeRight) ? UIApplication.shared.statusBarFrame.height : (self.view.frame.height - frame.height) / 2
        self.maskView.cropFrame = frame
        self.maskView.frame = self.view.bounds
        self.maskView.setNeedsDisplay()
        
        self.scrollView.zoomScale = 1
        self.update()
    }
    
    fileprivate func update() {
        
        guard self.imageView.image != nil else {
            self.imageView.frame = .zero
            return
        }
        
        let imageSize: CGSize = self.imageView.image?.size ?? .zero
        let imageWHScale = imageSize.width / imageSize.height
        let containerSize = CGSize(width: self.view.frame.width, height: ((UIApplication.shared.statusBarOrientation == .portrait || UIApplication.shared.statusBarOrientation == .portraitUpsideDown) ? self.view.frame.height : self.maskView.cropFrame.height))
        let containerWHScale = containerSize.width / containerSize.height
        
        var frame: CGRect = .zero
        if imageWHScale > containerWHScale {
            frame.size.width = containerSize.width
            frame.size.height = frame.size.width / imageWHScale
        } else {
            frame.size.height = containerSize.height
            frame.size.width = frame.size.height * imageWHScale
        }
        self.imageView.frame = frame
        
        var contentFrame = self.maskView.cropFrame
        var contentSize: CGSize = .zero
        var contentOffset: CGPoint = .zero
        
        if self.imageView.frame.height > contentFrame.height {
            contentSize.height = self.imageView.frame.height
            contentOffset.y = (self.imageView.frame.height - contentFrame.height)/2
        } else {
            contentFrame.size.height = self.imageView.frame.height
            contentFrame.origin.y = self.maskView.cropFrame.minY + (self.maskView.cropFrame.height - self.imageView.frame.height)/2
            contentSize.height = self.imageView.frame.height + 1
        }
        
        if self.imageView.frame.width > contentFrame.width {
            contentSize.width = self.imageView.frame.width
            contentOffset.x = (self.imageView.frame.width - contentFrame.width)/2
        } else {
            contentFrame.size.width = self.imageView.frame.width
            contentFrame.origin.x = self.maskView.cropFrame.minX + (self.maskView.cropFrame.width - self.imageView.frame.width)/2
            contentSize.width = self.imageView.frame.width + 1
        }
        
        self.scrollView.frame = contentFrame
        self.scrollView.contentSize = contentSize
        self.scrollView.contentOffset = contentOffset
        self.scrollView.contentInset = .zero
    }
    
    func touchUpInsideCancelButton(_ button: UIButton) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func touchUpInsideFinishButton(_ button: UIButton) {
        var cropRect: CGRect = .zero
        cropRect.origin.x = floor(self.scrollView.contentOffset.x + self.scrollView.contentInset.left + 0.5)
        cropRect.origin.y = floor(self.scrollView.contentOffset.y + self.scrollView.contentInset.top + 0.5)
        cropRect.size.width = floor(self.imageView.frame.width < self.maskView.cropFrame.width ? self.imageView.frame.width : self.maskView.cropFrame.width) - 1
        cropRect.size.height = floor(self.imageView.frame.height < self.maskView.cropFrame.height ? self.imageView.frame.height : self.maskView.cropFrame.height) - 1
        let image = self.crop(cropView: self.imageView, cropRect: cropRect)
        MTImageLibrary.sharedInstance.croperComplete?(image)
        self.navigationController?.dismiss(animated: true)
    }
    
    fileprivate func crop(cropView: UIImageView, cropRect: CGRect) -> UIImage? {
        let showImageSize = cropView.frame.size
        let UIScreenScale = UIScreen.main.scale
        if let originalImage = cropView.image {
            UIGraphicsBeginImageContextWithOptions(showImageSize, false, UIScreenScale)
            originalImage.draw(in: CGRect(x: 0, y: 0, width: showImageSize.width, height: showImageSize.height))
            let showImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            if let showImage = showImage, let cgShowImage = showImage.cgImage {
                if let cropCGShowImage = cgShowImage.cropping(to: CGRect(x: cropRect.minX * UIScreenScale, y: cropRect.minY * UIScreenScale, width: cropRect.width * UIScreenScale, height: cropRect.height * UIScreenScale)) {
                    return UIImage(cgImage: cropCGShowImage, scale: UIScreenScale, orientation: .up)
                }
            }
        }
        return nil
    }
}

extension MTImageLibraryCrop: UIScrollViewDelegate {
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        
        if self.imageView.frame.height >= self.scrollView.frame.height {
            if self.imageView.frame.height <= self.maskView.cropFrame.height {
                self.scrollView.contentInset.top = -(self.imageView.frame.height - self.scrollView.frame.height)/2
                self.scrollView.contentInset.bottom = self.scrollView.contentInset.top
                
                var contentSize = self.scrollView.contentSize
                contentSize.height = self.imageView.frame.height + 1
                self.scrollView.contentSize = contentSize
            } else {
                self.scrollView.contentInset.top = -(self.maskView.cropFrame.height - self.scrollView.frame.height)/2
                self.scrollView.contentInset.bottom = self.scrollView.contentInset.top
                
                var contentSize = self.scrollView.contentSize
                contentSize.height = self.maskView.cropFrame.height + 1
            }
        }
        
        if self.imageView.frame.width >= self.scrollView.frame.width {
            if self.imageView.frame.width <= self.maskView.cropFrame.width {
                self.scrollView.contentInset.left = -(self.imageView.frame.width - self.scrollView.frame.width)/2
                self.scrollView.contentInset.right = self.scrollView.contentInset.left
                
                var contentSize = self.scrollView.contentSize
                contentSize.width = self.imageView.frame.width + 1
                self.scrollView.contentSize = contentSize
            } else {
                self.scrollView.contentInset.left = -(self.maskView.cropFrame.width - self.scrollView.frame.width)/2
                self.scrollView.contentInset.right = self.scrollView.contentInset.left
                
                var contentSize = self.scrollView.contentSize
                contentSize.width = self.maskView.cropFrame.width + 1
            }
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}

fileprivate class MTImageLibraryCropMaskView: UIView {
    
    var cropFrame: CGRect = .zero
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.isUserInteractionEnabled = false
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.setFillColor(UIColor(white: 0, alpha: 0.5).cgColor)
        ctx?.fill(rect)
        
        ctx?.setStrokeColor(UIColor.white.cgColor)
        ctx?.stroke(self.cropFrame.insetBy(dx: 1, dy: 1), width: 1.5)
        ctx?.addRect(self.cropFrame.insetBy(dx: 1, dy: 1))
        ctx?.setBlendMode(.clear)
        ctx?.fillPath()
    }
}
