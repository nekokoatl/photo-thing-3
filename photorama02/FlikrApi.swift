
import Foundation


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

static func photosFromJSONData(data: NSData) -> PhotosResult {
            do {
//we have to go deeper O_o
                let jsonObject: AnyObject = try NSJSONSerialization.JSONObjectWithData(data, options: [])
                guard let jsonDictionary = jsonObject as? [NSObject: AnyObject],
                photos = jsonDictionary["photos"] as? [String: AnyObject],
                    photosArray = photos["photo"] as? [[String: AnyObject]] else {
                //ошибка тогда
                return .Failure(FlickrError.InvalidJSONData)
                                                                                 }
                var finalPhotos = [Photo]()
                for photoJSON in photosArray {
                    if let photo = photoFromJSONObject(photoJSON){
                    finalPhotos.append(photo)
                                                                 }
                                             }
                if finalPhotos.count == 0 && photosArray.count > 0 {
                //когда не появилось ничего
                    return .Failure(FlickrError.InvalidJSONData)
                                                                   }
                
                return .Success(finalPhotos)
                }
            catch let error {
                return .Failure(error)
                            }
                                                             }

//knowing what Fliсkr API expects
struct FlikrAPI {
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
    
private static func flickrURL(method method: Method,
                                     parameters: [String:String]?) -> NSURL? {
 //       return NSURL()
 // NSURLComponents  - construct nsulr from components
    let components = NSURLComponents(string : baseURLString)!
    var queryItems = [NSURLQueryItem]()
    
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
    //подозрительно !
                                       }
    
    private static func photoFromJSONObject(json: [String : Anyobject]) -> Photo? {
    guard let photoID = json["id"] as? String,
                title = json["title"] as? String,
                dateString = json["datetaken"] as? String,
                photoURLstring = json["url_h"] as? String,
                url = NSURL(string: photoURLString),
                dateTaken = dateFormatter.dateFromString(dateString) else {
        return nil
                    //если что-то пошло не так^^^
                                                                          }
        return Photo(title: title, photoID: photoID, remoteURL: url, dateTaken: dateTaken)
                                                                                  }
    
                }