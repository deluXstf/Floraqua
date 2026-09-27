import 'package:flutter/material.dart';

import '../services/gemini_exceptions.dart';
import '../l10n/generated/app_localizations.dart';
import '../l10n/l10n_extensions.dart';
import '../theme/app_theme.dart';

void showGeminiLoadingDialog(BuildContext context, String message) {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      content: Row(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(width: 20),
          Expanded(child: Text(message)),
        ],
      ),
    ),
  );
}

void showGeminiErrorSnack(BuildContext context, Object error) {
  final l10n = context.l10n;
  final message = switch (error) {
    QuotaExceededException() => l10n.geminiQuotaError,
    GeminiApiException e => _apiErrorMessage(l10n, e.message),
    NetworkUnavailableException e => _networkErrorMessage(l10n, e.message),
    PlantNotRecognizedException() => l10n.geminiPlantNotFound,
    _ => l10n.geminiGenericError,
  };
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), backgroundColor: context.floraqua.error),
  );
}

String _apiErrorMessage(AppLocalizations l10n, String original) {
  final match = RegExp(r'\((\d{3})\)').firstMatch(original);
  final status = int.tryParse(match?.group(1) ?? '');
  return status == null ? l10n.geminiGenericError : l10n.geminiApiError(status);
}

String _networkErrorMessage(AppLocalizations l10n, String original) {
  if (original.contains('защищённое') || original.contains('secure')) {
    return l10n.geminiSecureConnectionError;
  }
  if (original.contains('секунд') || original.contains('seconds')) {
    final match = RegExp(r'(\d+)').firstMatch(original);
    final seconds = int.tryParse(match?.group(1) ?? '30') ?? 30;
    return l10n.geminiTimeoutError(seconds);
  }
  return l10n.geminiNetworkError;
}
