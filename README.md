# 🚀 Practical Task – Flutter Application

![Flutter](https://img.shields.io/badge/Flutter-3.29.3-blue.svg)
![Dart](https://img.shields.io/badge/Dart-Stable-blue.svg)
![State Management](https://img.shields.io/badge/State%20Management-BLoC-yellow.svg)
![Firebase](https://img.shields.io/badge/Firebase-Integrated-orange.svg)

---

## 📖 Overview
This project is a **Flutter application** developed for a **practical round assessment**.  
It provides a feed-based social experience where users can **sign up, create posts, like, comment, and manage their own feeds**.

---

## 🛠 Tech Stack
- **Flutter Version:** 3.29.3
- **Dart:** Compatible with Flutter 3.29.3
- **State Management:** BLoC (flutter_bloc)
- **Backend Services:**
    - Authentication: **Firebase Authentication (Email/Password)**
    - Database: **Cloud Firestore**
    - Storage: **Firebase Storage (for images)**

---

## ✨ Features

- ✅ **User Authentication** (Email/Password)
- ✅ **Create & Edit Feeds** with image and caption
- ✅ **Feed Listing with Real-Time Updates**
- ✅ **Like & Unlike Functionality**
- ✅ **Comment System on Feeds**
- ✅ **My Feed (User-Specific Posts)**
- ✅ **Profile Management**
- ✅ **Splash & Home Navigation**

---

## 📂 Folder Structure
lib/
│
├── model/                     # Data models (Feed, Comment, etc.)
│   ├── comment_model.dart
│   └── feed_model.dart
│
├── screen/                    # Screens organized by feature
│   ├── feed_create_edit/      # Feed creation & editing
│   ├── feed_listing/          # Feed listing, comments, like features
│   ├── home/                  # Home screen
│   ├── my_feed/               # User-specific feed
│   ├── profile/               # Profile screen
│   ├── sign_up/               # Authentication (Sign Up)
│   └── splash_screen/         # Splash screen
│
├── utils/                     # Constants, colors, common widgets
│   ├── app_color.dart
│   ├── app_string.dart
│   ├── common_widget.dart
│   └── const_data.dart
│
└── main.dart                  # Application entry point

---

## 🏗 Architecture

The project follows a **BLoC (Business Logic Component)** architecture:
- **Cubit** for managing state of feeds, comments, and authentication.
- **Repository Layer** as the data source between Firebase and UI.
- **Clear separation of concerns**: UI → Cubit → Repository → Firebase.

---

## ⚡ Getting Started

### Prerequisites
- Install [Flutter 3.29.3](https://flutter.dev/docs/get-started/install)
- Firebase Project with:
    - Cloud Firestore
    - Firebase Authentication
    - Firebase Storage (if image upload required)

### Installation
1. Clone the repository:
   git clone <repo-url>
   cd practical_task
2. Get dependencies:
   flutter pub get
3. Configure Firebase:
  Add google-services.json to android/app/
 (Optional) Add GoogleService-Info.plist for iOS
4. Run the project
   flutter run

