//
//  FeedViewState.swift
//  PhotoFeedTestApp
//
//  Created by Alexander Ermichev on 26.06.2024.
//

enum FeedViewState {
    case notStarted
    case started(state: LoadingState, fetched: FetchedPart)

    enum LoadingState {
        case idle
        case fetching
        case error
        case refreshing /// Separate from fetching to indicate refresh control presence
    }

    struct FetchedPart {
        let models: [PhotoModel]
        let hasNextPage: Bool
    }
}

extension FeedViewState {

    var isLoading: Bool {
        switch self {
        case .started(.fetching, _), .started(.refreshing, _): true
        default: false
        }
    }

    var isRefreshing: Bool {
        switch self {
        case .started(.refreshing, _): true
        default: false
        }
    }

}

