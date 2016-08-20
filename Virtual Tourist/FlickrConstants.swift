//
//  FlickrConstants.swift
//  Virtual Tourist
//
//  Created by Mike Weng on 1/28/16.
//  Copyright © 2016 Weng. All rights reserved.
//

import Foundation

extension FlickrClient {
    
    struct Constants {
        
        // MARK: - URLs
        static let ApiKey = "a1fb758da7f6900bb07a713cff79c15a"
        static let BaseUrlSSL = "https://api.flickr.com/services/rest/"
        static let BaseImageUrl = "http://image.tmdb.org/t/p/"
        static let BOUNDING_BOX_HALF_WIDTH = 1.0
        static let BOUNDING_BOX_HALF_HEIGHT = 1.0
        static let LAT_MIN = -90.0
        static let LAT_MAX = 90.0
        static let LON_MIN = -180.0
        static let LON_MAX = 180.0
    }
    
    struct Method {
        
        static let Search = "flickr.photos.search"
        
    }
    
    struct Keys {
        static let Stat = "stat"
        static let Photos = "photos"
        static let Pages = "pages"


    }
    
    struct Values {
        static let KevinBaconIDValue = 4724
    }    
}