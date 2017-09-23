//
//  DetailTitleTableViewCell.swift
//  GPlaceKit
//
//  Created by jeanclad on 2017. 9. 23..
//  Copyright © 2017년 jeanclad. All rights reserved.
//

import UIKit

class DetailTitleTableViewCell: UITableViewCell {

    @IBOutlet fileprivate var name: UILabel!
    @IBOutlet fileprivate var addr: UILabel!
    @IBOutlet fileprivate var phoneNum: UILabel!
    
    internal var item: DetailResultModel? {
        didSet {
            guard let item = item else {
                return
            }
            
            name.text = item.name
            addr.text = item.addr
            phoneNum.text = item.phoneNum
        }
    }}
