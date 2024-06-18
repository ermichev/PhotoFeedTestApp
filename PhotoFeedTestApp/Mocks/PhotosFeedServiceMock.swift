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
   
    // MARK: - Public properties

    var state: AnyPublisher<PhotosFeedSessionState, Never> {
        stateImpl.eraseToAnyPublisher()
    }

    var hasNextPage: Bool {
        Self.testPage?.nextPage != nil
    }

    // MARK: - Constructors

    init() { }

    // MARK: - Public methods

    func start() {
        guard stateImpl.value.loadingState == .notStarted else { return assertionFailure() }

        stateImpl.send((.fetching, stateImpl.value.fetchedValues))
        dispatch(after: 1.0) { [weak self] in
            guard let self else { return }
            let newValues = stateImpl.value.fetchedValues + (Self.testPage?.photos ?? [])
            stateImpl.send((.idle, newValues))
        }
    }
    
    func retry() {
        guard stateImpl.value.loadingState == .error else { return assertionFailure() }
    }
    
    func fetchNextPage() {
        guard stateImpl.value.loadingState == .idle else { return assertionFailure() }

        stateImpl.send((.fetching, stateImpl.value.fetchedValues))
        dispatch(after: 1.0) { [weak self] in
            guard let self else { return }
            let newValues = stateImpl.value.fetchedValues + (Self.testPage?.photos ?? [])
            stateImpl.send((.idle, newValues))
        }
    }
    
    func clear() {
        stateImpl.send((.notStarted, []))
    }
    
    // MARK: - Private properties

    private var stateImpl = CurrentValueSubject<PhotosFeedSessionState, Never>((.notStarted, []))

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
