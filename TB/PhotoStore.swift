//  PhotoStore.swift
//  Created by Nekokoatl on 07/08/16.

import CoreData
import UIKit

class PhotoStore {
    
    let coreDataStack = CoreDataStack(modelName: "Phtrm")
    let imageStore = ImageStore()
    
    
    enum ImageResult {
        case Success(UIImage)
        case Failure(ErrorType)
    }
    
    enum PhotoError: ErrorType {
        case ImageCreationError
    }
    
    // просто добавили nsurl session⬇️

    let session: NSURLSession = {
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        return NSURLSession(configuration: config)
    }()
    
    //    func fetchRecentPhotos(){
    // data task vs download task vs upload task
    // fetch recent photos создает nsurlrequest а nsurlsession создает nsurlsessiondatatask чтобы передать request на серв
    
    func fetchRecentPhotos(completion completion: (PhotosResult) -> Void) {
        
        let url = FlickrAPI.recentPhotosURL()
        let request = NSURLRequest(URL: url)
        let task = session.dataTaskWithRequest(request) {
            (data, response, error) -> Void in
            
            var result = self.processRecentPhotosRequest(data: data, error: error)
            
            if case let .Success(photos) = result {
                let mainQueueContext = self.coreDataStack.mainQueueContext
                mainQueueContext.performBlockAndWait() {
                    try! mainQueueContext.obtainPermanentIDsForObjects(photos)
                }
                let objectIDs = photos.map{ $0.objectID }
                let predicate = NSPredicate(format: "self IN %@", objectIDs)
                let sortByDateTaken = NSSortDescriptor(key: "dateTaken", ascending: true)
                do {
                    try self.coreDataStack.saveChanges()
                    
                    let mainQueuePhotos = try self.fetchMainQueuePhotos(predicate: predicate, sortDescriptors: [sortByDateTaken])
                    result = .Success(mainQueuePhotos)
                }
                catch let error {
                    result = .Failure(error)
                }
            }
            completion(result)
        }
        task.resume()
        
    }
    
    func processRecentPhotosRequest(data data: NSData?, error: NSError?) -> PhotosResult {
        guard let jsonData = data else {
            return .Failure(error!)
        }
        
        return FlickrAPI.photosFromJSONData(jsonData, inContext: self.coreDataStack.mainQueueContext)
    }
    

//          if let jsonData = data {
//                if let jsonString = NSString(data: jsonData,
//                                             encoding: NSUTF8StringEncoding) {
//                print(jsonString)
//                                                                             }
//            do {
//                let jsonObject: AnyObject = try NSJSONSerialization.JSONObjectWithData(jsonData, options: [])
//                print(jsonObject)
//               }
//            catch let error {
//                print("Error creating Json Object 😥 : \(error)")
//                            }
//                                   }
//            else if let requestError  = error {
//            print("Error fetching recent photos 👻: \(requestError)")
//
//                                              }
//            else {
//                    print("Unexpected error 🙀")
//
//                 }
//            let result = self.processRecentPhotosRequest(data: data, error: error)
//            completion(result)
//                    }
//        task.resume()
//            }

    func fetchImageForPhoto(photo: Photo, completion: (ImageResult) -> Void) {
        let photoKey = photo.photoKey
        if let image = imageStore.imageForKey(photoKey) {
            completion(.Success(image))
            return
        }
        
        let photoURL = photo.remoteURL
        let request = NSURLRequest(URL: photoURL)
        
        let task = session.dataTaskWithRequest(request) {
            (data, response, error) -> Void in
            
            let result = self.processImageRequest(data: data, error: error)
            
            if case let .Success(image) = result {
                photo.image = image
                self.imageStore.setImage(image, forKey: photoKey)
            }
            
            completion(result)
        }
        task.resume()
    }
    
    func processImageRequest(data data: NSData?, error: NSError?) -> ImageResult {
        
        guard let imageData = data, image = UIImage(data: imageData) else {
            
            // 💀
            if data == nil {
                return .Failure(error!)
            }
            else {
                return .Failure(PhotoError.ImageCreationError)
            }
        }
        
        return .Success(image)
    }
    
    func fetchMainQueuePhotos(predicate predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil) throws -> [Photo] {
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.predicate = predicate
        
        let mainQueueContext = self.coreDataStack.mainQueueContext
        var mainQueuePhotos: [Photo]?
        var fetchRequestError: ErrorType?
        mainQueueContext.performBlockAndWait() {
            do {
                mainQueuePhotos = try mainQueueContext.executeFetchRequest(fetchRequest) as? [Photo]
            }
            catch let error {
                fetchRequestError = error
            }
        }
        
        guard let photos = mainQueuePhotos else {
            throw fetchRequestError!
        }
        
        return photos
    }
    
func fetchMainQueueTags(predicate predicate: NSPredicate? = nil,
                                  sortDescriptors: [NSSortDescriptor]? = nil) throws -> [NSManagedObject] {
    let fetchRequest = NSFetchRequest(entityName: "Tag")
    fetchRequest.predicate = predicate
    fetchRequest.sortDescriptors = sortDescriptors
    
    let mainQueueContext = self.coreDataStack.mainQueueContext
    var mainQueueTags: [NSManagedObject]?
    var fetchRequestError: ErrorType?
    mainQueueContext.performBlockAndWait() {
        do {
            mainQueueTags =
                try mainQueueContext.executeFetchRequest(fetchRequest) as? [NSManagedObject]
        } catch let error {
            fetchRequestError = error
        }
    }
    guard let tags = mainQueueTags else {
        throw fetchRequestError!
    }
    return tags
}


}