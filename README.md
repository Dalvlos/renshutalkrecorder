# RenshuTalkRecorder

RenshuTalkRecorder is an iOS application that allows users to type a sentence and record an audio corresponding to their reading of that sentence. It's a great tool for practicing pronunciation, associating sentences while studying a new language, or even for personal recordings!

## Features

- Type a sentence in the text field
- Record your reading of the sentence with a single tap
- Play back the recorded audio to compare and practice
- Save multiple sentences and audio recordings (in development)

## Prerequisites

- Xcode 15 or higher
- iOS 16.0+
- Swift 5.0+
- Microphone permissions enabled

## How to Run the App

1. Clone this repository:
   ```sh
   git clone https://github.com/Dalvlos/renshutalkrecorder.git
   ```
2. Open the project in Xcode (`.xcodeproj` or `.xcworkspace`)
3. Connect a physical device or use the simulator
4. Build and run the app (Cmd + R)
5. Allow microphone access when prompted
6. To fully test microphone functionality, a physical iPhone device is required

## Project Structure

- `ViewController.swift`: Main screen for typing sentences and recording/listening to audio
- `AudioManager.swift`: Logic for audio recording and playback (AVFoundation)
- `Models/`: Data models (future)
- `Resources/`: Assets and auxiliary files

## Technologies

- Swift
- SwiftUI
- AVFoundation for audio

## Future Improvements

- List and manage saved sentences/audio
- Share recordings
- History of practice sessions

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.
