# Nongki Yuk! 🍹

*An App to Discover South Jakarta's Most Popular Hangout Spots*

## 📱 Description

**Nongki Yuk!** is a mobile app prototype built with a *user-centered design* approach to help users find trending hangout spots in South Jakarta based on **crowd level predictions**.

## 🎥 Demo Videos
[**Click to watch Demo**](https://drive.google.com/file/d/1tH0YyKVUPMJL93QOug0T48VASNI3x0Le/view?usp=sharing)

## 📱 Features

### 🏠 Core Features
- **Place Discovery**: Browse and search for popular hangout spots in South Jakarta
- **Real-time Crowd Monitoring**: View current crowd levels with **Comfy**, **Normal (Sedang)**, **Crowded** labels
- **Interactive Reviews**: Read and write reviews with photos and videos
- **Navigation Integration**: Direct integration with Google Maps for directions
- **Favorites System**: Bookmark and manage your favorite places with bookmark icons
- **Recent Places**: Track places you've recently visited
- **Advanced Search**: Filter places by rating, distance, and crowd level
- **Media Upload**: Support for photos and videos in reviews
  
### 🎨 User Interface
- **Modern Design**: Clean and intuitive Material Design interface
- **Dark/Light Theme**: Support for both light and dark themes with automatic switching
- **Responsive Layout**: Optimized for various screen sizes and orientations
- **Smooth Animations**: Enhanced user experience with fluid transitions
- **Custom Icons**: Bookmark icons for favorites, consistent color scheme

### 🔐 Authentication & Security
- **Firebase Authentication**: Secure user registration and login
- **Profile Management**: User profiles with customizable settings
- **Data Privacy**: Secure handling of user data and preferences
- **Session Management**: Automatic login state persistence

### 📍 Location Services
- **GPS Integration**: Real-time location-based recommendations
- **Distance Calculation**: Shows distance from user's current location
- **Map Integration**: Seamless navigation to selected places
- **Location Permissions**: Proper handling of location access

### 🔔 Notifications
- **Label Change Alerts**: Notifications when place crowd levels change
- **Review Updates**: Real-time updates for new reviews
- **Custom Notifications**: Beautiful notification design with actions

## 📱 App Screenshots

### Main Features
- **Home Page**: Discover popular places with search functionality and filters
- **Place Details**: Comprehensive information with reviews, photos, and navigation
- **Favorites**: Manage your bookmarked places with bookmark icons
- **Profile**: User settings and preferences with theme switching
- **Reviews**: Interactive review system with media upload support
- **Navigation**: Seamless integration with Google Maps

### Navigation Flow
1. **Landing Page** → User onboarding and app introduction
2. **Authentication** → Login/Signup with Firebase Auth
3. **Home Page** → Browse places with search and filters
4. **Place Details** → View comprehensive information and reviews
5. **Reviews** → Read/write reviews with media upload
6. **Navigation** → Open in Google Maps with directions
7. **Favorites** → Manage bookmarked places
   
---

## 🛠️ Technology Stack

### Frontend (Flutter)
- **Framework**: Flutter 3.7.0+
- **State Management**: Provider pattern with ChangeNotifier
- **UI Components**: Material Design 3 with custom theming
- **Navigation**: Flutter Navigator 2.0 with route guards
- **Media Handling**: Image and video picker with preview

### Backend & Services
- **Database**: Firebase Firestore (NoSQL)
- **Authentication**: Firebase Auth (Email/Password)
- **Storage**: Firebase Storage (for media uploads)
- **Notifications**: Awesome Notifications
- **Maps**: Google Maps Flutter
- **Location**: Geolocator package
- **URL Handling**: URL Launcher for external links

### Key Dependencies
```yaml
provider: ^6.0.0
cloud_firestore: ^4.13.6
firebase_auth: ^4.17.4
google_maps_flutter: ^2.12.2
geolocator: ^10.1.0
image_picker: ^0.8.7+4
video_player: ^2.8.1
chewie: ^1.7.4
url_launcher: ^6.2.5
awesome_notifications: ^0.10.0
file_picker: ^8.0.0+1
flutter_dotenv: ^5.1.0
```

## 📁 Project Structure

```
# NAME IT YOURSELF/
├── lib/
│   ├── visitor/
│   │   ├── constants/          # App constants and configurations
│   │   │   └── app_constants.dart  # Colors, text styles, routes
│   │   ├── models/             # Data models (Place, User, Review)
│   │   ├── pages/              # UI screens and pages
│   │   │   ├── home_page.dart
│   │   │   ├── selected_place.dart
│   │   │   ├── favorite_places_page.dart
│   │   │   ├── review_page.dart
│   │   │   └── ...
│   │   ├── service/            # Business logic and API services
│   │   ├── state/              # State management (AppState)
│   │   ├── theme/              # App theming and styling
│   │   ├── utils/              # Utility functions and helpers
│   │   └── widgets/            # Reusable UI components
│   ├── main.dart               # App entry point
│   └── firebase_options.dart   # Firebase configuration
├── backend_python/             # Data scraping and processing backend
│   ├── functions/              # Python utility functions
│   │   ├── utils/              # Scraping utilities
│   │   └── banner.py           # UI components
│   ├── datasets/               # Place data and JSON files
│   ├── csv/                    # CSV data files
│   └── main.py                 # Backend entry point
├── android/                    # Android-specific configurations
├── ios/                        # iOS-specific configurations
├── test/                       # Test files
└── pubspec.yaml               # Flutter dependencies
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.7.0 or higher
- Dart SDK 3.0.0 or higher
- Android Studio / VS Code with Flutter extension
- Firebase project setup
- Google Maps API key
- Python 3.8+ (for backend)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/TUBES-MOBILE-7.git
   cd TUBES-MOBILE-7
   ```

2. **Install Flutter dependencies**
   ```bash
   flutter pub get
   ```

3. **Setup Firebase**
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Enable Authentication (Email/Password)
   - Create Firestore database
   - Enable Storage
   - Download `google-services.json` for Android
   - Download `GoogleService-Info.plist` for iOS
   - Place them in the respective platform folders

4. **Configure environment variables**
   - Create a `.env` file in the root directory
   - Add your API keys and configuration:
   ```
   GOOGLE_MAPS_API_KEY=your_api_key_here
   FIREBASE_PROJECT_ID=your_project_id
   ```

5. **Run the application**
   ```bash
   flutter run
   ```

## 🔧 Configuration

### Firebase Setup
1. Enable Authentication (Email/Password)
2. Create Firestore database with proper security rules
3. Enable Storage for media uploads
4. Configure security rules for data access
5. Set up Firebase project settings

### Google Maps API
1. Enable Maps SDK for Android/iOS
2. Enable Places API for place details
3. Enable Directions API for navigation
4. Add API key to configuration files
5. Set up billing for API usage

### Environment Variables
Create a `.env` file with:
```
GOOGLE_MAPS_API_KEY=your_api_key_here
FIREBASE_PROJECT_ID=your_project_id
```

## 🧪 Testing

### Unit Tests
```bash
flutter test
```

### Widget Tests
```bash
flutter test test/widget_test.dart
```

### Integration Tests
```bash
flutter drive --target=test_driver/app.dart
```

### Manual Testing Checklist
- [ ] User registration and login
- [ ] Place browsing and search
- [ ] Favorite/bookmark functionality
- [ ] Review creation with media
- [ ] Navigation to Google Maps
- [ ] Theme switching (dark/light)
- [ ] Notification handling

## 📦 Building for Production

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Development Guidelines
- Follow Flutter coding conventions
- Add proper error handling
- Include unit tests for new features
- Update documentation for API changes
- Test on multiple devices/screen sizes

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Team

- **Mobile Development**: Flutter team
- **Backend Development**: Python team
- **UI/UX Design**: Design team
- **Project Management**: Team leads

## 🐛 Known Issues

- [ ] Video upload optimization needed for large files
- [ ] Offline mode implementation pending
- [ ] Push notification improvements for better delivery
- [ ] Performance optimization for large datasets
- [ ] Accessibility improvements for screen readers

## 🔮 Future Enhancements

- [ ] Offline mode support with local caching
- [ ] Advanced filtering options (price range, amenities)
- [ ] Social features (sharing, following, recommendations)
- [ ] AR navigation features with camera integration
- [ ] Multi-language support (Indonesian, English)
- [ ] Voice search integration
- [ ] Real-time chat between users
- [ ] Loyalty program and rewards
- [ ] Integration with food delivery services
- [ ] Advanced analytics and insights

## 📞 Support

For support and questions:
- Create an issue in the repository
- Contact the development team
- Check the documentation
- Review the troubleshooting guide

## 🔄 Recent Updates

### Latest Features
- ✅ Changed favorite icons from heart to bookmark for better UX
- ✅ Fixed navigation issues in favorite places page
- ✅ Enhanced review system with video support
- ✅ Improved notification system
- ✅ Added dark/light theme support
- ✅ Optimized image loading and caching

---

**Made with ❤️ by the Nongki Yuk! Development Team**

