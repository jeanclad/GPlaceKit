//
//  ViewController.swift
//  GPlaceKit
//
//  Created by jeanclad on 2017. 9. 21..
//  Copyright © 2017년 jeanclad. All rights reserved.
//

import UIKit

internal class ViewController: UIViewController {
    
    @IBOutlet fileprivate var tableView: UITableView!
    @IBOutlet fileprivate var searchBar: UISearchBar!
    
    fileprivate var textSearchViewModel = TextSearchViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        self.tableView.estimatedRowHeight = 104
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        searchBar.becomeFirstResponder()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailViewController", let destination = segue.destination as? DetailViewController {
            if let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) {
                let placeId = textSearchViewModel.textSearchModel?.searchResults[indexPath.row].placeId
                destination.detailViewModel.placeId = placeId
            }
        }
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return textSearchViewModel.numberOfItem
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath) as! SearchListTableViewCell
        
        cell.item = textSearchViewModel.textSearchModel?.searchResults[indexPath.row]
        
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
            
            textSearchViewModel.requestTextSearchItems(searchable: searchString!, completionHandler: {status in
                if status != nil {
                    // TODO: 메소드로 정리
                    let alert = UIAlertController(title: "알림", message: status, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    DispatchQueue.main.async {
                        self.tableView.setContentOffset(CGPoint.zero, animated: false)
                        self.tableView.reloadData()
                    }
                }
            }) { (error) in
                // TODO: 메소드로 정리
                let alert = UIAlertController(title: "알림", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}

