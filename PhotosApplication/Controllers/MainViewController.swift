//
//  MainViewController.swift
//  PhotosApplication
//
//  Created by Faizyy on 28/03/21.
//

import UIKit
import Photos

class MainViewController: UICollectionViewController {

    var viewModel: MainViewModel!
    var itemsInRow = 4 // Initial number of photos to display in a single row
    var ROW_SPACING: CGFloat = 1
    var ITEM_SPACING: CGFloat = 1
    let photoManager = PHCachingImageManager()
//    fileprivate var thumbnailSize: CGSize! // Used to determine photo quality
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = MainViewModelImplementation()
        setupCollectionView()
//        updateThumbnailSize()
        bind()
        requestPermission()
        addGestureRecogniser()
    }
    
//    private func updateThumbnailSize() {
//        thumbnailSize = collectionView(collectionView, layout: collectionView.collectionViewLayout, sizeForItemAt: IndexPath(row: 0, section: 0))
//        photoManager.stopCachingImagesForAllAssets()
//    }
    
    private func addGestureRecogniser() {
        // Pinch Gesture
        let gestureRecogniser = UIPinchGestureRecognizer(target: self, action: #selector(didPinch(sender:)))
        collectionView.addGestureRecognizer(gestureRecogniser)
    }
    
    @objc private func didPinch(sender: UIPinchGestureRecognizer) {
        // focusIndex :- Index of the photo cell on which user started zooming.
        guard let focusIndex = collectionView.indexPathForItem(at: sender.location(in: collectionView)), sender.state == .began else {
            return
        }
        
        if sender.velocity > 0 { // Zoom in
            if itemsInRow == 1 {
                return
            }
            itemsInRow = itemsInRow == 4 ? 3 : 1
        } else { // Zoom out
            if itemsInRow == 4 {
                return
            }
            itemsInRow = itemsInRow == 1 ? 3 : 4
        }
        // Update the image Quality and start caching new quality images.
//        updateThumbnailSize()
//        startCaching()
        
        // Animate the collectionView to update number of photos in a row.
        collectionView.performBatchUpdates({
            collectionView.reloadData()
            collectionView.collectionViewLayout.invalidateLayout()
            collectionView.scrollToItem(at: focusIndex, at: .centeredVertically, animated: false)
        }, completion: nil)
    }
    
    // This function provides implementation of viewModel callbacks.
    private func bind() {
        viewModel.didFetchPhotoAssetsSucceed = { [weak self] in
            guard let self = self else { return }
//            self.startCaching()
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
        
        viewModel.didFetchPhotoAssetsFail = { [weak self] error in
            guard let self = self else { return }
            // Show Alert
            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            self.present(alert, animated: true, completion: nil)
        }
    }

//    private func startCaching() {
          // Cache all the asset images.
//        let indexSet = IndexSet.init(integersIn: 0...self.viewModel.photoAssets.count-1)
//        let assetList = self.viewModel.photoAssets.objects(at: indexSet)
//        let options = PHImageRequestOptions()
//        options.deliveryMode = .opportunistic
//        self.photoManager.startCachingImages(for: assetList, targetSize: self.thumbnailSize, contentMode: .aspectFill, options: options)
//    }
    
    private func setupCollectionView() {
        collectionView.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: PhotoCollectionViewCell.identifier)
        collectionView.allowsSelection = false
        collectionView.collectionViewLayout = UICollectionViewFlowLayout()
    }
    
    // Function to check User Authorisation.
    private func requestPermission() {
        guard PHPhotoLibrary.authorizationStatus() != .authorized else {
            viewModel.fetchPhotoAssets()
          return
        }
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .authorized:
                self.viewModel.fetchPhotoAssets()
            default:
                print("Cannot proceed without photos permission!")
            }
        }
    }

}

extension MainViewController: UICollectionViewDelegateFlowLayout {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.photoAssets.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.identifier, for: indexPath) as? PhotoCollectionViewCell else {
            fatalError("Could not dequeue cell of type \(PhotoCollectionViewCell.description())")
        }
        let size = self.collectionView(collectionView, layout: collectionView.collectionViewLayout, sizeForItemAt: indexPath)
        cell.imageView.fetchImage(for: viewModel.getPhotoAsset(at: indexPath.row), targetSize: size, imageManager: self.photoManager)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let insets = (CGFloat(itemsInRow - 1) * ITEM_SPACING)
        let cellWidth = (view.frame.size.width / CGFloat(itemsInRow)) - insets
        
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return ITEM_SPACING
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return ROW_SPACING
    }
}
