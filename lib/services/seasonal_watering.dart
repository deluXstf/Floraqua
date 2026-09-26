/// Сезоны по календарным месяцам Северного полушария.
///
/// Это приблизительная подсказка для комнатных растений, а не замена
/// проверке влажности грунта: температура, освещение, горшок и конкретный вид
/// растения тоже влияют на частоту полива.
enum PlantSeason { spring, summer, autumn, winter }

class SeasonalWatering {
  SeasonalWatering._();

  /// Умеренная корректировка базового интервала, полученного от Gemini или
  /// заданного пользователем: летом поливаем чаще, в холодный сезон реже.
  static PlantSeason seasonForDate(DateTime date) => switch (date.month) {
        3 || 4 || 5 => PlantSeason.spring,
        6 || 7 || 8 => PlantSeason.summer,
        9 || 10 || 11 => PlantSeason.autumn,
        _ => PlantSeason.winter,
      };

  static String seasonName(PlantSeason season) => switch (season) {
        PlantSeason.spring => 'весна',
        PlantSeason.summer => 'лето',
        PlantSeason.autumn => 'осень',
        PlantSeason.winter => 'зима',
      };

  static double _multiplier(PlantSeason season) => switch (season) {
        PlantSeason.spring => 1.0,
        PlantSeason.summer => 0.8,
        PlantSeason.autumn => 1.2,
        PlantSeason.winter => 1.5,
      };

  /// Рассчитать эффективный интервал для даты, ограниченный диапазоном 1–30.
  /// Округление сделано до ближайшего целого дня.
  static int frequencyFor(int baseFrequency, DateTime date) {
    final season = seasonForDate(date);
    return (baseFrequency * _multiplier(season)).round().clamp(1, 30).toInt();
  }
}
