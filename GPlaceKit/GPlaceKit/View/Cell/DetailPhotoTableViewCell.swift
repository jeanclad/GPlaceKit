//
//  DetailPhotoTableViewCell.swift
//  GPlaceKit
//
//  Created by jeanclad on 2017. 9. 23..
//  Copyright © 2017년 jeanclad. All rights reserved.
//

import UIKit

class DetailPhotoTableViewCell: UITableViewCell {

    @IBOutlet private var collectionView: UICollectionView!
    @IBOutlet private var moreButton: UIButton!
    
    internal var item: [DetailPhotos]? {
        didSet {
            guard item != nil else {
                return
            }
            
            if (item?.count)! > 6{
                moreButton.isHidden = false
            } else {
                moreButton.isHidden = true
            }
            
            self.collectionView.reloadData()
        }
    }
    
    // MARK: Action
    @IBAction func moreButtonPressed(_ sender: UIButton) {
        guard item != nil else {
            return
        }
    }
}

extension DetailPhotoTableViewCell:  UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return min(6, item?.count ?? 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCollectionCell", for: indexPath) as! DetailPhotoCollectionViewCell
        DispatchQueue.main.async {
            cell.item = self.item?[indexPath.item]
        }
        return cell
    }
}

extension DetailPhotoTableViewCell:  UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 90, height: 90)
    }
}
