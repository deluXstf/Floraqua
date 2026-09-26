import 'package:flutter/material.dart';

import '../services/gemini_exceptions.dart';
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
  final message = switch (error) {
    QuotaExceededException e => e.message,
    GeminiApiException e => e.message,
    NetworkUnavailableException e => e.message,
    PlantNotRecognizedException e => e.message,
    _ => 'Что-то пошло не так: $error',
  };
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), backgroundColor: context.floraqua.error),
  );
}
