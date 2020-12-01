//
//  PhotoAlbumViewCell.swift
//  Virtual Tourist
//
//  Created by Ivan Zandonà on 30/11/20.
//

import Foundation
import UIKit

class PhotoAlbumViewCell : UICollectionViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!

    static let reuseIdentifier = "PhotoAlbumViewCell"
    
    func setPhotoImageView(imageView: UIImage, sizeFit: Bool) {
        photoImageView.image = imageView
        if sizeFit == true {
            photoImageView.sizeToFit()
        }
    }
}
