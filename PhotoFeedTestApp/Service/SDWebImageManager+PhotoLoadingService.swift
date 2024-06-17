//
//  SDWebImageManager+PhotoLoadingService.swift
//  PhotoFeedTestApp
//
//  Created by Alexander Ermichev on 15.06.2024.
//

import Combine
import SDWebImage
import UIKit

extension SDWebImageManager: PhotoLoadingService {
    
    func loadPhoto(_ model: PhotoModel, size: PhotoSize) -> AnyPublisher<UIImage, Error> {
        guard let url = model.imageUrls[size] else {
            return Fail(error: Errors.invalidUrlSize).eraseToAnyPublisher()
        }

        return Deferred { [weak self] in
            Future<UIImage, Error> { [weak self] promise in
                self?.loadImage(with: url, progress: nil) { image, _, error, cacheType, _, _ in
                    if let image {
                        Logger.log.debug("Image loaded, cache type: \(cacheType)")
                        promise(.success(image))
                    } else {
                        Logger.log.debug("Image load failed, error: \(error)")
                        promise(.failure(error ?? Errors.unknownError))
                    }
                }
            }
        }.eraseToAnyPublisher()
    }

}

extension SDImageCacheType: CustomStringConvertible {
  
    public var description: String {
        switch self {
        case .none: return ".none"
        case .memory: return ".memory"
        case .disk: return ".disk"
        case .all: return ".all"
        @unknown default: return "unknown case"
        }
    }

}
