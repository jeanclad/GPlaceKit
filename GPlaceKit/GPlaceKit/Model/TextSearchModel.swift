//
//  TextSearchModel.swift
//  GPlaceKit
//
//  Created by jeanclad on 2017. 9. 22..
//  Copyright © 2017년 jeanclad. All rights reserved.
//

import UIKit

internal class SearchResult: NSObject {
    internal let name: String
    internal let addr: String
    
    // TODO: get 프로퍼티에서 Array -> String으로 구현해볼것
    internal var types: [String]
    
    init(name: String, addr: String, types: [String]) {
        self.name = name
        self.addr = addr
        self.types = types
    }
}

internal class TextSearchModel: NSObject {
    internal var searchResults: [SearchResult] = []
    
    internal func clearModel() {
        self.searchResults = []
    }
    
    init(searchResults: NSArray) {
        for dic in searchResults {
            let result = dic as? NSDictionary
            let searchResult = SearchResult.init(name: result?["name"] as! String,
                                                 addr: result?["formatted_address"] as! String,
                                                 types: result?["types"] as! Array)
            self.searchResults.append(searchResult)            
        }
    }
}
