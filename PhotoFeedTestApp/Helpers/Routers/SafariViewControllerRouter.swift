//
//  SafariViewControllerRouter.swift
//  PhotoFeedTestApp
//
//  Created by Alexander Ermichev on 24.06.2024.
//

import SafariServices

protocol SafariViewControllerRouter {
    func openUrl(_ url: URL)
}

final class SafariViewControllerRouterImpl: SafariViewControllerRouter {

    func openUrl(_ url: URL) {
        let viewController = SFSafariViewController(url: url)
        viewController.modalPresentationStyle = .overCurrentContext
        UIApplication.shared.topViewController()?.present(viewController, animated: true)
    }

}

// -

public extension UIWindow {

    func topViewController() -> UIViewController? {
        var topViewController = rootViewController

        while (topViewController?.presentedViewController != nil) {
            topViewController = topViewController?.presentedViewController!
        }
        return topViewController
    }

}


extension UIApplication {

    func applicationScene() -> UIWindowScene? {
        connectedScenes.first { $0.session.role == .windowApplication } as? UIWindowScene
    }

    func applicationKeyWindow() -> UIWindow? {
        applicationScene()?.keyWindow
    }

    func topViewController() -> UIViewController? {
        applicationKeyWindow()?.topViewController()
    }

}
