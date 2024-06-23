//
//  RTLHelper.swift
//  PhotoFeedTestApp
//
//  Created by Alexander Ermichev on 20.06.2024.
//

import UIKit

extension UIView {

    var isRTL: Bool {
        UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .rightToLeft
    }
    
}
