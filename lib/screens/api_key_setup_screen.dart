import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/secure_storage_service.dart';
import '../l10n/l10n_extensions.dart';
import '../theme/app_theme.dart';

/// Экран ввода персонального API-ключа Gemini — аналог ApiKeySetupDialog
/// из Python-версии. Показывается при первом запуске (пока ключ не найден
/// в SecureStorageService) или когда пользователь явно решил сменить ключ.
///
/// [onSaved] вызывается после успешного сохранения ключа — колбэк, а не
/// Navigator.pop(), потому что этот экран может быть показан и как корневой
/// виджет приложения (при первом запуске, ещё до того, как вообще есть
/// стек навигации, куда можно было бы "вернуться").
class ApiKeySetupScreen extends StatefulWidget {
  final SecureStorageService secureStorage;
  final ValueChanged<String> onSaved;

  const ApiKeySetupScreen({
    super.key,
    required this.secureStorage,
    required this.onSaved,
  });

  @override
  State<ApiKeySetupScreen> createState() => _ApiKeySetupScreenState();
}

class _ApiKeySetupScreenState extends State<ApiKeySetupScreen> {
  final _controller = TextEditingController();
  bool _obscure = true;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static const _apiKeyPageUrl = 'https://aistudio.google.com/app/apikey';

  /// Открыть страницу получения ключа в системном браузере — так пользователю
  /// вообще не нужно копировать ссылку вручную (в отличие от прежнего
  /// варианта с SnackBar, откуда текст нельзя было скопировать). Если по
  /// какой-то причине открыть браузер не получилось (нет обработчика ссылок
  /// и т.п.) — показываем ссылку в диалоге с выделяемым текстом, чтобы её
  /// всё равно можно было скопировать вручную как запасной вариант.
  Future<void> _openApiKeyPage() async {
    final uri = Uri.parse(_apiKeyPageUrl);
    var opened = false;
    try {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      // Диалог ниже содержит ссылку, которую можно скопировать вручную.
    }
    if (!opened && mounted) {
      _showCopyableLinkDialog();
    }
  }

  void _showCopyableLinkDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.apiGetKeyTitle),
        content: const SelectableText(_apiKeyPageUrl),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.l10n.apiClose),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final key = _controller.text.trim();
    if (key.isEmpty) {
      setState(() => _error = context.l10n.apiEnterKey);
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    // Здесь намеренно НЕТ проверки ключа реальным запросом к Gemini API
    // (в Python-версии validate_api_key() делал пробный вызов) — это можно
    // добавить позже; пока просто сохраняем и даём GeminiService самому
    // сообщить о проблеме при первом реальном обращении (ошибка будет
    // видна пользователю в виде обычного сообщения об ошибке сети/ключа).
    try {
      await widget.secureStorage.saveApiKey(key);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = context.l10n.apiSaveError;
      });
      debugPrint('Ошибка сохранения Gemini-ключа: $error');
      return;
    }

    if (!mounted) return;
    widget.onSaved(key);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.floraqua.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🌱', style: TextStyle(fontSize: 56)),
                  const SizedBox(height: 16),
                  Text(
                    'Floraqua',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: context.floraqua.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.apiDescription,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: context.floraqua.textSecondary),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.floraqua.warning.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      context.l10n.apiSecurityNotice,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: context.floraqua.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  TextButton(
                    onPressed: _openApiKeyPage,
                    child: Text(context.l10n.apiWhereGetKey),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _controller,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      labelText: context.l10n.apiKeyLabel,
                      border: const OutlineInputBorder(),
                      errorText: _error,
                      suffixIcon: IconButton(
                        icon: Icon(
                            _obscure ? Icons.visibility_off : Icons.visibility),
                        tooltip: _obscure
                            ? context.l10n.apiShowKey
                            : context.l10n.apiHideKey,
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    onSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _saving ? null : _submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: context.floraqua.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : Text(context.l10n.commonContinue),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
