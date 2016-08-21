//  PhotoStore.swift
//  Created by Nekokoatl on 07/08/16.


import Foundation

class PhotoStore {
    
    let session: NSURLSession = {
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        return NSURLSession(configuration: config)
                                }()
    func processRecentPhotosRequest(data data: NSData?, error: NSError) -> PhotosResult {
        guard let jsonData = data else {
            return .Failure(error)
        }
    return FlikrAPI.photosFromJSONData(jsonData)
    }
    
//    func fetchRecentPhotos(){
    func fetchRecentPhotos(completion completion: (PhotosResult) -> Void){
        let url = FlikrAPI.recentPhotosURL()
        let request = NSURLRequest(URL: url)
        let task = session.dataTaskWithRequest(request) {
        (data, response, error) -> Void in
            
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
            let result = self.processRecentPhotosRequest(data: data, error: error)
            completion(result)
                                                        }
        task.resume()
        
                            }
    
                }