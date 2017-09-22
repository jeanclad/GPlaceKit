//
//  ViewController.swift
//  GPlaceKit
//
//  Created by jeanclad on 2017. 9. 21..
//  Copyright © 2017년 jeanclad. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    
    fileprivate var textSearchViewModel = TextSearchViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        textSearchViewModel.requestTextSearchItems(searchable: "플레이뮤지엄", completionHandler: { 
            // test by jeanclad
            print(" aa ", self.textSearchViewModel.numberOfItem)
        }) { (error) in
            
        }
    }
    
}

