//
//  PhotoLoadingServiceMock.swift
//  PhotoFeedTestApp
//
//  Created by Alexander Ermichev on 26.06.2024.
//

import Combine
import SDWebImage

final class PhotoLoadingServiceMock: PhotoLoadingService {
   
    init(failHalfRequests: Bool) {
        self.failHalfRequests = failHalfRequests
    }

    func loadPhoto(_ model: PhotoModel, size: PhotoSize) -> AnyPublisher<UIImage, Error> {
        impl.loadPhoto(model, size: size)
            .delay(for: .seconds(1), scheduler: RunLoop.main)
            .tryMap { [weak self] in
                guard let self else { return $0 }
                if failHalfRequests && random.next() % 2 == 0 {
                    throw Errors.unknownError
                } else {
                    return $0
                }
            }
            .eraseToAnyPublisher()
    }
    
    private let failHalfRequests: Bool
    private var random = SystemRandomNumberGenerator()

    private let impl = SDWebImageManager.shared

}
