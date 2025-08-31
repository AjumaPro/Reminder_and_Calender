# Alarm Sounds

This directory contains alarm sound files for the timer functionality.

## Files:

### alarm.mp3 (Custom Alarm)
- **Purpose**: Custom alarm sound for timer completion
- **Format**: MP3
- **Size**: Keep under 1MB for better performance
- **Usage**: Primary alarm sound for work/break session completion

### system_alarm.mp3 (System Fallback)
- **Purpose**: Fallback alarm sound when custom alarm is not available
- **Format**: MP3
- **Usage**: Automatic fallback if custom alarm fails to load

## How to add custom alarm sounds:

### Option 1: Replace existing files
1. Copy your MP3 file to this directory
2. Rename it to `alarm.mp3` (replaces the current file)
3. The app will automatically use this file for alarms

### Option 2: Add new alarm sounds
1. Copy your MP3 files to this directory
2. Update the `AlarmService` to reference your new files
3. Ensure files are properly referenced in `pubspec.yaml`

## Fallback System:
If no alarm sounds are available, the app will use:
1. **Haptic Feedback**: Vibration patterns on supported devices
2. **Visual Indicators**: Flashing UI elements
3. **System Notifications**: Platform-specific alerts

## Requirements:
- **Format**: MP3 (recommended) or other audio formats supported by audioplayers
- **Duration**: 3-10 seconds recommended
- **Quality**: 128kbps or higher for good audio quality
- **Size**: Under 1MB for optimal performance

## Testing:
To test alarm sounds:
1. Start a Pomodoro timer
2. Wait for it to complete
3. The alarm should play automatically
4. Use the "Stop Alarm" button to silence it

## Troubleshooting:
- If alarms don't play, check file permissions
- Ensure audio files are properly formatted
- Verify `audioplayers` dependency is included in `pubspec.yaml`
- Check device volume settings 