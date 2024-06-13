//
//  PhotosFeedServiceMock.swift
//  PhotoFeedTestApp
//
//  Created by Alexander Ermichev on 09.06.2024.
//

import Combine
import Foundation

class PhotosFeedServiceMock: PhotosFeedService {
    func feedSession(pageSize: Int) -> PhotosFeedSession {
        PhotosFeedSessionMock()
    }
}

class PhotosFeedSessionMock: PhotosFeedSession {
   
    var state: AnyPublisher<PhotosFeedSessionState, Never> {
        stateImpl.eraseToAnyPublisher()
    }

    var photos: AnyPublisher<[PhotoModel], Never> {
        photosImpl.eraseToAnyPublisher()
    }

    init() { }

    func start() {
        guard stateImpl.value == .notStarted else { return assertionFailure() }

        stateImpl.send(.fetching)
        dispatch(after: 1.0) { [weak self] in
            guard let self else { return }
            photosImpl.send(Self.testPage?.photos ?? [])
            stateImpl.send(.idle)
        }
    }
    
    func retry() {
        guard stateImpl.value == .error else { return assertionFailure() }
    }
    
    func fetchNextPage() {
        guard stateImpl.value == .idle else { return assertionFailure() }

        stateImpl.send(.fetching)
        dispatch(after: 1.0) { [weak self] in
            guard let self else { return }
            photosImpl.send(photosImpl.value + (Self.testPage?.photos ?? []))
            stateImpl.send(.idle)
        }
    }
    
    func clear() {
        photosImpl.send([])
        stateImpl.send(.notStarted)
    }
    
    private var stateImpl = CurrentValueSubject<PhotosFeedSessionState, Never>(.notStarted)
    private var photosImpl = CurrentValueSubject<[PhotoModel], Never>([])

    private static let testPage: PhotosPageModel? = {
        guard let path = Bundle.main.path(forResource: "test_page", ofType: "json") else { return nil }
        let url = URL(fileURLWithPath: path)
        guard let data = try? Data(contentsOf: url, options: .alwaysMapped) else { return nil }
        return try? JSONDecoder().decode(PhotosPageModel.self, from: data)
    }()

}

// -

func dispatch(after: TimeInterval, block: @escaping (() -> Void)) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(after * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),
        execute: block
    )
}
