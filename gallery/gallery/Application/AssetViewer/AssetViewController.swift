//
//  AssetViewController.swift
//  gallery
//
//  Created by 진형탁 on 2017. 11. 30..
//  Copyright © 2017년 njir. All rights reserved.
//

import UIKit
import Photos

class AssetViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var assetCollectionView: UICollectionView!
    @IBOutlet weak var customNavBar: UINavigationBar!
    @IBOutlet weak var closeBtn: UIBarButtonItem!
    @IBOutlet weak var navBarTitle: UINavigationItem!
    @IBOutlet weak var leftArrowBtn: UIButton!
    @IBOutlet weak var rightArrowBtn: UIButton!
    
    // MARK: - Properties
    
    var photoLibrary: PhotoLibrary!
    var passedIndexPath = IndexPath()
    
    fileprivate var scollOnceOnly = false
    fileprivate var numberOfSections = 1
    fileprivate let sectionInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    fileprivate let itemsPerRow: CGFloat = 4
    
    // MARK: - Initialze
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
        setNavTitle(indexPath: self.passedIndexPath)
        initCollectionView()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        let offset = self.assetCollectionView.contentOffset
        let width  = self.assetCollectionView.bounds.size.width
        
        let index = round(offset.x / width)
        let newOffset = CGPoint(x: index * size.width, y: offset.y)
        
        self.assetCollectionView.setContentOffset(newOffset, animated: false)
        
        coordinator.animate(alongsideTransition: { (_) in
            self.assetCollectionView.reloadData()
            self.assetCollectionView.setContentOffset(newOffset, animated: false)
        }, completion: nil)
    }
    
    // MARK: - UI Function
    
    func setUI() {
        self.assetCollectionView.backgroundColor = UIColor.black
    }
    
    func setNavTitle(indexPath: IndexPath) {
        self.navBarTitle.title = "\(indexPath.row+1) / \(self.photoLibrary.count)"
    }
    
    // MARK: - Outlet Actions
    
    @IBAction func pressCloseBtn(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func pressLeftArrow(_ sender: UIButton) {
        // TODO
    }
    
    @IBAction func pressRightArrow(_ sender: UIButton) {
        // TODO
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource {

extension AssetViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func initCollectionView() {
        self.assetCollectionView.delegate = self
        self.assetCollectionView.dataSource = self
        self.assetCollectionView.showsHorizontalScrollIndicator = false
        self.assetCollectionView.isPagingEnabled = true
        self.assetCollectionView.register(ImageCell.self, forCellWithReuseIdentifier: "ImageCell")
        self.assetCollectionView.register(VideoCell.self, forCellWithReuseIdentifier: "VideoCell")
        self.assetCollectionView.autoresizingMask = UIViewAutoresizing(rawValue: UIViewAutoresizing.RawValue(UInt8(UIViewAutoresizing.flexibleWidth.rawValue) | UInt8(UIViewAutoresizing.flexibleHeight.rawValue)))
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photoLibrary.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let asset = self.photoLibrary.getAsset(at: indexPath.row)
        if asset?.mediaType == .video {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCell", for: indexPath) as! VideoCell
            asset?.getURL() { url in
                cell.videoItemUrl = url
            }
            return cell
        } else { // .image
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        // scroll to selected cell
        if !self.scollOnceOnly {
            self.assetCollectionView.scrollToItem(at: passedIndexPath, at: .left, animated: false)
            self.scollOnceOnly = true
        }
        
        // Show media data
        self.photoLibrary.setLibrary(mode: .full, at: indexPath.row) { image, isVideo in
            DispatchQueue.main.async {
                // set title
                self.setNavTitle(indexPath: indexPath)
                
                if isVideo {
                    let cell = cell as! VideoCell
                    cell.avPlayer?.play()
                } else { // .image
                    let cell = cell as! ImageCell
                    cell.assetImg.image = image
                }
            }
        }
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout

extension AssetViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewHeight = self.assetCollectionView.bounds.height
        let collectionViewWidth = self.assetCollectionView.bounds.width
        return CGSize(width: collectionViewWidth, height: collectionViewHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return self.sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
}

extension AssetViewController {
    
    // to pause video when dragging
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let indexPath = self.assetCollectionView.indexPathsForVisibleItems.first
        
        if let asset = self.photoLibrary.getAsset(at: (indexPath?.row)!),
            asset.mediaType == .video {
            let cell = self.assetCollectionView.cellForItem(at: indexPath!) as! VideoCell
            cell.avPlayer?.pause()
        }
    }
}
