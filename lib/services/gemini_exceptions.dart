/// Квота Gemini API исчерпана (HTTP 429).
class QuotaExceededException implements Exception {
  final String message;
  const QuotaExceededException(this.message);
  @override
  String toString() => message;
}

/// Gemini вернул отказ API (4xx/5xx) или некорректный формат ответа.
class GeminiApiException implements Exception {
  final String message;
  const GeminiApiException(this.message);
  @override
  String toString() => message;
}

/// Сеть недоступна или соединение с Google не удалось установить.
class NetworkUnavailableException implements Exception {
  final String message;
  const NetworkUnavailableException(this.message);
  @override
  String toString() => message;
}

/// Ответ модели корректен, но на фото нет подходящего растения.
class PlantNotRecognizedException implements Exception {
  final String message;
  const PlantNotRecognizedException(this.message);
  @override
  String toString() => message;
}
