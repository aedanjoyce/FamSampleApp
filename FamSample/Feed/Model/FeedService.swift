//
//  FeedService.swift
//  FamSample
//
//  Created by Aedan Joyce on 12/1/21.
//

import UIKit

struct FeedService {
    /// Returns  an array of photos, nextPage, and a flag to determine if paging is still possible
    static func fetchImages(page: Int, completion: @escaping ([Photo], Int, Bool) -> ()) {
        FlickrNetwork.fetchPhotos(pageLimit: 10, page: page) { photos, nextPage, isPageable in
            completion(photos, nextPage, isPageable)
        }
    }
    
}
