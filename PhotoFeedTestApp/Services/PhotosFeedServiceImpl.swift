//
//  PhotosFeedServiceImpl.swift
//  PhotoFeedTestApp
//
//  Created by Alexander Ermichev on 26.06.2024.
//

import Combine
import Foundation

final class PhotosFeedServiceImpl: PhotosFeedService {

    init(apiKey: String) {
        self.apiKey = apiKey
    }

    func feedSession(pageSize: Int) -> PhotosFeedSession {
        PhotosFeedSessionImpl(pageSize: pageSize, apiKey: apiKey)
    }

    private let apiKey: String

}

// -

final class PhotosFeedSessionImpl: PhotosFeedSession {

    // MARK: - Public properties

    let state: AnyPublisher<PhotosFeedSessionState, Never>

    var hasNextPage: Bool { nextPageUrl != nil }

    // MARK: - Constructors

    init(pageSize: Int, apiKey: String) {
        self.apiKey = apiKey

        stateImpl = .init((.notStarted, []))
        state = stateImpl.share().eraseToAnyPublisher()

        firstPageUrl = URL(string: "https://api.pexels.com/v1/curated?per_page=\(pageSize)")
    }

    // MARK: - Public methods

    func start() {
        guard stateImpl.value.loadingState == .notStarted else { return assertionFailure() }
        nextPageUrl = firstPageUrl
        performPageRequest(currentValues: [])
    }
    
    func retry() {
        guard stateImpl.value.loadingState == .error else { return assertionFailure() }
        performPageRequest(currentValues: stateImpl.value.fetchedValues)
    }
    
    func fetchNextPage() {
        guard stateImpl.value.loadingState == .idle else { return assertionFailure() }
        performPageRequest(currentValues: stateImpl.value.fetchedValues)
    }
    
    func clearAndRestart() {
        nextPageUrl = firstPageUrl
        performPageRequest(currentValues: [])
    }

    // MARK: - Private properties

    private let apiKey: String
    private let firstPageUrl: URL?
    private var nextPageUrl: URL?

    private let stateImpl: CurrentValueSubject<PhotosFeedSessionState, Never>

}

private extension PhotosFeedSessionImpl {

    // MARK: - Private methods

    private func performPageRequest(currentValues: [PhotoModel]) {
        guard let requestURL = nextPageUrl else { return assertionFailure() }

        var request = URLRequest(url: requestURL)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.setValue(apiKey, forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, _ in
            guard let self else { return }

            if let data,
               let pageModel = try? JSONDecoder().decode(PhotosPageModel.self, from: data)
            {
                nextPageUrl = pageModel.nextPage
                stateImpl.send((.idle, currentValues + pageModel.photos))
                Logger.log.debug("Recieved photos: \(pageModel.photos.map {$0.id}), url: \(requestURL)")
            } else {
                stateImpl.send((.error, currentValues))
            }
        }

        stateImpl.send((.fetching, currentValues))
        task.resume()
    }

}
