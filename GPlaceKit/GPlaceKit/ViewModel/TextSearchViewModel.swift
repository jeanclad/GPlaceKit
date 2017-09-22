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
        return textSearchModel?.searchResults.count ?? 0
    }
    
    internal func requestTextSearchItems(searchable: String,
                                         completionHandler: @escaping () -> Void,
                                         errorHandler failResponse: @escaping (Error) -> Void) {
        let url = "https://maps.googleapis.com/maps/api/place/textsearch/json?query=\(searchable)&language=ko&key=AIzaSyCjonlfatxCINuBE9iogcYElYFl30-AgNs"
        if let encoded_url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            HTTPService.shared.fetchGET(urlString: encoded_url, completion: { (response) in
                if let data = response.data {
                    guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary else {
                        completionHandler()
                        return
                    }
                    
                    
//                    for dic in (json?["results"] as? NSArray)! {
//                        let result = dic as? NSDictionary
//                        print(dic)
//                        let model = TextSearchModel(name: result?["name"] as! String,
//                                                    addr: result?["formatted_address"] as! String,
//                                                    types: result?["types"] as! Array)
//                        
//                        self.textSearchModel.append(model)
//                    }
                    
                    if let results = json?["results"] as? NSArray {
                        self.textSearchModel = TextSearchModel(searchResults: results)
                        completionHandler()
                        return
                    }
                }
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
    
//    internal func nameForItemAtIndexPath(indexPath: IndexPath) -> String {
//        return textSearchModel[indexPath.row].name
//    }
//    
//    internal func addrForItemAtIndexPath(indexPath: IndexPath) -> String {
//        return textSearchModel[indexPath.row].addr
//    }
//
//    internal func typesForItemAtIndexPath(indexPath: IndexPath) -> String {
//        return textSearchModel[indexPath.row].types.description
//    }
}


