#!/usr/bin/env swift
//
//  GenerateIcons.swift
//  LiveLedger - App Icon Generator
//
//  Run this script from Terminal:
//  cd /Users/chinonso/Desktop/LiveLedger/LiveLedger
//  swift GenerateIcons.swift
//

import Foundation
import AppKit

// MARK: - Colors
let greenStart = NSColor(red: 0.02, green: 0.59, blue: 0.41, alpha: 1.0)
let greenEnd = NSColor(red: 0.02, green: 0.47, blue: 0.34, alpha: 1.0)
let liveRed = NSColor(red: 0.94, green: 0.27, blue: 0.27, alpha: 1.0)
let buttonGray = NSColor(red: 0.8, green: 0.84, blue: 0.88, alpha: 1.0)

// MARK: - Icon Sizes for App Store
let iconSizes: [(name: String, size: Int)] = [
    ("AppStore_1024x1024", 1024),
    ("iPhone_180x180_3x", 180),
    ("iPhone_120x120_2x", 120),
    ("iPadPro_167x167", 167),
    ("iPad_152x152", 152),
    ("iPad_76x76", 76),
    ("Spotlight_120x120_3x", 120),
    ("Spotlight_80x80_2x", 80),
    ("Spotlight_40x40", 40),
    ("Settings_87x87_3x", 87),
    ("Settings_58x58_2x", 58),
    ("Settings_29x29", 29),
    ("Notification_60x60_3x", 60),
    ("Notification_40x40_2x", 40),
    ("Notification_20x20", 20)
]

// MARK: - Draw Icon
func drawIcon(size: CGFloat) -> NSImage {
    let image = NSImage(size: NSSize(width: size, height: size))
    
    image.lockFocus()
    
    let rect = NSRect(x: 0, y: 0, width: size, height: size)
    let cornerRadius = size * 0.22
    let path = NSBezierPath(roundedRect: rect, xRadius: cornerRadius, yRadius: cornerRadius)
    
    // Green gradient background
    let gradient = NSGradient(colors: [greenStart, greenEnd])!
    gradient.draw(in: path, angle: -45)
    
    // Signal arcs (top right)
    NSColor.white.withAlphaComponent(0.4).setStroke()
    drawArc(in: rect, radius: size * 0.35, lineWidth: size * 0.02, offsetX: size * 0.15, offsetY: size * 0.12)
    
    NSColor.white.withAlphaComponent(0.7).setStroke()
    drawArc(in: rect, radius: size * 0.25, lineWidth: size * 0.02, offsetX: size * 0.15, offsetY: size * 0.12)
    
    NSColor.white.setStroke()
    drawArc(in: rect, radius: size * 0.15, lineWidth: size * 0.02, offsetX: size * 0.15, offsetY: size * 0.12)
    
    // Calculator body
    let calcWidth = size * 0.22
    let calcHeight = size * 0.30
    let calcX = size * 0.22
    let calcY = size * 0.22
    
    let calcRect = NSRect(x: calcX, y: calcY, width: calcWidth, height: calcHeight)
    let calcPath = NSBezierPath(roundedRect: calcRect, xRadius: size * 0.02, yRadius: size * 0.02)
    NSColor.white.setFill()
    calcPath.fill()
    
    // Calculator screen
    let screenRect = NSRect(x: calcX + calcWidth * 0.1, y: calcY + calcHeight * 0.7, width: calcWidth * 0.8, height: calcHeight * 0.2)
    let screenPath = NSBezierPath(roundedRect: screenRect, xRadius: size * 0.01, yRadius: size * 0.01)
    greenEnd.setFill()
    screenPath.fill()
    
    // Calculator buttons (3x3 grid)
    let btnSize = calcWidth * 0.2
    let btnSpacing = calcWidth * 0.08
    let btnStartX = calcX + calcWidth * 0.15
    let btnStartY = calcY + calcHeight * 0.1
    
    for row in 0..<3 {
        for col in 0..<3 {
            let btnX = btnStartX + CGFloat(col) * (btnSize + btnSpacing)
            let btnY = btnStartY + CGFloat(row) * (btnSize + btnSpacing)
            let btnRect = NSRect(x: btnX, y: btnY, width: btnSize, height: btnSize * 0.7)
            let btnPath = NSBezierPath(roundedRect: btnRect, xRadius: 1, yRadius: 1)
            buttonGray.setFill()
            btnPath.fill()
        }
    }
    
    // Big "L" letter stamped on calculator
    let font = NSFont.systemFont(ofSize: size * 0.28, weight: .black)
    let textAttributes: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: NSColor.white
    ]
    let letterL = "L"
    let textSize = letterL.size(withAttributes: textAttributes)
    let textX = calcX + calcWidth * 0.5
    let textY = calcY + calcHeight * 0.2
    
    // Draw shadow
    let shadowAttributes: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: greenEnd.withAlphaComponent(0.5)
    ]
    letterL.draw(at: NSPoint(x: textX + 2, y: textY - 2), withAttributes: shadowAttributes)
    letterL.draw(at: NSPoint(x: textX, y: textY), withAttributes: textAttributes)
    
    // LIVE badge
    let badgeFont = NSFont.systemFont(ofSize: size * 0.07, weight: .black)
    let badgeText = "LIVE"
    let badgeAttributes: [NSAttributedString.Key: Any] = [
        .font: badgeFont,
        .foregroundColor: NSColor.white
    ]
    let badgeSize = badgeText.size(withAttributes: badgeAttributes)
    let badgePadH = size * 0.03
    let badgePadV = size * 0.015
    let badgeX = size * 0.12
    let badgeY = size * 0.72
    
    let badgeRect = NSRect(
        x: badgeX - badgePadH,
        y: badgeY - badgePadV,
        width: badgeSize.width + badgePadH * 2,
        height: badgeSize.height + badgePadV * 2
    )
    let badgePath = NSBezierPath(roundedRect: badgeRect, xRadius: size * 0.025, yRadius: size * 0.025)
    liveRed.setFill()
    badgePath.fill()
    
    badgeText.draw(at: NSPoint(x: badgeX, y: badgeY), withAttributes: badgeAttributes)
    
    image.unlockFocus()
    return image
}

func drawArc(in rect: NSRect, radius: CGFloat, lineWidth: CGFloat, offsetX: CGFloat, offsetY: CGFloat) {
    let centerX = rect.midX + offsetX
    let centerY = rect.midY + offsetY
    
    let path = NSBezierPath()
    path.appendArc(
        withCenter: NSPoint(x: centerX - radius, y: centerY - radius),
        radius: radius,
        startAngle: 0,
        endAngle: 90
    )
    path.lineWidth = lineWidth
    path.stroke()
}

// MARK: - Main
print("🎨 LiveLedger Icon Generator")
print("============================\n")

let outputDir = "./AppIcons"
let fileManager = FileManager.default

// Create output directory
try? fileManager.createDirectory(atPath: outputDir, withIntermediateDirectories: true)

print("📁 Output folder: \(outputDir)\n")
print("Generating icons...\n")

for (name, size) in iconSizes {
    let image = drawIcon(size: CGFloat(size))
    
    // Convert to PNG
    guard let tiffData = image.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiffData),
          let pngData = bitmap.representation(using: .png, properties: [:]) else {
        print("❌ Failed to generate \(name)")
        continue
    }
    
    let filename = "\(outputDir)/\(name).png"
    do {
        try pngData.write(to: URL(fileURLWithPath: filename))
        print("✅ \(name).png (\(size)x\(size))")
    } catch {
        print("❌ Failed to save \(name): \(error)")
    }
}

print("\n============================")
print("✅ Done! Icons saved to: \(outputDir)")
print("\nUpload these to App Store Connect:")
print("- AppStore_1024x1024.png → App Store Icon")
print("- iPhone_*.png → iPhone icons")
print("- iPad_*.png → iPad icons")
print("- Settings_*.png → Settings icons")
print("- Spotlight_*.png → Spotlight search icons")
print("- Notification_*.png → Notification icons")


