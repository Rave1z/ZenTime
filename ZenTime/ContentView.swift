//
//  ContentView.swift
//  ZenTime
//
//  Created by Anvesh Kalia on 8/30/25.
//

import SwiftUI
import AVFoundation
import UserNotifications

struct ContentView: View {
    @StateObject private var timerManager = TimerManager()
    @StateObject private var sessionManager = SessionManager()
    @State private var selectedDuration: Int = 10
    @State private var selectedAmbientSound: AmbientSound = .none
    @State private var showingSettings = false
    @State private var showingHistory = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Header
                VStack {
                    Text("ZenTime")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Meditation Timer")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Timer Display
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                        .frame(width: 250, height: 250)
                    
                    Circle()
                        .trim(from: 0, to: timerManager.progress)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [.blue, .purple]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 250, height: 250)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 1), value: timerManager.progress)
                    
                    VStack {
                        Text(timerManager.timeString)
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text(timerManager.isRunning ? "Meditating..." : "Ready")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Duration Selector
                VStack(alignment: .leading, spacing: 10) {
                    Text("Duration")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach([1, 5, 10, 15, 20, 30, 45, 60], id: \.self) { duration in
                                Button(action: {
                                    selectedDuration = duration
                                    timerManager.setDuration(duration)
                                }) {
                                    Text("\(duration)m")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(selectedDuration == duration ? .white : .primary)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 10)
                                        .background(
                                            RoundedRectangle(cornerRadius: 20)
                                                .fill(selectedDuration == duration ? Color.blue : Color.gray.opacity(0.2))
                                        )
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Ambient Sound Selector
                VStack(alignment: .leading, spacing: 10) {
                    Text("Ambient Sound")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(AmbientSound.allCases, id: \.self) { sound in
                                Button(action: {
                                    selectedAmbientSound = sound
                                    timerManager.setAmbientSound(sound)
                                }) {
                                    VStack(spacing: 5) {
                                        Image(systemName: sound.iconName)
                                            .font(.title2)
                                        Text(sound.displayName)
                                            .font(.caption)
                                    }
                                    .foregroundColor(selectedAmbientSound == sound ? .white : .primary)
                                    .padding(.horizontal, 15)
                                    .padding(.vertical, 10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(selectedAmbientSound == sound ? Color.green : Color.gray.opacity(0.2))
                                    )
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Control Buttons
                HStack(spacing: 20) {
                    // Reset Button
                    Button(action: {
                        timerManager.reset()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Circle().fill(Color.orange))
                    }
                    
                    // Start/Pause Button
                    Button(action: {
                        if timerManager.isRunning {
                            timerManager.pause()
                        } else {
                            timerManager.start()
                        }
                    }) {
                        Image(systemName: timerManager.isRunning ? "pause.fill" : "play.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .frame(width: 80, height: 80)
                            .background(Circle().fill(timerManager.isRunning ? Color.red : Color.green))
                    }
                    
                    // Resume Button (only show when paused)
                    if timerManager.isPaused {
                        Button(action: {
                            timerManager.resume()
                        }) {
                            Image(systemName: "play.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(Circle().fill(Color.blue))
                        }
                    } else {
                        // Settings Button
                        Button(action: {
                            showingSettings = true
                        }) {
                            Image(systemName: "gearshape.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(Circle().fill(Color.gray))
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationBarHidden(true)
            .onAppear {
                timerManager.requestNotificationPermission()
                sessionManager.loadSessions()
            }
            .onChange(of: timerManager.isCompleted) { completed in
                if completed {
                    sessionManager.addSession(duration: selectedDuration, ambientSound: selectedAmbientSound)
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView(sessionManager: sessionManager)
            }
            .sheet(isPresented: $showingHistory) {
                HistoryView(sessionManager: sessionManager)
            }
        }
    }
}

// MARK: - Timer Manager
class TimerManager: ObservableObject {
    @Published var timeRemaining: TimeInterval = 600 // 10 minutes default
    @Published var isRunning = false
    @Published var isPaused = false
    @Published var isCompleted = false
    @Published var progress: Double = 1.0
    
    private var timer: Timer?
    private var totalTime: TimeInterval = 600
    private var audioPlayer: AVAudioPlayer?
    private var ambientPlayer: AVAudioPlayer?
    
    var timeString: String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func setDuration(_ minutes: Int) {
        totalTime = TimeInterval(minutes * 60)
        timeRemaining = totalTime
        progress = 1.0
        isCompleted = false
    }
    
    func setAmbientSound(_ sound: AmbientSound) {
        stopAmbientSound()
        if sound != .none {
            playAmbientSound(sound)
        }
    }
    
    func start() {
        if isPaused {
            resume()
            return
        }
        
        isRunning = true
        isPaused = false
        isCompleted = false
        timeRemaining = totalTime
        progress = 1.0
        
        playStartBell()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.updateTimer()
        }
    }
    
    func pause() {
        isRunning = false
        isPaused = true
        timer?.invalidate()
        timer = nil
    }
    
    func resume() {
        isRunning = true
        isPaused = false
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.updateTimer()
        }
    }
    
    func reset() {
        isRunning = false
        isPaused = false
        isCompleted = false
        timeRemaining = totalTime
        progress = 1.0
        
        timer?.invalidate()
        timer = nil
        
        stopAmbientSound()
    }
    
    private func updateTimer() {
        if timeRemaining > 0 {
            timeRemaining -= 1
            progress = timeRemaining / totalTime
        } else {
            completeSession()
        }
    }
    
    private func completeSession() {
        isRunning = false
        isPaused = false
        isCompleted = true
        progress = 0.0
        
        timer?.invalidate()
        timer = nil
        
        playEndBell()
        stopAmbientSound()
        sendNotification()
    }
    
    private func playStartBell() {
        // Simulate start bell sound
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    private func playEndBell() {
        // Simulate end bell sound
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    private func playAmbientSound(_ sound: AmbientSound) {
        // Stop any currently playing ambient sound
        stopAmbientSound()
        
        // Get the audio file name based on the sound type
        let fileName = getAudioFileName(for: sound)
        
        // Load and play the audio file
        if let audioURL = Bundle.main.url(forResource: fileName, withExtension: "mp3") {
            do {
                // Configure audio session for ambient playback
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
                try AVAudioSession.sharedInstance().setActive(true)
                
                // Create and configure the audio player
                ambientPlayer = try AVAudioPlayer(contentsOf: audioURL)
                ambientPlayer?.numberOfLoops = -1 // Loop indefinitely
                ambientPlayer?.volume = 0.3 // Set volume to 30%
                ambientPlayer?.play()
                
                print("Playing ambient sound: \(sound.displayName)")
            } catch {
                print("Error playing ambient sound: \(error.localizedDescription)")
            }
        } else {
            print("Audio file is not found: \(fileName).mp3")
        }
    }
    
    private func getAudioFileName(for sound: AmbientSound) -> String {
        switch sound {
        case .none:
            return ""
        case .rain:
            return "rain_sound"
        case .brownNoise:
            return "brown_noise"
        case .omTone:
            return "om_tone"
        }
    }
    
    private func stopAmbientSound() {
        ambientPlayer?.stop()
        ambientPlayer = nil
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else {
                print("Notification permission denied")
            }
        }
    }
    
    private func sendNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Meditation Complete"
        content.body = "Amazingly Done! Your meditation session has finished."
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
}

// MARK: - Session Manager
class SessionManager: ObservableObject {
    @Published var sessions: [MeditationSession] = []
    private let userDefaults = UserDefaults.standard
    private let sessionsKey = "meditation_sessions"
    
    func addSession(duration: Int, ambientSound: AmbientSound) {
        let session = MeditationSession(
            id: UUID(),
            date: Date(),
            duration: duration,
            ambientSound: ambientSound
        )
        sessions.append(session)
        saveSessions()
    }
    
    func loadSessions() {
        if let data = userDefaults.data(forKey: sessionsKey),
           let decodedSessions = try? JSONDecoder().decode([MeditationSession].self, from: data) {
            sessions = decodedSessions
        }
    }
    
    private func saveSessions() {
        if let encoded = try? JSONEncoder().encode(sessions) {
            userDefaults.set(encoded, forKey: sessionsKey)
        }
    }
    
    func clearHistory() {
        sessions.removeAll()
        userDefaults.removeObject(forKey: sessionsKey)
    }
}

// MARK: - Models
struct MeditationSession: Codable, Identifiable {
    let id: UUID
    let date: Date
    let duration: Int
    let ambientSound: AmbientSound
}

enum AmbientSound: String, CaseIterable, Codable {
    case none = "none"
    case rain = "rain"
    case brownNoise = "brown_noise"
    case omTone = "om_tone"
    
    var displayName: String {
        switch self {
        case .none: return "None"
        case .rain: return "Rain"
        case .brownNoise: return "Brown Noise"
        case .omTone: return "Om Tone"
        }
    }
    
    var iconName: String {
        switch self {
        case .none: return "speaker.slash"
        case .rain: return "cloud.rain"
        case .brownNoise: return "waveform"
        case .omTone: return "music.note"
        }
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @ObservedObject var sessionManager: SessionManager
    @Environment(\.presentationMode) var presentationMode
    @State private var showingReminderSettings = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Session History")) {
                    Button("View History") {
                        // This would show the history view
                    }
                    
                    Button("Clear History") {
                        sessionManager.clearHistory()
                    }
                    .foregroundColor(.red)
                }
                
                Section(header: Text("Notifications")) {
                    Button("Daily Reminder Settings") {
                        showingReminderSettings = true
                    }
                }
                
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
            .sheet(isPresented: $showingReminderSettings) {
                ReminderSettingsView()
            }
        }
    }
}

// MARK: - History View
struct HistoryView: View {
    @ObservedObject var sessionManager: SessionManager
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                ForEach(sessionManager.sessions.reversed()) { session in
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Text("\(session.duration) minutes")
                                .font(.headline)
                            Spacer()
                            Text(session.ambientSound.displayName)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Text(session.date, style: .date)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(session.date, style: .time)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 5)
                }
            }
            .navigationTitle("Session History")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

// MARK: - Reminder Settings View
struct ReminderSettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var isReminderEnabled = false
    @State private var reminderTime = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Daily Reminder")) {
                    Toggle("Enable Daily Reminder", isOn: $isReminderEnabled)
                    
                    if isReminderEnabled {
                        DatePicker("Reminder Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                    }
                }
            }
            .navigationTitle("Reminder Settings")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

#Preview {
    ContentView()
}
