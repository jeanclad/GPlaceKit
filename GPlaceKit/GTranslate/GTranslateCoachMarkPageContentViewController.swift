//
//  GTranslateCoachMarkPageContentViewController.swift
//  main
//
//  Created by jeanclad on 2017. 6. 15..
//  Copyright © 2017년 interpark-int. All rights reserved.
//

import Foundation

class GTranslateCoachMarkPageContentViewController: UIViewController {
    
    @IBOutlet var guardView: UIView!
    @IBOutlet var coachImageView: UIImageView!
    var pageIndex: Int?
    var coachImageName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        coachImageView.image = UIImage(named: coachImageName!)
    }
}
