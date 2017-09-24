//
//  DetailPhotoCollectionViewCell.swift
//  GPlaceKit
//
//  Created by jeanclad on 2017. 9. 23..
//  Copyright © 2017년 jeanclad. All rights reserved.
//

import UIKit

class DetailPhotoCollectionViewCell: UICollectionViewCell {
    @IBOutlet private var photoImageView: AsyncImageView!
    internal var item: DetailPhotos? {
        didSet {
            guard let item = item else {
                return
            }
            
            let url = UrlFactory().getPhotoUrl(size: photoImageView.bounds.size, reference: item.reference)
            if let url = url {
                photoImageView.loadImage(urlString: url)
            }
        }
    }
        
    override func prepareForReuse() {
        super.prepareForReuse()
        
        photoImageView.image = UIImage()
    }
}
