//
//  Photo.swift
//  Virtual Tourist
//
//  Created by Ivan Zandonà on 29/11/20.
//

import Foundation

struct Photos: Codable {
    let page, pages, perpage: Int
    let total: String
    let photo: [PhotoStruct]
}
