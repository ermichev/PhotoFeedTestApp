//
//  FeedView.swift
//  PhotoFeedTestApp
//
//  Created by Alexander Ermichev on 08.06.2024.
//

import SwiftUI

struct FeedView: UIViewControllerRepresentable {
    
    @Environment(\.applicationDeps) var deps

    func makeUIViewController(context: Context) -> FeedCollectionViewController {
        FeedCollectionViewController(deps: deps)
    }
    
    func updateUIViewController(_ uiViewController: FeedCollectionViewController, context: Context) {

    }

}

#Preview {
    FeedView()
}
