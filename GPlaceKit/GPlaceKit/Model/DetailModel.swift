//
//  DetailModel.swift
//  GPlaceKit
//
//  Created by jeanclad on 2017. 9. 23..
//  Copyright © 2017년 jeanclad. All rights reserved.
//

import UIKit

internal class DetailResultModel: NSObject {
    internal let name: String?
    internal let addr: String?
    internal let phoneNum: String?
    internal let lat: NSNumber?
    internal let lng: NSNumber?

    
    init(name: String?, addr: String?, phoneNum: String?, lat: NSNumber?, lng: NSNumber?) {
        self.name = name
        self.addr = addr
        self.phoneNum = phoneNum
        self.lat = lat
        self.lng = lng
    }
}

// TODO: 삭제
//internal class DetailInfo: NSObject {
//    internal let placeId: String
//    
//    init(placeId: String) {
//        self.placeId = placeId
//    }
//}
