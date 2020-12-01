//
//  SearchPhotoResponse.swift
//  Virtual Tourist
//
//  Created by Ivan Zandonà on 29/11/20.
//

import Foundation

struct SearchPhotoResponse: Codable {
    let photos: Photos
    let stat: String
}
