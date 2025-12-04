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
    
    // Show scroll indicator when more than 4 platforms (All + 3 default + custom)
    private var hasMorePlatforms: Bool {
        viewModel.platforms.count > 3
    }
    
    // Default platforms (TikTok, Instagram, Facebook)
    private var defaultPlatforms: [Platform] {
        viewModel.platforms.filter { !$0.isCustom }
    }
    
    // Custom platforms added by user
    private var customPlatforms: [Platform] {
        viewModel.platforms.filter { $0.isCustom }
    }
    
    // MARK: - Extracted Views
    private var platformHeader: some View {
        HStack(spacing: 8) {
            Text(localization.localized(.platform))
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(theme.textPrimary)
            
            Spacer()
            
            // Session Timer - centered
            sessionTimerView
            
            Spacer()
            
            // Add platform button
            Button {
                showingAddPlatform = true
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "plus")
                        .font(.system(size: 10, weight: .bold))
                    Text("Add")
                        .font(.system(size: 10, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(
                    Capsule()
                        .fill(
                            LinearGradient(colors: [theme.accentColor, theme.secondaryColor],
                                          startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                )
            }
            .accessibilityLabel("Add new platform")
            .accessibilityHint("Opens form to add a custom selling platform")
        }
    }
    
    private var sessionTimerView: some View {
        HStack(spacing: 6) {
            // Timer display - larger font
            Text(viewModel.formattedSessionTime)
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(viewModel.isTimerRunning ? theme.successColor : theme.textMuted)
                .fixedSize()
                .lineLimit(1)
            
            // Control buttons
            HStack(spacing: 4) {
                // Start button (only when not running and not paused)
                if !viewModel.isTimerRunning && !viewModel.isTimerPaused {
                    Button {
                        viewModel.startTimer()
                    } label: {
                        Image(systemName: "play.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.white)
                            .frame(width: 22, height: 22)
                            .background(Circle().fill(Color.green))
                    }
                    .accessibilityLabel("Start timer")
                }
                
                // Pause button (only when running)
                if viewModel.isTimerRunning {
                    Button {
                        viewModel.pauseTimer()
                    } label: {
                        Image(systemName: "pause.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.white)
                            .frame(width: 22, height: 22)
                            .background(Circle().fill(Color.orange))
                    }
                    .accessibilityLabel("Pause timer")
                }
                
                // Resume button (only when paused)
                if viewModel.isTimerPaused && !viewModel.isTimerRunning {
                    Button {
                        viewModel.resumeTimer()
                    } label: {
                        Image(systemName: "play.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.white)
                            .frame(width: 22, height: 22)
                            .background(Circle().fill(Color.green))
                    }
                    .accessibilityLabel("Resume timer")
                }
                
                // Stop/Reset button (only when timer has started or is paused)
                if viewModel.isTimerRunning || viewModel.isTimerPaused || viewModel.sessionElapsedTime > 0 {
                    Button {
                        viewModel.resetTimer()
                    } label: {
                        Image(systemName: "stop.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.white)
                            .frame(width: 22, height: 22)
                            .background(Circle().fill(Color.red))
                    }
                    .accessibilityLabel("Stop and reset timer")
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Session timer: \(viewModel.formattedSessionTime)")
        .fixedSize()
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(theme.cardBackground)
                .shadow(color: theme.shadowDark.opacity(0.1), radius: 2, x: 1, y: 1)
        )
    }
    
    private var platformChips: some View {
        GeometryReader { geo in
            let chipWidth: CGFloat = (geo.size.width - 30) / 4  // 4 chips, equal size
            
            ScrollView(.horizontal, showsIndicators: !customPlatforms.isEmpty) {
                HStack(spacing: 6) {
                    // "All" button - FIXED WIDTH
                    FixedPlatformChip(
                        platform: .all,
                        isSelected: viewModel.selectedPlatform == nil,
                        theme: theme,
                        width: chipWidth,
                        onTap: { viewModel.selectedPlatform = nil }
                    )
                    
                    // TikTok, Instagram, Facebook - SAME FIXED WIDTH
                    ForEach(defaultPlatforms) { platform in
                        FixedPlatformChip(
                            platform: platform,
                            isSelected: viewModel.selectedPlatform?.id == platform.id,
                            theme: theme,
                            width: chipWidth,
                            onTap: { viewModel.selectedPlatform = platform }
                        )
                    }
                    
                    // Custom platforms - SAME SIZE, scroll to see
                    ForEach(customPlatforms) { platform in
                        FixedPlatformChip(
                            platform: platform,
                            isSelected: viewModel.selectedPlatform?.id == platform.id,
                            theme: theme,
                            width: chipWidth,
                            onTap: { viewModel.selectedPlatform = platform },
                            showDelete: true,
                            onDelete: { viewModel.deletePlatform(platform) }
                        )
                    }
                }
            }
            .scrollDisabled(customPlatforms.isEmpty)
        }
        .frame(height: 50)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            platformHeader
            platformChips
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.cardBackground)
                .shadow(color: theme.shadowDark.opacity(0.12), radius: 5, x: 3, y: 3)
                .shadow(color: theme.shadowLight.opacity(0.3), radius: 5, x: -3, y: -3)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(theme.cardBorder, lineWidth: 1)
                )
        )
        .sheet(isPresented: $showingAddPlatform) {
            AddPlatformSheet(
                platformName: $newPlatformName,
                platformColor: $newPlatformColor,
                colorOptions: colorOptions,
                existingPlatforms: viewModel.platforms,
                localization: localization,
                onAdd: { name in
                    // Check for duplicate
                    if platformExists(name: name) {
                        duplicateErrorMessage = "\"\(name)\" already exists. Try \"\(name) 2\" or a different name."
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
    
    // Check if platform name already exists (case-insensitive)
    func platformExists(name: String) -> Bool {
        let lowercaseName = name.lowercased().trimmingCharacters(in: .whitespaces)
        
        // Check default platforms
        let defaultNames = ["tiktok", "instagram", "facebook", "all"]
        if defaultNames.contains(lowercaseName) {
            return true
        }
        
        // Check existing platforms
        return viewModel.platforms.contains { $0.name.lowercased() == lowercaseName }
    }
}

// FIXED WIDTH Platform Chip - ALL SAME SIZE
struct FixedPlatformChip: View {
    let platform: Platform
    let isSelected: Bool
    let theme: AppTheme
    let width: CGFloat
    let onTap: () -> Void
    var showDelete: Bool = false
    var onDelete: (() -> Void)? = nil
    
    @State private var showDeleteConfirm = false
    
    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .topTrailing) {
                VStack(spacing: 2) {
                    Image(systemName: platform.icon)
                        .font(.system(size: 14, weight: .semibold))
                    
                    Text(platform.name)
                        .font(.system(size: 10, weight: .bold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .foregroundColor(platform.swiftUIColor)
                .frame(width: width, height: 42)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isSelected ? platform.swiftUIColor.opacity(0.15) : theme.cardBackground)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(isSelected ? platform.swiftUIColor : theme.cardBorder, lineWidth: isSelected ? 2 : 1)
                )
                
                // Delete button for custom platforms
                if showDelete {
                    Button {
                        showDeleteConfirm = true
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                            .background(Circle().fill(theme.cardBackground))
                    }
                    .offset(x: 4, y: -4)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .confirmationDialog("Delete \(platform.name)?", isPresented: $showDeleteConfirm) {
            Button("Delete", role: .destructive) { onDelete?() }
            Button("Cancel", role: .cancel) {}
        }
    }
}

struct PlatformChip: View {
    let platform: Platform
    let isSelected: Bool
    let theme: AppTheme
    let onTap: () -> Void
    let onDelete: (() -> Void)?
    
    @State private var showDeleteConfirm = false
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 4) {
                // Icon with platform color
                Image(systemName: platform.icon)
                    .font(.system(size: 12, weight: .semibold))
                
                Text(platform.name)
                    .font(.system(size: 12, weight: .bold))
                
                if onDelete != nil {
                    Button {
                        showDeleteConfirm = true
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 10))
                            .foregroundColor(theme.textMuted.opacity(0.6))
                    }
                }
            }
            .foregroundColor(platform.swiftUIColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? platform.swiftUIColor.opacity(0.15) : theme.cardBackground)
                    .shadow(color: theme.shadowDark.opacity(0.1), radius: 3, x: 2, y: 2)
                    .shadow(color: theme.shadowLight.opacity(0.2), radius: 3, x: -2, y: -2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(isSelected ? platform.swiftUIColor : theme.cardBorder, lineWidth: isSelected ? 1.5 : 1)
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("\(platform.name) platform\(isSelected ? ", selected" : "")")
        .accessibilityHint("Tap to select this platform for new orders")
        .confirmationDialog("Delete Platform?", isPresented: $showDeleteConfirm) {
            Button("Delete", role: .destructive) {
                onDelete?()
            }
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
    
    // Get colors already used by existing platforms
    private var usedColors: Set<String> {
        Set(existingPlatforms.map { $0.color })
    }
    
    // Check if a color is available
    private func isColorAvailable(_ color: String) -> Bool {
        !usedColors.contains(color)
    }
    
    // Get first available color
    private var firstAvailableColor: String? {
        colorOptions.first { isColorAvailable($0) }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    TextField(localization.localized(.platformName), text: $platformName)
                        .textFieldStyle(.roundedBorder)
                        .onChange(of: platformName) { _, _ in
                            errorMessage = nil
                        }
                    
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
                    
                    // Color grid - 2 rows
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 44))], spacing: 12) {
                        ForEach(colorOptions, id: \.self) { color in
                            let isUsed = !isColorAvailable(color)
                            let isSelected = platformColor == color
                            
                            ZStack {
                                Circle()
                                    .fill(colorToSwiftUI(color))
                                    .frame(width: 40, height: 40)
                                    .opacity(isUsed ? 0.3 : 1.0)
                                
                                // Checkmark for selected
                                if isSelected && !isUsed {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                
                                // X for used colors
                                if isUsed {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white.opacity(0.6))
                                }
                                
                                // Selection ring
                                Circle()
                                    .strokeBorder(Color.white, lineWidth: isSelected && !isUsed ? 3 : 0)
                                    .frame(width: 40, height: 40)
                            }
                            .scaleEffect(isSelected && !isUsed ? 1.15 : 1.0)
                            .animation(.spring(response: 0.3), value: isSelected)
                            .onTapGesture {
                                if !isUsed {
                                    withAnimation { platformColor = color }
                                }
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
                // Auto-select first available color
                if let available = firstAvailableColor, usedColors.contains(platformColor) {
                    platformColor = available
                }
            }
        }
    }
    
    func colorToSwiftUI(_ color: String) -> Color {
        switch color {
        // Brand colors (for default platforms)
        case "tiktok": return Color(red: 0.93, green: 0.11, blue: 0.32)      // #EE1D52 Hot Pink
        case "instagram": return Color(red: 0.76, green: 0.21, blue: 0.55)   // #C13584 Magenta
        case "facebookblue": return Color(red: 0.09, green: 0.47, blue: 0.95) // #1877F2 Facebook Blue
        // Standard colors (for custom platforms)
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

// Preference key for tracking platform scroll position
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
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
