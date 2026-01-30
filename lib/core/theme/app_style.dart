enum AppStyle {
  cyberpunk, // Option 1: Neon/Dark
  professional, // Option 2: Clean/Light
  glass, // Option 3: Modern/Glass
  tactical, // Option 4: Rugged/Dark
  eco, // Option 5: Minimal/Green
}

extension AppStyleExtension on AppStyle {
  String get displayName {
    switch (this) {
      case AppStyle.cyberpunk:
        return 'Cyberpunk Neon';
      case AppStyle.professional:
        return 'Clean Professional';
      case AppStyle.glass:
        return 'Modern Glassmorphism';
      case AppStyle.tactical:
        return 'Dark Tactical';
      case AppStyle.eco:
        return 'Minimalist Eco';
    }
  }

  bool get isDark {
    switch (this) {
      case AppStyle.cyberpunk:
      case AppStyle.tactical:
      case AppStyle.glass:
        return true;
      case AppStyle.professional:
      case AppStyle.eco:
        return false;
    }
  }
}
