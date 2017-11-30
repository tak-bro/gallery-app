//
//  ThumbnailViewController.swift
//  gallery
//
//  Created by 진형탁 on 2017. 11. 28..
//  Copyright © 2017년 njir. All rights reserved.
//

import UIKit
import Photos

class ThumbnailViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var thumbnailCollectionView: UICollectionView!
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    
    // MARK:- Properties
    
    fileprivate var photoLibrary: PhotoLibrary!
    fileprivate var numberOfSections = 0
    fileprivate let sectionInsets = UIEdgeInsets(top: 0.5, left: 0.5, bottom: 0.5, right: 0.5)
    fileprivate let itemsPerRow: CGFloat = 4
    
    // MARK: - Initialze
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initCollectionView()
        initPhotoLib()
    }
    
    // MARK: - Navigation control
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AssetVC" {
            guard let assetVC = segue.destination as? AssetViewController else { return }
            guard let selectedIndexPath = sender as? IndexPath else { return }
            
            assetVC.photoLibrary = self.photoLibrary
            assetVC.passedIndexPath = selectedIndexPath
        }
    }
    
    // MARK: - Helper Functions
    
    func initPhotoLib() {
        // start spinner
        self.loadingSpinner.hidesWhenStopped = true
        self.loadingSpinner.startAnimating()
        requestAuthForPhoto()
    }
    
    func requestAuthForPhoto() {
        PHPhotoLibrary.requestAuthorization { (status) in
            switch status {
            case .authorized:
                self.photoLibrary = PhotoLibrary()
                self.numberOfSections = 1
                DispatchQueue.main.async {
                    self.thumbnailCollectionView.reloadData()
                    self.loadingSpinner.stopAnimating()
                }
            case .denied, .restricted:
                // TODO: Add alertview
                print("Not allowed")
                self.loadingSpinner.stopAnimating()
            case .notDetermined:
                // TODO: Add alertview
                print("Not determined yet")
                self.loadingSpinner.stopAnimating()
            }
        }
    }

}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource {

extension ThumbnailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func initCollectionView() {
        self.thumbnailCollectionView.delegate = self
        self.thumbnailCollectionView.dataSource = self
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photoLibrary.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ThumbnailCell", for: indexPath) as! ThumbnailCell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "AssetVC", sender: indexPath)
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ThumbnailViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        guard let cell = cell as? ThumbnailCell else {
            return
        }
        cell.thumbnailImg.image = nil
        cell.thumbnailImg.contentMode = .scaleAspectFill
        cell.thumbnailImg.clipsToBounds = true
        cell.videoPlayImg.isHidden = true
        
        DispatchQueue(label: "setThumbnail").async {
            self.photoLibrary.setLibrary(mode: .thumbnail, at: indexPath.row) { image, isVideo in
                if let image = image {
                    DispatchQueue.main.async {
                        cell.videoPlayImg.isHidden = isVideo ? false : true
                        cell.thumbnailImg.image = image
                    }
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow+1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
}
