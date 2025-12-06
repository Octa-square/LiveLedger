//
//  AppIconView.swift
//  LiveLedger
//
//  LiveLedger - Official L² App Icon Design
//

import SwiftUI

struct AppIconView: View {
    let size: CGFloat
    
    // Colors from the design
    private let greenStart = Color(red: 0.05, green: 0.59, blue: 0.41)
    private let greenEnd = Color(red: 0.04, green: 0.47, blue: 0.34)
    private let liveRed = Color(red: 0.94, green: 0.27, blue: 0.27)
    
    init(size: CGFloat = 512) {
        self.size = size
    }
    
    var body: some View {
        ZStack {
            // Green gradient background
            RoundedRectangle(cornerRadius: size * 0.22)
                .fill(
                    LinearGradient(
                        colors: [greenStart, greenEnd],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            // Signal arcs (top right)
            signalArcs
            
            // L² - Official Logo
            lSquaredLogo
            
            // LIVE badge (top left)
            liveBadge
        }
        .frame(width: size, height: size)
    }
    
    // Signal/broadcast arcs
    private var signalArcs: some View {
        let arcSize = size * 0.30
        return ZStack {
            // Outer arc
            SignalArc()
                .stroke(Color.white.opacity(0.4), lineWidth: size * 0.012)
                .frame(width: arcSize * 1.4, height: arcSize * 1.4)
            
            // Middle arc
            SignalArc()
                .stroke(Color.white.opacity(0.7), lineWidth: size * 0.012)
                .frame(width: arcSize * 1.0, height: arcSize * 1.0)
            
            // Inner arc
            SignalArc()
                .stroke(Color.white, lineWidth: size * 0.012)
                .frame(width: arcSize * 0.65, height: arcSize * 0.65)
        }
        .offset(x: size * 0.18, y: -size * 0.15)
    }
    
    // L² Logo - Official Design
    private var lSquaredLogo: some View {
        ZStack(alignment: .topTrailing) {
            // Large L
            Text("L")
                .font(.system(size: size * 0.45, weight: .black, design: .rounded))
                .foregroundColor(.white)
            
            // Superscript ² at top-right corner of L
            Text("²")
                .font(.system(size: size * 0.18, weight: .regular, design: .rounded))
                .foregroundColor(.white)
                .offset(x: size * 0.08, y: -size * 0.02)
        }
        .offset(y: size * 0.05)
    }
    
    // LIVE badge
    private var liveBadge: some View {
        Text("LIVE")
            .font(.system(size: size * 0.055, weight: .black, design: .rounded))
            .foregroundColor(.white)
            .padding(.horizontal, size * 0.035)
            .padding(.vertical, size * 0.018)
            .background(
                RoundedRectangle(cornerRadius: size * 0.022)
                    .fill(liveRed)
                    .shadow(color: liveRed.opacity(0.5), radius: size * 0.015)
            )
            .offset(x: -size * 0.28, y: -size * 0.32)
    }
}

// Signal arc shape (quarter circle, top-right corner)
struct SignalArc: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(
            center: CGPoint(x: 0, y: rect.height),
            radius: rect.width,
            startAngle: .degrees(-90),
            endAngle: .degrees(0),
            clockwise: false
        )
        return path
    }
}

// MARK: - Icon Export View (Run on device/simulator, not preview)
struct IconExportView: View {
    @State private var showingSaveAlert = false
    @State private var alertMessage = ""
    @State private var isSaving = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Preview icon (small, safe for preview)
                AppIconView(size: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 26))
                
                Text("LiveLedger App Icon")
                    .font(.title2.bold())
                
                Text("Export icons for App Store submission")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Divider()
                
                // Export buttons
                VStack(spacing: 12) {
                    ExportButton(title: "App Store (1024×1024)", size: 1024, isSaving: $isSaving) {
                        saveIcon(size: 1024, name: "AppStore_1024")
                    }
                    
                    ExportButton(title: "iPhone @3x (180×180)", size: 180, isSaving: $isSaving) {
                        saveIcon(size: 180, name: "iPhone_180")
                    }
                    
                    ExportButton(title: "iPhone @2x (120×120)", size: 120, isSaving: $isSaving) {
                        saveIcon(size: 120, name: "iPhone_120")
                    }
                    
                    ExportButton(title: "iPad Pro (167×167)", size: 167, isSaving: $isSaving) {
                        saveIcon(size: 167, name: "iPadPro_167")
                    }
                    
                    ExportButton(title: "iPad (152×152)", size: 152, isSaving: $isSaving) {
                        saveIcon(size: 152, name: "iPad_152")
                    }
                    
                    ExportButton(title: "Settings @3x (87×87)", size: 87, isSaving: $isSaving) {
                        saveIcon(size: 87, name: "Settings_87")
                    }
                }
                .padding(.horizontal)
                
                Divider()
                
                // Save all
                Button {
                    saveAllIcons()
                } label: {
                    HStack {
                        if isSaving {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "square.and.arrow.down.fill")
                        }
                        Text("Save All to Photos")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(12)
                }
                .disabled(isSaving)
                .padding(.horizontal)
                
                Text("Icons will be saved to your Photos library")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding()
        }
        .navigationTitle("Export Icons")
        .alert("Export Complete", isPresented: $showingSaveAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }
    
    func saveIcon(size: CGFloat, name: String) {
        isSaving = true
        DispatchQueue.main.async {
            let renderer = ImageRenderer(content:
                AppIconView(size: size)
                    .frame(width: size, height: size)
            )
            renderer.scale = 1.0
            
            if let uiImage = renderer.uiImage {
                UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
                alertMessage = "\(name) saved to Photos!"
                showingSaveAlert = true
            }
            isSaving = false
        }
    }
    
    func saveAllIcons() {
        isSaving = true
        let sizes: [(CGFloat, String)] = [
            (1024, "AppStore"), (180, "iPhone3x"), (120, "iPhone2x"),
            (167, "iPadPro"), (152, "iPad"), (87, "Settings3x"),
            (80, "Spotlight"), (58, "Settings2x"), (40, "Notification")
        ]
        
        DispatchQueue.main.async {
            var count = 0
            for (size, _) in sizes {
                let renderer = ImageRenderer(content:
                    AppIconView(size: size)
                        .frame(width: size, height: size)
                )
                renderer.scale = 1.0
                if let uiImage = renderer.uiImage {
                    UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
                    count += 1
                }
            }
            alertMessage = "\(count) icons saved to Photos!"
            showingSaveAlert = true
            isSaving = false
        }
    }
}

struct ExportButton: View {
    let title: String
    let size: CGFloat
    @Binding var isSaving: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "square.and.arrow.down")
                    .foregroundColor(.green)
                Text(title)
                    .foregroundColor(.primary)
                Spacer()
                Text("\(Int(size))px")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
        .disabled(isSaving)
    }
}

#Preview {
    AppIconView(size: 200)
        .clipShape(RoundedRectangle(cornerRadius: 44))
}
