//
//  DetailViewModel.swift
//  GPlaceKit
//
//  Created by jeanclad on 2017. 9. 23..
//  Copyright © 2017년 jeanclad. All rights reserved.
//

import UIKit

internal class DetailViewModel: NSObject {
    internal var placeId: String?
    internal var detailResultModel: DetailResultModel?
    internal let numberOfItem = 3
    
    internal func requestDeatailInfo(                                         completionHandler: @escaping () -> Void,
                                                                              errorHandler failResponse: @escaping (Error) -> Void) {
        if let placeId = placeId {
            let url = "https://maps.googleapis.com/maps/api/place/details/json?placeid=\(placeId)&language=ko&key=AIzaSyCjonlfatxCINuBE9iogcYElYFl30-AgNs"
            if let encoded_url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                HTTPService.shared.fetchGET(urlString: encoded_url, completion: { (response) in
                    if let data = response.data {
                        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary else {
                            completionHandler()
                            return
                        }
                        
                        if let results = json?["result"] as? NSDictionary {
                            self.detailResultModel = DetailResultModel(name: results["name"] as! String,
                                                                       addr: results["formatted_address"] as! String,
                                                                       phoneNum: results["formatted_phone_number"] as! String)
                            completionHandler()
                            return
                        }
                        // TODO: Error
                    }
                }, failure: { (error) in
                    
                })
            }
        }
    }
}
