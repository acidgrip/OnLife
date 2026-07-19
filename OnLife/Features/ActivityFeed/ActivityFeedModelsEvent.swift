//
//  Event.swift
//  Onlife
//
//  Created by Daniel Lee on 6/25/26.
//

import Foundation

struct Event: Identifiable, Codable {
    let id: String
    let title: String
    let hostedBy: String
    let imageURL: String?
    let location: String
    let date: Date
    let time: String
    let attendeeCount: Int
    let attendeeProfileImages: [String] // URLs of attendee profile pictures
    var isBookmarked: Bool
    var isJoined: Bool
    
    init(
        id: String = UUID().uuidString,
        title: String,
        hostedBy: String,
        imageURL: String? = nil,
        location: String,
        date: Date,
        time: String,
        attendeeCount: Int = 0,
        attendeeProfileImages: [String] = [],
        isBookmarked: Bool = false,
        isJoined: Bool = false
    ) {
        self.id = id
        self.title = title
        self.hostedBy = hostedBy
        self.imageURL = imageURL
        self.location = location
        self.date = date
        self.time = time
        self.attendeeCount = attendeeCount
        self.attendeeProfileImages = attendeeProfileImages
        self.isBookmarked = isBookmarked
        self.isJoined = isJoined
    }
}
