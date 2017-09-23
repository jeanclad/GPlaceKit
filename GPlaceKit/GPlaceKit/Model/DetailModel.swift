//
//  DetailModel.swift
//  GPlaceKit
//
//  Created by jeanclad on 2017. 9. 23..
//  Copyright © 2017년 jeanclad. All rights reserved.
//

import UIKit

internal class DetailPhotos: NSObject {
    internal let width: NSNumber?
    internal let height: NSNumber?
    internal var reference: String?
    
    init(width: NSNumber? = nil, height: NSNumber? = nil, reference: String? = nil) {
        self.width = width
        self.height = height
        self.reference = reference
    }
}

internal class DetailResultModel: NSObject {
    internal let name: String?
    internal let addr: String?
    internal let phoneNum: String?
    internal let lat: NSNumber?
    internal let lng: NSNumber?
    
    internal var detailPhotos: [DetailPhotos]?
    
    init(name: String? = nil, addr: String? = nil, phoneNum: String? = nil, lat: NSNumber? = nil, lng: NSNumber? = nil, photos: NSArray? = nil) {
        self.name = name
        self.addr = addr
        self.phoneNum = phoneNum
        self.lat = lat
        self.lng = lng
        
        if let photos = photos {
            self.detailPhotos = photos.map { (result: Any) -> DetailPhotos in
                let dic = result as? NSDictionary
                let detailPhotos = DetailPhotos(width: dic?["width"] as? NSNumber,
                                                height: dic?["height"] as? NSNumber,
                                                reference: dic?["photo_reference"] as? String)
                return detailPhotos
            }
        }
    }
}
