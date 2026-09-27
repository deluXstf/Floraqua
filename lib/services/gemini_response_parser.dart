import 'dart:convert';

import '../models/plant.dart' show clampWateringFrequency;
import 'gemini_exceptions.dart';

String extractGeminiResponseText(String responseBody) {
  try {
    final decoded = jsonDecode(responseBody);
    if (decoded is! Map<String, dynamic>) throw const FormatException();
    final candidates = decoded['candidates'];
    if (candidates is! List || candidates.isEmpty) {
      throw const FormatException();
    }
    final first = candidates.first;
    final content = first is Map ? first['content'] : null;
    final parts = content is Map ? content['parts'] : null;
    if (parts is! List || parts.isEmpty) throw const FormatException();
    final text = parts.first is Map ? parts.first['text'] : null;
    if (text is! String || text.trim().isEmpty) throw const FormatException();
    return text;
  } catch (_) {
    throw const GeminiApiException(
      'Gemini API вернул пустой или заблокированный ответ',
    );
  }
}

/// Достать JSON из ответа модели, убрав возможную markdown-обёртку.
Map<String, dynamic> extractGeminiJson(String text) {
  var cleaned = text.trim();
  if (cleaned.contains('```json')) {
    cleaned = cleaned.split('```json')[1].split('```')[0].trim();
  } else if (cleaned.contains('```')) {
    cleaned = cleaned.split('```')[1].split('```')[0].trim();
  }
  try {
    final decoded = jsonDecode(cleaned);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Ожидался JSON-объект');
    }
    return decoded;
  } catch (_) {
    throw const GeminiApiException(
      'Gemini вернул ответ в неожиданном формате. Попробуйте сделать фото ещё раз.',
    );
  }
}

/// Достать читаемое поле message из JSON ошибки Google API.
String extractGeminiApiErrorMessage(String responseBody) {
  try {
    final decoded = jsonDecode(responseBody);
    if (decoded is Map<String, dynamic>) {
      final error = decoded['error'];
      if (error is Map<String, dynamic> && error['message'] is String) {
        return error['message'] as String;
      }
    }
  } catch (_) {
    // Если тело не JSON, сохраняем исходное сообщение ответа.
  }
  return responseBody;
}

/// Надёжно достаёт число дней полива из ответа модели.
int parseWateringFrequency(dynamic value, {int fallback = 7}) {
  if (value is int) return clampWateringFrequency(value);
  if (value is double) return clampWateringFrequency(value.round());

  if (value is String) {
    final direct = num.tryParse(value.trim());
    if (direct != null) return clampWateringFrequency(direct.round());

    final match = RegExp(r'\d+(?:[.,]\d+)?').firstMatch(value);
    if (match != null) {
      final numStr = match.group(0)!.replaceAll(',', '.');
      final parsed = double.tryParse(numStr);
      if (parsed != null) return clampWateringFrequency(parsed.round());
    }
  }

  return clampWateringFrequency(fallback);
}
