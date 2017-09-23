//
//  DetailPhotoCollectionViewCell.swift
//  GPlaceKit
//
//  Created by jeanclad on 2017. 9. 23..
//  Copyright © 2017년 jeanclad. All rights reserved.
//

import UIKit

class DetailPhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet fileprivate var photoImageView: AsyncImageView!
    
    internal var item: DetailPhotos? {
        didSet {
            guard let item = item else {
                return
            }
            
            let url = getPhotoUrl(item: item)
            if let url = url {
                photoImageView.loadImage(urlString: url)
            }
        }
    }
    
    private func getPhotoUrl(item: DetailPhotos) -> String?{
        guard item.reference != nil else {
            return nil
        }
        
        var baseUrl = "https://maps.googleapis.com/maps/api/place/photo?"
        baseUrl.append("maxwidth=\(Int(photoImageView.bounds.width))&maxheight=\(Int(photoImageView.bounds.height))&")
        baseUrl.append("photoreference=\(item.reference!)&")
        // TODO: API_KEY 선언
        baseUrl.append("key=AIzaSyCjonlfatxCINuBE9iogcYElYFl30-AgNs")
        
        return baseUrl
    }
}
