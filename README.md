# ZenTime - Meditation Timer App

A beautiful and feature-rich meditation timer app built with SwiftUI for iOS.

## Features

### 🕐 Timer Functionality
- **Duration Selector**: Choose from 1, 5, 10, 15, 20, 30, 45, or 60 minutes
- **Visual Progress**: Animated circular progress indicator
- **Time Display**: Clear countdown timer with minutes and seconds
- **Status Indicators**: Shows "Ready", "Meditating...", or "Paused" states

### 🎵 Audio Features
- **Ambient Sounds**: 
  - None (silence)
  - Rain sounds
  - Brown noise
  - Om tone
- **Start/End Bells**: Haptic feedback and notification sounds
- **Audio Controls**: Easy ambient sound selection with visual icons

### ⏯️ Timer Controls
- **Start**: Begin meditation session
- **Pause**: Pause current session
- **Resume**: Continue paused session
- **Reset**: Reset timer to selected duration

### 📊 Session Management
- **Session History**: Track all completed meditation sessions
- **JSON Persistence**: Sessions saved locally using UserDefaults
- **Session Details**: Duration, ambient sound used, date and time
- **History View**: Browse past sessions with detailed information

### 🔔 Notifications & Reminders
- **Completion Notifications**: Get notified when meditation session ends
- **Daily Reminder System**: Set up daily meditation reminders
- **Permission Handling**: Automatic notification permission requests

### 🎨 User Interface
- **Modern Design**: Clean, minimalist interface with smooth animations
- **Dark/Light Mode**: Automatic support for system appearance
- **Haptic Feedback**: Tactile responses for better user experience
- **Accessibility**: Built with accessibility in mind

## Technical Implementation

### Architecture
- **SwiftUI**: Modern declarative UI framework
- **MVVM Pattern**: Clean separation of concerns
- **ObservableObject**: Reactive data binding
- **UserDefaults**: Local data persistence

### Key Components

#### TimerManager
- Manages timer state and countdown logic
- Handles audio playback and notifications
- Controls session lifecycle

#### SessionManager
- Manages meditation session history
- Handles JSON serialization/deserialization
- Provides data persistence

#### ContentView
- Main app interface
- Timer display and controls
- Navigation to settings and history

#### SettingsView
- App configuration options
- Session history management
- Reminder settings

#### HistoryView
- Displays past meditation sessions
- Session details and statistics

## Usage

1. **Select Duration**: Choose your desired meditation length (1-60 minutes)
2. **Choose Ambient Sound**: Select from available ambient sounds or none
3. **Start Session**: Tap the play button to begin
4. **Control Session**: Use pause, resume, or reset as needed
5. **Complete Session**: App automatically tracks completion and saves to history
6. **View History**: Access past sessions through settings
7. **Set Reminders**: Configure daily meditation reminders

## Requirements

- iOS 14.0+
- Xcode 12.0+
- Swift 5.3+

## Installation

1. Clone or download the project
2. Open `ZenTime.xcodeproj` in Xcode
3. Select your target device or simulator
4. Build and run the project

## Audio Implementation

### 🌧️ **Rain Sound Source**
- **Free Rain Sound**: [Freesound.org - Rain on Window](https://freesound.org/people/InspectorJ/sounds/346641/)
- **Duration**: 10 minutes (looped)
- **Quality**: High-quality stereo, 44.1kHz
- **License**: CC0 (completely free to use)
- **Direct Download**: [Rain on Window.mp3](https://freesound.org/data/previews/346/346641_5121236-lq.mp3)

### 📁 **Audio Files Included**
- `rain_sound.mp3` - Gentle rain on window (267KB)
- `brown_noise.mp3` - Soothing brown noise
- `om_tone.mp3` - Traditional meditation om sound

### 🔧 **Audio Features**
- **Automatic Looping**: Ambient sounds loop seamlessly
- **Volume Control**: Set to 30% for background ambiance
- **Audio Session Management**: Proper iOS audio session configuration
- **Background Playback**: Sounds continue during meditation
- **Haptic Feedback**: Tactile responses for start/end bells

## Future Enhancements

- [ ] Custom duration input
- [ ] Multiple ambient sound tracks
- [ ] Guided meditation support
- [ ] Statistics and analytics
- [ ] Apple Watch companion app
- [ ] iCloud sync for sessions
- [ ] Export session data
- [ ] Custom themes and colors

## License

This project is open source and available under the MIT License.

---

**ZenTime** - Find your inner peace, one breath at a time.
