//
//  FlickrConvenience.swift
//  Virtual Tourist
//
//  Created by Mike Weng on 1/28/16.
//  Copyright © 2016 Weng. All rights reserved.
//

import Foundation
import MapKit

extension FlickrClient {

    func getPhotos(coordinate: CLLocationCoordinate2D, page: NSNumber, completionHandler: (success: Bool, photos: [[String:AnyObject]]?, errorString: String?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let methodParameters = [
            "method" : Method.Search,
            "api_key" : Constants.ApiKey,
            "bbox" : createBoundingBoxString(coordinate.latitude, longitude: coordinate.longitude),
            "safe_search" : "1",
            "extras" : "url_m",
            "format" : "json",
            "nojsoncallback" : "1",
            "per_page" : "21",
            "page" : String(page)
        ]
        
        /* 2. Make the request */
        taskForGETMethod(methodParameters, completionHandler: { (parsedResult, error) in
            
            /* 3. Send the desired value(s) to completion handler */
            guard error == nil else {
                completionHandler(success: false, photos: nil, errorString: "Login Failed (Get User Data).")
                return
            }
            /* GUARD: Did Flickr return an error? */
            guard let stat = parsedResult[Keys.Stat] as? String where stat == "ok" else {
                completionHandler(success: false, photos: nil, errorString: "Flickr API returned an error. See error code and message in \(parsedResult)")
                return
            }
            
            /* GUARD: Is "photos" key in our result? */
            guard let photosDictionary = parsedResult[Keys.Photos] as? NSDictionary else {
                completionHandler(success: false, photos: nil, errorString: "Cannot find keys 'photos' in \(parsedResult)")
                return
            }
            
            /* GUARD: Is the "photo" key in photosDictionary? */
            guard let photosArray = photosDictionary["photo"] as? [[String: AnyObject]] else {
                completionHandler(success: false, photos: nil, errorString: "Cannot find key 'photo' in \(photosDictionary)")
                return
            }
            
//            /* GUARD: Is "pages" key in the photosDictionary? */
//            guard let totalPages = photosDictionary["pages"] as? Int else {
//                print("Cannot find key 'pages' in \(photosDictionary)")
//                return
//            }
//            
//            /* Pick a random page! */
//            let pageLimit = min(totalPages, 40)
//            let randomPage = Int(arc4random_uniform(UInt32(pageLimit))) + 1
//            self.getImageFromFlickrBySearchWithPage(methodArguments, pageNumber: randomPage)
            
            completionHandler(success: true, photos: photosArray, errorString: nil)
            
        })
        
        print("implement me: UdacityClient getUserData")
        
    }
    
    func createBoundingBoxString(latitude: Double, longitude: Double) -> String {
        
        /* Fix added to ensure box is bounded by minimum and maximums */
        let bottom_left_lon = max(longitude - Constants.BOUNDING_BOX_HALF_WIDTH, Constants.LON_MIN)
        let bottom_left_lat = max(latitude - Constants.BOUNDING_BOX_HALF_HEIGHT, Constants.LAT_MIN)
        let top_right_lon = min(longitude + Constants.BOUNDING_BOX_HALF_HEIGHT, Constants.LON_MAX)
        let top_right_lat = min(latitude + Constants.BOUNDING_BOX_HALF_HEIGHT, Constants.LAT_MAX)
        
        return "\(bottom_left_lon),\(bottom_left_lat),\(top_right_lon),\(top_right_lat)"
    }

}