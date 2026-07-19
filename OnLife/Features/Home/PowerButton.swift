//
//  PowerButton.swift
//  Onlife
//
//  Created by Daniel Lee on 6/13/26.
//

import SwiftUI

/// A button that toggles between online and offline states with animated feedback
struct PowerButton: View {
    @Binding var isOnline: Bool
    @Environment(\.colorScheme) private var colorScheme
    
    var size: CGFloat = 44
    
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isOnline.toggle()
            }
        } label: {
            Image.powerButton(isOnline: isOnline, colorScheme: colorScheme)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size, height: size)
        }
        .buttonStyle(.plain)
        .scaleEffect(isOnline ? 1.0 : 0.95)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isOnline)
    }
}

#Preview("Power Button States") {
    VStack(spacing: 40) {
        // Light mode
        VStack(spacing: 20) {
            Text("Light Mode")
                .font(.headline)
            
            HStack(spacing: 40) {
                VStack {
                    PowerButton(isOnline: .constant(false))
                    Text("Off")
                        .font(.caption)
                }
                
                VStack {
                    PowerButton(isOnline: .constant(true))
                    Text("On")
                        .font(.caption)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        
        // Dark mode
        VStack(spacing: 20) {
            Text("Dark Mode")
                .font(.headline)
            
            HStack(spacing: 40) {
                VStack {
                    PowerButton(isOnline: .constant(false))
                    Text("Off")
                        .font(.caption)
                }
                
                VStack {
                    PowerButton(isOnline: .constant(true))
                    Text("On")
                        .font(.caption)
                }
            }
        }
        .padding()
        .background(Color.black)
        .foregroundColor(.white)
        .cornerRadius(12)
    }
    .padding()
}

#Preview("Interactive") {
    @Previewable @State var isOnline = false
    
    VStack(spacing: 30) {
        Image.onlifeLogo(colorScheme: .dark)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 200)
        
        PowerButton(isOnline: $isOnline, size: 60)
        
        Text(isOnline ? "You are Online" : "You are Offline")
            .font(.headline)
            .foregroundColor(isOnline ? .green : .gray)
    }
    .padding()
}
