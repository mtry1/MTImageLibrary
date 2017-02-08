//
//  MTImageLibraryDataManager.swift
//  SwiftDemo
//
//  Created by zhourongqing on 2017/1/11.
//  Copyright © 2017年 mtry. All rights reserved.
//

import UIKit
import Photos

class MTImageLibraryDataManager: NSObject {
    
    class func fetchCollectionData(complete:@escaping (Array<PHAssetCollection>) -> Void) {
        
        var collections = [PHAssetCollection]()
        let subtypes = [PHAssetCollectionSubtype.smartAlbumUserLibrary,
                        PHAssetCollectionSubtype.smartAlbumRecentlyAdded,
                        PHAssetCollectionSubtype.smartAlbumPanoramas]
        
        let systemCollectionResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil)
        systemCollectionResult.enumerateObjects({(collection, index, stop) in
            if subtypes.contains(collection.assetCollectionSubtype) {
                if collection.numberOfAsset() > 0 {
                    if collection.assetCollectionSubtype == .smartAlbumUserLibrary {
                        collections.insert(collection, at: 0)
                    } else {
                        collections.append(collection)
                    }
                }
            }
        })
        
        let userCollectionResult = PHCollectionList.fetchTopLevelUserCollections(with: nil)
        userCollectionResult.enumerateObjects ({(collection, index, stop) in
            if let collection = collection as? PHAssetCollection {
                if collection.numberOfAsset() > 0 {
                    collections.append(collection)
                }
            }
        })
        
        complete(collections)
    }
}

extension PHAssetCollection {
    
    func numberOfAsset() -> Int {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "mediaType = \(PHAssetMediaType.image.rawValue)", argumentArray: nil)
        let fetchResult = PHAsset.fetchAssets(in: self, options: fetchOptions)
        return fetchResult.count
    }
    
    func posterImage(size: CGSize, complete: @escaping (UIImage?) -> Void) {
        if let asset = self.assets().first {
            asset.image(size: size, complete: complete)
        }
    }
    
    func assets() -> Array<PHAsset> {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "mediaType = \(PHAssetMediaType.image.rawValue)", argumentArray: nil)
        let fetchResult = PHAsset.fetchAssets(in: self, options: fetchOptions)
        var assets = [PHAsset]()
        fetchResult.enumerateObjects({ (asset, index, stop) in
            assets.insert(asset, at: 0)
        })
        return assets
    }
}

extension PHAsset {
    
    func image(size: CGSize, complete: @escaping (UIImage?) -> Void) {
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.resizeMode = .exact
        PHImageManager.default().requestImage(for: self, targetSize: size, contentMode: .aspectFill, options: options) { (image, info) in
            complete(image)
        }
    }
}
