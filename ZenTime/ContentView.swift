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
                HeaderView()
                TimerView(timerManager: timerManager)
                DurationSelectorView(selectedDuration: $selectedDuration, timerManager: timerManager)
                AmbientSoundSelectorView(selectedAmbientSound: $selectedAmbientSound, timerManager: timerManager)
                ControlButtonsView(
                    timerManager: timerManager,
                    showingSettings: $showingSettings
                )
                
                Spacer()
            }
            .padding()
            .navigationBarHidden(true)
            .onAppear {
                timerManager.requestNotificationPermission()
                sessionManager.loadSessions()
            }
            .onChange(of: timerManager.isCompleted) { _, completed in
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

// MARK: - Header View
struct HeaderView: View {
    var body: some View {
        VStack {
            Text("ZenTime")
                .font(.system(size: 42, weight: .heavy, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.purple, .pink, .orange],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            Text("Your Daily Chill Session")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Timer View
struct TimerView: View {
    @ObservedObject var timerManager: TimerManager
    
    var body: some View {
        ZStack {
            TimerBackgroundCircle()
            TimerProgressCircle(progress: timerManager.progress)
            TimerContentView(timerManager: timerManager)
        }
    }
}

struct TimerBackgroundCircle: View {
    var body: some View {
        Circle()
            .stroke(Color.gray.opacity(0.2), lineWidth: 12)
            .frame(width: 280, height: 280)
    }
}

struct TimerProgressCircle: View {
    let progress: Double
    
    var body: some View {
        Circle()
            .trim(from: 0, to: progress)
            .stroke(
                LinearGradient(
                    gradient: Gradient(colors: [.purple, .pink, .orange, .yellow]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                style: StrokeStyle(lineWidth: 12, lineCap: .round)
            )
            .frame(width: 280, height: 280)
            .rotationEffect(.degrees(-90))
            .animation(.easeInOut(duration: 1), value: progress)
    }
}

struct TimerContentView: View {
    @ObservedObject var timerManager: TimerManager
    
    var body: some View {
        VStack(spacing: 8) {
            Text(timerManager.timeString)
                .font(.system(size: 52, weight: .black, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.purple, .pink],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            Text(timerManager.isRunning ? "Stay focused! 💪" : "Ready to chill? 😌")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Duration Selector View
struct DurationSelectorView: View {
    @Binding var selectedDuration: Int
    @ObservedObject var timerManager: TimerManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("How long do you want to focus?")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            DurationScrollView(selectedDuration: $selectedDuration, timerManager: timerManager)
        }
    }
}

struct DurationScrollView: View {
    @Binding var selectedDuration: Int
    @ObservedObject var timerManager: TimerManager
    
    private let durations = [1, 5, 10, 15, 20, 30, 45, 60]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                ForEach(durations, id: \.self) { duration in
                    DurationButton(
                        duration: duration,
                        isSelected: selectedDuration == duration,
                        action: {
                            selectedDuration = duration
                            timerManager.setDuration(duration)
                        }
                    )
                }
            }
            .padding(.horizontal)
        }
    }
}

struct DurationButton: View {
    let duration: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("\(duration)m")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(isSelected ? 
                            AnyShapeStyle(LinearGradient(colors: [.purple, .pink], startPoint: .leading, endPoint: .trailing)) :
                            AnyShapeStyle(Color.gray.opacity(0.1))
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(isSelected ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
    }
}

// MARK: - Ambient Sound Selector View
struct AmbientSoundSelectorView: View {
    @Binding var selectedAmbientSound: AmbientSound
    @ObservedObject var timerManager: TimerManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Pick your vibe 🎵")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            AmbientSoundScrollView(selectedAmbientSound: $selectedAmbientSound, timerManager: timerManager)
        }
    }
}

struct AmbientSoundScrollView: View {
    @Binding var selectedAmbientSound: AmbientSound
    @ObservedObject var timerManager: TimerManager
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                ForEach(AmbientSound.allCases, id: \.self) { sound in
                    AmbientSoundButton(
                        sound: sound,
                        isSelected: selectedAmbientSound == sound,
                        action: {
                            selectedAmbientSound = sound
                            timerManager.setAmbientSound(sound)
                        }
                    )
                }
            }
            .padding(.horizontal)
        }
    }
}

struct AmbientSoundButton: View {
    let sound: AmbientSound
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: sound.iconName)
                    .font(.title)
                Text(sound.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(isSelected ? .white : .primary)
            .padding(.horizontal, 20)
            .padding(.vertical, 15)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? 
                        AnyShapeStyle(LinearGradient(colors: [.green, .teal], startPoint: .leading, endPoint: .trailing)) :
                        AnyShapeStyle(Color.gray.opacity(0.1))
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

// MARK: - Control Buttons View
struct ControlButtonsView: View {
    @ObservedObject var timerManager: TimerManager
    @Binding var showingSettings: Bool
    
    var body: some View {
        HStack(spacing: 25) {
            ResetButton(action: { timerManager.reset() })
            StartPauseButton(timerManager: timerManager)
            
            if timerManager.isPaused {
                ResumeButton(action: { timerManager.resume() })
            } else {
                SettingsButton(action: { showingSettings = true })
            }
        }
    }
}

struct ResetButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: "arrow.clockwise")
                    .font(.title2)
                Text("Reset")
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(.white)
            .frame(width: 70, height: 70)
            .background(
                Circle()
                    .fill(LinearGradient(colors: [.orange, .red], startPoint: .top, endPoint: .bottom))
            )
        }
    }
}

struct StartPauseButton: View {
    @ObservedObject var timerManager: TimerManager
    
    var body: some View {
        Button(action: {
            if timerManager.isRunning {
                timerManager.pause()
            } else {
                timerManager.start()
            }
        }) {
            VStack(spacing: 4) {
                Image(systemName: timerManager.isRunning ? "pause.fill" : "play.fill")
                    .font(.title)
                Text(timerManager.isRunning ? "Pause" : "Start")
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(.white)
            .frame(width: 90, height: 90)
            .background(
                Circle()
                    .fill(timerManager.isRunning ? 
                        LinearGradient(colors: [.red, .pink], startPoint: .top, endPoint: .bottom) :
                        LinearGradient(colors: [.green, .teal], startPoint: .top, endPoint: .bottom)
                    )
            )
        }
    }
}

struct ResumeButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: "play.fill")
                    .font(.title2)
                Text("Resume")
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(.white)
            .frame(width: 70, height: 70)
            .background(
                Circle()
                    .fill(LinearGradient(colors: [.blue, .purple], startPoint: .top, endPoint: .bottom))
            )
        }
    }
}

struct SettingsButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: "gearshape.fill")
                    .font(.title2)
                Text("Settings")
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(.white)
            .frame(width: 70, height: 70)
            .background(
                Circle()
                    .fill(LinearGradient(colors: [.gray, .secondary], startPoint: .top, endPoint: .bottom))
            )
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
        content.title = "Focus Session Complete! 🎉"
        content.body = "You crushed it! Your chill session is done. Time to celebrate! 🚀"
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
        case .none: return "Silent"
        case .rain: return "Rainy Day"
        case .brownNoise: return "White Noise"
        case .omTone: return "Zen Vibes"
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
                Section(header: Text("Your Progress")) {
                    Button("View Your Sessions") {
                        // This would show the history view
                    }
                    
                    Button("Clear All Sessions") {
                        sessionManager.clearHistory()
                    }
                    .foregroundColor(.red)
                }
                
                Section(header: Text("Stay Motivated")) {
                    Button("Set Daily Reminders") {
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
            .navigationTitle("⚙️ Settings")
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
            .navigationTitle("📊 Your Sessions")
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
                Section(header: Text("Daily Motivation")) {
                    Toggle("Get Daily Reminders", isOn: $isReminderEnabled)
                    
                    if isReminderEnabled {
                        DatePicker("When to remind you", selection: $reminderTime, displayedComponents: .hourAndMinute)
                    }
                }
            }
            .navigationTitle("⏰ Reminders")
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
