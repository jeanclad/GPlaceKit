//
//  UrlFactory.swift
//  GPlaceKit
//
//  Created by jeanclad on 2017. 9. 24..
//  Copyright © 2017년 jeanclad. All rights reserved.
//

import UIKit

class UrlFactory {
    
    internal func getTextSearchUrl(searchable: String) -> String {
        return "https://maps.googleapis.com/maps/api/place/textsearch/json?query=\(searchable)&language=ko&key=\(apiKey)"
    }
    
    internal func getDetailPlaceUrl(placeId: String) -> String {
        return "https://maps.googleapis.com/maps/api/place/details/json?placeid=\(placeId)&language=ko&key=\(apiKey)"
    }
    
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
        
        var baseUrl = "https://maps.googleapis.com/maps/api/place/photo?"
        baseUrl.append("maxwidth=\(Int(size.width))&maxheight=\(Int(size.height))&")
        baseUrl.append("photoreference=\(reference!)&")
        baseUrl.append("key=\(apiKey)")
        
        return baseUrl
    }
}
