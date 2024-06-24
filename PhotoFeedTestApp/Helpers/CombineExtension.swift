//
//  CombineExtension.swift
//  PhotoFeedTestApp
//
//  Created by Alexander Ermichev on 24.06.2024.
//

import Combine

extension CurrentValueSubject where Output: Equatable {

    func distinctValues() -> AnyPublisher<Output, Failure> {
        prepend(value)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

}
