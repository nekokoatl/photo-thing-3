
import Foundation
import CoreData


//raw value that matches corresponding Flickr endpoint
enum Method: String {
    case RecentPhotos = "flickr.photos.getRecent"
                    }

enum PhotosResult {
    case Success([Photo])
    case Failure(ErrorType)
                  }

enum FlickrError: ErrorType {
    case InvalidJSONData
                            }


//knowing what Fliсkr API expects
struct FlickrAPI {
    
    //BASE URL тут
    private static let baseURLString = "https://api.flickr.com/services/rest"
    //private видится только внутри этого файла
    
    //api key с сайта
    private static let APIKey = "498f1266828ba891164738c8119dc9bb"
    
    private static let dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()

    
    //в какой урл
    private static func flickrURL(method method: Method,
                                         parameters: [String:String]?) -> NSURL? {
        //       return NSURL()
        // NSURLComponents  - construct nsulr from components
        let components = NSURLComponents(string : baseURLString)!
        
        var queryItems = [NSURLQueryItem]()
        //параметры базовые
        let baseParams = [
            "method": method.rawValue,
            "format": "json",
            "nojsoncallback": "1",
            "api_key": APIKey
        ]
        for (key, value) in baseParams {
            let item = NSURLQueryItem(name: key, value: value)
            queryItems.append(item)
        }
        
        if let additionalParams = parameters {
            for (key, value) in additionalParams {
                let item = NSURLQueryItem(name: key, value: value)
                queryItems.append(item)
            }
        }
        components.queryItems = queryItems
        
        return components.URL!
        
    }
    
    
    
    static func recentPhotosURL() -> NSURL {
        return flickrURL(method: .RecentPhotos,
                         parameters: ["extras": "url_h,date_taken"])!
    }
    
    
    static func photosFromJSONData(data: NSData, inContext context: NSManagedObjectContext) -> PhotosResult {
        do {
            let jsonObject: AnyObject = try NSJSONSerialization.JSONObjectWithData(data, options: [])
            
            guard let
                jsonDictionary = jsonObject as? [NSObject:AnyObject],
                photos = jsonDictionary["photos"] as? [String:AnyObject],
                photosArray = photos["photo"] as? [[String:AnyObject]] else {
                    //ошибка тогда
                    return .Failure(FlickrError.InvalidJSONData)
            }
            var finalPhotos = [Photo]()
            
            for photoJSON in photosArray {
                if let photo = photoFromJSONObject(photoJSON, inContext: context) {
                    finalPhotos.append(photo)
                }
            }
            if finalPhotos.count == 0 && photosArray.count > 0 {
                //фоток нет тоже ошибка
                return .Failure(FlickrError.InvalidJSONData)
            }
            
            return .Success(finalPhotos)
        }
        catch let error {
            return .Failure(error)
        }
    }




//   private мешалось везде :(
    private static func photoFromJSONObject(json: [String: AnyObject], inContext context: NSManagedObjectContext) -> Photo? {
        guard let
            photoID = json["id"] as? String,
            title = json["title"] as? String,
            dateString = json["datetaken"] as? String,
            photoURLString = json["url_h"] as? String,
            url = NSURL(string: photoURLString),
            dateTaken = dateFormatter.dateFromString(dateString) else {
                
                // если что-то не то
                return nil
        }
        
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        let predicate = NSPredicate(format: "photoID == \(photoID)")
        fetchRequest.predicate = predicate
        
        var fetchedPhotos: [Photo]!
        context.performBlockAndWait() {
            fetchedPhotos = try! context.executeFetchRequest(fetchRequest) as! [Photo]
        }
        if fetchedPhotos.count > 0 {
            return fetchedPhotos.first
        }
        
        var photo: Photo!
        context.performBlockAndWait() {
            photo = NSEntityDescription.insertNewObjectForEntityForName("Photo", inManagedObjectContext: context) as! Photo
            photo.title = title
            photo.photoID = photoID
            photo.remoteURL = url
            photo.dateTaken = dateTaken
        }
        
        return photo
    }


}