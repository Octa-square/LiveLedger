//
//  PlatformSelectorView.swift
//  LiveLedger
//
//  LiveLedger - Platform Selector
//  ADAPTIVE LAYOUT: Responds to window width changes
//  - Width >= 500: Shows 4 platforms in row
//  - Width 350-500: Shows 3 platforms in row
//  - Width < 350: Shows 2 platforms in row (ultra-compact)
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
    @State private var scrollOffset: CGFloat = 0
    
    private var theme: AppTheme { themeManager.currentTheme }
    
    let colorOptions = ["pink", "purple", "blue", "orange", "green", "red", "yellow", "cyan", "indigo", "mint", "teal", "brown"]
    
    // ADAPTIVE CONSTANTS
    private let itemSpacing: CGFloat = 8
    private let minChipWidth: CGFloat = 70  // Minimum width to prevent squishing
    private let chipHeight: CGFloat = 44    // Minimum tap target height
    
    // Separate default and custom platforms
    private var defaultPlatforms: [Platform] {
        viewModel.platforms.filter { !$0.isCustom }
    }
    
    private var customPlatforms: [Platform] {
        viewModel.platforms.filter { $0.isCustom }
    }
    
    // All platforms in display order: All, TikTok, Instagram, Facebook, then custom
    private var allPlatformsOrdered: [Platform?] {
        var result: [Platform?] = [nil] // nil represents "All"
        result.append(contentsOf: defaultPlatforms)
        result.append(contentsOf: customPlatforms)
        return result
    }
    
    // Calculate visible columns based on width
    private func visibleColumns(for width: CGFloat) -> CGFloat {
        if width < 300 { return 2 }
        if width < 400 { return 3 }
        return 4
    }
    
    private func hasMorePlatforms(columns: Int) -> Bool {
        allPlatformsOrdered.count > columns
    }
    
    // Timer view (compact) - adapts to narrow widths
    @ViewBuilder
    private func sessionTimerView(isNarrow: Bool) -> some View {
        HStack(spacing: isNarrow ? 2 : 4) {
            Text(viewModel.formattedSessionTime)
                .font(.system(size: isNarrow ? 11 : 13, weight: .bold, design: .monospaced))
                .foregroundColor(viewModel.isTimerRunning ? theme.successColor : .white.opacity(0.7))
            
            // Control buttons - use minimum tap targets
            HStack(spacing: 2) {
                if !viewModel.isTimerRunning && !viewModel.isTimerPaused {
                    Button { viewModel.startTimer() } label: {
                        Image(systemName: "play.fill")
                            .font(.system(size: 9))
                            .foregroundColor(.white)
                            .frame(width: 24, height: 24) // Minimum tap target
                            .background(Circle().fill(Color.green))
                    }
                }
                
                if viewModel.isTimerRunning {
                    Button { viewModel.pauseTimer() } label: {
                        Image(systemName: "pause.fill")
                            .font(.system(size: 9))
                            .foregroundColor(.white)
                            .frame(width: 24, height: 24)
                            .background(Circle().fill(Color.orange))
                    }
                }
                
                if viewModel.isTimerPaused && !viewModel.isTimerRunning {
                    Button { viewModel.resumeTimer() } label: {
                        Image(systemName: "play.fill")
                            .font(.system(size: 9))
                            .foregroundColor(.white)
                            .frame(width: 24, height: 24)
                            .background(Circle().fill(Color.green))
                    }
                }
                
                if viewModel.isTimerRunning || viewModel.isTimerPaused || viewModel.sessionElapsedTime > 0 {
                    Button { viewModel.resetTimer() } label: {
                        Image(systemName: "stop.fill")
                            .font(.system(size: 9))
                            .foregroundColor(.white)
                            .frame(width: 24, height: 24)
                            .background(Circle().fill(Color.red))
                    }
                }
            }
        }
        .padding(.horizontal, isNarrow ? 4 : 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(theme.isDarkTheme ? Color.black.opacity(0.4) : Color.gray.opacity(0.15))
        )
    }
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let isVeryNarrow = width < 350
            let isNarrow = width < 450
            let columns = visibleColumns(for: width)
            
            VStack(alignment: .leading, spacing: 4) {
                // ROW 1: Header row - adapts layout on narrow screens
                headerRow(isNarrow: isNarrow, isVeryNarrow: isVeryNarrow)
                
                // ROW 2: Platform buttons - ADAPTIVE columns
                platformButtonsRow(width: width, columns: columns)
                
                // Scroll indicator
                scrollIndicator(columns: Int(columns))
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
    
    // MARK: - Header Row
    @ViewBuilder
    private func headerRow(isNarrow: Bool, isVeryNarrow: Bool) -> some View {
        if isVeryNarrow {
            // Stack vertically on very narrow screens
            VStack(spacing: 4) {
                HStack {
                    Text(localization.localized(.platform))
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    addButton(isNarrow: true)
                }
                
                sessionTimerView(isNarrow: true)
            }
        } else {
            // Horizontal layout
            HStack(alignment: .center, spacing: 0) {
                Text(localization.localized(.platform))
                    .font(.system(size: isNarrow ? 12 : 13, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                sessionTimerView(isNarrow: isNarrow)
                
                Spacer()
                
                addButton(isNarrow: isNarrow)
            }
        }
    }
    
    // MARK: - Add Button
    @ViewBuilder
    private func addButton(isNarrow: Bool) -> some View {
        Button {
            showingAddPlatform = true
        } label: {
            HStack(spacing: 3) {
                Image(systemName: "plus")
                    .font(.system(size: 9, weight: .bold))
                if !isNarrow {
                    Text("Add")
                        .font(.system(size: 10, weight: .semibold))
                }
            }
            .foregroundColor(.white)
            .padding(.horizontal, isNarrow ? 8 : 10)
            .padding(.vertical, 6)
            .frame(minWidth: 44, minHeight: 32) // Minimum tap target
            .background(
                Capsule()
                    .fill(
                        LinearGradient(colors: [theme.accentColor, theme.secondaryColor],
                                      startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
            )
        }
    }
    
    // MARK: - Platform Buttons Row
    @ViewBuilder
    private func platformButtonsRow(width: CGFloat, columns: CGFloat) -> some View {
        let totalSpacing = itemSpacing * (columns - 1)
        let itemWidth = max(minChipWidth, (width - totalSpacing) / columns)
        
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: itemSpacing) {
                // "All" button
                AlignedPlatformChip(
                    platform: .all,
                    isSelected: viewModel.selectedPlatform == nil,
                    theme: theme,
                    width: itemWidth,
                    height: chipHeight,
                    onTap: { viewModel.selectedPlatform = nil },
                    onDelete: nil
                )
                
                // Default platforms (TikTok, Instagram, Facebook)
                ForEach(defaultPlatforms) { platform in
                    AlignedPlatformChip(
                        platform: platform,
                        isSelected: viewModel.selectedPlatform?.id == platform.id,
                        theme: theme,
                        width: itemWidth,
                        height: chipHeight,
                        onTap: { viewModel.selectedPlatform = platform },
                        onDelete: nil
                    )
                }
                
                // Custom platforms - scroll to reveal
                ForEach(customPlatforms) { platform in
                    AlignedPlatformChip(
                        platform: platform,
                        isSelected: viewModel.selectedPlatform?.id == platform.id,
                        theme: theme,
                        width: itemWidth,
                        height: chipHeight,
                        onTap: { viewModel.selectedPlatform = platform },
                        onDelete: { viewModel.deletePlatform(platform) }
                    )
                }
            }
        }
        .frame(height: chipHeight)
    }
    
    // MARK: - Scroll Indicator
    @ViewBuilder
    private func scrollIndicator(columns: Int) -> some View {
        HStack(spacing: 4) {
            Spacer()
            
            // Page dots - show based on platform count
            let pageCount = max(1, min((allPlatformsOrdered.count - 1) / columns + 1, 4))
            ForEach(0..<pageCount, id: \.self) { index in
                Circle()
                    .fill(index == 0 ? theme.accentColor : Color.white.opacity(0.4))
                    .frame(width: 5, height: 5)
            }
            
            // Scroll arrow indicator
            Image(systemName: "chevron.right")
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(hasMorePlatforms(columns: columns) ? theme.textMuted : theme.textMuted.opacity(0.3))
            
            Spacer()
        }
    }
    
    func platformExists(name: String) -> Bool {
        let lowercaseName = name.lowercased().trimmingCharacters(in: .whitespaces)
        let defaultNames = ["tiktok", "instagram", "facebook", "all"]
        if defaultNames.contains(lowercaseName) { return true }
        return viewModel.platforms.contains { $0.name.lowercased() == lowercaseName }
    }
}

// MARK: - Aligned Platform Chip (same width as product cards)
struct AlignedPlatformChip: View {
    let platform: Platform
    let isSelected: Bool
    let theme: AppTheme
    let width: CGFloat
    let height: CGFloat
    let onTap: () -> Void
    let onDelete: (() -> Void)?
    @ObservedObject var localization = LocalizationManager.shared
    
    @State private var showDeleteConfirm = false
    
    // Get localized name for default platforms
    private var localizedName: String {
        switch platform.name.lowercased() {
        case "all": return localization.localized(.all)
        case "tiktok": return localization.localized(.tiktok)
        case "instagram": return localization.localized(.instagram)
        case "facebook": return localization.localized(.facebook)
        default: return platform.name
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 2) {
                Image(systemName: platform.icon)
                    .font(.system(size: 16, weight: .semibold))
                
                Text(localizedName)
                    .font(.system(size: 10, weight: .bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .foregroundColor(isSelected ? .white : platform.swiftUIColor)
            .frame(width: width, height: height)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? platform.swiftUIColor.opacity(0.85) : theme.cardBackgroundWithOpacity(0.4))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(isSelected ? platform.swiftUIColor : theme.cardBorder, lineWidth: isSelected ? 2 : 1)
            )
            .overlay(alignment: .topTrailing) {
                if onDelete != nil {
                    Button {
                        showDeleteConfirm = true
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.8))
                            .background(Circle().fill(Color.black.opacity(0.3)))
                    }
                    .padding(2) // Keep inside bounds
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

struct PlatformChip: View {
    let platform: Platform
    let isSelected: Bool
    let theme: AppTheme
    let chipWidth: CGFloat
    let chipHeight: CGFloat
    let onTap: () -> Void
    let onDelete: (() -> Void)?
    @ObservedObject var localization = LocalizationManager.shared
    
    @State private var showDeleteConfirm = false
    
    // Get localized name for default platforms
    private var localizedName: String {
        switch platform.name.lowercased() {
        case "all": return localization.localized(.all)
        case "tiktok": return localization.localized(.tiktok)
        case "instagram": return localization.localized(.instagram)
        case "facebook": return localization.localized(.facebook)
        default: return platform.name
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 3) {
                Image(systemName: platform.icon)
                    .font(.system(size: 16, weight: .semibold))
                
                Text(localizedName)
                    .font(.system(size: 10, weight: .bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .foregroundColor(isSelected ? .white : platform.swiftUIColor)
            .frame(width: chipWidth, height: chipHeight)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? platform.swiftUIColor.opacity(0.85) : theme.cardBackgroundWithOpacity(0.4))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(isSelected ? platform.swiftUIColor : theme.cardBorder, lineWidth: isSelected ? 2 : 1)
            )
            .overlay(alignment: .topTrailing) {
                if onDelete != nil {
                    Button {
                        showDeleteConfirm = true
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.8))
                            .background(Circle().fill(Color.black.opacity(0.3)))
                    }
                    .padding(2) // Keep inside bounds
                }
            }
            .scaleEffect(isSelected ? 1.03 : 1.0)
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
