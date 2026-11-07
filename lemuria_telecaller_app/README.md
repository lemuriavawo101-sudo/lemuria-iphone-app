# 📱 Lemuria Telecaller Mobile App (Flutter for Android & iOS)

Cross-platform mobile application built with **Flutter** for Lemuria Varmam Clinic telecallers. Provides **Mandatory In-App Dual Voice Call Recording** over Mobile Data / Wi-Fi, real-time lead queue management, and 1-click WhatsApp appointment confirmations.

---

## 🏛️ System Architecture

```
[Flutter Mobile App (iOS / Android)]
       │
       ├── In-App Softphone (Data / Wi-Fi Voice Stream)
       │       └── Mandatory Audio Recorder (Microphone + Speaker)
       │
       ├── Authenticated via Mobile JWT (Bearer Token)
       │
       ▼ (HTTPS REST API)
[Lemuria Server (https://dev.lemuriavawo.org)]
       │
       ├── /api/mobile/login (PIN Auth for Reps)
       ├── /api/mobile/leads (Live Queue & Hot Leads)
       ├── /api/mobile/call/start (Call Session Lock)
       ├── /api/mobile/call/upload-recording (Saves WAV to /data/telecaller-recordings/)
       ├── /api/mobile/lead/disposition (Slot Locking & Outcome Tracking)
       └── /api/mobile/whatsapp/send-action (Dispatches Google Maps Pin / Booking via Evolution API)
```

---

## 🛡️ Mandatory Recording Enforcement (Anti-Bypass Gate)

1. **Automatic Trigger**: When the telecaller taps **Call Patient**, `MandatoryRecorderService` starts audio capture immediately upon connect.
2. **No Disable Option**: There is **no "Stop Recording" button** in the UI. Telecallers cannot mute or turn off compliance recording.
3. **Hardware & App Store Compliance**:
   - **iOS (Apple)**: Uses official `AVAudioEngine` and `NSMicrophoneUsageDescription`. 100% compliant with Apple App Review Guidelines.
   - **Android**: Uses standard `android.permission.RECORD_AUDIO`. Zero reliance on banned accessibility hacks.
4. **Post-Call Lock**: When the call ends, the screen locks with `Encrypting & Uploading Recording...`. Telecallers **cannot** move to the next lead until the audio WAV is uploaded and verified by the server.

---

## 👥 Pre-Configured Telecaller Logins

| Telecaller | Username | Security PIN | Assigned Line | Role |
| :--- | :--- | :--- | :--- | :--- |
| **Sudha** | `sudha` | `3210` | Line 02 (+91 80562 94950) | Senior Varmam Health Telecaller |
| **Aravind** | `aravind` | `1234` | Line 01 (Inbound Sales) | Varmam Therapy Advisor |
| **Clinic Manager** | `admin` | `9999` | Admin Master Line | Super Administrator |

---

## 🚀 How to Run & Build

### 1. Requirements
- Flutter SDK 3.x+
- Android Studio / Xcode
- CocoaPods (for iOS build)

### 2. Install Dependencies
```bash
cd lemuria_telecaller_app
flutter pub get
```

### 3. Run on Device / Simulator
```bash
# Android Device / Emulator
flutter run -d android

# iPhone / iOS Simulator
flutter run -d ios
```

### 4. Build Release Packages
```bash
# Generate Android APK for telecaller distribution
flutter build apk --release

# Generate iOS Archive for TestFlight / App Store
flutter build ipa --release
```

---

## 📁 Project Structure

```
lemuria_telecaller_app/
├── lib/
│   ├── main.dart                      # App entry point & orientation lock
│   ├── theme/
│   │   └── app_theme.dart             # Lemuria Luxury White & Gold styling
│   ├── models/
│   │   ├── lead_model.dart            # Lead attributes & pain symptoms
│   │   └── telecaller_model.dart      # Rep profile & assigned line
│   ├── services/
│   │   ├── api_service.dart           # Connects to https://dev.lemuriavawo.org
│   │   └── mandatory_recorder_service.dart # Enforces dual-channel call recording & upload
│   └── screens/
│       ├── login_screen.dart          # Telecaller PIN login
│       ├── lead_queue_screen.dart     # Assigned queue & hot lead filters
│       ├── lead_detail_screen.dart    # Full symptoms & WhatsApp history
│       ├── in_app_dialer_screen.dart  # In-app dialer with mandatory recording badge
│       └── disposition_screen.dart    # Outcome tagging, slot lock & WhatsApp handoff
├── android/app/src/main/AndroidManifest.xml # Android permissions
└── ios/Runner/Info.plist              # iOS microphone & background audio configs
```

