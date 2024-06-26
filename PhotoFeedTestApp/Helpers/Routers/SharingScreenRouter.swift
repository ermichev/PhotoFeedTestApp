//
//  SharingScreenRouter.swift
//  PhotoFeedTestApp
//
//  Created by Alexander Ermichev on 25.06.2024.
//

import UIKit

final class SharingScreenRouterImpl: SharingScreenRouter {
   
    func shareImage(_ image: UIImage, sourceRect: CGRect) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            Logger.log.error("Failed to get jpeg image data")
            return
        }

        let activityVC = UIActivityViewController(activityItems: [imageData], applicationActivities: nil)

        if let rootVC = UIApplication.shared.applicationKeyWindow()?.rootViewController,
           let topVC = UIApplication.shared.topViewController()
        {
            activityVC.popoverPresentationController?.sourceView = topVC.view
            activityVC.popoverPresentationController?.sourceRect = topVC.view.convert(sourceRect, from: rootVC.view)
            topVC.present(activityVC, animated: true)
        }
    }

}
