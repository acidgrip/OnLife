//
//  AppTabBar.swift
//  Onlife
//
//  Created by Daniel Lee on 6/25/26.
//

import SwiftUI

enum AppTab: String, CaseIterable {
    case map = "Map"
    case explore = "Explore"
    case home = "Home"
    case calendar = "Calendar"
    case friends = "Friends"
    
    var icon: String {
        switch self {
        case .map:
            return "map"
        case .explore:
            return "safari"
        case .home:
            return "house.fill"
        case .calendar:
            return "calendar"
        case .friends:
            return "person.2"
        }
    }
}

struct AppTabBar: View {
    @Binding var selectedTab: AppTab
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                Spacer()
                
                Button {
                    selectedTab = tab
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 22))
                            .foregroundColor(selectedTab == tab ? Color(red: 1.0, green: 0.5, blue: 0.35) : .gray)
                            .frame(height: 28)
                        
                        if selectedTab == tab {
                            Circle()
                                .fill(Color(red: 1.0, green: 0.5, blue: 0.35))
                                .frame(width: 4, height: 4)
                        }
                    }
                }
                
                Spacer()
            }
        }
        .frame(height: 60)
        .background(Color.black.opacity(0.95))
        .overlay(alignment: .top) {
            Divider()
                .background(Color.white.opacity(0.1))
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        VStack {
            Spacer()
            AppTabBar(selectedTab: .constant(.home))
        }
    }
}
