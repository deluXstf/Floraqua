import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Хранилище API-ключа — прямой аналог keyring-обёртки из Python-версии
/// (load_saved_api_key/save_api_key/clear_saved_api_key). flutter_secure_storage
/// сам выбирает подходящее защищённое хранилище на каждой платформе. В
/// используемой Windows-реализации секреты защищаются Windows DPAPI и лежат в
/// служебном зашифрованном файле приложения; на iOS/macOS используется Keychain.
/// Обычный пользователь не должен видеть API-ключ в открытом виде на диске.
class SecureStorageService {
  static const _apiKeyStorageKey = 'gemini_api_key';
  static const _reminderTimeStorageKey = 'watering_reminder_time';
  static const _gardenViewModeStorageKey = 'garden_view_mode';
  static const _themeModeStorageKey = 'theme_mode';
  static const _localeCodeStorageKey = 'locale_code';
  static const _onboardingCompleteStorageKey = 'onboarding_complete';

  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<String?> loadApiKey() async {
    final value = await _storage.read(key: _apiKeyStorageKey);
    return (value != null && value.trim().isNotEmpty) ? value.trim() : null;
  }

  Future<void> saveApiKey(String key) async {
    await _storage.write(key: _apiKeyStorageKey, value: key.trim());
  }

  Future<void> clearApiKey() async {
    await _storage.delete(key: _apiKeyStorageKey);
  }

  Future<String?> loadReminderTime() async =>
      _storage.read(key: _reminderTimeStorageKey);

  Future<void> saveReminderTime(int hour, int minute) async {
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      throw RangeError('Некорректное время напоминания');
    }
    await _storage.write(
      key: _reminderTimeStorageKey,
      value:
          '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}',
    );
  }

  Future<String?> loadGardenViewMode() async =>
      _storage.read(key: _gardenViewModeStorageKey);

  Future<void> saveGardenViewMode(String mode) async {
    if (mode != 'grid' && mode != 'list') {
      throw ArgumentError.value(mode, 'mode', 'Допустимы grid или list');
    }
    await _storage.write(key: _gardenViewModeStorageKey, value: mode);
  }

  Future<String?> loadThemeMode() async =>
      _storage.read(key: _themeModeStorageKey);

  Future<void> saveThemeMode(String mode) async {
    if (!const {'system', 'light', 'dark'}.contains(mode)) {
      throw ArgumentError.value(
        mode,
        'mode',
        'Допустимы system, light или dark',
      );
    }
    await _storage.write(key: _themeModeStorageKey, value: mode);
  }

  Future<String?> loadLocaleCode() async =>
      _storage.read(key: _localeCodeStorageKey);

  Future<void> saveLocaleCode(String code) async {
    if (code != 'ru' && code != 'en') {
      throw ArgumentError.value(code, 'code', 'Supported locales: ru, en');
    }
    await _storage.write(key: _localeCodeStorageKey, value: code);
  }

  Future<bool> hasCompletedOnboarding() async =>
      await _storage.read(key: _onboardingCompleteStorageKey) == 'true';

  Future<void> completeOnboarding() async =>
      _storage.write(key: _onboardingCompleteStorageKey, value: 'true');
}
