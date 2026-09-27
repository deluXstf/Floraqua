import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../services/plant_store.dart';
import '../services/secure_storage_service.dart';
import '../l10n/l10n_extensions.dart';
import '../theme/app_theme.dart';

/// Экран настроек — аналог окна "О программе" из Python-версии: экспорт/
/// импорт сада, экспорт календаря полива, смена API-ключа.
class SettingsScreen extends StatelessWidget {
  final PlantStore store;
  final SecureStorageService secureStorage;
  final ThemeMode themeMode;
  final Future<void> Function(ThemeMode) onThemeModeChanged;
  final String localeCode;
  final Future<void> Function(String) onLocaleCodeChanged;
  final VoidCallback onChangeApiKey;

  const SettingsScreen({
    super.key,
    required this.store,
    required this.secureStorage,
    required this.themeMode,
    required this.onThemeModeChanged,
    this.localeCode = 'ru',
    this.onLocaleCodeChanged = _ignoreLocaleChange,
    required this.onChangeApiKey,
  });

  static Future<void> _ignoreLocaleChange(String _) async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.settingsTitle)),
      body: Center(
        child: ConstrainedBox(
          // Оставляем удобную читаемую ширину и центрируем настройки на ПК.
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _ThemeModeTile(
                value: themeMode,
                onChanged: (mode) async {
                  try {
                    await onThemeModeChanged(mode);
                  } catch (error) {
                    if (context.mounted) {
                      _showSnack(
                        context,
                        context.l10n.themeSaveError,
                        isError: true,
                      );
                    }
                    rethrow;
                  }
                },
              ),
              _LanguageTile(
                value: localeCode,
                onChanged: (code) async {
                  try {
                    await onLocaleCodeChanged(code);
                  } catch (_) {
                    if (context.mounted) {
                      _showSnack(context, context.l10n.localeSaveError,
                          isError: true);
                    }
                    rethrow;
                  }
                },
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    children: [
                      const Text('🌱', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 8),
                      Text(
                        'FLORAQUA',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: context.floraqua.primary,
                        ),
                      ),
                      Text(
                        context.l10n.appVersion,
                        style: TextStyle(
                          color: context.floraqua.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _SettingsTile(
                icon: Icons.upload_file_outlined,
                title: context.l10n.exportGardenTitle,
                subtitle: context.l10n.exportGardenSubtitle,
                onTap: () => _exportGarden(context),
              ),
              _SettingsTile(
                icon: Icons.download_outlined,
                title: context.l10n.importGardenTitle,
                subtitle: context.l10n.importGardenSubtitle,
                onTap: () => _importGarden(context),
              ),
              _SettingsTile(
                icon: Icons.calendar_month_outlined,
                title: context.l10n.calendarTitle,
                subtitle: context.l10n.calendarSubtitle,
                onTap: () => _exportCalendar(context),
              ),
              ListenableBuilder(
                listenable: store,
                builder: (context, _) => _SettingsTile(
                  icon: Icons.notifications_active_outlined,
                  title: context.l10n.reminderTitle,
                  subtitle:
                      context.l10n.reminderSubtitle(store.reminderTimeLabel),
                  onTap: () => _chooseReminderTime(context),
                ),
              ),
              const Divider(height: 32),
              _SettingsTile(
                icon: Icons.vpn_key_outlined,
                title: context.l10n.changeApiTitle,
                subtitle: context.l10n.changeApiSubtitle,
                onTap: () => _changeApiKey(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _timestamp() {
    final now = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${now.year}${two(now.month)}${two(now.day)}';
  }

  Future<void> _chooseReminderTime(BuildContext context) async {
    final selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: store.reminderHour,
        minute: store.reminderMinute,
      ),
      initialEntryMode: TimePickerEntryMode.input,
      builder: (context, child) {
        final compactTheme = Theme.of(context).copyWith(
          timePickerTheme: TimePickerThemeData(
            hourMinuteTextStyle: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w600,
            ),
            hourMinuteShape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            hourMinuteColor: context.floraqua.primaryLight,
            dialTextStyle: const TextStyle(fontSize: 13),
            dialHandColor: context.floraqua.primary,
          ),
        );
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: Theme(data: compactTheme, child: child!),
        );
      },
    );
    if (selected == null || !context.mounted) return;

    try {
      await secureStorage.saveReminderTime(selected.hour, selected.minute);
      await store.updateReminderTime(selected.hour, selected.minute);
      if (!context.mounted) return;
      _showSnack(
        context,
        context.l10n.reminderSaved(store.reminderTimeLabel),
      );
    } catch (e) {
      if (!context.mounted) return;
      _showSnack(context, context.l10n.reminderSaveError, isError: true);
    }
  }

  void _showSnack(BuildContext context, String message,
      {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? context.floraqua.error : null,
      ),
    );
  }

  Future<void> _exportGarden(BuildContext context) async {
    final path = await FilePicker.platform.saveFile(
      dialogTitle: context.l10n.exportDialogTitle,
      fileName: 'my_garden_export_${_timestamp()}.zip',
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );
    if (path == null || !context.mounted) return;

    final destPath = path.endsWith('.zip') ? path : '$path.zip';
    final ok = await store.exportGarden(destPath);
    if (!context.mounted) return;
    _showSnack(
      context,
      ok ? context.l10n.exportSuccess : context.l10n.exportFailure,
      isError: !ok,
    );
  }

  Future<void> _importGarden(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.importConfirmTitle),
        content: Text(context.l10n.importConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.l10n.commonContinue),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final result = await FilePicker.platform.pickFiles(
      dialogTitle: context.l10n.importFileDialogTitle,
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );
    final path = result?.files.single.path;
    if (path == null || !context.mounted) return;

    final ok = await store.importGarden(path);
    if (!context.mounted) return;
    _showSnack(
      context,
      ok ? context.l10n.importSuccess : context.l10n.importFailure,
      isError: !ok,
    );
  }

  Future<void> _exportCalendar(BuildContext context) async {
    final path = await FilePicker.platform.saveFile(
      dialogTitle: context.l10n.calendarSaveDialogTitle,
      fileName: 'watering_calendar_${_timestamp()}.ics',
      type: FileType.custom,
      allowedExtensions: ['ics'],
    );
    if (path == null || !context.mounted) return;

    final destPath = path.endsWith('.ics') ? path : '$path.ics';
    final ok = await store.exportWateringCalendar(destPath);
    if (!context.mounted) return;
    _showSnack(
      context,
      ok ? context.l10n.calendarSaved : context.l10n.calendarSaveFailure,
      isError: !ok,
    );
  }

  Future<void> _changeApiKey(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.changeApiTitle),
        content: Text(context.l10n.changeApiConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.l10n.commonChange),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await secureStorage.clearApiKey();
      if (!context.mounted) return;
      Navigator.of(context).pop();
      onChangeApiKey();
    } catch (error) {
      if (!context.mounted) return;
      _showSnack(context, context.l10n.deleteApiKeyError, isError: true);
    }
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: context.floraqua.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.chip),
        side: BorderSide(color: context.floraqua.divider),
      ),
      child: ListTile(
        leading: Icon(icon, color: context.floraqua.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        onTap: onTap,
      ),
    );
  }
}

class _ThemeModeTile extends StatefulWidget {
  final ThemeMode value;
  final Future<void> Function(ThemeMode) onChanged;

  const _ThemeModeTile({required this.value, required this.onChanged});

  @override
  State<_ThemeModeTile> createState() => _ThemeModeTileState();
}

class _ThemeModeTileState extends State<_ThemeModeTile> {
  late ThemeMode _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.value;
  }

  @override
  void didUpdateWidget(covariant _ThemeModeTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) _selected = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.floraqua;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: palette.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.chip),
        side: BorderSide(color: palette.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.palette_outlined, color: palette.primary),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.themeTitle,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        context.l10n.settingsSavedOnDevice,
                        style: TextStyle(
                          fontSize: 12,
                          color: palette.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<ThemeMode>(
              key: ValueKey(_selected),
              initialValue: _selected,
              decoration: const InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              items: [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text(context.l10n.themeSystem),
                ),
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text(context.l10n.themeLight),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text(context.l10n.themeDark),
                ),
              ],
              onChanged: (mode) {
                if (mode == null) return;
                _select(mode);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _select(ThemeMode mode) async {
    final previous = _selected;
    setState(() => _selected = mode);
    try {
      await widget.onChanged(mode);
    } catch (_) {
      if (mounted) setState(() => _selected = previous);
    }
  }
}

class _LanguageTile extends StatefulWidget {
  final String value;
  final Future<void> Function(String) onChanged;

  const _LanguageTile({required this.value, required this.onChanged});

  @override
  State<_LanguageTile> createState() => _LanguageTileState();
}

class _LanguageTileState extends State<_LanguageTile> {
  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.value;
  }

  @override
  void didUpdateWidget(covariant _LanguageTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) _selected = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.floraqua;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: palette.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.chip),
        side: BorderSide(color: palette.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.language_rounded, color: palette.primary),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.languageLabel,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text(
                        l10n.settingsSavedOnDevice,
                        style: TextStyle(
                          fontSize: 12,
                          color: palette.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              key: ValueKey(_selected),
              initialValue: _selected,
              decoration: const InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              items: [
                DropdownMenuItem(
                    value: 'ru', child: Text(l10n.languageRussian)),
                DropdownMenuItem(
                    value: 'en', child: Text(l10n.languageEnglish)),
              ],
              onChanged: (code) {
                if (code != null) _select(code);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _select(String code) async {
    final previous = _selected;
    setState(() => _selected = code);
    try {
      await widget.onChanged(code);
    } catch (_) {
      if (mounted) setState(() => _selected = previous);
    }
  }
}
