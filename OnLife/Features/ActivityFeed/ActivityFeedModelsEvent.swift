//
//  Event.swift
//  Onlife
//
//  Created by Daniel Lee on 6/25/26.
//

import CoreLocation
import Foundation

struct Event: Identifiable, Codable {
    let id: String
    let title: String
    let hostedBy: String
    let imageURL: String?
    let location: String // display label (e.g. "Skyline Terrace, Block B"), not used for filtering
    let latitude: Double? // GPS coordinate of the event, if known
    let longitude: Double?
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
        latitude: Double? = nil,
        longitude: Double? = nil,
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
        self.latitude = latitude
        self.longitude = longitude
        self.date = date
        self.time = time
        self.attendeeCount = attendeeCount
        self.attendeeProfileImages = attendeeProfileImages
        self.isBookmarked = isBookmarked
        self.isJoined = isJoined
    }

    /// `nil` unless both `latitude` and `longitude` are known.
    var coordinate: CLLocationCoordinate2D? {
        guard let latitude, let longitude else { return nil }
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    /// Distance from `location`, or `nil` if this event has no known coordinate.
    func distance(from location: CLLocation) -> CLLocationDistance? {
        guard let coordinate else { return nil }
        return CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude).distance(from: location)
    }
}
