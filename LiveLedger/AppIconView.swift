//
//  AppIconView.swift
//  LiveLedger
//
//  LiveLedger - App Icon Design (Logo 10 - L with Signal + Calculator)
//

import SwiftUI

struct AppIconView: View {
    let size: CGFloat
    
    // Colors from the design
    private let greenStart = Color(red: 0.02, green: 0.59, blue: 0.41) // #059669
    private let greenEnd = Color(red: 0.02, green: 0.47, blue: 0.34)   // #047857
    private let liveRed = Color(red: 0.94, green: 0.27, blue: 0.27)    // #ef4444
    
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
            
            // Main content
            ZStack {
                // Signal arcs (top right)
                signalArcs
                
                // Calculator with L stamped on it
                calculatorWithL
            }
            
            // LIVE badge (top left)
            liveBadge
        }
        .frame(width: size, height: size)
    }
    
    // Signal/broadcast arcs
    private var signalArcs: some View {
        let arcSize = size * 0.35
        return ZStack {
            // Outer arc (most transparent)
            SignalArc()
                .stroke(Color.white.opacity(0.4), lineWidth: size * 0.014)
                .frame(width: arcSize * 1.4, height: arcSize * 1.4)
            
            // Middle arc
            SignalArc()
                .stroke(Color.white.opacity(0.7), lineWidth: size * 0.014)
                .frame(width: arcSize * 1.0, height: arcSize * 1.0)
            
            // Inner arc (most visible)
            SignalArc()
                .stroke(Color.white, lineWidth: size * 0.014)
                .frame(width: arcSize * 0.65, height: arcSize * 0.65)
        }
        .offset(x: size * 0.12, y: -size * 0.08)
    }
    
    // Calculator with L stamped on it
    private var calculatorWithL: some View {
        let calcWidth = size * 0.18
        let calcHeight = size * 0.24
        
        return ZStack {
            // Calculator body
            RoundedRectangle(cornerRadius: calcWidth * 0.12)
                .fill(Color.white)
                .frame(width: calcWidth, height: calcHeight)
                .shadow(color: Color.black.opacity(0.2), radius: size * 0.01, y: size * 0.005)
            
            // Screen (green display)
            RoundedRectangle(cornerRadius: calcWidth * 0.05)
                .fill(greenEnd)
                .frame(width: calcWidth * 0.8, height: calcHeight * 0.2)
                .offset(y: -calcHeight * 0.32)
            
            // Buttons grid (3x3)
            VStack(spacing: calcWidth * 0.08) {
                ForEach(0..<3, id: \.self) { index in
                    HStack(spacing: calcWidth * 0.08) {
                        calcButton(w: calcWidth * 0.22, h: calcHeight * 0.12)
                        calcButton(w: calcWidth * 0.22, h: calcHeight * 0.12)
                        calcButton(w: calcWidth * 0.22, h: calcHeight * 0.12)
                    }
                }
            }
            .offset(y: calcHeight * 0.12)
            
            // "L" stamped ON the calculator (overlapping)
            Text("L")
                .font(.system(size: calcHeight * 0.9, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: greenEnd.opacity(0.5), radius: 2, x: 1, y: 1)
                .offset(x: calcWidth * 0.35, y: -calcHeight * 0.1)
        }
        .offset(x: -size * 0.12, y: size * 0.12)
    }
    
    private func calcButton(w: CGFloat, h: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: w * 0.15)
            .fill(Color(red: 0.8, green: 0.84, blue: 0.88)) // #cbd5e1
            .frame(width: w, height: h)
    }
    
    // LIVE badge
    private var liveBadge: some View {
        Text("LIVE")
            .font(.system(size: size * 0.065, weight: .black, design: .rounded))
            .foregroundColor(.white)
            .padding(.horizontal, size * 0.04)
            .padding(.vertical, size * 0.02)
            .background(
                RoundedRectangle(cornerRadius: size * 0.025)
                    .fill(liveRed)
                    .shadow(color: liveRed.opacity(0.5), radius: size * 0.02)
            )
            .offset(x: -size * 0.25, y: -size * 0.30)
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
