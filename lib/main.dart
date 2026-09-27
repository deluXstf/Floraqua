import 'package:flutter/material.dart';

import 'l10n/generated/app_localizations.dart';
import 'screens/api_key_setup_screen.dart';
import 'screens/garden_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/gemini_service.dart';
import 'services/notification_service.dart';
import 'services/plant_store.dart';
import 'services/secure_storage_service.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const FloraquaApp());
}

class FloraquaApp extends StatefulWidget {
  const FloraquaApp({super.key});

  @override
  State<FloraquaApp> createState() => _FloraquaAppState();
}

class _FloraquaAppState extends State<FloraquaApp> {
  final _secureStorage = SecureStorageService();
  ThemeMode _themeMode = ThemeMode.system;
  String _localeCode = 'ru';
  bool _preferencesLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAppPreferences();
  }

  Future<void> _loadAppPreferences() async {
    try {
      final savedMode = await _secureStorage.loadThemeMode();
      final mode = switch (savedMode) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };
      if (mounted) setState(() => _themeMode = mode);
    } catch (error) {
      debugPrint('Не удалось загрузить тему: $error');
    }

    try {
      final savedLocale = await _secureStorage.loadLocaleCode();
      if ((savedLocale == 'ru' || savedLocale == 'en') && mounted) {
        setState(() => _localeCode = savedLocale!);
      }
    } catch (error) {
      debugPrint('Could not load language preference: $error');
    } finally {
      if (mounted) setState(() => _preferencesLoaded = true);
    }
  }

  Future<void> _changeThemeMode(ThemeMode mode) async {
    await _secureStorage.saveThemeMode(mode.name);
    if (mounted) setState(() => _themeMode = mode);
  }

  Future<void> _changeLocaleCode(String code) async {
    await _secureStorage.saveLocaleCode(code);
    if (mounted) setState(() => _localeCode = code);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Floraqua',
      locale: Locale(_localeCode),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(brightness: Brightness.light),
      darkTheme: buildAppTheme(brightness: Brightness.dark),
      themeMode: _themeMode,
      home: _preferencesLoaded
          ? _AppStartup(
              secureStorage: _secureStorage,
              themeMode: _themeMode,
              localeCode: _localeCode,
              onThemeModeChanged: _changeThemeMode,
              onLocaleCodeChanged: _changeLocaleCode,
            )
          : const Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }
}

/// Решает, нужен ли новому пользователю onboarding, Gemini-ключ или сад.
class _AppStartup extends StatefulWidget {
  final SecureStorageService secureStorage;
  final ThemeMode themeMode;
  final String localeCode;
  final Future<void> Function(ThemeMode) onThemeModeChanged;
  final Future<void> Function(String) onLocaleCodeChanged;

  const _AppStartup({
    required this.secureStorage,
    required this.themeMode,
    required this.localeCode,
    required this.onThemeModeChanged,
    required this.onLocaleCodeChanged,
  });

  @override
  State<_AppStartup> createState() => _AppStartupState();
}

class _AppStartupState extends State<_AppStartup> {
  String? _apiKey;
  bool _onboardingComplete = false;
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _checkFirstRun();
  }

  Future<void> _checkFirstRun() async {
    String? key;
    var onboardingComplete = false;
    try {
      key = await widget.secureStorage.loadApiKey();
    } catch (error) {
      debugPrint('Не удалось загрузить Gemini-ключ: $error');
    }
    try {
      onboardingComplete = await widget.secureStorage.hasCompletedOnboarding();
    } catch (error) {
      debugPrint('Не удалось проверить первый запуск: $error');
    }

    // Keep existing users with a saved personal key out of the new onboarding.
    if (!onboardingComplete && key != null) {
      try {
        await widget.secureStorage.completeOnboarding();
      } catch (error) {
        debugPrint('Не удалось отметить onboarding завершённым: $error');
      }
      onboardingComplete = true;
    }

    if (!mounted) return;
    setState(() {
      _apiKey = key;
      _onboardingComplete = onboardingComplete;
      _checking = false;
    });
  }

  Future<void> _finishOnboarding() async {
    await widget.secureStorage.completeOnboarding();
    if (!mounted) return;
    setState(() => _onboardingComplete = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_onboardingComplete) {
      return OnboardingScreen(
        localeCode: widget.localeCode,
        onLocaleCodeChanged: widget.onLocaleCodeChanged,
        onComplete: _finishOnboarding,
      );
    }

    if (_apiKey == null) {
      return ApiKeySetupScreen(
        secureStorage: widget.secureStorage,
        onSaved: (key) => setState(() => _apiKey = key),
      );
    }

    return _GardenRoot(
      apiKey: _apiKey!,
      secureStorage: widget.secureStorage,
      themeMode: widget.themeMode,
      localeCode: widget.localeCode,
      onThemeModeChanged: widget.onThemeModeChanged,
      onLocaleCodeChanged: widget.onLocaleCodeChanged,
      onChangeApiKey: () => setState(() => _apiKey = null),
    );
  }
}

/// Создаёт долгоживущие сервисы сада один раз на экран.
class _GardenRoot extends StatefulWidget {
  final String apiKey;
  final SecureStorageService secureStorage;
  final ThemeMode themeMode;
  final String localeCode;
  final Future<void> Function(ThemeMode) onThemeModeChanged;
  final Future<void> Function(String) onLocaleCodeChanged;
  final VoidCallback onChangeApiKey;

  const _GardenRoot({
    required this.apiKey,
    required this.secureStorage,
    required this.themeMode,
    required this.localeCode,
    required this.onThemeModeChanged,
    required this.onLocaleCodeChanged,
    required this.onChangeApiKey,
  });

  @override
  State<_GardenRoot> createState() => _GardenRootState();
}

class _GardenRootState extends State<_GardenRoot> {
  late final GeminiService _geminiService;
  late final NotificationService _notificationService;
  late final PlantStore _store;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _geminiService = GeminiService(
      apiKey: widget.apiKey,
      localeCode: widget.localeCode,
    );
    _notificationService = NotificationService(localeCode: widget.localeCode);
    _store = PlantStore(
      geminiService: _geminiService,
      notificationService: _notificationService,
      localeCode: widget.localeCode,
    );
    _init();
  }

  Future<void> _init() async {
    try {
      final savedReminderTime = await widget.secureStorage.loadReminderTime();
      final match = savedReminderTime == null
          ? null
          : RegExp(r'^(\d{2}):(\d{2})$').firstMatch(savedReminderTime);
      if (match != null) {
        final hour = int.tryParse(match.group(1)!);
        final minute = int.tryParse(match.group(2)!);
        if (hour != null && minute != null && hour <= 23 && minute <= 59) {
          _notificationService.setReminderTime(hour, minute);
        }
      }
    } catch (error) {
      debugPrint('Не удалось загрузить время напоминаний: $error');
    }

    await _notificationService.init();
    if (mounted) setState(() => _ready = true);
  }

  @override
  void didUpdateWidget(covariant _GardenRoot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.localeCode != widget.localeCode) {
      _store.updateLocale(widget.localeCode);
    }
  }

  @override
  void dispose() {
    _store.dispose();
    _geminiService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return GardenScreen(
      store: _store,
      secureStorage: widget.secureStorage,
      themeMode: widget.themeMode,
      localeCode: widget.localeCode,
      onThemeModeChanged: widget.onThemeModeChanged,
      onLocaleCodeChanged: widget.onLocaleCodeChanged,
      onChangeApiKey: widget.onChangeApiKey,
    );
  }
}
