//
//  PhotosFeedServiceMock.swift
//  PhotoFeedTestApp
//
//  Created by Alexander Ermichev on 09.06.2024.
//

import Combine
import Foundation

class PhotosFeedServiceMock: PhotosFeedService {

    init(failHalfRequests: Bool) {
        self.failHalfRequests = failHalfRequests
    }

    func feedSession(pageSize: Int) -> PhotosFeedSession {
        PhotosFeedSessionMock(pageSize: pageSize, failHalfRequests: failHalfRequests)
    }

    private let failHalfRequests: Bool

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

    init(pageSize: Int, failHalfRequests: Bool) {
        self.pageSize = pageSize
        self.failHalfRequests = failHalfRequests
    }

    // MARK: - Public methods

    func start() {
        guard stateImpl.value.loadingState == .notStarted else { return assertionFailure() }
        makeRequest(currentValues: [])
    }
    
    func retry() {
        guard stateImpl.value.loadingState == .error else { return assertionFailure() }
        makeRequest(currentValues: stateImpl.value.fetchedValues)
    }
    
    func fetchNextPage() {
        guard stateImpl.value.loadingState == .idle else { return assertionFailure() }
        makeRequest(currentValues: stateImpl.value.fetchedValues)
    }
    
    func clearAndRestart() {
        makeRequest(currentValues: [])
    }

    private func makeRequest(currentValues: [PhotoModel]) {
        stateImpl.send((.fetching, currentValues))
        dispatch(after: 1.0) { [weak self] in
            guard let self else { return }
            if failHalfRequests && random.next() % 2 == 0 {
                stateImpl.send((.error, currentValues))
            } else {
                let newValues = Self.testPage?.photos.prefix(pageSize) ?? []
                stateImpl.send((.idle, currentValues + newValues))
            }
        }
    }

    // -

    class func mockPhotosPage() -> [PhotoModel] {
        testPage?.photos ?? []
    }

    // MARK: - Private properties

    private let pageSize: Int
    private let failHalfRequests: Bool

    private var stateImpl = CurrentValueSubject<PhotosFeedSessionState, Never>((.notStarted, []))

    private var random = SystemRandomNumberGenerator()

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
