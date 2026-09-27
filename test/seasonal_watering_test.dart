import 'package:flutter_test/flutter_test.dart';
import 'package:plant_garden/services/seasonal_watering.dart';

void main() {
  group('SeasonalWatering.seasonForDate', () {
    test('распределяет месяцы по сезонам Северного полушария', () {
      expect(
          SeasonalWatering.seasonName(
            SeasonalWatering.seasonForDate(DateTime(2026, 3, 1)),
          ),
          'весна');
      expect(
          SeasonalWatering.seasonName(
            SeasonalWatering.seasonForDate(DateTime(2026, 6, 1)),
          ),
          'лето');
      expect(
          SeasonalWatering.seasonName(
            SeasonalWatering.seasonForDate(DateTime(2026, 9, 1)),
          ),
          'осень');
      expect(
          SeasonalWatering.seasonName(
            SeasonalWatering.seasonForDate(DateTime(2026, 12, 1)),
          ),
          'зима');
      expect(SeasonalWatering.seasonForDate(DateTime(2026, 1, 1)),
          PlantSeason.winter);
    });
  });

  group('SeasonalWatering.frequencyFor', () {
    test('уменьшает интервал летом и увеличивает осенью/зимой', () {
      expect(SeasonalWatering.frequencyFor(10, DateTime(2026, 4, 1)), 10);
      expect(SeasonalWatering.frequencyFor(10, DateTime(2026, 7, 1)), 8);
      expect(SeasonalWatering.frequencyFor(10, DateTime(2026, 10, 1)), 12);
      expect(SeasonalWatering.frequencyFor(10, DateTime(2026, 1, 1)), 15);
    });

    test('ограничивает результат диапазоном от 1 до 30 дней', () {
      expect(SeasonalWatering.frequencyFor(1, DateTime(2026, 7, 1)), 1);
      expect(SeasonalWatering.frequencyFor(30, DateTime(2026, 1, 1)), 30);
    });

    test('не меняет базовую частоту в весенний период', () {
      expect(SeasonalWatering.frequencyFor(7, DateTime(2026, 5, 15)), 7);
    });
  });
}
