# MediMate AI - AI-powered Medication Management App

MediMate AI is a comprehensive cross-platform mobile application built with Flutter that helps users manage medication schedules, track expiry dates, and interact with an AI-powered chatbot for medicine-related guidance.

## 🚀 Features

### Core Functionality
- **Medication Reminder System**: Set daily, weekly, or custom interval reminders
- **Medicine Expiry Tracking**: Monitor expiry dates with smart categorization (Safe, Expiring Soon, Expired)
- **AI-Powered Chat Assistant**: Get medication advice and help via natural language conversation
- **User Authentication**: Secure Firebase-based authentication system
- **Offline Support**: Local data storage with SQLite for offline functionality

### ML & AI Integration
- **OCR Medicine Label Recognition**: Extract medicine information from images using Tesseract + OpenCV
- **Smart Reminder Prediction**: LSTM/Logistic Regression models to predict missed doses
- **Personalized AI Responses**: OpenAI GPT integration for intelligent medication guidance
- **Adherence Pattern Analysis**: ML-powered insights into medication compliance

### User Experience
- **Modern Material Design**: Clean, intuitive interface following Material Design principles
- **Real-time Notifications**: Push notifications and local alerts for medication reminders
- **Cross-platform**: Works seamlessly on both iOS and Android
- **Responsive Design**: Optimized for various screen sizes and orientations

## 🛠️ Tech Stack

### Frontend
- **Flutter**: Cross-platform mobile development framework
- **Dart**: Programming language
- **Provider**: State management solution

### Backend & Services
- **Firebase**: Authentication, Firestore database, Cloud Messaging
- **Firebase ML Kit**: On-device machine learning capabilities

### Machine Learning
- **Tesseract OCR**: Text extraction from medicine images
- **OpenCV**: Image preprocessing and enhancement
- **TensorFlow Lite**: On-device ML model inference
- **OpenAI GPT API**: Natural language processing for AI chat

### Database
- **Firebase Firestore**: Cloud database for real-time synchronization
- **SQLite**: Local database for offline functionality

## 📱 Screenshots

The app includes the following main screens:
- **Splash Screen**: App introduction and loading
- **Authentication**: Login and signup screens
- **Home Screen**: Dashboard with quick access cards
- **Reminders**: Medication schedule management
- **History**: Medication adherence tracking
- **Expiry Tracker**: Medicine expiry monitoring
- **AI Chat**: Intelligent medication assistance
- **Profile**: User settings and information

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio / Xcode
- Firebase project setup
- OpenAI API key (optional, for enhanced AI features)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/medimate-ai.git
   cd medimate-ai
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Enable Authentication, Firestore, Cloud Messaging, and Storage
   - Download `google-services.json` for Android and `GoogleService-Info.plist` for iOS
   - Place them in the respective platform directories

4. **Configure Firebase**
   - Update Firebase configuration in `lib/main.dart`
   - Configure Firestore security rules
   - Set up Cloud Messaging for notifications

5. **OpenAI API Setup (Optional)**
   - Get an API key from [OpenAI](https://platform.openai.com/)
   - Update the API key in `lib/services/ai_service.dart`

6. **Platform-specific Setup**

   **Android:**
   - Ensure `google-services.json` is in `android/app/`
   - Update `android/app/build.gradle` if needed
   - Set minimum SDK version to 21

   **iOS:**
   - Ensure `GoogleService-Info.plist` is in `ios/Runner/`
   - Update bundle identifier in Xcode
   - Configure signing and capabilities

### Building the App

1. **Debug Build**
   ```bash
   flutter run
   ```

2. **Release Build - Android**
   ```bash
   flutter build apk --release
   ```

3. **Release Build - iOS**
   ```bash
   flutter build ios --release
   ```

## 🔧 Configuration

### Environment Variables
Create a `.env` file in the root directory:
```env
OPENAI_API_KEY=your_openai_api_key_here
FIREBASE_PROJECT_ID=your_firebase_project_id
```

### Firebase Configuration
Update `lib/firebase_options.dart` with your Firebase project settings:
```dart
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: 'your-api-key',
      appId: 'your-app-id',
      messagingSenderId: 'your-sender-id',
      projectId: 'your-project-id',
      // ... other configuration
    );
  }
}
```

## 📊 ML Models

### OCR Pipeline
- **Image Preprocessing**: OpenCV for noise reduction and enhancement
- **Text Extraction**: Tesseract OCR for medicine label reading
- **Data Parsing**: Custom algorithms for expiry date and medicine name extraction

### Reminder Prediction
- **Feature Engineering**: Time patterns, medicine types, user behavior
- **Model Training**: LSTM networks for sequence prediction
- **Real-time Inference**: On-device model execution for privacy

### AI Chat
- **Natural Language Processing**: OpenAI GPT integration
- **Context Awareness**: Medicine-specific knowledge base
- **Fallback Responses**: Predefined responses when API unavailable

## 🔒 Security & Privacy

- **Data Encryption**: All sensitive health data encrypted at rest
- **Local Processing**: ML models run on-device for privacy
- **Secure Authentication**: Firebase Auth with email/password
- **Permission Management**: Granular access control for device features

## 🧪 Testing

### Unit Tests
```bash
flutter test
```

### Integration Tests
```bash
flutter test integration_test/
```

### Widget Tests
```bash
flutter test test/widget_test.dart
```

## 📦 Deployment

### Android
1. Generate signed APK:
   ```bash
   flutter build apk --release
   ```
2. Test on various devices
3. Upload to Google Play Store

### iOS
1. Build for release:
   ```bash
   flutter build ios --release
   ```
2. Archive in Xcode
3. Upload to App Store Connect

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- **Documentation**: Check the [Wiki](../../wiki) for detailed guides
- **Issues**: Report bugs and feature requests via [GitHub Issues](../../issues)
- **Discussions**: Join community discussions in [GitHub Discussions](../../discussions)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- OpenAI for AI capabilities
- OpenCV and Tesseract communities
- All contributors and beta testers

## 📈 Roadmap

- [ ] Voice input for AI chat
- [ ] Barcode scanning for medicines
- [ ] Family member management
- [ ] Integration with healthcare providers
- [ ] Advanced analytics dashboard
- [ ] Wearable device integration
- [ ] Multi-language support

---

**Note**: This app is for educational and demonstration purposes. Always consult healthcare professionals for medical advice.
