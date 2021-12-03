//
//  PhotoDataResponse.swift
//  FamSample
//
//  Created by Aedan Joyce on 12/3/21.
//

import UIKit

// Response object for flickr api
struct PhotoDataResponse: Codable {
    struct PhotoData: Codable {
        let page: String
        let pages: Int
        let perpage: String
        let total: Int
        let photo: [Photo]
    }
    
    struct Photo: Codable {
        let id, owner, secret, server: String
        let farm: Int
        let title: String
        let ispublic, isfriend, isfamily: Int
    }
    
    let photos: PhotoData
}

class Photo: NSObject {
    var image: UIImage
    
    init(image: UIImage) {
        self.image = image
    }
    
}
