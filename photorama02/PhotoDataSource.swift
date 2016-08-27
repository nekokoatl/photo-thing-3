//  PhotoDataSource.swift
//  Created by Nekokoatl on 27/08/16.

import UIKit

class PhotoDataSourse: NSObject, UICollectionViewDataSource {

    var photos = [Photo]()
    
    func collectionView(collection: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let identifier = "UICollectionViewCell"
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath)
        return cell
    }
}
