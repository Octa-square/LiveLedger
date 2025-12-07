//
//  AppIconGenerator.swift
//  LiveLedger
//
//  Use this to preview and export the L² app icon
//  Run in Xcode Preview, then screenshot and resize to 1024x1024
//

import SwiftUI

// MARK: - L² App Icon Design (1024x1024)
struct AppIconView: View {
    let size: CGFloat
    
    init(size: CGFloat = 1024) {
        self.size = size
    }
    
    var body: some View {
        ZStack {
            // Green gradient background
            RoundedRectangle(cornerRadius: size * 0.22)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.05, green: 0.59, blue: 0.41),  // #0D9669
                            Color(red: 0.04, green: 0.47, blue: 0.34)   // #0A7857
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)
            
            // Subtle inner shadow/glow effect
            RoundedRectangle(cornerRadius: size * 0.22)
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.15),
                            Color.clear
                        ],
                        center: .topLeading,
                        startRadius: 0,
                        endRadius: size * 0.8
                    )
                )
                .frame(width: size, height: size)
            
            // L² Logo - CLOSE TOGETHER
            HStack(alignment: .top, spacing: -size * 0.02) {
                // Large "L"
                Text("L")
                    .font(.system(size: size * 0.55, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                
                // Superscript "2" - CLOSE to L, larger size
                Text("²")
                    .font(.system(size: size * 0.28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .baselineOffset(size * 0.22)
            }
            .offset(x: size * 0.02, y: size * 0.02) // Slight centering adjustment
            
            // Optional: "LIVE" badge at top-left corner
            Text("LIVE")
                .font(.system(size: size * 0.08, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, size * 0.04)
                .padding(.vertical, size * 0.02)
                .background(
                    RoundedRectangle(cornerRadius: size * 0.03)
                        .fill(Color.red)
                )
                .offset(x: -size * 0.28, y: -size * 0.35)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Simple L² Icon (No LIVE badge - cleaner for small sizes)
struct AppIconSimpleView: View {
    let size: CGFloat
    
    init(size: CGFloat = 1024) {
        self.size = size
    }
    
    var body: some View {
        ZStack {
            // Green gradient background
            RoundedRectangle(cornerRadius: size * 0.22)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.05, green: 0.59, blue: 0.41),
                            Color(red: 0.04, green: 0.47, blue: 0.34)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)
            
            // L² Logo - TIGHT SPACING
            HStack(alignment: .top, spacing: -size * 0.03) {
                Text("L")
                    .font(.system(size: size * 0.6, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                
                Text("²")
                    .font(.system(size: size * 0.32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .baselineOffset(size * 0.25)
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Preview for Different Sizes
struct AppIconPreviews: View {
    var body: some View {
        VStack(spacing: 30) {
            Text("L² App Icon Previews")
                .font(.headline)
            
            HStack(spacing: 20) {
                VStack {
                    AppIconSimpleView(size: 180)
                    Text("iPhone Home")
                        .font(.caption)
                }
                
                VStack {
                    AppIconSimpleView(size: 120)
                    Text("Spotlight")
                        .font(.caption)
                }
                
                VStack {
                    AppIconSimpleView(size: 60)
                    Text("Settings")
                        .font(.caption)
                }
            }
            
            Divider()
            
            Text("With LIVE Badge:")
                .font(.subheadline)
            
            HStack(spacing: 20) {
                AppIconView(size: 180)
                AppIconView(size: 120)
                AppIconView(size: 60)
            }
            
            Divider()
            
            Text("Export Size (1024x1024):")
                .font(.subheadline)
            
            AppIconSimpleView(size: 200)
                .overlay(
                    Text("Use this design")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(4)
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(4)
                        .offset(y: 80)
                )
        }
        .padding()
    }
}

#Preview("App Icon Generator") {
    AppIconPreviews()
}

#Preview("1024x1024 Export") {
    AppIconSimpleView(size: 512)
        .padding(50)
        .background(Color.gray.opacity(0.2))
}

