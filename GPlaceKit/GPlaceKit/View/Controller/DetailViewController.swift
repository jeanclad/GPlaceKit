//
//  DetailViewController.swift
//  GPlaceKit
//
//  Created by jeanclad on 2017. 9. 22..
//  Copyright © 2017년 jeanclad. All rights reserved.
//

import UIKit

internal class DetailViewController: UIViewController {
    
    internal var detailViewModel = DetailViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        detailViewModel.requestDeatailInfo(completionHandler: { 
            
        }) { (error) in
            
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
