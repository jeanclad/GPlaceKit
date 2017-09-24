//
//  DetailViewController.swift
//  GPlaceKit
//
//  Created by jeanclad on 2017. 9. 22..
//  Copyright © 2017년 jeanclad. All rights reserved.
//

import UIKit

internal class DetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    internal var detailViewModel = DetailViewModel()
    @IBOutlet fileprivate var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.estimatedRowHeight = 100
        
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
    
    // UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return UITableViewAutomaticDimension
        } else if indexPath.row == 1 {
            return 200
        }
        return 130
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath) as! DetailTitleTableViewCell
            cell.item = detailViewModel.detailResultModel
            return cell
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "mapCell", for: indexPath) as! DetailMapTableViewCell
            cell.item = detailViewModel.detailResultModel
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "photoCell", for: indexPath) as! DetailPhotoTableViewCell
            cell.item = detailViewModel.detailResultModel?.detailPhotos
            return cell
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PhotoPageVViewController", let destination = segue.destination as? PhotoPageVViewController {
            destination.photoPageViewModel.detailPhotos = detailViewModel.detailResultModel?.detailPhotos
        }
    }
}
