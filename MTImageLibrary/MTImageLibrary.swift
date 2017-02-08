//
//  MTImageLibrary.swift
//  SwiftDemo
//
//  Created by zhourongqing on 2017/1/11.
//  Copyright © 2017年 mtry. All rights reserved.
//

import UIKit
import Photos

typealias MTImageLibraryPickerComplete = (Array<PHAsset>) -> Void
typealias MTImageLibraryCroperComplete = (UIImage?) -> Void
typealias MTImageLibraryErrorHander    = (String) -> Void

class MTImageLibrary: NSObject {
    static let sharedInstance = MTImageLibrary()
    private override init() {}
    
    private(set) var maxSelectNumber: Int = 9
    private(set) var allowsCroping:   Bool = true
    private(set) var pickerComplete:  MTImageLibraryPickerComplete?
    private(set) var croperComplete:  MTImageLibraryCroperComplete?
    private(set) var errorHander:     MTImageLibraryErrorHander?
    
    @discardableResult
    func show(inController: UIViewController) -> MTImageLibrary {
        let status:PHAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        if status == .restricted || status == .denied {
            self.errorHander?("请在设置->隐私->照片中允许访问")
        } else if status == .notDetermined {
            PHPhotoLibrary.requestAuthorization({(s) in
                if s == .authorized {
                    DispatchQueue.main.async {
                        self.show(inController: inController)
                    }
                }
            })
        } else {
            inController.present(UINavigationController(rootViewController: MTImageLibraryList()), animated: true, completion: nil)
        }
        return self
    }
    
    ///picker 和 croper 互斥
    @discardableResult
    func picker(maxNumber: Int, pickerComplete: @escaping MTImageLibraryPickerComplete) -> MTImageLibrary {
        self.allowsCroping = false
        self.maxSelectNumber = maxNumber
        self.pickerComplete = pickerComplete
        self.croperComplete = nil
        return self
    }
    
    ///picker 和 croper 互斥
    @discardableResult
    func croper(croperComplete: @escaping MTImageLibraryCroperComplete) -> MTImageLibrary {
        self.allowsCroping = true
        self.maxSelectNumber = 1
        self.croperComplete = croperComplete
        self.pickerComplete = nil
        return self
    }
    
    @discardableResult
    func error(errorHander: @escaping MTImageLibraryErrorHander) -> MTImageLibrary {
        self.errorHander = errorHander
        return self
    }
}
