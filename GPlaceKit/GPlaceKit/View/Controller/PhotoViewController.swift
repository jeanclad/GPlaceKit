//
//  PhotoViewController.swift
//  GPlaceKit
//
//  Created by jeanclad on 2017. 9. 23..
//  Copyright © 2017년 jeanclad. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController {
    
    @IBOutlet private var photoImageView: UIImageView!
    internal var photoViewModel = PhotoViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let urlString = photoViewModel.photoModel?.imageUrl {
            ImageLoader.sharedLoader.downloadImageFrom(urlString: urlString, completionHandler: { (image) in
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
