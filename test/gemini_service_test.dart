// Тесты GeminiService — прямое зеркало test_plant_garden_app.py (Python-версия).
// Мокаем не "датчики" (их нет), а сам HTTP-слой — через http.testing.MockClient,
// без build_runner/кодогенерации, чтобы было проще проверить вручную без SDK
// под рукой (см. предупреждение в plan-документе о невозможности прогнать это
// здесь автоматически).
//
// Запуск: flutter test test/gemini_service_test.dart

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:plant_garden/services/gemini_service.dart';
import 'package:plant_garden/services/gemini_prompts.dart';

http.Response _okResponse(String text) {
  final body = jsonEncode({
    'candidates': [
      {
        'content': {
          'parts': [
            {'text': text}
          ]
        }
      }
    ]
  });
  return _utf8Response(body, 200);
}

http.Response _errorResponse(int code, {String message = 'error'}) {
  return _utf8Response(jsonEncode({'error': message}), code);
}

/// Собрать http.Response с гарантированно корректной обработкой кириллицы.
///
/// ВАЖНО: обычный конструктор http.Response(String body, int statusCode)
/// в разных версиях пакета http вёл себя по-разному с не-ASCII текстом —
/// либо по умолчанию кодировал в Latin-1 (что падает на кириллице вроде
/// "норм"/"Фикус" с ошибкой "Invalid argument (string): Contains invalid
/// characters"), либо (как в установленной здесь версии 1.6.0) вообще не
/// принимает именованный параметр encoding для явного переопределения.
/// Response.bytes() обходит эту нестабильность API целиком: мы сами кодируем
/// строку в байты через utf8.encode(...) и передаём уже готовые байты — от
/// точной сигнатуры строкового конструктора это больше не зависит. Заголовок
/// charset=utf-8 нужен на случай, если сервис или сам http-пакет будут
/// определять кодировку ДЕКОДИРОВАНИЯ (response.body) по заголовкам.
http.Response _utf8Response(String body, int statusCode) {
  return http.Response.bytes(
    utf8.encode(body),
    statusCode,
    headers: {'content-type': 'application/json; charset=utf-8'},
  );
}

void main() {
  group('GeminiService retry policy', () {
    test('успешный ответ с первой попытки — без ретраев', () async {
      var calls = 0;
      final client = MockClient((request) async {
        calls++;
        return _okResponse(
            '{"needs_water_now": false, "moisture_notes": "норм"}');
      });

      final service = GeminiService(apiKey: 'test', client: client);
      final result = await service.assessWateringByPhoto(imageBytes: [1, 2, 3]);

      expect(result['needs_water_now'], false);
      expect(calls, 1);
    });

    test('сбой сети, затем успех — должен вернуть результат после повтора',
        () async {
      var calls = 0;
      final client = MockClient((request) async {
        calls++;
        if (calls == 1) throw const SocketException('network down');
        return _okResponse(
            '{"needs_water_now": false, "moisture_notes": "норм"}');
      });

      final service = GeminiService(apiKey: 'test', client: client);
      final result = await service.assessWateringByPhoto(imageBytes: [1, 2, 3]);

      expect(result['needs_water_now'], false);
      expect(calls, 2);
    });

    test('постоянное отсутствие сети возвращает отдельную Network-ошибку',
        () async {
      var calls = 0;
      final client = MockClient((request) async {
        calls++;
        throw const SocketException('offline');
      });
      final service = GeminiService(apiKey: 'test', client: client);

      await expectLater(
        service.assessWateringByPhoto(imageBytes: [1, 2, 3]),
        throwsA(isA<NetworkUnavailableException>().having(
          (error) => error.message,
          'message',
          contains('Проверьте интернет'),
        )),
      );
      expect(calls, GeminiService.maxRetries + 1);
    });

    test('квота (429) — НЕ ретраится, сразу QuotaExceededException', () async {
      var calls = 0;
      final client = MockClient((request) async {
        calls++;
        return _errorResponse(429);
      });

      final service = GeminiService(apiKey: 'test', client: client);

      await expectLater(
        service.assessWateringByPhoto(imageBytes: [1, 2, 3]),
        throwsA(isA<QuotaExceededException>()),
      );
      expect(calls, 1);
    });

    test('клиентская ошибка 400 — НЕ ретраится', () async {
      var calls = 0;
      final client = MockClient((request) async {
        calls++;
        return _errorResponse(400, message: 'bad request');
      });

      final service = GeminiService(apiKey: 'test', client: client);

      await expectLater(
        service.assessWateringByPhoto(imageBytes: [1, 2, 3]),
        throwsA(isA<GeminiApiException>()),
      );
      expect(calls, 1);
    });

    test('серверная ошибка 500 — ДОЛЖНА ретраиться, в отличие от 4xx',
        () async {
      var calls = 0;
      final client = MockClient((request) async {
        calls++;
        if (calls == 1) return _errorResponse(500);
        return _okResponse(
            '{"needs_water_now": true, "moisture_notes": "сухо"}');
      });

      final service = GeminiService(apiKey: 'test', client: client);
      final result = await service.assessWateringByPhoto(imageBytes: [1, 2, 3]);

      expect(result['needs_water_now'], true);
      expect(calls, 2);
    });

    test('постоянный сбой — исчерпывает ретраи и падает GeminiApiException',
        () async {
      var calls = 0;
      final client = MockClient((request) async {
        calls++;
        return _errorResponse(503);
      });

      final service = GeminiService(apiKey: 'test', client: client);

      await expectLater(
        service.assessWateringByPhoto(imageBytes: [1, 2, 3]),
        throwsA(isA<GeminiApiException>()),
      );
      // maxRetries=2 → максимум 3 попытки суммарно
      expect(calls, GeminiService.maxRetries + 1);
    });
  });

  group('identifyPlant', () {
    test('English locale provides English identification and context prompts', () {
      expect(identifyPlantPromptFor('en'), contains('common plant name in English'));
      expect(
        buildGeminiContextBlock(potSize: 'Medium', localeCode: 'en'),
        contains('Additional growing conditions'),
      );
      expect(
        buildGeminiContextBlock(potSize: 'Medium', localeCode: 'en'),
        contains('Pot size: Medium'),
      );
    });

    test('некорректный JSON от модели возвращает понятную ошибку сервиса',
        () async {
      final client = MockClient((request) async => _okResponse('это не JSON'));
      final service = GeminiService(apiKey: 'test', client: client);

      await expectLater(
        service.identifyPlant(imageBytes: [1, 2, 3]),
        throwsA(
          isA<GeminiApiException>().having(
            (error) => error.message,
            'message',
            contains('неожиданном формате'),
          ),
        ),
      );
    });

    test('растение не распознано — бросает PlantNotRecognizedException',
        () async {
      final client = MockClient((request) async {
        return _okResponse('{"error": "Растение не обнаружено"}');
      });

      final service = GeminiService(apiKey: 'test', client: client);

      await expectLater(
        service.identifyPlant(imageBytes: [1, 2, 3]),
        throwsA(isA<PlantNotRecognizedException>()),
      );
    });

    test('структурированные условия попадают в тело запроса', () async {
      String? capturedBody;
      final client = MockClient((request) async {
        capturedBody = request.body;
        return _okResponse(
          '{"name": "Фикус", "scientific_name": "Ficus", "watering_frequency": 10, '
          '"watering_amount": "200 мл", "light_requirements": "яркий", '
          '"temperature": "20°C", "humidity": "средняя", "care_tips": "норм", '
          '"difficulty": "легко", "needs_water_now": false, "moisture_notes": "норм"}',
        );
      });

      final service = GeminiService(apiKey: 'test', client: client);
      final plant = await service.identifyPlant(
        imageBytes: [1, 2, 3],
        potSize: 'Маленький (до 10 см)',
        location: 'Южное окно',
        hasDrainage: 'Да',
        userNotes: 'пересадили неделю назад',
      );

      expect(plant['name'], 'Фикус');
      expect(capturedBody, contains('Маленький (до 10 см)'));
      expect(capturedBody, contains('Южное окно'));
      expect(capturedBody, contains('пересадили неделю назад'));
    });
  });

  group('parseWateringFrequency', () {
    test('валидное целое число', () {
      expect(parseWateringFrequency(7), 7);
    });

    test('обрезается до максимума 30', () {
      expect(parseWateringFrequency(100), 30);
    });

    test('обрезается до минимума 1', () {
      expect(parseWateringFrequency(0), 1);
    });

    test('достаёт число из текста "раз в 7 дней"', () {
      expect(parseWateringFrequency('раз в 7 дней'), 7);
    });

    test('нет числа в тексте — используется значение по умолчанию', () {
      expect(parseWateringFrequency('иногда', fallback: 7), 7);
    });

    test('null — используется значение по умолчанию', () {
      expect(parseWateringFrequency(null, fallback: 7), 7);
    });
  });

  test('неполный ответ identifyPlant превращается в понятную ошибку', () async {
    final client = MockClient((request) async => _okResponse(
          '{"watering_frequency": 7}',
        ));
    final service = GeminiService(apiKey: 'test', client: client);

    await expectLater(
      service.identifyPlant(imageBytes: [1, 2, 3]),
      throwsA(isA<GeminiApiException>()),
    );
  });

  test('пустой или заблокированный ответ Gemini не приводит к TypeError', () async {
    final client = MockClient((request) async => _utf8Response(
          jsonEncode({'candidates': []}),
          200,
        ));
    final service = GeminiService(apiKey: 'test', client: client);

    await expectLater(
      service.assessWateringByPhoto(imageBytes: [1, 2, 3]),
      throwsA(isA<GeminiApiException>()),
    );
  });

}
