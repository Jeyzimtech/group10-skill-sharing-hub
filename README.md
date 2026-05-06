# Skills Sharing Hub

Official Repository: [https://github.com/Jeyzimtech/group10-skill-sharing-hub.git](https://github.com/Jeyzimtech/group10-skill-sharing-hub.git)

Skills Sharing Hub is a premium, all-in-one platform designed to connect expert tutors with eager students. Whether you want to master a new programming language, pick up a musical instrument, or learn advanced business strategy, Skills Sharing Hub provides the tools to make knowledge exchange seamless, interactive, and personalized.

---

## Key Features

### Funda Mwana AI Tutor
- **AI Study Buddy**: Powered by advanced AI (OpenRouter/Owl-Alpha), providing 24/7 educational support and concept explanations.
- **Floating Robot Interface**: A dedicated AI assistant button accessible from anywhere in the app for instant help.
- **Contextual Learning**: Tailored responses based on student queries to help master complex skills.

### Real-Time Video Calling
- **Integrated Video Sessions**: Built on Agora RTC, allowing seamless face-to-face tutoring sessions.
- **Dual-View Support**: View both local and remote video streams with high quality and low latency.
- **Call Controls**: One-tap camera switching, microphone muting, and instant call termination.

### Smart Messaging System
- **Real-Time Communication**: Instant message delivery powered by Firebase Firestore.
- **Channel Synchronization**: Deterministic chat ID generation ensures both users are always in the same conversation.
- **System Notifications**: Automatic alerts in chat when a tutor or student initiates a video session.

### Skill Discovery & Management
- **Search & Filtering**: Find tutors by skill name or category (Programming, Design, Music, etc.) with a powerful search bar.
- **Featured Tutors**: Discover top-rated experts on the home dashboard.
- **Skill Posting**: Users can easily list their own skills and become tutors to share knowledge with the community.

### Tutor & User Profiles
- **Rich Profiles**: Detailed tutor pages showcasing skills, bios, and ratings.
- **Review System**: Students can leave ratings and feedback for tutors to build community trust.
- **Become a Tutor**: One-click transition for students to start offering their own expertise.

### Premium Experience
- **Modern UI/UX**: Sleek dark-mode aesthetic with vibrant teal accents and professional typography.
- **Responsive Layouts**: Optimized for mobile and tablet devices using a custom Responsive framework.
- **Glassmorphism Design**: Elegant translucent elements for a high-end, futuristic feel.

### Security & Privacy
- **Secure Key Management**: API keys are isolated and excluded from version control to prevent leaks.
- **Firebase Authentication**: Robust user login and registration flow for secure data access.
- **Firestore Security Rules**: Protected database access to ensure user data privacy.

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
Developed by the Skills Sharing Hub Team.
