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
                self?.loadImage(with: url, progress: nil) { image, _, error, _, _, _ in
                    if let image {
                        promise(.success(image))
                    } else {
                        promise(.failure(error ?? Errors.unknownError))
                    }
                }
            }
        }.eraseToAnyPublisher()
    }
    

}
