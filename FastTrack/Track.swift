//
//  Track.swift
//  FastTrack
//
//  Created by Ali Soner Inceoglu on 27.10.26.
//

import Foundation


struct Track: Identifiable, Decodable {
    var id: Int { trackId }
    var artworkUrl: URL? {
        let replacedString = artworkUrl100.replacingOccurrences(of: "100x100", with: "300x300")
        return URL(string: replacedString)
    }
    
    let trackId: Int
    let artistName: String
    let trackName: String
    let previewUrl: URL
    let artworkUrl100: String
}

struct SearchResult: Decodable {
    let results: [Track]
}
