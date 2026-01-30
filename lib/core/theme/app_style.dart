enum AppStyle {
  cyberpunk, // Option 1: Neon/Dark
  professional, // Option 2: Clean/Light
  glass, // Option 3: Modern/Glass
  tactical, // Option 4: Rugged/Dark
  eco, // Option 5: Minimal/Green
  neuralNexus, // Option 6: Futuristic Dark (Design System 1)
  precisionClarity, // Option 7: Professional Light (Design System 2)
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
      case AppStyle.neuralNexus:
        return 'The Neural Nexus';
      case AppStyle.precisionClarity:
        return 'Precision Clarity';
    }
  }

  bool get isDark {
    switch (this) {
      case AppStyle.cyberpunk:
      case AppStyle.tactical:
      case AppStyle.glass:
      case AppStyle.neuralNexus:
        return true;
      case AppStyle.professional:
      case AppStyle.eco:
      case AppStyle.precisionClarity:
        return false;
    }
  }
}
