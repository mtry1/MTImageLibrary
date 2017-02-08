//
//  MTImageLibraryZoomView.swift
//  MTImageOperationDemo
//
//  Created by zhourongqing on 2017/2/4.
//  Copyright © 2017年 mtry. All rights reserved.
//

import UIKit

protocol MTImageZoomViewScrollViewDelegate: NSObjectProtocol {
    func didSingleTouch()
}

class MTImageLibraryZoomView: UIView {

    fileprivate lazy var scrollView: MTImageZoomViewScrollView = {
        let scrollView: MTImageZoomViewScrollView = MTImageZoomViewScrollView()
        scrollView.backgroundColor = UIColor.clear
        scrollView.delegate = self
        scrollView.maximumZoomScale = 2.5
        scrollView.minimumZoomScale = 1.0
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    fileprivate lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    private lazy var singleRecognizer: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer()
        tap.numberOfTapsRequired = 1
        tap.addTarget(self, action: #selector(singleTouchGestureRecognizer(_:)))
        return tap
    }()
    
    private lazy var doubleRecognizer: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer()
        tap.numberOfTapsRequired = 2
        tap.addTarget(self, action: #selector(doubleTouchGestureRecognizer(_:)))
        return tap
    }()
    
    weak var delegate: MTImageZoomViewScrollViewDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.scrollView)
        self.scrollView.addSubview(self.imageView)
        self.scrollView.addGestureRecognizer(self.singleRecognizer)
        self.scrollView.addGestureRecognizer(self.doubleRecognizer)
        self.singleRecognizer.require(toFail: self.doubleRecognizer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.scrollView.zoomScale = 1
        self.scrollView.frame = self.bounds
        
        guard self.imageView.image != nil else { return }
        
        let imageSize: CGSize = self.imageView.image?.size ?? .zero
        let containerSize: CGSize = self.scrollView.bounds.size
        let imageWHScale = imageSize.width / imageSize.height
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
        self.scrollView.contentSize = self.imageView.frame.size
        
        self.updateContentInset()
    }
    
    fileprivate func updateContentInset() {
        let containerSize = self.scrollView.bounds.size
        let imageViewSize = self.imageView.frame.size
        
        var insets: UIEdgeInsets = .zero
        if containerSize.width > imageViewSize.width {
            insets.left = containerSize.width/2 - imageViewSize.width/2
        }
        if containerSize.height > imageViewSize.height {
            insets.top = containerSize.height/2 - imageViewSize.height/2
        }
        self.scrollView.contentInset = insets
    }
    
    func doubleTouchGestureRecognizer(_ recognizer: UITapGestureRecognizer) {
        if self.scrollView.zoomScale <= 1 {
            let point = recognizer.location(in: self.scrollView)
            self.scrollView.zoom(to: CGRect(x: point.x, y: point.y, width: 0, height: 0), animated: true)
        } else {
            self.scrollView.setZoomScale(1, animated: true)
        }
    }
    
    func singleTouchGestureRecognizer(_ recognizer: UITapGestureRecognizer) {
        self.delegate?.didSingleTouch()
    }
    
    func reload(image: UIImage?) {
        self.imageView.image = image
        self.setNeedsLayout()
    }
}

extension MTImageLibraryZoomView: UIScrollViewDelegate {
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.updateContentInset()
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}

fileprivate class MTImageZoomViewScrollView: UIScrollView {
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.next?.touchesBegan(touches, with: event)
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.next?.touchesEnded(touches, with: event)
    }
}
