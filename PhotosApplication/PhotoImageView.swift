//
//  PhotoImageView.swift
//  PhotosApplication
//
//  Created by Faizyy on 28/03/21.
//

import UIKit
import Photos

class PhotoImageView: UIImageView {

    var id: String?
    
    func fetchImage(for asset: PHAsset, targetSize: CGSize, imageManager: PHCachingImageManager) {
        self.id = asset.localIdentifier
        let options = PHImageRequestOptions()
//        options.deliveryMode = .opportunistic
        imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: options) { image, _ in
            if let image = image, asset.localIdentifier == self.id {
                self.image = image
            }
        }
    }

}
