//
//  DetailMapTableViewCell.swift
//  GPlaceKit
//
//  Created by jeanclad on 2017. 9. 23..
//  Copyright © 2017년 jeanclad. All rights reserved.
//

import UIKit

class DetailMapTableViewCell: UITableViewCell {
    @IBOutlet private var mapImageView: UIImageView!
    
    internal var item: DetailResultModel? {
        didSet {
            guard let item = item else {
                return
            }
            
            let url = UrlFactory().getMapUrlFromCurrentScreen(lat: item.lat, lng: item.lng)
            if let urlString = url {
                ImageLoader.sharedLoader.downloadImageFrom(urlString: urlString, completionHandler: { (image) in
                    self.mapImageView.image = image
                })
            }
        }
    }
}
