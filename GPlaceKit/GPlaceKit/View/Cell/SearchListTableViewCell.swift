//
//  SearchListTableViewCell.swift
//  GPlaceKit
//
//  Created by jeanclad on 2017. 9. 22..
//  Copyright © 2017년 jeanclad. All rights reserved.
//

import UIKit

class SearchListTableViewCell: UITableViewCell {

    @IBOutlet fileprivate var name: UILabel!
    @IBOutlet fileprivate var addr: UILabel!
    @IBOutlet fileprivate var types: UILabel!
    
    internal var item: SearchResult? {
        didSet {
            guard let item = item else {
                return
            }
            
            name.text = item.name
            addr.text = item.addr
            
            if let pTypes = item.types {
                types.text = pTypes.description
            }
        }
    }
}
