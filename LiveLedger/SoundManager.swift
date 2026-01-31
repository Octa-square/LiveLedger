//
//  SoundManager.swift
//  LiveLedger
//
//  LiveLedger - Sound Effects Manager
//

import SwiftUI
import AVFoundation
import Combine

// MARK: - Sound Types
enum OrderSound: String, CaseIterable, Codable {
    case cash = "Cash Register"
    case success = "Success"
    case pop = "Pop"
    case notification = "Notification"
    
    var systemSoundID: SystemSoundID {
        switch self {
        case .cash: return 1016     // Tweet
        case .success: return 1054  // Positive
        case .pop: return 1104      // Pop
        case .notification: return 1007 // Received
        }
    }
}

// MARK: - Sound Settings
struct SoundSettings: Codable {
    var orderSoundEnabled: Bool = true
    var orderSound: OrderSound = .cash
    var orderVolume: Float = 0.8
}

// MARK: - Sound Manager
class SoundManager: ObservableObject {
    static let shared = SoundManager()
    
    @Published var settings: SoundSettings {
        didSet {
            saveSettings()
        }
    }
    
    private let settingsKey = "liveledger_sound_settings"
    
    private init() {
        // Load saved settings
        if let data = UserDefaults.standard.data(forKey: settingsKey),
           let decoded = try? JSONDecoder().decode(SoundSettings.self, from: data) {
            settings = decoded
        } else {
            settings = SoundSettings()
        }
    }
    
    func saveSettings() {
        if let data = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(data, forKey: settingsKey)
        }
    }
    
    // MARK: - Play Sounds
    func playOrderAddedSound() {
        guard settings.orderSoundEnabled else { return }
        playSystemSound(settings.orderSound.systemSoundID, volume: settings.orderVolume)
    }
    
    func previewOrderSound() {
        playSystemSound(settings.orderSound.systemSoundID, volume: settings.orderVolume)
    }
    
    private func playSystemSound(_ soundID: SystemSoundID, volume: Float) {
        // System sounds use device volume, so we use AudioServicesPlaySystemSound
        // For volume control, we'd need custom audio files, but system sounds are reliable
        AudioServicesPlaySystemSound(soundID)
    }
}

// MARK: - Sound Settings View
struct SoundSettingsView: View {
    @ObservedObject var soundManager = SoundManager.shared
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                // Order Sound Section
                Section {
                    // Enable/Disable
                    Toggle(isOn: $soundManager.settings.orderSoundEnabled) {
                        Label("Order Added Sound", systemImage: "bag.badge.plus")
                    }
                    
                    if soundManager.settings.orderSoundEnabled {
                        // Sound Selection
                        Picker("Sound", selection: $soundManager.settings.orderSound) {
                            ForEach(OrderSound.allCases, id: \.self) { sound in
                                Text(sound.rawValue).tag(sound)
                            }
                        }
                        
                        // Volume Slider
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "speaker.fill")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 12))
                                Slider(value: $soundManager.settings.orderVolume, in: 0...1)
                                    .tint(.green)
                                Image(systemName: "speaker.wave.3.fill")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 12))
                            }
                            
                            Text("Volume: \(Int(soundManager.settings.orderVolume * 100))%")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        // Preview Button
                        Button {
                            soundManager.previewOrderSound()
                        } label: {
                            HStack {
                                Image(systemName: "play.circle.fill")
                                Text("Preview Sound")
                            }
                            .foregroundColor(.green)
                        }
                    }
                } header: {
                    Text("Order Sound")
                } footer: {
                    Text("Plays when a new order is added")
                }
                
                // Reset Section
                Section {
                    Button(role: .destructive) {
                        soundManager.settings = SoundSettings()
                    } label: {
                        Label("Reset to Defaults", systemImage: "arrow.counterclockwise")
                    }
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
    SoundSettingsView()
}

