//
//  PhotoPageViewModel.swift
//  GPlaceKit
//
//  Created by jeanclad on 2017. 9. 24..
//  Copyright © 2017년 jeanclad. All rights reserved.
//

import UIKit

class PhotoPageViewModel: NSObject {
    internal var detailPhotos: [DetailPhotos]?
    internal var numberOfItem: Int {
        if let detailPhotos = detailPhotos  {
            return detailPhotos.count
        }
        return 0
    }

    internal func getPhotoUrl(size: CGSize, index: Int) -> String? {
        let url = UrlFactory().getPhotoUrl(size: size, reference: detailPhotos?[index].reference)
        return url
    }
}
