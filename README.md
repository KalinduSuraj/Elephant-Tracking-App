# 🐘 IoT Elephant Protection for Railways

A Flutter mobile application designed to **enhance railway safety** by providing **real-time alerts** and **GPS-based tracking** of elephants detected near railway tracks. Integrated with Firebase services and IoT sensor data to prevent train-elephant collisions and protect both wildlife and transport infrastructure.

---

## 🚀 Features

- **🔒 User Authentication**: Secure login/register using Firebase (email/password).
- **📡 Real-Time Elephant Detection**: Reads detection data from Firebase Realtime Database.
- **🚨 Proximity Alert System**: Warns if an elephant is within 800m and seen within the last 10 minutes.
- **📍 Live GPS Tracking**: Tracks the train's live location using the device GPS.
- **🗺️ Interactive Map**: Displays elephant and train locations on a dynamic map (with live updates).
- **⚙️ Settings Page**: Manage user profile data.
- **🎬 Splash Screen**: Branded loading screen at app launch.

---

## 🛠 Technologies Used

| Technology | Purpose |
|------------|---------|
| **Flutter SDK** | Cross-platform mobile development |
| **Firebase Auth** | Email/password authentication |
| **Firebase Realtime DB** | Real-time data updates from IoT sensors |
| **flutter_map** | Interactive map rendering |
| **latlong2** | Coordinate calculations for mapping |
| **geolocator** | GPS location access |

---

## 📦 Setup Instructions

### ✅ Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Firebase CLI](https://firebase.google.com/docs/cli) (`npm install -g firebase-tools`)
- Android Studio or VS Code with Flutter and Dart plugins

---

### 🧪 1. Clone the Repository

```bash
git clone https://github.com/KalinduSuraj/Elephant-Tracking-App.git
cd Elephant-Tracking-App
```

---

### 🔥 2. Firebase Setup

#### a. Create Firebase Project

- Go to [Firebase Console](https://console.firebase.google.com/)
- Click **Add Project**, follow instructions

#### b. Enable Services

- **Authentication** → Enable **Email/Password**
- **Realtime Database** → Click **Create Database** → Choose locked mode

#### c. Register App(s)

- Add Android/iOS/Web apps
- Download and place:
    - `google-services.json` → `android/app/`
    - `GoogleService-Info.plist` → `ios/Runner/`

#### d. Generate Firebase Config

From root of project:

```bash
flutterfire configure
```

This will generate: `lib/firebase_options.dart`

---

### 📚 3. Add Required Packages

Add to `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^2.x.x
  firebase_auth: ^4.x.x
  firebase_database: ^10.x.x
  flutter_map: ^6.x.x
  latlong2: ^0.9.x
  geolocator: ^11.x.x
```

Then run:

```bash
flutter pub get
```

---

### 🔐 4. Realtime Database Rules

In Firebase Console → Realtime Database → **Rules**:

```json
{
  "rules": {
    "elephant_locations": {
      ".read": "auth != null",
      ".write": "auth != null"
    },
    "train_locations": {
      ".read": "auth != null",
      ".write": "auth != null"
    },
    "$other": {
      ".read": false,
      ".write": false
    }
  }
}
```

Click **Publish**.

---

### 🖼️ 5. Splash Screen Logo

Place your logo at:  
`assets/images/logo2.png`

Then in `pubspec.yaml`:

```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/images/logo2.png
```

Change `Image.network()` in SplashScreen to:

```dart
Image.asset('assets/images/logo2.png')
```

---

### ▶️ 6. Run the App

```bash
flutter run
```

---

## 🧾 Firebase Database Structure

```json
{
  "elephant_locations": {
    "E01": {
      "id": "E01",
      "position": {
        "lat": 7.8850,
        "lng": 80.7800
      },
      "timestamp":"2025/06/22 19:24:59"
    }
  },
  "users": {
    "wXTRKD54GIWAFlIOiCNjzPWVZNj2": {
      "email": "admin@test.com",
      "name": "driver",
      "role": "admin"
    },
    "ylKqaf4W4jWxX0KkepdWlUQJiqw1":{
      "email": "driver@gmail.com",
      "name": "driver",
      "role": "driver"
    }
  }

}
```

> `timestamp` must be in **milliseconds since epoch**  
> Your app reads this to trigger proximity alerts

---

## 🧭 App Usage

1. Launch app → Splash screen appears
2. Login/Register with Firebase Auth
3. HomeScreen shows:
    - Live GPS location
    - Count of nearby elephants
    - Red warning if elephant is within 800m and 10 min
4. Map View → Shows markers for train + elephants
5. Settings → Edit user info

---

## 🤝 Contributing

Fork the repository, make changes, and submit a pull request.  
All contributions are welcome!

---

> Created with ❤️ by Kalindu Suraj
