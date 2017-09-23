//
//  TextSearchModel.swift
//  GPlaceKit
//
//  Created by jeanclad on 2017. 9. 22..
//  Copyright © 2017년 jeanclad. All rights reserved.
//

import UIKit

internal class SearchResult: NSObject {
    internal let name: String?
    internal let addr: String?
    internal let placeId: String?
    internal var types: [String]?
    
    init(name: String? = nil, addr: String? = nil, placeId: String? = nil, types: [String]? = nil) {
        self.name = name
        self.addr = addr
        self.placeId = placeId
        self.types = types
    }
}

internal class TextSearchModel: NSObject {
    internal var searchResults: [SearchResult] = []
    
    internal func clearModel() {
        self.searchResults = []
    }
    
    init(searchResults: NSArray) {
        self.searchResults = searchResults.map { (result: Any) -> SearchResult in
            let dic = result as? NSDictionary
            let searchResult = SearchResult(name: dic?["name"] as? String,
                                            addr: dic?["formatted_address"] as? String,
                                       placeId: dic?["place_id"] as? String,
                                       types: dic?["types"] as? Array)
            return searchResult
        }        
    }
}
