# 🚗 Algerian Driving License App (Permis App)

A modern, highly efficient Flutter application designed for Algerian driving schools to manage exam candidates and automate the generation of standardized, officially formatted PDF rosters.

## ✨ Features

- **📝 Session Management**: Create, view, and maintain exam sessions, including custom dates, locations (Wilaya handling), and examiner details.
- **👥 Candidate Roster**: Easily add, edit, and organize candidates with complete personal details and driving license categories (A, B, etc.).
- **📄 PDF Generation**: Generate ready-to-print, official-format A4 PDF sheets that align entirely with the Algerian driving license exam standards. It includes full table layouts and properly positioned arabic text.
- **💾 Offline First**: Fully functional without internet connectivity, utilizing Hive CE for fast and reliable local storage.
- **🇩🇿 Arabic-First Design**: Complete Right-to-Left (RTL) interface, exclusively incorporating the *Amiri* font for beautiful and readable Arabic typography across the app and exported PDFs.
- **🎨 Modern UI/UX**: Clean, feature-based user interface following a material design language, allowing quick data entry and navigation.

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev/) (Dart)
- **State Management**: [flutter_bloc](https://pub.dev/packages/flutter_bloc) (Cubit)
- **Local Database**: [hive_ce](https://pub.dev/packages/hive_ce)
- **Document Generation**: [pdf](https://pub.dev/packages/pdf), [printing](https://pub.dev/packages/printing)
- **Storage/Utilities**: `path_provider`, `uuid`, `intl`

## 🚀 Getting Started

### Prerequisites
- Flutter SDK `^3.10.3` or higher
- Dart SDK `^3.0.0` or higher

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd permis
```

2. Get the dependencies:
```bash
flutter pub get
```

3. Run the application (targeting Chrome or your preferred emulator/device):
```bash
flutter run
```

## 🏗️ Architecture

The app follows a **Feature-First Architecture** for ultimate scalability and cleanly separated concerns:
- `lib/core/`: Common themes, database services, and utility helpers.
- `lib/features/`: Feature-specific logic containing `presentation` (UI + Cubits) and `data` (Models + Repositories) for:
  - `session`: Managing exam sessions and candidate entities.
  - `pdf`: handling the data formatting and styling for PDF output.

## 🤝 Contributing

Contributions, issues, and feature requests are always welcome! 

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.
