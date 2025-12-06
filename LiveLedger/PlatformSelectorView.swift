//
//  PlatformSelectorView.swift
//  LiveLedger
//
//  LiveLedger - Platform Selector
//

import SwiftUI

struct PlatformSelectorView: View {
    @ObservedObject var viewModel: SalesViewModel
    @ObservedObject var themeManager: ThemeManager
    @ObservedObject var localization: LocalizationManager
    @State private var showingAddPlatform = false
    @State private var newPlatformName = ""
    @State private var newPlatformColor = "orange"
    @State private var showDuplicateError = false
    @State private var duplicateErrorMessage = ""
    
    private var theme: AppTheme { themeManager.currentTheme }
    
    let colorOptions = ["pink", "purple", "blue", "orange", "green", "red", "yellow", "cyan", "indigo", "mint", "teal", "brown"]
    
    // Separate default and custom platforms
    private var defaultPlatforms: [Platform] {
        viewModel.platforms.filter { !$0.isCustom }
    }
    
    private var customPlatforms: [Platform] {
        viewModel.platforms.filter { $0.isCustom }
    }
    
    // Timer view (compact)
    private var sessionTimerView: some View {
        HStack(spacing: 4) {
            Text(viewModel.formattedSessionTime)
                .font(.system(size: 13, weight: .bold, design: .monospaced))
                .foregroundColor(viewModel.isTimerRunning ? theme.successColor : .white.opacity(0.7))
            
            // Control buttons
            HStack(spacing: 3) {
                if !viewModel.isTimerRunning && !viewModel.isTimerPaused {
                    Button { viewModel.startTimer() } label: {
                        Image(systemName: "play.fill")
                            .font(.system(size: 9))
                            .foregroundColor(.white)
                            .frame(width: 20, height: 20)
                            .background(Circle().fill(Color.green))
                    }
                }
                
                if viewModel.isTimerRunning {
                    Button { viewModel.pauseTimer() } label: {
                        Image(systemName: "pause.fill")
                            .font(.system(size: 9))
                            .foregroundColor(.white)
                            .frame(width: 20, height: 20)
                            .background(Circle().fill(Color.orange))
                    }
                }
                
                if viewModel.isTimerPaused && !viewModel.isTimerRunning {
                    Button { viewModel.resumeTimer() } label: {
                        Image(systemName: "play.fill")
                            .font(.system(size: 9))
                            .foregroundColor(.white)
                            .frame(width: 20, height: 20)
                            .background(Circle().fill(Color.green))
                    }
                }
                
                if viewModel.isTimerRunning || viewModel.isTimerPaused || viewModel.sessionElapsedTime > 0 {
                    Button { viewModel.resetTimer() } label: {
                        Image(systemName: "stop.fill")
                            .font(.system(size: 9))
                            .foregroundColor(.white)
                            .frame(width: 20, height: 20)
                            .background(Circle().fill(Color.red))
                    }
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.black.opacity(0.4))
        )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // ROW 1: "Platform" | Timer (center) | "+ Add" - ALL ON SAME LINE
            HStack {
                // "Platform" label - left aligned
                Text("Platform")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                // Timer - centered
                sessionTimerView
                
                Spacer()
                
                // "+ Add" button - right aligned
                Button {
                    showingAddPlatform = true
                } label: {
                    HStack(spacing: 3) {
                        Image(systemName: "plus")
                            .font(.system(size: 9, weight: .bold))
                        Text("Add")
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(colors: [theme.accentColor, theme.secondaryColor],
                                              startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                    )
                }
            }
            
            // ROW 2: Platform boxes - All, TikTok, Instagram, Facebook (4 boxes)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    // "All" button
                    PlatformChip(
                        platform: .all,
                        isSelected: viewModel.selectedPlatform == nil,
                        theme: theme,
                        onTap: { viewModel.selectedPlatform = nil },
                        onDelete: nil
                    )
                    
                    // Default platforms (TikTok, Instagram, Facebook)
                    ForEach(defaultPlatforms) { platform in
                        PlatformChip(
                            platform: platform,
                            isSelected: viewModel.selectedPlatform?.id == platform.id,
                            theme: theme,
                            onTap: { viewModel.selectedPlatform = platform },
                            onDelete: nil
                        )
                    }
                    
                    // Custom platforms (scroll to see)
                    ForEach(customPlatforms) { platform in
                        PlatformChip(
                            platform: platform,
                            isSelected: viewModel.selectedPlatform?.id == platform.id,
                            theme: theme,
                            onTap: { viewModel.selectedPlatform = platform },
                            onDelete: { viewModel.deletePlatform(platform) }
                        )
                    }
                }
                .padding(.horizontal, 2)
            }
            
            // Scroll indicator dots (only show if custom platforms exist)
            if !customPlatforms.isEmpty {
                HStack {
                    Spacer()
                    HStack(spacing: 4) {
                        ForEach(0..<min(3, customPlatforms.count + 1), id: \.self) { index in
                            Circle()
                                .fill(index == 0 ? theme.accentColor : Color.white.opacity(0.3))
                                .frame(width: 5, height: 5)
                        }
                    }
                    Spacer()
                }
            }
        }
        .sheet(isPresented: $showingAddPlatform) {
            AddPlatformSheet(
                platformName: $newPlatformName,
                platformColor: $newPlatformColor,
                colorOptions: colorOptions,
                existingPlatforms: viewModel.platforms,
                localization: localization,
                onAdd: { name in
                    if platformExists(name: name) {
                        duplicateErrorMessage = "\"\(name)\" already exists."
                        showDuplicateError = true
                        return false
                    }
                    viewModel.addCustomPlatform(name: name, color: newPlatformColor)
                    newPlatformName = ""
                    showingAddPlatform = false
                    return true
                },
                onCancel: {
                    newPlatformName = ""
                    showingAddPlatform = false
                }
            )
            .presentationDetents([.height(320)])
        }
        .alert("Platform Already Exists", isPresented: $showDuplicateError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(duplicateErrorMessage)
        }
    }
    
    func platformExists(name: String) -> Bool {
        let lowercaseName = name.lowercased().trimmingCharacters(in: .whitespaces)
        let defaultNames = ["tiktok", "instagram", "facebook", "all"]
        if defaultNames.contains(lowercaseName) { return true }
        return viewModel.platforms.contains { $0.name.lowercased() == lowercaseName }
    }
}

struct PlatformChip: View {
    let platform: Platform
    let isSelected: Bool
    let theme: AppTheme
    let onTap: () -> Void
    let onDelete: (() -> Void)?
    
    // Uniform sizing
    private let chipWidth: CGFloat = 70
    private let chipHeight: CGFloat = 36
    
    @State private var showDeleteConfirm = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 2) {
                Image(systemName: platform.icon)
                    .font(.system(size: 14, weight: .semibold))
                
                Text(platform.name)
                    .font(.system(size: 9, weight: .bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .foregroundColor(isSelected ? .white : platform.swiftUIColor)
            .frame(width: chipWidth, height: chipHeight)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? platform.swiftUIColor.opacity(0.8) : Color.black.opacity(0.4))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(isSelected ? platform.swiftUIColor : Color.white.opacity(0.2), lineWidth: isSelected ? 2 : 1)
            )
            .overlay(alignment: .topTrailing) {
                if onDelete != nil {
                    Button {
                        showDeleteConfirm = true
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .offset(x: 4, y: -4)
                }
            }
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
        .confirmationDialog("Delete Platform?", isPresented: $showDeleteConfirm) {
            Button("Delete", role: .destructive) { onDelete?() }
            Button("Cancel", role: .cancel) {}
        }
    }
}

struct AddPlatformSheet: View {
    @Binding var platformName: String
    @Binding var platformColor: String
    let colorOptions: [String]
    let existingPlatforms: [Platform]
    @ObservedObject var localization: LocalizationManager
    let onAdd: (String) -> Bool
    let onCancel: () -> Void
    
    @State private var errorMessage: String?
    
    private var usedColors: Set<String> {
        Set(existingPlatforms.map { $0.color })
    }
    
    private func isColorAvailable(_ color: String) -> Bool {
        !usedColors.contains(color)
    }
    
    private var firstAvailableColor: String? {
        colorOptions.first { isColorAvailable($0) }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    TextField(localization.localized(.platformName), text: $platformName)
                        .textFieldStyle(.roundedBorder)
                        .onChange(of: platformName) { _, _ in errorMessage = nil }
                    
                    if let error = errorMessage {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                                .font(.system(size: 12))
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Select Color")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("(used colors greyed out)")
                            .font(.caption2)
                            .foregroundColor(.secondary.opacity(0.6))
                    }
                    .padding(.horizontal)
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 44))], spacing: 12) {
                        ForEach(colorOptions, id: \.self) { color in
                            let isUsed = !isColorAvailable(color)
                            let isSelected = platformColor == color
                            
                            ZStack {
                                Circle()
                                    .fill(colorToSwiftUI(color))
                                    .frame(width: 40, height: 40)
                                    .opacity(isUsed ? 0.3 : 1.0)
                                
                                if isSelected && !isUsed {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                
                                if isUsed {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white.opacity(0.6))
                                }
                                
                                Circle()
                                    .strokeBorder(Color.white, lineWidth: isSelected && !isUsed ? 3 : 0)
                                    .frame(width: 40, height: 40)
                            }
                            .scaleEffect(isSelected && !isUsed ? 1.15 : 1.0)
                            .animation(.spring(response: 0.3), value: isSelected)
                            .onTapGesture {
                                if !isUsed { withAnimation { platformColor = color } }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .padding(.top, 20)
            .navigationTitle(localization.localized(.addPlatform))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(localization.localized(.cancel), action: onCancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(localization.localized(.add)) {
                        let trimmedName = platformName.trimmingCharacters(in: .whitespaces)
                        if !onAdd(trimmedName) {
                            errorMessage = "This platform already exists"
                        }
                    }
                    .disabled(platformName.trimmingCharacters(in: .whitespaces).isEmpty || !isColorAvailable(platformColor))
                }
            }
            .onAppear {
                if let available = firstAvailableColor, usedColors.contains(platformColor) {
                    platformColor = available
                }
            }
        }
    }
    
    func colorToSwiftUI(_ color: String) -> Color {
        switch color {
        case "tiktok": return Color(red: 0.93, green: 0.11, blue: 0.32)
        case "instagram": return Color(red: 0.76, green: 0.21, blue: 0.55)
        case "facebookblue": return Color(red: 0.09, green: 0.47, blue: 0.95)
        case "pink": return .pink
        case "purple": return .purple
        case "blue": return .blue
        case "orange": return .orange
        case "green": return .green
        case "red": return .red
        case "yellow": return .yellow
        case "cyan": return .cyan
        case "indigo": return .indigo
        case "mint": return .mint
        case "teal": return .teal
        case "brown": return .brown
        default: return .gray
        }
    }
}

#Preview {
    ZStack {
        LinearGradient(colors: [.purple, .blue, .pink], startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
        
        PlatformSelectorView(viewModel: SalesViewModel(), themeManager: ThemeManager(), localization: LocalizationManager.shared)
            .padding()
    }
}
