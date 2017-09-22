//
//  TextSearchModel.swift
//  GPlaceKit
//
//  Created by jeanclad on 2017. 9. 22..
//  Copyright © 2017년 jeanclad. All rights reserved.
//

import UIKit

internal class TextSearchModel: NSObject {
    public let name: String
    public let addr: String
    public var types: [String]
    
    init(name: String, addr: String, types: [String]) {
        self.name = name
        self.addr = addr
        self.types = types
    }
}
