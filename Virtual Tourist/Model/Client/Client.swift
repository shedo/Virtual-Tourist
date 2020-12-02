//
//  Client.swift
//  Virtual Tourist
//
//  Created by Ivan Zandonà on 27/11/20.
//

import Foundation

class Client {
    
    static let apiKey = "459f2357651203fd82c366f06dfbf383"
    static let keySecret = "2a3d6012523e298f"
    static let photosPerPage = 10
    static let flickrLimit = 4000

    enum Endpoints {
        static let base = "https://www.flickr.com/services/rest/?method="
        static let apiKeyParam = "&api_key=\(Client.apiKey)"
        
        static let radius = 20
        case searchPhotos(Double, Double, Int, Int)

        var urlString: String {
            switch self {
                 case .searchPhotos(let latitude, let longitude, let perPage, let pageNum):
                    return Endpoints.base + "flickr.photos.search" + (Endpoints.apiKeyParam) +
                         "&lat=\(latitude)" +
                         "&lon=\(longitude)" +
                         "&radius=\(Endpoints.radius)" +
                         "&per_page=\(perPage)" +
                         "&page=\(pageNum)" +
                         "&format=json&nojsoncallback=1&extras=url_m"
            }
        }
     
      var url: URL {
        return URL(string: urlString)!
      }
    }
    
    class func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionDataTask {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        task.resume()
        
        return task
    }
    
    class func getPhotos(latitude: Double, longitude: Double, totalPageAmount:  Int = 20, completion: @escaping ([PhotoStruct], Int, Error?) -> Void) -> Void {

        let numberPages = min(totalPageAmount == 0 ? 20 : totalPageAmount, self.flickrLimit/self.photosPerPage)
        let randomPageNum = Int(arc4random_uniform(UInt32(numberPages)) + 1)
        let searchPhotos = Endpoints.searchPhotos(latitude, longitude, numberPages, randomPageNum).url

        let _ = taskForGETRequest(url: searchPhotos, responseType: SearchPhotoResponse.self) { response, error in
               if let response = response {
                completion(response.photos.photo, response.photos.pages, nil)
               } else {
                   completion([], 0, error)
               }
           }
       }
    
    class func downloadPhoto(img: String, completion: @escaping (Data?, Error?) -> Void) {
        let url = URL(string: img)
        
        guard let imageURL = url else {
             DispatchQueue.main.async {
                 completion(nil, nil)
             }
             return
         }
         
         let request = URLRequest(url: imageURL)
         let task = URLSession.shared.dataTask(with: request) { data, response, error in
             DispatchQueue.main.async {
                 completion(data, nil)
             }
         }
         task.resume()
    }
    
}
