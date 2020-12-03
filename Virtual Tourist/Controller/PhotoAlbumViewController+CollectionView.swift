//
//  PhotoAlbumViewController+CollectionView.swift
//  Virtual Tourist
//
//  Created by Ivan Zandonà on 30/11/20.
//

import Foundation
import UIKit

extension PhotoAlbumViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = fetchedResultsController.sections?[section].numberOfObjects ?? 0
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoAlbumViewCell.reuseIdentifier, for: indexPath as IndexPath) as! PhotoAlbumViewCell
        guard !(self.fetchedResultsController.fetchedObjects?.isEmpty)! else {
            return cell
        }
        
        let photoData = self.fetchedResultsController.object(at: indexPath)
        if photoData.imageData == nil {
            newCollectionButton.isEnabled = false
            DispatchQueue.global(qos: .background).async {
                if let imageUrl = photoData.imageUrl {
                    if let imageData = try? Data(contentsOf: imageUrl) {
                        DispatchQueue.main.async {
                            photoData.imageData = imageData
                            do {
                                try self.dataController.viewContext.save()
                            } catch {
                                print("Error during saving image")
                            }
                            
                            let image = UIImage(data: imageData)!
                            cell.setPhotoImageView(imageView: image, sizeFit: true)
                        }
                    }
                }
            }
        } else {
            if let imageData = photoData.imageData {
                let image = UIImage(data: imageData)!
                cell.setPhotoImageView(imageView: image, sizeFit: false)
            }
            
        }
        newCollectionButton.isEnabled = true
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedImageToRemove = fetchedResultsController.object(at: indexPath)
        self.removeImage(photo: selectedImageToRemove)
    }
    
    func configureCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsMultipleSelection = true
        
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let space:CGFloat = 3.0
            let dimension = (view.frame.size.width - (2 * space)) / 3.0
            flowLayout.minimumInteritemSpacing = space
            flowLayout.minimumLineSpacing = space
            flowLayout.itemSize = CGSize(width: dimension, height: dimension)
        }
    }
}
