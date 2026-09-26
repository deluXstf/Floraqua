import 'package:flutter_test/flutter_test.dart';
import 'package:plant_garden/models/plant.dart';

Plant _plant() => Plant(
      id: 1,
      name: 'Фикус',
      customName: 'Домашний фикус',
      scientificName: 'Ficus elastica',
      imagePath: '/photos/ficus.jpg',
      wateringFrequency: 10,
      wateringAmount: '200 мл',
      lightRequirements: 'Рассеянный свет',
      temperature: '18-24°C',
      humidity: 'Средняя',
      careTips: 'Проверять грунт',
      difficulty: 'легко',
      lastWatered: DateTime(2026, 9, 1),
      nextWatering: DateTime(2026, 9, 11),
      wateringHistory: [DateTime(2026, 8, 20), DateTime(2026, 9, 1)],
      lastNotified: DateTime(2026, 9, 2),
      potSize: 'Средний',
      location: 'Южное окно',
      hasDrainage: 'Да',
      userNotes: 'Не ставить на сквозняк',
    );

void main() {
  test('Plant JSON serialization round-trip preserves data', () {
    final original = _plant();
    final restored = Plant.fromJson(original.toJson());

    expect(restored.id, original.id);
    expect(restored.displayName, original.displayName);
    expect(restored.scientificName, original.scientificName);
    expect(restored.imagePath, original.imagePath);
    expect(restored.wateringFrequency, original.wateringFrequency);
    expect(restored.nextWatering, original.nextWatering);
    expect(restored.wateringHistory, original.wateringHistory);
    expect(restored.userNotes, original.userNotes);
  });

  test('copyWith can explicitly clear nullable fields', () {
    final cleared = _plant().copyWith(
      customName: null,
      imagePath: null,
      lastWatered: null,
      lastNotified: null,
      potSize: null,
      location: null,
      hasDrainage: null,
      userNotes: null,
    );

    expect(cleared.customName, isNull);
    expect(cleared.imagePath, isNull);
    expect(cleared.lastWatered, isNull);
    expect(cleared.lastNotified, isNull);
    expect(cleared.potSize, isNull);
    expect(cleared.location, isNull);
    expect(cleared.hasDrainage, isNull);
    expect(cleared.userNotes, isNull);
  });

  test('copyWith leaves nullable fields unchanged when omitted', () {
    final updated = _plant().copyWith(name: 'Фикус обновлён');

    expect(updated.name, 'Фикус обновлён');
    expect(updated.customName, 'Домашний фикус');
    expect(updated.imagePath, '/photos/ficus.jpg');
    expect(updated.lastWatered, DateTime(2026, 9, 1));
  });

  test('fromJson tolerates missing optional fields from older backups', () {
    final plant = Plant.fromJson({
      'id': 2,
      'name': 'Пеперомия',
      'watering_frequency': 7,
      'next_watering': '2026-10-03T09:00:00.000',
    });

    expect(plant.name, 'Пеперомия');
    expect(plant.customName, isNull);
    expect(plant.wateringHistory, isEmpty);
    expect(plant.wateringFrequency, 7);
  });

  test('fromJson clamps invalid watering frequency to supported range', () {
    final tooLow = Plant.fromJson({
      'id': 3,
      'name': 'Растение',
      'watering_frequency': 0,
    });
    final tooHigh = Plant.fromJson({
      'id': 4,
      'name': 'Растение',
      'watering_frequency': 100,
    });

    expect(tooLow.wateringFrequency, 1);
    expect(tooHigh.wateringFrequency, 30);
  });
}
