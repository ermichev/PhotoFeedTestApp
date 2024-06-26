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
    }

    struct FetchedPart {
        let models: [PhotoModel]
        let hasNextPage: Bool
    }
}

extension FeedViewState {

    var isLoading: Bool {
        switch self {
        case .started(.fetching, _): true
        default: false
        }
    }

    var isError: Bool {
        switch self {
        case .started(.error, _): true
        default: false
        }
    }

    var isNotStarted: Bool {
        switch self {
        case .notStarted: true
        default: false
        }
    }

}

