//
//  PhotoModel.swift
//  GPlaceKit
//
//  Created by jeanclad on 2017. 9. 24..
//  Copyright © 2017년 jeanclad. All rights reserved.
//

import UIKit

class PhotoModel: NSObject {
    internal var imageUrl: String?
    
    init(imageUrl: String? = nil) {
        self.imageUrl = imageUrl
    }
}
