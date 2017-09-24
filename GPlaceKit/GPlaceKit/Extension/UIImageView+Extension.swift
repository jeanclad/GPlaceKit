//
//  UIImageView+Extension.swift
//  GPlaceKit
//
//  Created by jeanclad on 2017. 9. 24..
//  Copyright © 2017년 jeanclad. All rights reserved.
//

import UIKit

extension UIImageView {
    func loadImage(urlString: String? ){
        guard let urlString = urlString else {
            return
        }
        
        let CACHE_SEC : TimeInterval = 5 * 60;
        let req = NSURLRequest(url: NSURL(string:urlString)! as URL,
                               cachePolicy: .returnCacheDataElseLoad,
                               timeoutInterval: CACHE_SEC);
        let conf =  URLSessionConfiguration.default
        let session = URLSession(configuration: conf, delegate: nil, delegateQueue: OperationQueue.main);
        
        session.dataTask(with: req as URLRequest, completionHandler:
            { (data, resp, err) in
                if((err) == nil){
                    let image = UIImage(data:data!)
                    self.image = image;
                    
                } else{
                    print("AsyncImageView:Error \(err?.localizedDescription ?? "")");
                }
        }).resume();
    }
}
