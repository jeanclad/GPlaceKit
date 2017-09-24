//
//  ImageLoader.swift
//  GPlaceKit
//
//  Created by jeanclad on 2017. 9. 24..
//  Copyright © 2017년 jeanclad. All rights reserved.
//

import UIKit

class ImageLoader {
    let imageCache = NSCache<NSString, AnyObject>()
    
    class var sharedLoader : ImageLoader {
        struct Static {
            static let instance : ImageLoader = ImageLoader()
        }
        return Static.instance
    }
    
    func downloadImageFrom(urlString: String,
                           completionHandler: @escaping (_ image: UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            completionHandler(nil)
            return
        }
        
        if let cachedImage = imageCache.object(forKey: url.absoluteString as NSString) as? UIImage {
            let image = cachedImage
            completionHandler(image)
        } else {
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else {
                    return
                }
                
                DispatchQueue.main.async {
                    let imageToCache = UIImage(data: data)
                    self.imageCache.setObject(imageToCache!, forKey: url.absoluteString as NSString)
                    let image = imageToCache
                    completionHandler(image)
                }
                }.resume()
        }
    }
}


