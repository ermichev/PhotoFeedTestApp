//
//  PhotosFeedService.swift
//  PhotoFeedTestApp
//
//  Created by Alexander Ermichev on 09.06.2024.
//

import Combine

enum PhotosFeedSessionState {
    case notStarted
    case fetching
    case idle
    case error
}

protocol PhotosFeedSession {
    var state: AnyPublisher<PhotosFeedSessionState, Never> { get }
    var photos: AnyPublisher<[PhotoModel], Never> { get }
    func start()
    func retry()
    func fetchNextPage()
    func clear()
}

protocol PhotosFeedService {
    func feedSession(pageSize: Int) -> PhotosFeedSession
}
