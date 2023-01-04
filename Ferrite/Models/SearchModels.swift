//
//  SearchModels.swift
//  Ferrite
//
//  Created by Brian Dashore on 9/2/22.
//

import Foundation

public struct SearchResult: Codable, Hashable, Sendable {
    let title: String?
    let source: String
    let size: String?
    let magnet: Magnet
    let seeders: String?
    let leechers: String?
}
