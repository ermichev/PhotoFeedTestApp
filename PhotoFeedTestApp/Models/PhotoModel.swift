//
//  PhotoModel.swift
//  PhotoFeedTestApp
//
//  Created by Alexander Ermichev on 08.06.2024.
//

import Foundation
import UIKit

struct PhotographerModel: Identifiable {
    let id: Int
    let name: String
    let url: URL
}

enum PhotoSize: String, CaseIterable, CodingKey {
    case original
    case large2x
    case large
    case medium
    case small
    case portrait
    case landscape
    case tiny
}

struct PhotoModel: Identifiable {
    let id: Int
    let size: (width: Int, height: Int)
    let url: URL
    let photographer: PhotographerModel
    let averageColor: UIColor
    let altText: String
    let imageUrls: [PhotoSize: URL]

    enum CodingKeys: String, CodingKey {
        case id
        case width
        case height
        case url
        case photographer
        case photographerUrl = "photographer_url"
        case photographerId = "photographer_id"
        case averageColor = "avg_color"
        case altText = "alt"
        case imageUrls = "src"

    }

    enum ParsingError: Error {
        case invalidColorString
    }

}

extension PhotoModel: Decodable {

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try values.decode(Int.self, forKey: .id)
        size = (
            width: try values.decode(Int.self, forKey: .width),
            height: try values.decode(Int.self, forKey: .height)
        )
        url = try values.decode(URL.self, forKey: .url)
        averageColor = try Self.parseColor(from: try values.decode(String.self, forKey: .averageColor))
        altText = try values.decode(String.self, forKey: .altText)

        photographer = PhotographerModel(
            id: try values.decode(Int.self, forKey: .photographerId),
            name: try values.decode(String.self, forKey: .photographer),
            url: try values.decode(URL.self, forKey: .photographerUrl)
        )

        imageUrls = try Self.parseImageUrls(
            from: try values.nestedContainer(keyedBy: PhotoSize.self, forKey: .imageUrls)
        )

    }

    private static func parseColor(from hexString: String) throws -> UIColor {
        guard let color = UIColor(hexString: hexString) else { throw ParsingError.invalidColorString }
        return color
    }

    private static func parseImageUrls(from container: KeyedDecodingContainer<PhotoSize>) throws -> [PhotoSize: URL] {
        var result: [PhotoSize: URL] = [:]
        for size in PhotoSize.allCases {
            result[size] = try container.decode(URL.self, forKey: size)
        }
        return result
    }

}
