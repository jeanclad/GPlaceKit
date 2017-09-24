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
    internal var numberOfItem: Int {
        if detailResultModel != nil {
            return 3
        }
        return 0
    }
    
    internal func requestDeatailInfo(completionHandler: @escaping (_ status: String?) ->Void,                                     errorHandler failResponse: @escaping (Error) -> Void) {
        if let placeId = placeId {
            let url = UrlFactory().getDetailPlaceUrl(placeId: placeId)
            if let encoded_url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                HTTPService.shared.fetchGET(urlString: encoded_url, completion: { (response) in
                    if let data = response.data {
                        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary else {
                            completionHandler(StringFactory().getTextJsonFail())
                            return
                        }
                        
                        if let erorr = json?["error_message"] as? String {
                            completionHandler(erorr)
                            return
                        }
                        
                        if let results = json?["result"] as? NSDictionary {
                            self.detailResultModel =
                                DetailResultModel(name: results["name"] as? String,
                                                  addr: results["formatted_address"] as? String,
                                                  phoneNum: results["formatted_phone_number"] as? String,
                                                  lat: results.value(forKeyPath: "geometry.location.lat") as? NSNumber,
                                                  lng: results.value(forKeyPath: "geometry.location.lng") as? NSNumber,
                                                  photos: results["photos"] as? NSArray)
                            completionHandler(nil)
                            return
                        } else {
                            completionHandler(StringFactory().getTextJsonFail())
                            return
                        }
                    }
                }, failure: { (error) in
                    failResponse(error)
                    return
                })
            } else {
                completionHandler(StringFactory().getTextDetailFail())
                return
            }
        }
    }
}
