/// Собрать структурированный блок условий содержания для prompt.
String buildGeminiContextBlock({
  String? potSize,
  String? location,
  String? hasDrainage,
  String? userNotes,
  String localeCode = 'ru',
}) {
  final english = localeCode == 'en';
  final lines = <String>[];
  if (potSize != null && potSize.isNotEmpty) {
    lines.add(
      english
          ? '- Pot size: ${_translateContextValue(potSize, localeCode)}'
          : '- Размер горшка: $potSize',
    );
  }
  if (location != null && location.isNotEmpty) {
    lines.add(
      english
          ? '- Location: ${_translateContextValue(location, localeCode)}'
          : '- Место расположения: $location',
    );
  }
  if (hasDrainage != null && hasDrainage.isNotEmpty) {
    lines.add(
      english
          ? '- Drainage holes: ${_translateContextValue(hasDrainage, localeCode)}'
          : '- Дренажные отверстия в горшке: $hasDrainage',
    );
  }
  if (userNotes != null && userNotes.trim().isNotEmpty) {
    lines.add(english
        ? '- User notes: ${userNotes.trim()}'
        : '- Заметки пользователя: ${userNotes.trim()}');
  }

  if (lines.isEmpty) return '';

  return english
      ? '\n\nAdditional growing conditions for this plant (consider them when assessing its condition, watering, and care):\n${lines.join('\n')}'
      : '\n\nДополнительная информация об условиях содержания этого растения '
          '(обязательно учти её при оценке состояния, поливе и советах по уходу):\n'
          '${lines.join('\n')}';
}

String _translateContextValue(String value, String localeCode) {
  if (localeCode != 'en') return value;
  return switch (value) {
    'Маленький (до 10 см)' => 'Small (up to 10 cm)',
    'Средний (10-20 см)' || 'Средний (10–20 см)' => 'Medium (10–20 cm)',
    'Большой (20-30 см)' || 'Большой (20–30 см)' => 'Large (20–30 cm)',
    'Очень большой (30+ см)' => 'Extra large (30+ cm)',
    'Южное окно' => 'South-facing window',
    'Северное окно' => 'North-facing window',
    'Восточное окно' => 'East-facing window',
    'Западное окно' => 'West-facing window',
    'Подальше от окна' => 'Away from a window',
    'Балкон/лоджия' || 'Балкон / лоджия' => 'Balcony / loggia',
    'Да' => 'Yes',
    'Нет' => 'No',
    'Не знаю' => "Don't know",
    _ => value,
  };
}

const String identifyPlantPrompt = '''
Проанализируй изображение растения.
Если НЕТ растения: {"error": "Растение не обнаружено"}
Если ЕСТЬ растение, верни JSON:
{
 "name": "название на русском",
 "scientific_name": "латинское название",
 "watering_frequency": число_дней (1-30),
 "watering_amount": "объём (например: 200-300 мл)",
 "light_requirements": "яркий свет/полутень/тень",
 "temperature": "диапазон (например: 18-24°C)",
 "humidity": "низкая/средняя/высокая",
 "care_tips": "краткие советы",
 "difficulty": "легко/средне/сложно",
 "needs_water_now": true или false (оцени по видимому состоянию почвы и тургору листьев на фото),
 "moisture_notes": "краткое пояснение на русском (1 предложение), на основе чего сделан вывод"
}
Учти при оценке ВСЮ переданную ниже дополнительную информацию (размер горшка,
место расположения, дренаж и заметки пользователя), если она есть — это
напрямую влияет на реальную частоту полива и советы по уходу (например,
маленький горшок на южном окне сохнет намного быстрее, чем большой горшок
в тени; отсутствие дренажных отверстий — риск переувлажнения и загнивания
корней, об этом стоит упомянуть в care_tips). Если пользователь пишет в
заметках, что только что полил растение — НЕ отмечай needs_water_now как true.
Отвечай ТОЛЬКО JSON.''';

const String moisturePrompt = '''
Посмотри на фото растения и оцени, нуждается ли оно в поливе прямо сейчас.
Обрати внимание на: цвет и видимую сухость почвы, тургор листьев (упругие или вялые),
подсыхание краёв листьев и другие визуальные признаки.
Верни ТОЛЬКО JSON:
{
 "needs_water_now": true или false,
 "moisture_notes": "краткое пояснение на русском (1-2 предложения)"
}''';

String identifyPlantPromptFor(String localeCode) => localeCode == 'en'
    ? '''Analyze the plant in the image.
If no plant is visible, return {"error": "No plant detected"}.
If a plant is visible, return only this JSON:
{
 "name": "common plant name in English",
 "scientific_name": "Latin scientific name",
 "watering_frequency": number_of_days (1-30),
 "watering_amount": "estimated amount (for example: 200-300 ml)",
 "light_requirements": "bright indirect light/partial shade/shade",
 "temperature": "range (for example: 18-24°C)",
 "humidity": "low/medium/high",
 "care_tips": "brief practical care tips in English",
 "difficulty": "easy/moderate/challenging",
 "needs_water_now": true or false (based on visible soil and leaf turgor),
 "moisture_notes": "brief explanation in English (1-2 sentences)"
}
Consider all additional growing conditions below when assessing care and watering. A small pot in a sunny window dries faster than a large pot in shade; no drainage holes increase the risk of overwatering and root rot. If the user's notes say the plant was just watered, do not set needs_water_now to true. Return JSON only.'''
    : identifyPlantPrompt;

String moisturePromptFor(String localeCode) => localeCode == 'en'
    ? '''Look at the plant photo and assess whether it needs watering right now.
Consider soil color and visible dryness, leaf turgor (firm or wilted), dry leaf edges, and other visual clues.
Return JSON only:
{
 "needs_water_now": true or false,
 "moisture_notes": "brief explanation in English (1-2 sentences)"
}'''
    : moisturePrompt;
