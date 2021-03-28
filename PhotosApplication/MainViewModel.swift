//
//  MainViewModel.swift
//  PhotosApplication
//
//  Created by Faizyy on 28/03/21.
//

import Foundation
import Photos

protocol MainViewModel {
    var photoAssets: PHFetchResult<PHAsset> { get set }
    
    var didFetchPhotoAssetsSucceed: (()->Void)? { get set }
    var didFetchPhotoAssetsFail: ((Error)->Void)? { get set }
    
    func fetchPhotoAssets()
    func getPhotoAsset(at index: Int) -> PHAsset
}

class MainViewModelImplementation: MainViewModel {
    var didFetchPhotoAssetsSucceed: (() -> Void)?
    var didFetchPhotoAssetsFail: ((Error) -> Void)?

    var photoAssets = PHFetchResult<PHAsset>()
    
    func fetchPhotoAssets() {
        
        photoAssets = PHAsset.fetchAssets(with: .image, options: PHFetchOptions())
        didFetchPhotoAssetsSucceed?()
    }
    
    func getPhotoAsset(at index: Int) -> PHAsset {
        guard index <= photoAssets.count else {
            fatalError("Index out of bounds.")
        }
        return self.photoAssets.object(at: index)
    }
    
    
    
}
