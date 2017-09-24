//
//  PhotoViewController.swift
//  GPlaceKit
//
//  Created by jeanclad on 2017. 9. 23..
//  Copyright © 2017년 jeanclad. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController {

    @IBOutlet private var photoImageView: AsyncImageView!
    internal var photoViewModel = PhotoViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        photoImageView.loadImage(urlString: photoViewModel.photoModel?.imageUrl)
    }
}
