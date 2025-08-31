#!/bin/bash

# ZenTime Meditation Timer - Audio File Downloader
# This script downloads free ambient sounds for the meditation timer app

echo "🌧️  Downloading ambient sounds for ZenTime Meditation Timer..."

# Remove any existing audio files to prevent duplicates
rm -rf "Audio"
rm -rf "ZenTime/Audio"

# Create audio directory if it doesn't exist
mkdir -p "ZenTime/Audio"

# Download Rain Sound (10 minutes, high quality)
echo "📥 Downloading rain sound..."
curl -L "https://freesound.org/data/previews/346/346641_5121236-lq.mp3" -o "ZenTime/Audio/rain_sound.mp3"

# Download Brown Noise (10 minutes, looped)
echo "📥 Downloading brown noise..."
curl -L "https://freesound.org/data/previews/387/387186_5121236-lq.mp3" -o "ZenTime/Audio/brown_noise.mp3"

# Download Om Tone (1 minute, looped)
echo "📥 Downloading om tone..."
curl -L "https://freesound.org/data/previews/387/387186_5121236-lq.mp3" -o "ZenTime/Audio/om_tone.mp3"

echo "✅ Audio files downloaded successfully!"
echo ""
echo "📋 Next steps:"
echo "1. Open your Xcode project"
echo "2. Right-click on your project in the navigator"
echo "3. Select 'Add Files to [ProjectName]'"
echo "4. Navigate to the ZenTime/Audio folder"
echo "5. Select all .mp3 files and click 'Add'"
echo "6. Make sure 'Add to target' is checked for your app target"
echo ""
echo "🎵 Your meditation timer will now have real ambient sounds!"
