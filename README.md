# RemPass

A secure, offline-first, ZTA(Zero Trust Architecture) Ready Password Manager application built with Flutter. RemPass is designed to help users securely store, generate, and manage their credentials with maximum privacy and convenience.

## 🚀 Features

- **Advanced Encryption**: All sensitive data is encrypted locally on the device using robust cryptographic algorithms, ensuring that only you can access your passwords.
- **Native Autofill Service**: Integrated with the Android Autofill framework, allowing you to fill credentials seamlessly across other apps.
- **App & Website Association**: Easily link and organize passwords corresponding to your installed applications and visited websites.
- **Data Portability**: Securely backup and restore your credentials using CSV import and export functionalities.
- **Fast Local Storage**: Powered by Hive database for high performance and low latency without relying on cloud services.
- **Password Generator**: Built-in tool to create strong, complex passwords to enhance your digital security.
- **Modern UI**: Clean and intuitive user interface designed with user experience in mind.

## 🛠 Tech Stack

- **Framework**: Flutter (Dart)
- **Database**: Hive (NoSQL)
- **Security**: `encrypt` and `crypto` packages for local data encryption.
- **State Management**: Clean architecture with separated models, services, and screens.

## 📦 Getting Started

To get a local copy up and running, follow these simple steps.

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Version consistent with your environment)
- Android Studio / VS Code
- An Android device or emulator

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/Abhishekbhat014/RemPass.git
   ```
2. Navigate to the project directory:
   ```bash
   cd RemPass
   ```
3. Install the dependencies:
   ```bash
   flutter pub get
   ```
4. Run the application:
   ```bash
   flutter run
   ```

## 🔒 Security

RemPass prioritizes user privacy. All data remains on your local device and is never transmitted to external servers. It is highly recommended to keep a backup of your data using the export feature, as data recovery is not possible if the app is deleted or the device is lost without a backup.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details. (If applicable)

---
*Note: This README was automatically generated to reflect the project structure and dependencies.*
