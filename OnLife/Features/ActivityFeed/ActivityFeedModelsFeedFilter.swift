//
//  FeedFilter.swift
//  Onlife
//
//  Created by Daniel Lee on 6/25/26.
//

import Foundation

enum FeedFilter: String, CaseIterable, Identifiable {
    case nearbyScenes = "12 scenes nearby"
    case scenesPickingUp = "Scenes picking up"
    case all = "All"
    case posts = "Posts"
    case events = "Events"
    
    var id: String { rawValue }
}
