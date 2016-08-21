//
//  PhotosVC.swift
//  photorama02
//
//  Created by Nekokoatl on 24/07/16.
//  Copyright © 2016 nekokoatl. All rights reserved.
//

import UIKit

class PhotosVC: UIViewController {
    
    @IBOutlet var imageView: UIImageView!
    
    var store = PhotoStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        store.fetchRecentPhotos()
    }
    
                                 }
