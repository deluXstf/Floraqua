import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:http/http.dart' as http;

import 'gemini_exceptions.dart';
import 'gemini_prompts.dart';
import 'gemini_response_parser.dart';

export 'gemini_exceptions.dart';
export 'gemini_response_parser.dart' show parseWateringFrequency;

/// Сервис работы с Gemini API — прямой порт _generate_with_timeout и
/// связанных функций из plant_garden_app.py (Python-версия), включая
/// retry-политику, уже покрытую тестами там (см. test_plant_garden_app.py —
/// используем её как спецификацию поведения при портировании).
class GeminiService {
  static const int maxRetries = 2;
  static const Duration retryBaseDelay = Duration(milliseconds: 1500);
  static const Duration defaultTimeout = Duration(seconds: 30);
  static const String modelName = 'gemini-2.5-flash';

  final String apiKey;
  final http.Client _client;
  String localeCode;
  final Random _random = Random();

  GeminiService({required this.apiKey, http.Client? client, this.localeCode = 'ru'})
      : _client = client ?? http.Client();

  Uri get _endpoint => Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$modelName:generateContent');

  /// Распознавание растения по фото + автооценка потребности в поливе.
  ///
  /// potSize/location/hasDrainage — структурированные условия содержания,
  /// напрямую влияющие на реальную частоту полива (см. buildGeminiContextBlock).
  /// userNotes — свободный текст для всего остального.
  ///
  /// Бросает [PlantNotRecognizedException], если на фото не растение.
  /// Бросает отдельные исключения для квоты, сетевого сбоя, отказа API и
  /// отсутствия растения — вызывающий код должен явно сообщить причину.
  Future<Map<String, dynamic>> identifyPlant({
    required List<int> imageBytes,
    String? userNotes,
    String? potSize,
    String? location,
    String? hasDrainage,
  }) async {
    final prompt = identifyPlantPromptFor(localeCode) +
        buildGeminiContextBlock(
          potSize: potSize,
          location: location,
          hasDrainage: hasDrainage,
          userNotes: userNotes,
          localeCode: localeCode,
        );

    final response = await _callWithRetry(prompt, imageBytes);
    final data = extractGeminiJson(response);

    if (data.containsKey('error')) {
      throw PlantNotRecognizedException(
          data['error'] as String? ?? 'Растение не обнаружено');
    }

    // Частота полива иногда приходит не числом, а строкой вроде "раз в неделю" —
    // не должно ронять приложение (аналог _parse_watering_frequency).
    final name = data['name'];
    if (name is! String || name.trim().isEmpty) {
      throw const GeminiApiException('Gemini не вернул название растения');
    }
    data['name'] = name.trim();
    data['watering_frequency'] =
        parseWateringFrequency(data['watering_frequency']);
    if (data['needs_water_now'] is! bool) data['needs_water_now'] = false;
    for (final key in [
      'scientific_name',
      'watering_amount',
      'light_requirements',
      'temperature',
      'humidity',
      'care_tips',
      'difficulty',
      'moisture_notes',
    ]) {
      if (data[key] != null && data[key] is! String) data.remove(key);
    }

    return data;
  }

  /// Повторная оценка влажности по новому фото уже существующего растения —
  /// аналог assess_watering_by_photo. Условия содержания подтягиваются из
  /// уже сохранённых данных растения (context), а не запрашиваются заново.
  Future<Map<String, dynamic>> assessWateringByPhoto({
    required List<int> imageBytes,
    String? potSize,
    String? location,
    String? hasDrainage,
    String? userNotes,
  }) async {
    final prompt = moisturePromptFor(localeCode) +
        buildGeminiContextBlock(
          potSize: potSize,
          location: location,
          hasDrainage: hasDrainage,
          userNotes: userNotes,
          localeCode: localeCode,
        );

    final response = await _callWithRetry(prompt, imageBytes,
        timeout: const Duration(seconds: 20));
    return extractGeminiJson(response);
  }

  // ---------------------------------------------------------------------
  // Retry-политика — прямой порт _generate_with_timeout из Python-версии.
  // ---------------------------------------------------------------------

  /// Вызов Gemini API с таймаутом, повтором на переходные сбои и понятной
  /// обработкой ошибок квоты.
  ///
  /// Retry-политика (сознательно консервативная — портирована 1-в-1 из
  /// Python-версии, где она покрыта тестами):
  /// - Таймаут / обрыв сети / 5xx — до [maxRetries] повторов с экспоненциальной
  ///   задержкой + джиттером (джиттер — чтобы несколько параллельных запросов
  ///   не били по API синхронной пачкой).
  /// - Квота (HTTP 429) — НЕ повторяется немедленно: повторный запрос сразу
  ///   после отказа по квоте только усугубит ситуацию.
  /// - Прочие клиентские ошибки (4xx, кроме 429) — тоже не повторяются: если
  ///   запрос был некорректен, повтор с теми же данными не изменит результат.
  Future<String> _callWithRetry(
    String prompt,
    List<int> imageBytes, {
    Duration timeout = defaultTimeout,
  }) async {
    Object? lastError;

    for (var attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        final body = jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt},
                {
                  'inline_data': {
                    'mime_type': 'image/jpeg',
                    'data': base64Encode(imageBytes),
                  }
                },
              ]
            }
          ]
        });

        final response = await _client
            .post(
              _endpoint,
              headers: {
                'Content-Type': 'application/json',
                'x-goog-api-key': apiKey,
              },
              body: body,
            )
            .timeout(timeout);

        if (response.statusCode == 200) {
          return extractGeminiResponseText(response.body);
        }

        if (response.statusCode == 429) {
          throw const QuotaExceededException(
            'Превышена квота Gemini API. Подождите некоторое время '
            'или проверьте лимиты в Google AI Studio.',
          );
        }

        if (response.statusCode >= 400 && response.statusCode < 500) {
          // Клиентская ошибка — повторять с теми же данными бессмысленно
          throw GeminiApiException(
              'Ошибка обращения к Gemini API (${response.statusCode}): '
              '${extractGeminiApiErrorMessage(response.body)}');
        }

        // 5xx — считаем потенциально временной, уходим в ветку ретрая ниже
        lastError = GeminiApiException(
            'Ошибка обращения к Gemini API (${response.statusCode}): '
            '${extractGeminiApiErrorMessage(response.body)}');
      } on QuotaExceededException {
        rethrow; // не ретраим, пробрасываем как есть
      } on TimeoutException {
        lastError = NetworkUnavailableException(
          'Не удалось дождаться ответа Gemini за ${timeout.inSeconds} секунд. '
          'Проверьте подключение к интернету и попробуйте снова.',
        );
      } on SocketException {
        lastError = const NetworkUnavailableException(
          'Не удалось подключиться к Gemini. Проверьте интернет и повторите попытку.',
        );
      } on HandshakeException {
        lastError = const NetworkUnavailableException(
          'Не удалось установить защищённое соединение с Gemini. '
          'Проверьте интернет и дату/время устройства.',
        );
      } on http.ClientException {
        lastError = const NetworkUnavailableException(
          'Не удалось установить сетевое соединение с Gemini. '
          'Проверьте интернет и повторите попытку.',
        );
      } on GeminiApiException {
        rethrow; // клиентская 4xx — пробрасываем сразу, без ретрая
      } catch (e) {
        lastError = GeminiApiException('Ошибка обращения к Gemini API: $e');
      }

      if (attempt < maxRetries) {
        final backoffMs = retryBaseDelay.inMilliseconds * pow(2, attempt);
        final jitterMs = _random.nextDouble() * 500;
        final delay = Duration(milliseconds: (backoffMs + jitterMs).round());
        await Future.delayed(delay);
      }
    }

    if (lastError is Exception) throw lastError;
    throw const GeminiApiException('Неизвестная ошибка обращения к Gemini API');
  }

  void dispose() => _client.close();
}
