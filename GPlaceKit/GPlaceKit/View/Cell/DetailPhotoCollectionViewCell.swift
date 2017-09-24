//
//  DetailPhotoCollectionViewCell.swift
//  GPlaceKit
//
//  Created by jeanclad on 2017. 9. 23..
//  Copyright © 2017년 jeanclad. All rights reserved.
//

import UIKit

class DetailPhotoCollectionViewCell: UICollectionViewCell {
    @IBOutlet private var photoImageView: UIImageView!
    internal var item: DetailPhotos? {
        didSet {
            guard let item = item else {
                return
            }
            
            let url = UrlFactory().getPhotoUrl(size: photoImageView.bounds.size, reference: item.reference)
            if let url = url {
                ImageLoader.sharedLoader.downloadImageFrom(urlString: url, completionHandler: { (image) in
                    guard image != nil else {
                        return
                    }
                    
                    if (image?.size.width)! > self.photoImageView.bounds.width ||
                        (image?.size.height)! > self.photoImageView.bounds.height {
                        self.photoImageView.image = image?.resizeImage(targetSize: self.photoImageView.bounds.size)
                    } else {
                        self.photoImageView.image = image
                    }
                })
            }
        }
    }
        
    override func prepareForReuse() {
        super.prepareForReuse()
        
        photoImageView.image = UIImage()
    }
}
