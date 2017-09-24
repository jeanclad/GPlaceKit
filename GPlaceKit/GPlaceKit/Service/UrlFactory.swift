//
//  UrlFactory.swift
//  GPlaceKit
//
//  Created by jeanclad on 2017. 9. 24..
//  Copyright © 2017년 jeanclad. All rights reserved.
//

import UIKit

class UrlFactory {
    internal func getMapUrlFromCurrentScreen(lat: NSNumber?, lng: NSNumber?) -> String? {
        guard let lat = lat, let lng = lng else {
            return nil
        }
        
        let screenWidth = Int(UIScreen.main.bounds.width)
        let url = "https://maps.googleapis.com/maps/api/staticmap?center=\(lat),\(lng)&zoom=16&size=\(screenWidth)x200&markers=\(lat),\(lng)&key=\(apiKey)"
        
        return url
    }
    
    internal func getPhotoUrl(size: CGSize, reference: String?) -> String?{
        guard reference != nil else {
            return nil
        }
        
        let testSize = CGSize(width: 100, height: 100)
        var baseUrl = "https://maps.googleapis.com/maps/api/place/photo?"
        // test by jeanclad
        baseUrl.append("maxwidth=\(Int(testSize.width))&maxheight=\(Int(testSize.height))&")
        baseUrl.append("photoreference=\(reference!)&")
        baseUrl.append("key=\(apiKey)")
        
        return baseUrl
    }
}
