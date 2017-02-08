//
//  ViewController.swift
//  MTImageLibraryDemo
//
//  Created by zhourongqing on 2017/2/8.
//  Copyright © 2017年 mtry. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    func touchUpInsideCroperButton(_ button:UIButton) {
        MTImageLibrary.sharedInstance.show(inController: self).error { (message) in
            print(message)
        }.croper { (image) in
            self.imageView.image = image
        }
    }
    
    func touchUpInsidePickerButton(_ button:UIButton) {
        MTImageLibrary.sharedInstance.show(inController: self).error { (message) in
            print(message)
        }.picker(maxNumber: 3) { (images) in
            print(images)
        }
    }
    
    lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.backgroundColor = UIColor.gray
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return view
    }()
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        self.imageView.frame = self.view.bounds
        self.view.addSubview(self.imageView)
        
        let pickerButton = UIButton(frame: CGRect(x: 10, y: self.view.bounds.height - 60, width: 100, height: 50))
        pickerButton.autoresizingMask = [.flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        pickerButton.backgroundColor = UIColor.brown
        pickerButton.setTitle("picker", for: UIControlState.normal)
        pickerButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        pickerButton.addTarget(self, action: #selector(self.touchUpInsidePickerButton(_:)), for: UIControlEvents.touchUpInside)
        self.view.addSubview(pickerButton)
        
        let croperButton = UIButton(frame: CGRect(x: self.view.bounds.width - 110, y: self.view.bounds.height - 60, width: 100, height: 50))
        croperButton.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin, .flexibleBottomMargin]
        croperButton.backgroundColor = UIColor.brown
        croperButton.setTitle("croper", for: UIControlState.normal)
        croperButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        croperButton.addTarget(self, action: #selector(self.touchUpInsideCroperButton(_:)), for: UIControlEvents.touchUpInside)
        self.view.addSubview(croperButton)
    }

}

