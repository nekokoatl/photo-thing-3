//  PhotosVC.swift
//  Created by Nekokoatl on 24/07/16.

import UIKit

class PhotosVC: UIViewController {
    
    @IBOutlet var collectionView: UICollectionView!
    
    var store = PhotoStore()
    //property injection ^^
    let photoDataSource = PhotoDataSourse()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = photoDataSource
        
        
        store.fetchRecentPhotos() {
            (photosResult) -> Void in
            
            switch photosResult {
            case let .Success(photos):
                print("found \(photos.count)")
            case let .Failure(error):
                print("smth is wrong \(error)")
        }
    }
    
    
                                 }
}
