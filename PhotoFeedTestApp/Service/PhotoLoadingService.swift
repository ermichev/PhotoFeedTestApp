//
//  PhotoLoadingService.swift
//  PhotoFeedTestApp
//
//  Created by Alexander Ermichev on 09.06.2024.
//

import Combine
import UIKit

protocol PhotoLoadingService {
    func loadPhoto(_ model: PhotoModel, size: PhotoSize) -> AnyPublisher<UIImage, Error>
}
