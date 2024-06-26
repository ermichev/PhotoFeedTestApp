//
//  PhotosFeedService.swift
//  PhotoFeedTestApp
//
//  Created by Alexander Ermichev on 09.06.2024.
//

import Combine

enum SessionLoadingState {
    case notStarted
    case fetching
    case idle
    case error
}

typealias PhotosFeedSessionState = (
    loadingState: SessionLoadingState,
    fetchedValues: [PhotoModel]
)

protocol PhotosFeedSession {
    var state: AnyPublisher<PhotosFeedSessionState, Never> { get }
    var hasNextPage: Bool { get }
    func start()
    func retry()
    func fetchNextPage()
    func clear()
}

protocol PhotosFeedService {
    func feedSession(pageSize: Int) -> PhotosFeedSession
}
