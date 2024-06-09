//
//  PhotosPageModel.swift
//  PhotoFeedTestApp
//
//  Created by Alexander Ermichev on 09.06.2024.
//

import Foundation

struct PhotosPageModel {
    let page: Int
    let perPage: Int
    let photos: [PhotoModel]
    let nextPage: URL?

    enum CodingKeys: String, CodingKey {
        case page
        case perPage = "per_page"
        case photos
        case nextPage = "next_page"
    }
}

extension PhotosPageModel: Decodable {
 
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        page = try values.decode(Int.self, forKey: .page)
        perPage = try values.decode(Int.self, forKey: .perPage)
        photos = try values.decode([PhotoModel].self, forKey: .photos)
        nextPage = try values.decode(URL.self, forKey: .nextPage)
    }

}
