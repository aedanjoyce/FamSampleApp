//
//  FlickrNetwork.swift
//  FamSample
//
//  Created by Aedan Joyce on 12/1/21.
//

import UIKit


struct FlickrNetwork {
    
    private static let apiKey = "0b64a3f81e43bd52031db1114664035d"
    private let secret = "41f82c2d0a30a886"
    
    // sets up url for api get request
    static func setupURL(pageLimit: Int, page: Int? = 1) -> URL? {
        var url = URLComponents(string: "https://www.flickr.com/services/rest")
        url?.queryItems = [
            URLQueryItem(name: "method", value: "flickr.galleries.getPhotos"),
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "gallery_id", value: "66941286-72157677780731583"),
            URLQueryItem(name: "per_page", value: String(pageLimit)),
            URLQueryItem(name: "page", value: String(page ?? 1)),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "nojsoncallback", value: String(1))
        ]
        guard let absoluteURL = url?.url?.absoluteURL else {print("Couldn't construct url"); return nil}
        return absoluteURL
    }
    
    // fetches photos from flickr API endpoint
    static func fetchPhotos(pageLimit: Int, page: Int, completion: @escaping ([Photo], Int, Bool) -> ()) {
        
        var photos = [Photo]()
        guard let absoluteURL = setupURL(pageLimit: pageLimit, page: page) else {completion([], 1, true); return}
        // fetch photo ids
        sendNetworkRequest(absoluteURL) { data in
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    
                    let response = try decoder.decode(PhotoDataResponse.self, from: data)
                
                    // if we reached max pages, cancel the request, set isPageable to false
                    if (response.photos.pages < page) {
                        print("MAX PAGE REACHED")
                        completion([], page, false)
                        return
                    }
                    
                    // perform image data fetch in a dispatch group
                    let dispatchGroup = DispatchGroup()
                    
                    for photo in response.photos.photo {
                        let imageURL = "https://farm\(photo.farm).staticflickr.com/\(photo.server)/\(photo.id)_\(photo.secret).jpg"
                        guard let url = URL(string: imageURL) else {continue}
                        
                        dispatchGroup.enter()
                        getData(from: url) { data, url_response, error in
                            guard let data = data, error == nil else {dispatchGroup.leave();return }
                            photos.append(Photo(image: UIImage(data: data) ?? UIImage()))
                            dispatchGroup.leave()
                        }
                    }
                    
                    dispatchGroup.notify(queue: .main) {
                        let page = Int(response.photos.page) ?? 0
                        let nextPage = page + 1
                        completion(photos, nextPage, true)
                    }
                    
                    
                } catch {
                    print("cant")
                    print(error)
                }
            }
        }
    }
    
    private static func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    static private func sendNetworkRequest(_ url: URL, completion: @escaping (Data?) -> ()) {
        let task = URLSession.shared.dataTask(with: url) { data, url_response, error in
            if let error = error {
                print("Error fetching data, \(error.localizedDescription)")
                completion(nil)
                return
            }
            completion(data)
            }
        task.resume()
    }
    
    
    
    
    
    
}
