# LifeLine - Victim Mobile Application

## 🚨 About LifeLine

LifeLine is a disaster relief and emergency response system designed to
improve communication and coordination between **victims, rescuers,
NGOs, and administrators** during emergencies such as earthquakes,
floods, landslides, accidents, and other critical situations.

This repository contains the **Victim Mobile Application**, which is the
victim-facing component of the complete LifeLine system.

The victim application allows a person in an emergency to:

-   Create and authenticate an account.
-   Maintain personal/profile information.
-   Send an emergency **SOS** request.
-   Share and continuously update their GPS location.
-   View their location and responder locations on an interactive map.
-   Receive real-time rescue/status updates.
-   Obtain AI-assisted first-aid and emergency guidance.
-   Monitor rainfall/weather information.
-   Receive nearby earthquake information.
-   Communicate with rescuers/NGOs through real-time chat.
-   Use voice/video communication where supported.
-   Handle network interruptions through offline data handling and
    synchronization.

The overall LifeLine system integrates the victim application with
separate responder, NGO, and administrator applications.

------------------------------------------------------------------------

## 🎯 Objectives

The main objectives of the victim application are:

1.  **Reduce communication delays** during emergencies.
2.  **Transmit the victim's location** accurately to responders.
3.  **Provide a quick SOS mechanism** for requesting assistance.
4.  **Provide first-aid and safety guidance** while professional help is
    being arranged.
5.  **Provide environmental awareness** through weather/rain and
    earthquake information.
6.  **Enable direct communication** between victims and responders.
7.  **Support emergency operation during unstable connectivity** through
    local/offline handling.
8.  Provide a simple and accessible interface that can be used quickly
    during stressful situations.

------------------------------------------------------------------------

# 🧩 Victim Application Modules

The victim application is organized around the following functional
modules.

## 1. 🔐 Authentication & Account Module

Provides secure user access to the LifeLine system.

### Features

-   Google-based authentication.
-   User registration/sign-in.
-   Authentication validation.
-   Login/sign-up error handling.
-   Session persistence.
-   Role-aware access to the LifeLine platform.

------------------------------------------------------------------------

## 2. 👤 Victim Profile & Medical Information Module

Allows the victim to maintain information that can help responders
understand their situation.

### Features

-   Victim profile creation.
-   Personal information management.
-   Profile picture.
-   About/profile information.
-   Medical information associated with the victim profile.

------------------------------------------------------------------------

## 3. 🆘 SOS Emergency Broadcast Module

The core emergency-request module of the victim application.

### Features

-   Emergency SOS action.
-   Automatic retrieval of the victim's current GPS coordinates.
-   Emergency request generation.
-   Location attached to the SOS request.
-   Broadcast of the emergency request to the responder/NGO side.
-   Emergency request synchronization through the cloud backend.
-   Local handling of an SOS request when connectivity is unavailable,
    followed by synchronization when connectivity is restored.

------------------------------------------------------------------------

## 4. 📍 Real-Time GPS Location Tracking Module

Provides continuous location information during an emergency.

### Features

-   Device GPS access.
-   Current latitude and longitude retrieval.
-   Location updates during an active emergency.
-   Location synchronization with the backend.
-   Location visualization on the map.
-   Local queuing of location updates during connectivity interruptions.
-   Synchronization after the network becomes available.

The project report describes a real-time tracking algorithm that avoids
unnecessary updates and synchronizes queued location information when
connectivity is restored.

------------------------------------------------------------------------

## 5. 🗺️ Map & Navigation Module

Provides an interactive map for emergency-response awareness.

### Features

-   Interactive map.
-   Victim location.
-   Responder location where available.
-   Emergency/rescue locations.
-   Location markers.
-   Route/polyline support.
-   Location visualization during rescue operations.

> **Repository implementation note:** the current repository declares
> `flutter_map` and `latlong2` for map functionality and identifies the
> map implementation as OpenStreetMap in `pubspec.yaml`.

------------------------------------------------------------------------

## 6. 🤖 AI First-Aid & Emergency Guidance Module

Provides AI-assisted emergency guidance to victims.

### Features

-   Emergency guidance chatbot.
-   First-aid assistance.
-   Safety guidance.
-   Natural-language user queries.
-   Llama-based AI assistance through the project's AI service.
-   Offline fallback information stored locally for situations where
    network access is unavailable.

The project report specifies **GroqCloud with the Llama model** for
online AI guidance and a locally stored fallback for offline assistance.

> **Important:** AI guidance is an assistance feature and must not be
> treated as a replacement for professional emergency services or
> qualified medical advice.

------------------------------------------------------------------------

## 7. 🌧️ Weather & Rain Intensity Monitoring Module

Provides environmental information relevant to emergency conditions.

### Features

-   Current weather information.
-   Rain-intensity monitoring.
-   Location-based weather retrieval.
-   Flood-risk awareness based on rainfall information.

The project uses the **Open-Meteo Weather API** for weather and rainfall
information.

------------------------------------------------------------------------

## 8. 🌎 Earthquake Monitoring Module

Provides earthquake information relevant to the victim's location.

### Features

-   Retrieval of earthquake information from the USGS service.
-   Location-based earthquake monitoring.
-   Monitoring of earthquakes within the project's defined **300 km**
    range.
-   Recent earthquake information.
-   Earthquake-related emergency awareness.

------------------------------------------------------------------------

## 9. 💬 Real-Time Communication Module

Allows victims to communicate with rescuers and NGOs during an active
emergency.

### Features

-   One-to-one text communication.
-   Group chat support where available.
-   Real-time message exchange.
-   Emergency-related information sharing.
-   Media messaging support.
-   Communication with assigned responders.

------------------------------------------------------------------------

## 10. 📞 Voice & Video Calling Module

Provides direct audio/video communication between the victim and
responder.

### Features

-   Voice calling.
-   Video calling.
-   Incoming call handling.
-   Real-time communication using the project's WebRTC/Jitsi
    integration.
-   Call interface for emergency coordination.

------------------------------------------------------------------------

## 11. 📡 Offline & Connectivity Bridge Module

Designed for situations where network availability changes during an
emergency.

### Features

-   Internet connectivity monitoring.
-   Detection of network state changes.
-   Local storage/queuing of important information.
-   Queuing of location updates.
-   Queuing/handling of emergency information.
-   Synchronization with cloud services after connectivity is restored.
-   Direct dialing/SMS-related fallback capabilities where supported by
    the implementation.

------------------------------------------------------------------------

# 🛠️ Technology Stack

## Frontend / Mobile

-   **Flutter**
-   **Dart**
-   **Flutter Riverpod**

## Authentication & Cloud Backend

-   **Firebase Core**
-   **Firebase Authentication**
-   **Cloud Firestore**
-   **Google Sign-In**

## Location

-   **Geolocator**
-   **Geocoding**

## Maps

-   **Flutter Map**
-   **LatLong2**
-   **OpenStreetMap-based map implementation**

## Communication

-   **Jitsi Meet Flutter SDK**
-   **Connectivity Plus**
-   **Direct Dialer**
-   **Speech to Text**

## Emergency & External Services

-   **Open-Meteo Weather API**
-   **USGS Earthquake API**
-   **AI service using the project's Groq/Llama integration**
-   **HTTP**
-   **Flutter Polyline Points**

## Configuration & Build

-   **Envied**
-   **Envied Generator**
-   **Build Runner**
-   **Flutter Launcher Icons**

------------------------------------------------------------------------

# 📦 Dependencies

The current `pubspec.yaml` defines the following major dependencies:

``` yaml
cloud_firestore
firebase_core
geolocator
geocoding
flutter_riverpod
firebase_auth
google_sign_in
connectivity_plus
direct_dialer
speech_to_text
jitsi_meet_flutter_sdk
envied
latlong2
flutter_map
http
flutter_polyline_points
```

Development tooling includes:

``` yaml
flutter_test
flutter_lints
envied_generator
build_runner
flutter_launcher_icons
```

For the authoritative dependency versions, always refer to the
repository's `pubspec.yaml`.

------------------------------------------------------------------------

# ⚙️ Requirements

Before running the project, install:

-   Flutter SDK
-   Dart SDK compatible with the project's declared SDK constraint
-   Android Studio for Android development
-   Xcode for iOS development (macOS required)
-   Android SDK / emulator or a physical Android device
-   Xcode simulator or physical iOS device for iOS testing
-   A configured Firebase project
-   Required API/service credentials used by the application

The current repository declares the Dart SDK constraint:

``` text
>=3.7.0 <4.0.0
```

Check your local environment with:

``` bash
flutter doctor
```

------------------------------------------------------------------------

# 🚀 Installation & Setup

## 1. Clone the Repository

``` bash
git clone https://github.com/StorageArea483/LifeLine_Victim.git
```

``` bash
cd LifeLine_Victim
```

## 2. Install Flutter Dependencies

``` bash
flutter pub get
```

## 3. Configure Firebase

The project contains:

``` text
lib/firebase_options.dart
firebase.json
```

Make sure the Firebase configuration used by your local build
corresponds to the intended LifeLine Firebase project.

Required Firebase services for the victim application include:

-   Firebase Authentication
-   Google Sign-In
-   Cloud Firestore

## 4. Configure Environment Variables / Secrets

The project uses **Envied** for environment configuration.

Do **not** commit private API keys, service credentials, tokens, or
other secrets to GitHub.

Configure the required environment values according to the
environment/configuration classes used by the source code, then generate
the required Envied files using the project's build configuration.

Typical command:

``` bash
dart run build_runner build --delete-conflicting-outputs
```

> Use the exact environment variable names expected by the current
> source code. Do not invent or rename keys without updating the
> corresponding configuration classes.

## 5. Verify Connected Device

``` bash
flutter devices
```

## 6. Run the Application

``` bash
flutter run
```

For a specific device:

``` bash
flutter run -d <device-id>
```

------------------------------------------------------------------------

# 🔑 Required Permissions

Because the application uses emergency and communication functionality,
the Android/iOS project may require permissions for services such as:

-   Location/GPS
-   Internet/network access
-   Microphone
-   Camera
-   Notifications
-   Phone/dialer functionality
-   Speech recognition

Permissions should be reviewed in the platform-specific configuration
before deployment.

------------------------------------------------------------------------

# 🧪 Testing

The LifeLine project was tested across authentication, SOS broadcasting,
AI guidance, location tracking, environmental monitoring, communication,
and complete emergency workflows.

The project report documents:

-   System testing
-   Unit testing
-   Functional testing
-   Integration testing
-   Automated testing

------------------------------------------------------------------------

# 🔒 Security & Privacy

LifeLine is designed to protect user and emergency information.

Security considerations include:

-   Authenticated access.
-   Role-based authorization.
-   Cloud database security rules.
-   Protected environment configuration.
-   Avoiding hard-coded API secrets.
-   Secure communication mechanisms.
-   Controlled access to victim location and profile information.

### Important

Never commit files containing private credentials or secrets, including:

``` text
.env
private API keys
service-account credentials
private tokens
private signing credentials
```

Review `.gitignore` and the repository history before the final FYP
submission.

------------------------------------------------------------------------

# 📱 Supported Platforms

The project is designed as a cross-platform Flutter mobile application
for:

-   ✅ Android
-   ✅ iOS

Platform-specific files are maintained under:

``` text
android/
ios/
```

------------------------------------------------------------------------

# 📚 Project Documentation

The complete FYP report covers:

-   Introduction and project background
-   Problem definition
-   Requirement analysis
-   Use cases
-   Functional and non-functional requirements
-   System architecture
-   Data representation
-   Process flow
-   Class and sequence diagrams
-   Algorithms
-   External APIs
-   User interface
-   Implementation
-   Testing and evaluation
-   Conclusion and future work

The repository should be considered together with the final FYP report
for complete project documentation.

------------------------------------------------------------------------

# ⚠️ Emergency & Medical Disclaimer

LifeLine's AI guidance and emergency information features are intended
as **supporting information** while professional assistance is being
arranged.

They are not a substitute for qualified medical professionals, emergency
services, or official emergency instructions.

In a real emergency, users should contact the appropriate local
emergency services whenever possible.

------------------------------------------------------------------------

# 👨‍💻 Developers

**Daniyal Mushtaq**\
BS Computer Science --- COMSATS University Islamabad, Abbottabad Campus

**Aryan Sajid**\
BS Computer Science --- COMSATS University Islamabad, Abbottabad Campus

**Supervisor:** Ms. Aatikah Rasool

------------------------------------------------------------------------

# 🎓 Final Year Project

**LifeLine -- A Disaster Relief & Emergency Response App**

Bachelor of Science in Computer Science\
COMSATS University Islamabad, Abbottabad Campus\
Academic Session **2022--2026**\
**Final Year Project -- Spring 2026**

------------------------------------------------------------------------

## 📄 License

This repository is an academic Final Year Project repository. Unless a
separate license file is added to the repository, the project should be
treated as an academic submission rather than as a separately licensed
open-source package.

------------------------------------------------------------------------
