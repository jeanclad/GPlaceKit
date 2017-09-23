//
//  DetailViewController.swift
//  GPlaceKit
//
//  Created by jeanclad on 2017. 9. 22..
//  Copyright © 2017년 jeanclad. All rights reserved.
//

import UIKit

internal class DetailViewController: UIViewController, UITableViewDataSource {
    
    internal var detailViewModel = DetailViewModel()
    @IBOutlet fileprivate var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        detailViewModel.requestDeatailInfo(completionHandler: {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }) { (error) in
            
        }
    }
    
    // UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return detailViewModel.numberOfItem
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //        if indexPath.row == 0 {
        let cell = tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath) as! DetailTitleTableViewCell
        cell.item = detailViewModel.detailResultModel
        return cell
        //        } else indexPath.row == 1 {
        //
        //        }
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
