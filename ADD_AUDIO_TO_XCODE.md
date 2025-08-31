# Adding Audio Files to Xcode Project

## 🎵 **Step-by-Step Guide**

### 1. **Clean Up (if you have duplicates)**
If you're getting the "Multiple commands produce" error:
- Close Xcode
- Run: `rm -rf ~/Library/Developer/Xcode/DerivedData/ZenTime-*`
- Remove any duplicate Audio folders

### 2. **Add Audio Files to Xcode**
1. **Open Xcode** and your ZenTime project
2. **Right-click** on the `ZenTime` folder in the project navigator
3. **Select** "Add Files to 'ZenTime'"
4. **Navigate** to `ZenTime/Audio/` folder
5. **Select** all three `.mp3` files:
   - `rain_sound.mp3`
   - `brown_noise.mp3`
   - `om_tone.mp3`
6. **Make sure** these options are checked:
   - ✅ "Add to target: ZenTime"
   - ✅ "Create folder references" (blue folder icon)
7. **Click** "Add"

### 3. **Verify File Structure**
Your project should look like this:
```
ZenTime/
├── ZenTime/
│   ├── ContentView.swift
│   ├── ZenTimeApp.swift
│   ├── Assets.xcassets/
│   └── Audio/          ← Blue folder (folder reference)
│       ├── rain_sound.mp3
│       ├── brown_noise.mp3
│       └── om_tone.mp3
└── ZenTime.xcodeproj/
```

### 4. **Build and Test**
- **Clean Build Folder**: Product → Clean Build Folder
- **Build**: Product → Build
- **Run**: Product → Run

## 🚨 **Common Issues & Solutions**

### **"Multiple commands produce" Error**
- **Cause**: Audio files added twice or in wrong location
- **Solution**: 
  1. Remove all audio files from project
  2. Clean build folder
  3. Re-add files following steps above

### **"File not found" Error**
- **Cause**: Audio files not in app bundle
- **Solution**: Make sure "Add to target: ZenTime" is checked

### **Audio not playing**
- **Cause**: Wrong file names or missing files
- **Solution**: Verify file names match exactly:
  - `rain_sound.mp3`
  - `brown_noise.mp3`
  - `om_tone.mp3`

## 📁 **File Locations**
- **Source**: `ZenTime/Audio/` (in your project)
- **Bundle**: Will be copied to app bundle automatically
- **Code Reference**: `Bundle.main.url(forResource: "rain_sound", withExtension: "mp3")`

## ✅ **Success Indicators**
- No build errors
- Audio files show as blue folders in Xcode
- App runs without crashes
- Rain sound plays when selected
- Console shows "Playing ambient sound: Rain"
