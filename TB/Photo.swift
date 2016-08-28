//  Photo.swift
//  Created by Nekokoatl on 08/08/16.

import Foundation

class Photo {
    let title: String
    let remoteURL: NSURL
    let photoID: String
    let dateTaken: NSDate
    
    init(title: String, photoID: String, remoteURL: NSURL, dateTaken: NSDate){
        self.title = title
        self.photoID = photoID
        self.remoteURL = remoteURL
        self.dateTaken = dateTaken
            }
    }