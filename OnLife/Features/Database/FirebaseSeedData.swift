//
//  FirebaseSeedData.swift
//  Onlife
//
//  Created by Daniel Lee on 6/29/26.
//
//  USAGE: Run this once to populate your Firebase database with sample data
//  Add a button in your app to call `FirebaseSeedData.seedDatabase()`
//

import Foundation

#if DEBUG
/// Seeds the Firebase database with sample data for testing
struct FirebaseSeedData {
    
    @MainActor
    static func seedDatabase() async {
        let database = DatabaseManager.shared.service
        
        print("🌱 Starting database seeding...")
        
        do {
            // Seed Posts
            try await seedPosts(database: database)
            
            // Seed Events
            try await seedEvents(database: database)
            
            print("✅ Database seeding complete!")
        } catch {
            print("❌ Error seeding database: \(error.localizedDescription)")
        }
    }
    
    private static func seedPosts(database: DatabaseService) async throws {
        print("📝 Seeding posts...")
        
        let posts = [
            Post(
                userId: "user1",
                userName: "Sarah Chen",
                userProfileImageURL: "https://i.pravatar.cc/150?img=1",
                userLocation: "ARTS DISTRICT",
                content: "Just discovered this amazing coffee shop in the arts district! The vibes are immaculate ☕️✨"
            ),
            Post(
                userId: "user2",
                userName: "Marcus Johnson",
                userProfileImageURL: "https://i.pravatar.cc/150?img=2",
                userLocation: "DOWNTOWN",
                content: "Live music tonight at The Midnight Lounge 🎸 Who's coming?"
            ),
            Post(
                userId: "user3",
                userName: "Elena Rodriguez",
                userProfileImageURL: "https://i.pravatar.cc/150?img=3",
                userLocation: "VENICE BEACH",
                content: "Sunset sessions hit different when you're with good people 🌅"
            ),
            Post(
                userId: "user4",
                userName: "James Park",
                userProfileImageURL: "https://i.pravatar.cc/150?img=4",
                content: "New art installation opening this weekend. Contemporary meets street art. You don't want to miss this! 🎨"
            ),
            Post(
                userId: "user5",
                userName: "Olivia Martinez",
                userProfileImageURL: "https://i.pravatar.cc/150?img=5",
                userLocation: "SILVERLAKE",
                content: "Best brunch spot in Silverlake and the line is finally gone! Get here before noon 🥐"
            )
        ]
        
        for post in posts {
            _ = try await database.createPost(post)
            print("  ✓ Created post by \(post.userName)")
        }
    }
    
    private static func seedEvents(database: DatabaseService) async throws {
        print("🎉 Seeding events...")
        
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let nextWeek = Calendar.current.date(byAdding: .day, value: 7, to: Date())!
        let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: Date())!
        
        let events = [
            Event(
                title: "Rooftop Summer Kickoff",
                hostedBy: "The Rooftop Collective",
                imageURL: "https://images.unsplash.com/photo-1533174072545-7a4b6ad7a6c3?w=800",
                location: "Downtown LA",
                date: tomorrow,
                time: "8:00 PM",
                attendeeCount: 42,
                attendeeProfileImages: [
                    "https://i.pravatar.cc/150?img=10",
                    "https://i.pravatar.cc/150?img=11",
                    "https://i.pravatar.cc/150?img=12"
                ]
            ),
            Event(
                title: "Midnight Jazz Session",
                hostedBy: "Blue Note LA",
                imageURL: "https://images.unsplash.com/photo-1511192336575-5a79af67a629?w=800",
                location: "Hollywood",
                date: tomorrow,
                time: "11:00 PM",
                attendeeCount: 28,
                attendeeProfileImages: [
                    "https://i.pravatar.cc/150?img=13",
                    "https://i.pravatar.cc/150?img=14"
                ]
            ),
            Event(
                title: "Beach Bonfire & BBQ",
                hostedBy: "LA Social Club",
                imageURL: "https://images.unsplash.com/photo-1476900966873-ab0e478d5b89?w=800",
                location: "Santa Monica Beach",
                date: nextWeek,
                time: "6:00 PM",
                attendeeCount: 67,
                attendeeProfileImages: [
                    "https://i.pravatar.cc/150?img=15",
                    "https://i.pravatar.cc/150?img=16",
                    "https://i.pravatar.cc/150?img=17"
                ]
            ),
            Event(
                title: "Contemporary Art Gallery Opening",
                hostedBy: "MOCA",
                imageURL: "https://images.unsplash.com/photo-1531243269054-5ebf6f34081e?w=800",
                location: "Arts District",
                date: nextWeek,
                time: "7:00 PM",
                attendeeCount: 134,
                attendeeProfileImages: [
                    "https://i.pravatar.cc/150?img=18",
                    "https://i.pravatar.cc/150?img=19"
                ]
            ),
            Event(
                title: "Sunset Yacht Party",
                hostedBy: "Marina Social",
                imageURL: "https://images.unsplash.com/photo-1567899378494-47b22a2ae96a?w=800",
                location: "Marina del Rey",
                date: nextMonth,
                time: "5:00 PM",
                attendeeCount: 89,
                attendeeProfileImages: [
                    "https://i.pravatar.cc/150?img=20",
                    "https://i.pravatar.cc/150?img=21",
                    "https://i.pravatar.cc/150?img=22"
                ]
            ),
            Event(
                title: "Food Truck Festival",
                hostedBy: "LA Street Food",
                imageURL: "https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=800",
                location: "Grand Park",
                date: nextMonth,
                time: "12:00 PM",
                attendeeCount: 234,
                attendeeProfileImages: [
                    "https://i.pravatar.cc/150?img=23",
                    "https://i.pravatar.cc/150?img=24"
                ]
            )
        ]
        
        for event in events {
            _ = try await database.createEvent(event)
            print("  ✓ Created event: \(event.title)")
        }
    }
    
    /// Clears all data from the database (use with caution!)
    @MainActor
    static func clearAllData() async {
        print("⚠️ This will delete all data from Firebase!")
        print("⚠️ Not implemented for safety. Manually delete from Firebase Console.")
    }
}
#endif
