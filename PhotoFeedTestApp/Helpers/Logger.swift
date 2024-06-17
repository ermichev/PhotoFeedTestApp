//
//  Logger.swift
//  PhotoFeedTestApp
//
//  Created by Alexander Ermichev on 17.06.2024.
//

import OSLog

typealias Logger = os.Logger

extension Logger {

    static let log = Logger(subsystem: subsystem, category: "debug")

    private static var subsystem = Bundle.main.bundleIdentifier ?? Bundle.main.bundlePath

}
