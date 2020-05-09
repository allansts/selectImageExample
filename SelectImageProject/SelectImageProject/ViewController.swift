//
//  SelectImageViewController.swift
//  LoaderView
//
//  Created by Allan on 09/05/2020.
//  Copyright © 2020 Allan. All rights reserved.
//

import UIKit
import Photos
import BSImagePicker

class ViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var selectImageButton: UIButton!
    
    var selectedAssets = [PHAsset]()
    var selectedImages = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectImageButton.addTarget(self, action: #selector(actionGetImages(_:)), for: .touchUpInside)
        pageControl.currentPage = 0
        pageControl.hidesForSinglePage = true
        scrollView.delegate = self
        
    }
    
    
    @objc func actionGetImages(_ sender: UIButton) {
        selectedAssets.removeAll()
        
        let imagePicker = ImagePickerController()
        imagePicker.settings.selection.max = 3
        imagePicker.settings.theme.selectionStyle = .numbered
        imagePicker.settings.fetch.assets.supportedMediaTypes = [.image]
        imagePicker.settings.selection.unselectOnReachingMax = true

        self.presentImagePicker(imagePicker, select: { (asset) in
            
        }, deselect: { (asset) in
            
        }, cancel: { (assets) in
            
        }, finish: { (assets) in
            
            self.selectedAssets.append(contentsOf: assets)
            
            self.convertAssetToImages()
        }, completion: {})
        
    }
    
    func convertAssetToImages() -> Void {
        selectedImages = [UIImage]()
        
        selectedAssets.forEach({
            let option = PHImageRequestOptions()
            option.isSynchronous = true
            selectedImages.append(
                $0.image(targetSize: CGSize(width: 1000, height: 1000),
                     contentMode: .aspectFill, options: option)
            )
        })
        
        pageControl.numberOfPages = selectedImages.count
        setupSlideScrollView()
    }
    
    func setupSlideScrollView() {
        scrollView.contentSize = CGSize(width: view.frame.width * CGFloat(selectedImages.count), height: scrollView.frame.height)
        scrollView.isPagingEnabled = true
        
        for (i, img) in selectedImages.enumerated() {
            let imageView = UIImageView(frame:
                CGRect(x: view.frame.width * CGFloat(i), y: 0, width: view.frame.width, height: scrollView.frame.height)
            )
            imageView.image = img
            imageView.contentMode = .scaleToFill
            scrollView.addSubview(imageView)
        }
    }
}

extension ViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x/view.frame.width)
        pageControl.currentPage = Int(pageIndex)
    }
    
}


extension PHAsset {
    func image(targetSize: CGSize, contentMode: PHImageContentMode, options: PHImageRequestOptions?) -> UIImage {
        var thumbnail = UIImage()
        let imageManager = PHCachingImageManager()
        imageManager.requestImage(for: self, targetSize: targetSize, contentMode: contentMode, options: options, resultHandler: { image, _ in
            thumbnail = image!
        })
        return thumbnail
    }
}
