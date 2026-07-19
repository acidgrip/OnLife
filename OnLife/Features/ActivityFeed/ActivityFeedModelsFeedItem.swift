//
//  FeedItem.swift
//  Onlife
//
//  Created by Daniel Lee on 6/25/26.
//

import Foundation

enum FeedItem: Identifiable {
    case post(Post)
    case event(Event)
    
    var id: String {
        switch self {
        case .post(let post):
            return "post-\(post.id)"
        case .event(let event):
            return "event-\(event.id)"
        }
    }
}
