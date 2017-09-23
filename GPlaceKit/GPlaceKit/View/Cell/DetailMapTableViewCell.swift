//
//  DetailMapTableViewCell.swift
//  GPlaceKit
//
//  Created by jeanclad on 2017. 9. 23..
//  Copyright © 2017년 jeanclad. All rights reserved.
//

import UIKit

class DetailMapTableViewCell: UITableViewCell {
    @IBOutlet private var mapImageView: AsyncImageView!
    internal var item: DetailResultModel? {
        didSet {
            guard let item = item else {
                return
            }
            
            let url = getMapUrlFromCurrentScreen(lat: item.lat, lng: item.lng)
            if let urlString = url {
                mapImageView.loadImage(urlString: urlString)
            }
        }
    }

    private func getMapUrlFromCurrentScreen(lat: NSNumber?, lng: NSNumber?) -> String? {
        guard let lat = lat, let lng = lng else {
            return nil
        }
        
        let screenWidth = Int(UIScreen.main.bounds.width)
        // TODO: APK_KEY 선언
        let url = "https://maps.googleapis.com/maps/api/staticmap?center=\(lat),\(lng)&zoom=16&size=\(screenWidth)x200&markers=\(lat),\(lng)&key=AIzaSyCjonlfatxCINuBE9iogcYElYFl30-AgNs"
        
        return url
    }

}
