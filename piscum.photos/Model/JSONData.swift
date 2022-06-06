//
//  JSONData.swift
//  piscum.photos
//
//  Created by Danial Fajar on 05/06/2022.
//

import Foundation

struct PicsumDataModel: Codable {
    var id: String?
    var author: String?
    var width: Int?
    var height: Int?
    var url: String?
    var download_url: String?
}
