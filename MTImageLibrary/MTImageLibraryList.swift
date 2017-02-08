//
//  MTImageLibraryList.swift
//  SwiftDemo
//
//  Created by zhourongqing on 2017/1/11.
//  Copyright © 2017年 mtry. All rights reserved.
//

import UIKit
import Photos

class MTImageLibraryList: UIViewController {
    
    fileprivate var collections = [PHAssetCollection]()
    
    private lazy var tableView: UITableView = {
        let tableView:UITableView = UITableView(frame: self.view.bounds, style: .plain)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "照片"
        self.view.backgroundColor = UIColor.white
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "取消", style: .done, target: self, action: #selector(touchUpInsideRightBarButtonItem))
        self.view.addSubview(self.tableView)
        
        self.loadData()
    }
    
    func touchUpInsideRightBarButtonItem() {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func loadData() {
        MTImageLibraryDataManager.fetchCollectionData { (collections) in
            self.collections = collections
            self.tableView.reloadData()
        }
    }
}

extension MTImageLibraryList: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row < self.collections.count {
            let collection = self.collections[indexPath.row]
            let controller = MTImageLibraryDetails(collection: collection)
            controller.title = collection.localizedTitle
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}

extension MTImageLibraryList: UITableViewDataSource {
    
    fileprivate var cellHeight: CGFloat {
        return (UI_USER_INTERFACE_IDIOM() == .pad) ? 80 : 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.collections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "MTImageLibraryListIdentifier"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: identifier)
            cell?.accessoryType = .disclosureIndicator
            cell?.imageView?.contentMode = .scaleAspectFill
        }
        
        if indexPath.row < self.collections.count {
            let collection = self.collections[indexPath.row]
            cell?.textLabel?.text = collection.localizedTitle
            cell?.detailTextLabel?.text = "\(collection.numberOfAsset())"
            
            let scale = UIScreen.main.scale
            let imageSize = (self.cellHeight - 5) * scale
            collection.posterImage(size: CGSize(width: imageSize, height: imageSize), complete: { (image) in
                cell?.imageView?.image = image
                cell?.setNeedsLayout()
            })
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.cellHeight
    }
}
