//
//  DetailPhotoTableViewCell.swift
//  GPlaceKit
//
//  Created by jeanclad on 2017. 9. 23..
//  Copyright © 2017년 jeanclad. All rights reserved.
//

import UIKit

class DetailPhotoTableViewCell: UITableViewCell, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {

    @IBOutlet private var collectionView: UICollectionView!
    
    internal var item: [DetailPhotos]? {
        didSet {
            guard item != nil else {
                return
            }
            
            self.collectionView .reloadData()
        }
    }
    
    // UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return item?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCollectionCell", for: indexPath) as! DetailPhotoCollectionViewCell
        cell.item = item?[indexPath.item]
        return cell
    }
    
    // UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 90, height: 90)
    }
}
