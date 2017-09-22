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
     
        self.tableView.estimatedRowHeight = 104
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        searchBar.becomeFirstResponder()
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return textSearchViewModel.numberOfItem
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath) as! SearchListTableViewCell
        
        cell.item = textSearchViewModel.textSearchModel[indexPath.row]
        
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        let searchString = searchBar.text
        
        if searchString != "" {
            textSearchViewModel.clearModel()
            
            textSearchViewModel.requestTextSearchItems(searchable: searchString!, completionHandler: {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }) { (error) in
                // TODO: Alert
            }
        }
    }
}

