//
//  ImageCell.swift
//  gallery
//
//  Created by 진형탁 on 2017. 11. 30..
//  Copyright © 2017년 njir. All rights reserved.
//

import UIKit

class ImageCell: UICollectionViewCell, UIScrollViewDelegate {
    
    // MARK: - Properties
    
    var scrollView: UIScrollView!
    var assetImg: UIImageView!
    
    // MARK: - Initialize
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setScrollView()
        setFullImgView()
        self.addSubview(self.scrollView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.scrollView.frame = self.bounds
        self.assetImg.frame = self.bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.scrollView.setZoomScale(1, animated: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Set default view
    
    func setFullImgView() {
        self.assetImg = UIImageView()
        self.assetImg.image = nil
        self.assetImg.contentMode = .scaleAspectFit
        self.scrollView.addSubview(self.assetImg)
    }
    
    func setScrollView() {
        // Set Scroll View
        self.scrollView = UIScrollView()
        self.scrollView.delegate = self
        self.scrollView.alwaysBounceVertical = false
        self.scrollView.alwaysBounceHorizontal = false
        self.scrollView.showsVerticalScrollIndicator = true
        self.scrollView.flashScrollIndicators()
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 4.0
        
        // Add double tap gesture
        let doubleTapGest = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTapScrollView(recognizer:)))
        doubleTapGest.numberOfTapsRequired = 2
        self.scrollView.addGestureRecognizer(doubleTapGest)
    }
    
    // MARK: - Gesture Function
    
    @objc func handleDoubleTapScrollView(recognizer: UITapGestureRecognizer) {
        if scrollView.zoomScale == 1 {
            scrollView.zoom(to: zoomRectForScale(scale: scrollView.maximumZoomScale, center: recognizer.location(in: recognizer.view)), animated: true)
        } else {
            scrollView.setZoomScale(1, animated: true)
        }
    }
    
    func zoomRectForScale(scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        zoomRect.size.height = self.assetImg.frame.size.height / scale
        zoomRect.size.width = self.assetImg.frame.size.width / scale
        let newCenter = self.assetImg.convert(center, from: scrollView)
        zoomRect.origin.x = newCenter.x - (zoomRect.size.width / 2.0)
        zoomRect.origin.y = newCenter.y - (zoomRect.size.height / 2.0)
        
        return zoomRect
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.assetImg
    }
    
}
