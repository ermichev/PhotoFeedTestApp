//
//  SharingScreenRouter.swift
//  PhotoFeedTestApp
//
//  Created by Alexander Ermichev on 25.06.2024.
//

import UIKit

final class SharingScreenRouterImpl: SharingScreenRouter {
   
    func shareImage(_ image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            Logger.log.error("Failed to get jpeg image data")
            return
        }

        let activityVC = UIActivityViewController(activityItems: [imageData], applicationActivities: [])
        UIApplication.shared.topViewController()?.present(activityVC, animated: true)
    }

}
