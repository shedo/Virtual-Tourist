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
    @IBOutlet weak var downloadImage: UIActivityIndicatorView!
    
    static let reuseIdentifier = "PhotoAlbumViewCell"
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        downloadImage.isHidden = false
        downloadImage.startAnimating()
    }
    
    func setPhotoImageView(imageView: UIImage, sizeFit: Bool) {
        
        photoImageView.image = imageView
        if sizeFit == true {
            photoImageView.sizeToFit()
        }
        
        
        downloadImage.isHidden = true
        downloadImage.stopAnimating()
    }
}
