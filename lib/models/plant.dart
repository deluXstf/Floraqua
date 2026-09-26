/// Модель растения — прямой аналог plant-словаря из Python-версии
/// (plant_garden_app.py), но со строгой типизацией вместо Dict[str, Any].
///
/// Поля намеренно называются так же, как ключи в my_garden.json, чтобы при
/// желании можно было один раз мигрировать существующие данные пользователя
/// (см. PlantStore.migrateFromLegacyJson) без переименования на лету.
const Object _copyWithUnchanged = Object();

T? _nullableCopy<T>(Object? value, T? current) =>
    identical(value, _copyWithUnchanged) ? current : value as T?;

class Plant {
  final int id;
  final String name;
  final String? customName;
  final String scientificName;
  final String? imagePath;

  final int
      wateringFrequency; // дней между поливами, 1-30 (см. clampWateringFrequency)
  final String wateringAmount;
  final String lightRequirements;
  final String temperature;
  final String humidity;
  final String careTips;
  final String difficulty; // "легко" / "средне" / "сложно"

  final DateTime? lastWatered;
  final DateTime nextWatering;
  final List<DateTime> wateringHistory;

  final bool needsWaterNowDetected;
  final String moistureNotes;
  final DateTime? lastNotified;

  // Структурированные условия содержания — добавлены, чтобы Gemini мог давать
  // более точные рекомендации Gemini, учитывающие эти условия содержания.
  final String? potSize;
  final String? location;
  final String? hasDrainage;
  final String? userNotes;

  const Plant({
    required this.id,
    required this.name,
    this.customName,
    this.scientificName = '',
    this.imagePath,
    required this.wateringFrequency,
    this.wateringAmount = '200-300 мл',
    this.lightRequirements = 'Умеренное',
    this.temperature = '18-24°C',
    this.humidity = 'Средняя',
    this.careTips = 'Регулярный уход',
    this.difficulty = 'средне',
    this.lastWatered,
    required this.nextWatering,
    this.wateringHistory = const <DateTime>[],
    this.needsWaterNowDetected = false,
    this.moistureNotes = '',
    this.lastNotified,
    this.potSize,
    this.location,
    this.hasDrainage,
    this.userNotes,
  });

  /// Отображаемое имя — пользовательское, если задано, иначе распознанное ИИ.
  /// Аналог plant['custom_name'] or plant['name'] в Python-версии.
  String get displayName =>
      (customName != null && customName!.isNotEmpty) ? customName! : name;

  /// Нужен ли полив прямо сейчас — по расписанию (аналог check_watering_needs)
  bool needsWaterBySchedule([DateTime? now]) {
    final n = now ?? DateTime.now();
    return !nextWatering.isAfter(n);
  }

  Plant copyWith({
    Object? customName = _copyWithUnchanged,
    String? name,
    String? scientificName,
    Object? imagePath = _copyWithUnchanged,
    int? wateringFrequency,
    String? wateringAmount,
    String? lightRequirements,
    String? temperature,
    String? humidity,
    String? careTips,
    String? difficulty,
    Object? lastWatered = _copyWithUnchanged,
    DateTime? nextWatering,
    List<DateTime>? wateringHistory,
    bool? needsWaterNowDetected,
    String? moistureNotes,
    Object? lastNotified = _copyWithUnchanged,
    Object? potSize = _copyWithUnchanged,
    Object? location = _copyWithUnchanged,
    Object? hasDrainage = _copyWithUnchanged,
    Object? userNotes = _copyWithUnchanged,
  }) {
    return Plant(
      id: id,
      name: name ?? this.name,
      customName: _nullableCopy<String>(customName, this.customName),
      scientificName: scientificName ?? this.scientificName,
      imagePath: _nullableCopy<String>(imagePath, this.imagePath),
      wateringFrequency: wateringFrequency ?? this.wateringFrequency,
      wateringAmount: wateringAmount ?? this.wateringAmount,
      lightRequirements: lightRequirements ?? this.lightRequirements,
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      careTips: careTips ?? this.careTips,
      difficulty: difficulty ?? this.difficulty,
      lastWatered: _nullableCopy<DateTime>(lastWatered, this.lastWatered),
      nextWatering: nextWatering ?? this.nextWatering,
      wateringHistory: wateringHistory ?? this.wateringHistory,
      needsWaterNowDetected:
          needsWaterNowDetected ?? this.needsWaterNowDetected,
      moistureNotes: moistureNotes ?? this.moistureNotes,
      lastNotified: _nullableCopy<DateTime>(lastNotified, this.lastNotified),
      potSize: _nullableCopy<String>(potSize, this.potSize),
      location: _nullableCopy<String>(location, this.location),
      hasDrainage: _nullableCopy<String>(hasDrainage, this.hasDrainage),
      userNotes: _nullableCopy<String>(userNotes, this.userNotes),
    );
  }

  factory Plant.fromJson(Map<String, dynamic> json) {
    return Plant(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Растение',
      customName: json['custom_name'] as String?,
      scientificName: json['scientific_name'] as String? ?? '',
      imagePath: json['image_path'] as String?,
      wateringFrequency: clampWateringFrequency(
        (json['watering_frequency'] as num?)?.toInt() ?? 7,
      ),
      wateringAmount: json['watering_amount'] as String? ?? '200-300 мл',
      lightRequirements: json['light_requirements'] as String? ?? 'Умеренное',
      temperature: json['temperature'] as String? ?? '18-24°C',
      humidity: json['humidity'] as String? ?? 'Средняя',
      careTips: json['care_tips'] as String? ?? 'Регулярный уход',
      difficulty: json['difficulty'] as String? ?? 'средне',
      lastWatered: _parseDate(json['last_watered']),
      nextWatering: _parseDate(json['next_watering']) ?? DateTime.now(),
      wateringHistory: (json['watering_history'] as List<dynamic>?)
              ?.map((e) => _parseDate(e))
              .whereType<DateTime>()
              .toList() ??
          const <DateTime>[],
      needsWaterNowDetected: json['needs_water_now_detected'] as bool? ?? false,
      moistureNotes: json['moisture_notes'] as String? ?? '',
      lastNotified: _parseDate(json['last_notified']),
      potSize: json['pot_size'] as String?,
      location: json['location'] as String?,
      hasDrainage: json['has_drainage'] as String?,
      userNotes: json['user_notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'custom_name': customName,
        'scientific_name': scientificName,
        'image_path': imagePath,
        'watering_frequency': wateringFrequency,
        'watering_amount': wateringAmount,
        'light_requirements': lightRequirements,
        'temperature': temperature,
        'humidity': humidity,
        'care_tips': careTips,
        'difficulty': difficulty,
        'last_watered': lastWatered?.toIso8601String(),
        'next_watering': nextWatering.toIso8601String(),
        'watering_history':
            wateringHistory.map((d) => d.toIso8601String()).toList(),
        'needs_water_now_detected': needsWaterNowDetected,
        'moisture_notes': moistureNotes,
        'last_notified': lastNotified?.toIso8601String(),
        'pot_size': potSize,
        'location': location,
        'has_drainage': hasDrainage,
        'user_notes': userNotes,
      };

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is String && value.isEmpty) return null;
    try {
      return DateTime.parse(value as String);
    } catch (_) {
      return null; // как и в Python-версии — битая дата не должна ронять всё приложение
    }
  }
}

/// Ограничить частоту полива диапазоном 1-30 дней — прямой аналог
/// clamp-логики внутри _parse_watering_frequency в Python-версии.
int clampWateringFrequency(int days) => days.clamp(1, 30);
