//
//  BoxBreathingView.swift
//  ZenTime
//
//  Box Breathing Exercise Feature
//

import SwiftUI
import AVFoundation

struct BoxBreathingView: View {
    @StateObject private var breathingManager = BoxBreathingManager()
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedAmbientSound: AmbientSound = .none
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 4) {
                    Text("Box Breathing")
                        .font(.system(size: 32, weight: .heavy, design: .rounded))
                        .minimumScaleFactor(0.8)
                        .lineLimit(1)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .cyan, .teal],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text("4-4-4-4 Breathing Technique")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
                .padding(.top)
                
                // Cycle Counter
                HStack(spacing: 16) {
                    VStack {
                        Text("\(breathingManager.completedCycles)")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.blue)
                        Text("Cycles")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack {
                        Text("\(breathingManager.totalDuration)s")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.teal)
                        Text("Total Time")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
                
                // Breathing Animation
                ZStack {
                    BreathingVisualization(
                        phase: breathingManager.currentPhase,
                        progress: breathingManager.phaseProgress,
                        isActive: breathingManager.isRunning
                    )
                }
                .frame(height: 300)
                
                // Phase Display
                VStack(spacing: 8) {
                    Text(breathingManager.currentPhase.displayText)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(breathingManager.currentPhase.color)
                    
                    Text("\(Int(breathingManager.phaseTimeRemaining))s")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                }
                
                // Ambient Sound Selector (compact version)
                VStack(alignment: .leading, spacing: 6) {
                    Text("Background Sound")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(AmbientSound.allCases, id: \.self) { sound in
                                CompactSoundButton(
                                    sound: sound,
                                    isSelected: selectedAmbientSound == sound,
                                    action: {
                                        selectedAmbientSound = sound
                                        breathingManager.setAmbientSound(sound)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Control Buttons
                HStack(spacing: 18) {
                    Button(action: { breathingManager.reset() }) {
                        VStack(spacing: 2) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 18, weight: .semibold))
                            Text("Reset")
                                .font(.caption2)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(
                            Circle()
                                .fill(LinearGradient(colors: [.orange, .red], startPoint: .top, endPoint: .bottom))
                        )
                    }
                    
                    Button(action: {
                        if breathingManager.isRunning {
                            breathingManager.pause()
                        } else {
                            breathingManager.start()
                        }
                    }) {
                        VStack(spacing: 2) {
                            Image(systemName: breathingManager.isRunning ? "pause.fill" : "play.fill")
                                .font(.system(size: 22, weight: .semibold))
                            Text(breathingManager.isRunning ? "Pause" : "Start")
                                .font(.caption2)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.white)
                        .frame(width: 78, height: 78)
                        .background(
                            Circle()
                                .fill(breathingManager.isRunning ?
                                    LinearGradient(colors: [.red, .pink], startPoint: .top, endPoint: .bottom) :
                                    LinearGradient(colors: [.blue, .cyan], startPoint: .top, endPoint: .bottom)
                                )
                        )
                    }
                    
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        VStack(spacing: 2) {
                            Image(systemName: "xmark")
                                .font(.system(size: 18, weight: .semibold))
                            Text("Close")
                                .font(.caption2)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(
                            Circle()
                                .fill(LinearGradient(colors: [.gray, .secondary], startPoint: .top, endPoint: .bottom))
                        )
                    }
                }
                
                Spacer(minLength: 8)
            }
            .padding()
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Breathing Visualization
struct BreathingVisualization: View {
    let phase: BreathingPhase
    let progress: Double
    let isActive: Bool
    
    private var scale: CGFloat {
        switch phase {
        case .breatheIn:
            return 0.5 + (progress * 0.5) // Grows from 0.5 to 1.0
        case .holdIn:
            return 1.0 // Stays at full size
        case .breatheOut:
            return 1.0 - (progress * 0.5) // Shrinks from 1.0 to 0.5
        case .holdOut:
            return 0.5 // Stays at small size
        }
    }
    
    var body: some View {
        let baseSize: CGFloat = 240
        let strokeWidth: CGFloat = 5
        
        ZStack {
            // Outer circle (static background)
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: strokeWidth - 2)
                .frame(width: baseSize, height: baseSize)
            
            // Animated breathing circle
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            phase.color.opacity(0.6),
                            phase.color.opacity(0.3),
                            phase.color.opacity(0.1)
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: baseSize / 2
                    )
                )
                .frame(width: baseSize, height: baseSize)
                .scaleEffect(isActive ? scale : 0.5)
                .animation(.easeInOut(duration: 0.5), value: scale)
            
            // Inner circle border
            Circle()
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [phase.color, phase.color.opacity(0.5)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: strokeWidth
                )
                .frame(width: baseSize, height: baseSize)
                .scaleEffect(isActive ? scale : 0.5)
                .animation(.easeInOut(duration: 0.5), value: scale)
            
            // Progress indicator (small pulsing circle)
            Circle()
                .fill(phase.color)
                .frame(width: 16, height: 16)
                .scaleEffect(isActive ? (1.0 + sin(progress * .pi * 2) * 0.3) : 1.0)
                .animation(.easeInOut(duration: 0.3).repeatForever(autoreverses: true), value: isActive)
        }
    }
}

// MARK: - Compact Sound Button
struct CompactSoundButton: View {
    let sound: AmbientSound
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: sound.iconName)
                    .font(.system(size: 12))
                Text(sound.displayName)
                    .font(.caption2)
                    .fontWeight(.medium)
            }
            .foregroundColor(isSelected ? .white : .primary)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ?
                        AnyShapeStyle(LinearGradient(colors: [.blue, .cyan], startPoint: .leading, endPoint: .trailing)) :
                        AnyShapeStyle(Color.gray.opacity(0.1))
                    )
            )
        }
    }
}

// MARK: - Breathing Phase Enum
enum BreathingPhase {
    case breatheIn
    case holdIn
    case breatheOut
    case holdOut
    
    var displayText: String {
        switch self {
        case .breatheIn: return "Breathe In"
        case .holdIn: return "Hold"
        case .breatheOut: return "Breathe Out"
        case .holdOut: return "Hold"
        }
    }
    
    var color: Color {
        switch self {
        case .breatheIn: return .red  // per earlier request
        case .holdIn: return .cyan
        case .breatheOut: return .teal
        case .holdOut: return .green
        }
    }
    
    var duration: TimeInterval {
        return 5.0 // 5 seconds per phase
    }
    
    func nextPhase() -> BreathingPhase {
        switch self {
        case .breatheIn: return .holdIn
        case .holdIn: return .breatheOut
        case .breatheOut: return .holdOut
        case .holdOut: return .breatheIn
        }
    }
}

// MARK: - Box Breathing Manager
class BoxBreathingManager: ObservableObject {
    @Published var currentPhase: BreathingPhase = .breatheIn
    @Published var phaseTimeRemaining: TimeInterval = 5.0
    @Published var phaseProgress: Double = 0.0
    @Published var isRunning = false
    @Published var isPaused = false
    @Published var completedCycles = 0
    @Published var totalDuration = 0
    
    private var timer: Timer?
    private var phaseStartTime: Date?
    private var ambientPlayer: AVAudioPlayer?
    
    func start() {
        if isPaused {
            resume()
            return
        }
        
        isRunning = true
        isPaused = false
        currentPhase = .breatheIn
        phaseTimeRemaining = currentPhase.duration
        phaseProgress = 0.0
        phaseStartTime = Date()
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
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
        phaseStartTime = Date().addingTimeInterval(-phaseTimeRemaining + currentPhase.duration)
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.updateTimer()
        }
    }
    
    func reset() {
        isRunning = false
        isPaused = false
        currentPhase = .breatheIn
        phaseTimeRemaining = 5.0
        phaseProgress = 0.0
        completedCycles = 0
        totalDuration = 0
        
        timer?.invalidate()
        timer = nil
        
        stopAmbientSound()
    }
    
    private func updateTimer() {
        guard let startTime = phaseStartTime else { return }
        
        let elapsed = Date().timeIntervalSince(startTime)
        let remaining = currentPhase.duration - elapsed
        
        if remaining > 0 {
            phaseTimeRemaining = remaining
            phaseProgress = elapsed / currentPhase.duration
            totalDuration = completedCycles * 20 + Int(elapsed) + Int(currentPhase.rawValue) * 5
        } else {
            // Move to next phase
            transitionToNextPhase()
        }
    }
    
    private func transitionToNextPhase() {
        // Haptic feedback at phase transition
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        // Track completed cycles (after holdOut phase)
        if currentPhase == .holdOut {
            completedCycles += 1
        }
        
        // Move to next phase
        currentPhase = currentPhase.nextPhase()
        phaseTimeRemaining = currentPhase.duration
        phaseProgress = 0.0
        phaseStartTime = Date()
    }
    
    func setAmbientSound(_ sound: AmbientSound) {
        stopAmbientSound()
        if sound != .none {
            playAmbientSound(sound)
        }
    }
    
    private func playAmbientSound(_ sound: AmbientSound) {
        stopAmbientSound()
        
        let fileName = getAudioFileName(for: sound)
        
        if let audioURL = Bundle.main.url(forResource: fileName, withExtension: "mp3") {
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
                try AVAudioSession.sharedInstance().setActive(true)
                
                ambientPlayer = try AVAudioPlayer(contentsOf: audioURL)
                ambientPlayer?.numberOfLoops = -1
                ambientPlayer?.volume = 0.2
                ambientPlayer?.play()
            } catch {
                print("Error playing ambient sound: \(error.localizedDescription)")
            }
        }
    }
    
    private func getAudioFileName(for sound: AmbientSound) -> String {
        switch sound {
        case .none: return ""
        case .rain: return "rain_sound"
        case .brownNoise: return "brown_noise"
        }
    }
    
    private func stopAmbientSound() {
        ambientPlayer?.stop()
        ambientPlayer = nil
    }
    
    deinit {
        timer?.invalidate()
        stopAmbientSound()
    }
}

// Extension to track phase as raw value for calculation
extension BreathingPhase: RawRepresentable {
    typealias RawValue = Int
    
    init?(rawValue: Int) {
        switch rawValue {
        case 0: self = .breatheIn
        case 1: self = .holdIn
        case 2: self = .breatheOut
        case 3: self = .holdOut
        default: return nil
        }
    }
    
    var rawValue: Int {
        switch self {
        case .breatheIn: return 0
        case .holdIn: return 1
        case .breatheOut: return 2
        case .holdOut: return 3
        }
    }
}

#Preview {
    BoxBreathingView()
}
