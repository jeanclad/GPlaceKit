//
//  AsyncImageView.swift
//  GPlaceKit
//
//  Created by jeanclad on 2017. 9. 23..
//  Copyright © 2017년 jeanclad. All rights reserved.
//

import UIKit

class AsyncImageView: UIImageView {
    let CACHE_SEC : TimeInterval = 5 * 60;
    
    func loadImage(urlString: String){
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
