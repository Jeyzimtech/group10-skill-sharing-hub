# Skills Sharing Hub

Skills Sharing Hub is a premium, all-in-one platform designed to connect expert tutors with eager students. Whether you want to master a new programming language, pick up a musical instrument, or learn advanced business strategy, Skills Sharing Hub provides the tools to make knowledge exchange seamless, interactive, and personalized.

---

## Key Features

### Funda Mwana AI Tutor
- **Your 24/7 Study Buddy**: Powered by advanced AI (OpenRouter/Owl-Alpha), Funda Mwana is always online to answer questions, explain complex concepts, and guide your learning journey.
- **Context-Aware Chat**: Remembers your conversation to provide tailored educational support.

### Real-Time Video Calling
- **Integrated Video Sessions**: Powered by Agora, start high-quality video calls directly from your chat or scheduled sessions.
- **Dual-View & Controls**: Seamlessly switch cameras, mute audio, and experience crystal-clear tutoring sessions from anywhere in the world.

### Smart Messaging System
- **Real-Time Communication**: Built on Firebase Firestore for instant message delivery.
- **Session Notifications**: Automatic chat updates when video sessions are initiated, ensuring you never miss a call.

### Dynamic Dashboard
- **Personalized Recommendations**: Discover featured tutors and popular skill categories.
- **Flexible Scheduling**: Manage your upcoming sessions and track your learning progress in a sleek, dark-mode optimized interface.

---

## Technology Stack

- **Framework**: [Flutter](https://flutter.dev/) (Cross-platform Mobile Development)
- **Backend**: [Firebase](https://firebase.google.com/) (Auth, Firestore, Hosting)
- **Video Infrastructure**: [Agora RTC](https://www.agora.io/en/)
- **AI Integration**: [OpenRouter API](https://openrouter.ai/) (Owl-Alpha Model)
- **Image Hosting**: [Cloudinary](https://cloudinary.com/)

---

## Getting Started

### Prerequisites
- Flutter SDK (latest version)
- Android Studio / VS Code
- Firebase Project configured for Android/iOS

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Jeyzimtech/group10-skill-sharing-hub.git
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure Environment:**
   Create a file at `lib/config_keys.dart` (this file is gitignored for security) and add your keys:
   ```dart
   class ConfigKeys {
     static const String openRouterApiKey = "YOUR_OPENROUTER_KEY";
     static const String agoraAppId = "YOUR_AGORA_APP_ID";
   }
   ```

4. **Run the application:**
   ```bash
   flutter run
   ```

---

## Visuals

| Feature | Description |
|---------|-------------|
| **AI Tutor** | Premium floating robot assistant for instant access. |
| **Video Call** | Local and Remote video previews with low-latency. |
| **Modern UI** | Sleek dark-mode aesthetic with Glassmorphism accents. |

---

## License
This project is part of the Skills Sharing Hub initiative. All rights reserved.

---

## Contributors
Developed by the Skills Sharing Hub Team NUST Students
