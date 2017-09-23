//
//  TextSearchViewModel.swift
//  GPlaceKit
//
//  Created by jeanclad on 2017. 9. 22..
//  Copyright © 2017년 jeanclad. All rights reserved.
//

import UIKit

internal class TextSearchViewModel: NSObject {
    internal var textSearchModel: TextSearchModel?
    internal var numberOfItem: Int {
        if textSearchModel != nil {
            return (textSearchModel?.searchResults.count)!
        }
        return 0
    }
    
    internal func requestTextSearchItems(searchable: String,
                                         completionHandler: @escaping (_ status: String?) -> Void,
                                         errorHandler failResponse: @escaping (Error) -> Void) {
        // TODO: URL + API_KEY은 Define
        let url = "https://maps.googleapis.com/maps/api/place/textsearch/json?query=\(searchable)&language=ko&key=AIzaSyCjonlfatxCINuBE9iogcYElYFl30-AgNs"
        if let encoded_url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            HTTPService.shared.fetchGET(urlString: encoded_url, completion: { (response) in
                if let data = response.data {
                    guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary else {
                        completionHandler(nil)
                        return
                    }
                    
                    if let erorr = json?["error_message"] as? String {
                        completionHandler(erorr)
                        return
                    }
                    
                    if let results = json?["results"] as? NSArray {
                        self.textSearchModel = TextSearchModel(searchResults: results)
                    }
                    
                    completionHandler(nil)
                    return
                }
                print("aaa")
                // TODO: Error
            }) { (error) in
                failResponse(error)
                return
            }
        } else {
            // TODO: Alert(Something wrong)
        }
    }
    
    internal func clearModel() {
        textSearchModel?.clearModel()
    }
}


