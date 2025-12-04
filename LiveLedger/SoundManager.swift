//
//  SoundManager.swift
//  LiveLedger
//
//  LiveLedger - Sound Management for Audio Feedback
//

import SwiftUI
import AVFoundation
import Combine

// MARK: - Sound Types
enum TimerStartSound: String, CaseIterable, Codable {
    case beep = "Beep"
    case chime = "Chime"
    case bell = "Bell"
    case horn = "Horn"
    
    var systemSoundID: SystemSoundID {
        switch self {
        case .beep: return 1057   // Tink
        case .chime: return 1054  // Fanfare
        case .bell: return 1013   // Alert
        case .horn: return 1016   // Tweet
        }
    }
    
    var icon: String {
        switch self {
        case .beep: return "speaker.wave.2"
        case .chime: return "bell"
        case .bell: return "bell.fill"
        case .horn: return "megaphone"
        }
    }
}

enum OrderAddedSound: String, CaseIterable, Codable {
    case pop = "Pop"
    case click = "Click"
    case ding = "Ding"
    case coin = "Coin"
    
    var systemSoundID: SystemSoundID {
        switch self {
        case .pop: return 1104    // Pop
        case .click: return 1123  // Typewriter key
        case .ding: return 1025   // New Mail
        case .coin: return 1075   // SMS Received (short)
        }
    }
    
    var icon: String {
        switch self {
        case .pop: return "bubble.middle.bottom"
        case .click: return "hand.tap"
        case .ding: return "bell.badge"
        case .coin: return "centsign.circle"
        }
    }
}

// MARK: - Timer Interval Reminder
enum TimerInterval: Int, CaseIterable, Codable, Identifiable {
    case thirtyMinutes = 30
    case oneHour = 60
    case threeHours = 180
    case fiveHours = 300
    case sevenHours = 420
    case tenHours = 600
    
    var id: Int { rawValue }
    
    var displayName: String {
        switch self {
        case .thirtyMinutes: return "30 minutes"
        case .oneHour: return "1 hour"
        case .threeHours: return "3 hours"
        case .fiveHours: return "5 hours"
        case .sevenHours: return "7 hours"
        case .tenHours: return "10 hours"
        }
    }
    
    var minutes: Int { rawValue }
    var seconds: TimeInterval { TimeInterval(rawValue * 60) }
}

// MARK: - Sound Manager
@MainActor
class SoundManager: ObservableObject {
    static let shared = SoundManager()
    
    // Settings
    @Published var timerStartSound: TimerStartSound {
        didSet { saveSettings() }
    }
    @Published var orderAddedSound: OrderAddedSound {
        didSet { saveSettings() }
    }
    @Published var timerVolume: Float {
        didSet { saveSettings() }
    }
    @Published var orderVolume: Float {
        didSet { saveSettings() }
    }
    @Published var soundsEnabled: Bool {
        didSet { saveSettings() }
    }
    
    // Timer Interval Reminder Settings
    @Published var intervalRemindersEnabled: Bool {
        didSet { saveSettings() }
    }
    @Published var enabledIntervals: Set<TimerInterval> {
        didSet { saveSettings() }
    }
    @Published var triggeredIntervals: Set<Int> = [] // Track which intervals already beeped this session
    
    private let settingsKey = "liveledger_sound_settings"
    
    private init() {
        // Load saved settings or use defaults
        if let data = UserDefaults.standard.data(forKey: settingsKey),
           let settings = try? JSONDecoder().decode(SoundSettings.self, from: data) {
            self.timerStartSound = settings.timerStartSound
            self.orderAddedSound = settings.orderAddedSound
            self.timerVolume = settings.timerVolume
            self.orderVolume = settings.orderVolume
            self.soundsEnabled = settings.soundsEnabled
            self.intervalRemindersEnabled = settings.intervalRemindersEnabled ?? true
            self.enabledIntervals = Set(settings.enabledIntervals ?? TimerInterval.allCases)
        } else {
            // Defaults
            self.timerStartSound = .chime
            self.orderAddedSound = .pop
            self.timerVolume = 0.7
            self.orderVolume = 0.5
            self.soundsEnabled = true
            self.intervalRemindersEnabled = true
            self.enabledIntervals = Set(TimerInterval.allCases) // All intervals enabled by default
        }
    }
    
    // MARK: - Play Sounds
    func playTimerStartSound() {
        guard soundsEnabled else { return }
        // Reset triggered intervals when timer starts
        triggeredIntervals.removeAll()
        playSystemSound(timerStartSound.systemSoundID)
    }
    
    func playOrderAddedSound() {
        guard soundsEnabled else { return }
        playSystemSound(orderAddedSound.systemSoundID)
    }
    
    func playIntervalReminderSound() {
        guard soundsEnabled && intervalRemindersEnabled else { return }
        // Play a distinct reminder sound (double beep)
        playSystemSound(1052) // SIM Toolkit sound - distinct
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            AudioServicesPlaySystemSound(1052)
        }
    }
    
    // Check if timer elapsed time has hit an interval milestone
    func checkIntervalMilestone(elapsedSeconds: TimeInterval) {
        guard soundsEnabled && intervalRemindersEnabled else { return }
        
        for interval in enabledIntervals {
            let intervalSeconds = interval.seconds
            // Check if we just crossed this interval (within 1 second window)
            if elapsedSeconds >= intervalSeconds && elapsedSeconds < intervalSeconds + 1 {
                // Only trigger if not already triggered this session
                if !triggeredIntervals.contains(interval.rawValue) {
                    triggeredIntervals.insert(interval.rawValue)
                    playIntervalReminderSound()
                }
            }
        }
    }
    
    // Reset triggered intervals (call when timer resets)
    func resetTriggeredIntervals() {
        triggeredIntervals.removeAll()
    }
    
    func previewTimerSound(_ sound: TimerStartSound) {
        playSystemSound(sound.systemSoundID)
    }
    
    func previewOrderSound(_ sound: OrderAddedSound) {
        playSystemSound(sound.systemSoundID)
    }
    
    private func playSystemSound(_ soundID: SystemSoundID) {
        AudioServicesPlaySystemSound(soundID)
    }
    
    // MARK: - Settings Persistence
    private func saveSettings() {
        let settings = SoundSettings(
            timerStartSound: timerStartSound,
            orderAddedSound: orderAddedSound,
            timerVolume: timerVolume,
            orderVolume: orderVolume,
            soundsEnabled: soundsEnabled,
            intervalRemindersEnabled: intervalRemindersEnabled,
            enabledIntervals: Array(enabledIntervals)
        )
        if let data = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(data, forKey: settingsKey)
        }
    }
    
    // Settings model for persistence
    private struct SoundSettings: Codable {
        let timerStartSound: TimerStartSound
        let orderAddedSound: OrderAddedSound
        let timerVolume: Float
        let orderVolume: Float
        let soundsEnabled: Bool
        let intervalRemindersEnabled: Bool?
        let enabledIntervals: [TimerInterval]?
    }
}

// MARK: - Sound Settings View
struct SoundSettingsView: View {
    @ObservedObject var soundManager: SoundManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                // Master Toggle
                Section {
                    Toggle(isOn: $soundManager.soundsEnabled) {
                        Label("Enable Sounds", systemImage: "speaker.wave.3.fill")
                    }
                } footer: {
                    Text("Audio feedback for timer and order actions")
                }
                
                // Timer Start Sound
                Section {
                    // Sound Selection
                    ForEach(TimerStartSound.allCases, id: \.self) { sound in
                        Button {
                            soundManager.timerStartSound = sound
                            soundManager.previewTimerSound(sound)
                        } label: {
                            HStack {
                                Image(systemName: sound.icon)
                                    .font(.system(size: 16))
                                    .foregroundColor(.orange)
                                    .frame(width: 28)
                                
                                Text(sound.rawValue)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                if soundManager.timerStartSound == sound {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.orange)
                                }
                            }
                        }
                    }
                    
                    // Volume Slider
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Volume")
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                            Spacer()
                            Text("\(Int(soundManager.timerVolume * 100))%")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.orange)
                        }
                        
                        HStack {
                            Image(systemName: "speaker.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                            
                            Slider(value: $soundManager.timerVolume, in: 0...1)
                                .tint(.orange)
                            
                            Image(systemName: "speaker.wave.3.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical, 4)
                    
                    // Preview Button
                    Button {
                        soundManager.previewTimerSound(soundManager.timerStartSound)
                    } label: {
                        HStack {
                            Image(systemName: "play.circle.fill")
                            Text("Preview Timer Sound")
                        }
                        .foregroundColor(.orange)
                    }
                } header: {
                    HStack {
                        Image(systemName: "timer")
                        Text("Timer Start Sound")
                    }
                } footer: {
                    Text("Plays when you start the sales timer")
                }
                
                // Timer Interval Reminders
                Section {
                    // Master toggle for interval reminders
                    Toggle(isOn: $soundManager.intervalRemindersEnabled) {
                        HStack {
                            Image(systemName: "bell.badge.fill")
                                .foregroundColor(.purple)
                            Text("Enable Reminders")
                        }
                    }
                    
                    if soundManager.intervalRemindersEnabled {
                        // Interval selection
                        ForEach(TimerInterval.allCases) { interval in
                            Button {
                                if soundManager.enabledIntervals.contains(interval) {
                                    soundManager.enabledIntervals.remove(interval)
                                } else {
                                    soundManager.enabledIntervals.insert(interval)
                                }
                            } label: {
                                HStack {
                                    Image(systemName: soundManager.enabledIntervals.contains(interval) ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(soundManager.enabledIntervals.contains(interval) ? .purple : .gray)
                                    
                                    Text(interval.displayName)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                }
                            }
                        }
                        
                        // Preview Button
                        Button {
                            soundManager.playIntervalReminderSound()
                        } label: {
                            HStack {
                                Image(systemName: "play.circle.fill")
                                Text("Preview Reminder Sound")
                            }
                            .foregroundColor(.purple)
                        }
                    }
                } header: {
                    HStack {
                        Image(systemName: "clock.badge.checkmark")
                        Text("Timer Interval Reminders")
                    }
                } footer: {
                    Text("Beep at selected intervals to remind you how long you've been live")
                }
                
                // Order Added Sound
                Section {
                    // Sound Selection
                    ForEach(OrderAddedSound.allCases, id: \.self) { sound in
                        Button {
                            soundManager.orderAddedSound = sound
                            soundManager.previewOrderSound(sound)
                        } label: {
                            HStack {
                                Image(systemName: sound.icon)
                                    .font(.system(size: 16))
                                    .foregroundColor(.green)
                                    .frame(width: 28)
                                
                                Text(sound.rawValue)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                if soundManager.orderAddedSound == sound {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                }
                            }
                        }
                    }
                    
                    // Volume Slider
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Volume")
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                            Spacer()
                            Text("\(Int(soundManager.orderVolume * 100))%")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.green)
                        }
                        
                        HStack {
                            Image(systemName: "speaker.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                            
                            Slider(value: $soundManager.orderVolume, in: 0...1)
                                .tint(.green)
                            
                            Image(systemName: "speaker.wave.3.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical, 4)
                    
                    // Preview Button
                    Button {
                        soundManager.previewOrderSound(soundManager.orderAddedSound)
                    } label: {
                        HStack {
                            Image(systemName: "play.circle.fill")
                            Text("Preview Order Sound")
                        }
                        .foregroundColor(.green)
                    }
                } header: {
                    HStack {
                        Image(systemName: "bag.badge.plus")
                        Text("Order Added Sound")
                    }
                } footer: {
                    Text("Plays when you tap a product to add an order")
                }
            }
            .navigationTitle("Sound Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    SoundSettingsView(soundManager: SoundManager.shared)
}

