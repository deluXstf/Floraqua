// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Floraqua';

  @override
  String get languageLabel => 'Язык';

  @override
  String get languageRussian => 'Русский';

  @override
  String get languageEnglish => 'English';

  @override
  String get onboardingTitle1 => 'Ваш сад — в одном месте';

  @override
  String get onboardingDescription1 =>
      'Добавляйте любимые растения и находите их по фото. Floraqua сохранит карточки и важную информацию о каждом.';

  @override
  String get onboardingTitle2 => 'Уход с учётом сезона';

  @override
  String get onboardingDescription2 =>
      'Для растений есть подсказки и ориентиры по поливу. Перед поливом всё равно проверяйте влажность грунта.';

  @override
  String get onboardingTitle3 => 'Напоминания под ваш ритм';

  @override
  String get onboardingDescription3 =>
      'Выберите удобное время уведомлений. Для распознавания растений понадобится ваш личный ключ Gemini — он хранится на этом устройстве.';

  @override
  String get onboardingSkip => 'Пропустить';

  @override
  String get onboardingNext => 'Дальше';

  @override
  String get onboardingFinish => 'Перейти к настройке ключа';

  @override
  String onboardingProgress(int page, int total) {
    return '$page из $total';
  }

  @override
  String get onboardingSaveError =>
      'Не удалось сохранить настройки первого запуска. Попробуйте ещё раз.';

  @override
  String get apiGetKeyTitle => 'Получить API-ключ';

  @override
  String get apiClose => 'Закрыть';

  @override
  String get apiEnterKey => 'Введите ключ';

  @override
  String get apiSaveError =>
      'Не удалось сохранить ключ на этом устройстве. Проверьте разрешения и повторите попытку.';

  @override
  String get apiDescription =>
      'Для распознавания растений и советов по уходу нужен персональный ключ Google Gemini API.';

  @override
  String get apiSecurityNotice =>
      'Введите только свой ключ и не отправляйте его другим. Не вшивайте общий ключ разработчика в приложение: для такого режима нужен серверный прокси.';

  @override
  String get apiWhereGetKey => 'Где взять ключ?';

  @override
  String get apiKeyLabel => 'API-ключ Gemini';

  @override
  String get apiShowKey => 'Показать ключ';

  @override
  String get apiHideKey => 'Скрыть ключ';

  @override
  String get commonContinue => 'Продолжить';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get themeTitle => 'Тема оформления';

  @override
  String get settingsSavedOnDevice => 'Выбор сохраняется на этом устройстве';

  @override
  String get themeSystem => 'Как в системе';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get appVersion => 'Версия 1.1.0 (Flutter)';

  @override
  String get exportGardenTitle => 'Экспорт сада (.zip)';

  @override
  String get exportGardenSubtitle =>
      'Данные и фото всех растений — для переноса или резервной копии';

  @override
  String get importGardenTitle => 'Импорт сада (.zip)';

  @override
  String get importGardenSubtitle =>
      'Полностью заменит текущий список растений';

  @override
  String get calendarTitle => 'Календарь полива (.ics)';

  @override
  String get calendarSubtitle =>
      'Сезонные даты на год для календарей Google, Outlook и Apple; экспорт нужно обновлять вручную';

  @override
  String get reminderTitle => 'Время напоминания о поливе';

  @override
  String reminderSubtitle(String time) {
    return 'Напоминать в дни полива в $time';
  }

  @override
  String get changeApiTitle => 'Сменить API-ключ';

  @override
  String get changeApiSubtitle => 'Ввести другой персональный ключ Gemini';

  @override
  String reminderSaved(String time) {
    return 'Напоминания будут приходить в $time';
  }

  @override
  String get reminderSaveError =>
      'Не удалось сохранить время напоминания. Попробуйте ещё раз.';

  @override
  String get exportDialogTitle => 'Сохранить экспорт сада';

  @override
  String get exportSuccess => 'Сад экспортирован';

  @override
  String get exportFailure => 'Не удалось экспортировать сад';

  @override
  String get importConfirmTitle => 'Импорт сада';

  @override
  String get importConfirmBody =>
      'Импорт полностью заменит текущий список растений данными из архива. Перед заменой текущие данные будут сохранены в резервную копию.\n\nПродолжить?';

  @override
  String get commonCancel => 'Отмена';

  @override
  String get commonDelete => 'Удалить';

  @override
  String get commonEdit => 'Изменить';

  @override
  String get importFileDialogTitle => 'Выбрать файл экспорта сада';

  @override
  String get importSuccess => 'Сад импортирован';

  @override
  String get importFailure =>
      'Не удалось импортировать сад. Проверьте, что выбран корректный файл экспорта.';

  @override
  String get calendarSaveDialogTitle => 'Сохранить календарь полива';

  @override
  String get calendarSaved => 'Календарь сохранён';

  @override
  String get calendarSaveFailure => 'Не удалось создать файл календаря';

  @override
  String get changeApiConfirmBody =>
      'Текущий ключ будет удалён. Для дальнейшей работы с приложением нужно будет ввести новый.';

  @override
  String get commonChange => 'Сменить';

  @override
  String get deleteApiKeyError =>
      'Не удалось удалить ключ. Попробуйте ещё раз.';

  @override
  String get gardenSearchHint => 'Поиск по названию растения...';

  @override
  String get viewGrid => 'Сетка';

  @override
  String get viewList => 'Список';

  @override
  String get filterAll => 'Все';

  @override
  String get filterNeedsWater => 'К поливу';

  @override
  String get filterHealthy => 'Здоровы';

  @override
  String get gardenSettingsTooltip => 'Настройки';

  @override
  String get addPlant => 'Добавить растение';

  @override
  String get gardenLoadError => 'Не удалось загрузить сад. Попробуйте ещё раз.';

  @override
  String get gardenSaveViewError => 'Не удалось сохранить вид сада';

  @override
  String get gardenSaveWaterError => 'Не удалось сохранить полив';

  @override
  String get gardenSaveWaterFailure =>
      'Ошибка при сохранении полива. Попробуйте ещё раз.';

  @override
  String get gardenHealthTitle => 'Здоровье сада';

  @override
  String gardenHealthScore(int score) {
    return '$score% растений по графику полива';
  }

  @override
  String healthyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count растения в порядке',
      many: '$count растений в порядке',
      few: '$count растения в порядке',
      one: '$count растение в порядке',
    );
    return '$_temp0';
  }

  @override
  String dueCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count растения нуждаются в поливе',
      many: '$count растений нуждаются в поливе',
      few: '$count растения нуждаются в поливе',
      one: '$count растение нуждается в поливе',
    );
    return '$_temp0';
  }

  @override
  String get emptyGardenTitle => 'Здесь скоро будет ваш сад';

  @override
  String get emptySearchTitle => 'Ничего не найдено';

  @override
  String get emptyGardenDescription =>
      'Добавьте первое растение — Floraqua распознает его по фото и поможет следить за уходом.';

  @override
  String get emptySearchDescription =>
      'Попробуйте изменить поиск или фильтр, чтобы увидеть растения.';

  @override
  String get addFirstPlant => 'Добавить первое растение';

  @override
  String get resetSearch => 'Сбросить поиск и фильтры';

  @override
  String wateringFrequency(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Каждые $count дня',
      many: 'Каждые $count дней',
      few: 'Каждые $count дня',
      one: 'Каждые $count день',
    );
    return '$_temp0';
  }

  @override
  String get seasonSpring => 'весна';

  @override
  String get seasonSummer => 'лето';

  @override
  String get seasonAutumn => 'осень';

  @override
  String get seasonWinter => 'зима';

  @override
  String get plantDetailsTitle => 'Растение';

  @override
  String get plantNotFound => 'Растение больше не найдено.';

  @override
  String get plantActionsTooltip => 'Действия';

  @override
  String get recheckPhoto => 'Перепроверить по фото';

  @override
  String get moreActions => 'Другие действия';

  @override
  String get plantDetails => 'Подробнее';

  @override
  String get deletePlantTitle => 'Удалить растение?';

  @override
  String deletePlantBody(String plant) {
    return '«$plant» будет удалено безвозвратно.';
  }

  @override
  String get deletePlantMenu => 'Удалить растение';

  @override
  String get wateringLabel => 'Полив';

  @override
  String nextWateringDetails(String date, String time) {
    return 'Следующий: $date · уведомление в $time';
  }

  @override
  String get lastWatering => 'Последний полив';

  @override
  String historyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count записи в истории',
      many: '$count записей в истории',
      few: '$count записи в истории',
      one: '$count запись в истории',
    );
    return '$_temp0';
  }

  @override
  String get markWatered => 'Отметить полив';

  @override
  String get careConditions => 'Условия содержания';

  @override
  String get lightLabel => 'Освещение';

  @override
  String get temperatureLabel => 'Температура';

  @override
  String get humidityLabel => 'Влажность воздуха';

  @override
  String get difficultyLabel => 'Сложность ухода';

  @override
  String get baseWateringInterval => 'Базовый интервал полива';

  @override
  String get estimatedWaterAmount => 'Ориентировочная норма';

  @override
  String seasonCurrent(String season) {
    return 'Сейчас: $season';
  }

  @override
  String estimatedWaterFrequency(String frequency) {
    return 'Ориентировочно: $frequency';
  }

  @override
  String get careTips => 'Советы по уходу';

  @override
  String get lastPhotoAssessment => 'Оценка по последнему фото';

  @override
  String get wateringHistory => 'История полива';

  @override
  String get watered => 'Полито';

  @override
  String get myNotes => 'Мои заметки';

  @override
  String get placeAndPot => 'Место и горшок';

  @override
  String get potSize => 'Размер горшка';

  @override
  String get locationLabel => 'Расположение';

  @override
  String get drainageHoles => 'Дренажные отверстия';

  @override
  String get notSpecified => 'Не указано';

  @override
  String get wateringDisclaimer =>
      'График полива — ориентир. Перед поливом проверьте влажность грунта.';

  @override
  String addPhotoPermissionError(String source) {
    return 'Разрешите доступ к источнику «$source» в настройках устройства.';
  }

  @override
  String get permissionCamera => 'камере';

  @override
  String get permissionPhotos => 'фотографиям';

  @override
  String get loadingPhotoAnalysis => 'Анализ фото...';

  @override
  String get plantAdded => 'Растение добавлено';

  @override
  String get loadingPlantCheck => 'Проверка состояния...';

  @override
  String get photoSourceTitle => 'Добавить растение';

  @override
  String get photoSourcePrompt => 'Откуда добавить фотографию?';

  @override
  String get choosePhotoLibrary => 'Выбрать из фотогалереи';

  @override
  String get takePhotoNow => 'Сделать фото сейчас';

  @override
  String get deleteConfirmTitle => 'Удалить растение?';

  @override
  String get wateringSaved => 'Полив сохранён';

  @override
  String get waterNow => 'Полить';

  @override
  String get wateringInProgress => 'Полив…';

  @override
  String get closeViewer => 'Закрыть';

  @override
  String get onboardingError =>
      'Не удалось сохранить первый запуск. Попробуйте ещё раз.';

  @override
  String get plantEditorEditTitle => 'Изменить растение';

  @override
  String get plantEditorNewTitle => 'Новое растение';

  @override
  String get plantNameOptional => 'Название (необязательно)';

  @override
  String get wateringFrequencyField => 'Базовая частота полива (дней)';

  @override
  String get lastWateredDate => 'Дата последнего полива';

  @override
  String get dateWillClear => 'Дата будет очищена';

  @override
  String get dateNotSet => 'Не задана';

  @override
  String get dateDoNotChange => 'Не менять';

  @override
  String get commonClear => 'Очистить';

  @override
  String get wateringIntervalHelp =>
      'Это базовый интервал: приложение корректирует его по сезону. Дата следующего полива пересчитается по выбранной частоте и/или дате последнего полива.';

  @override
  String get notesForAiLabel => 'Другие примечания для ИИ (необязательно)';

  @override
  String get notesForAiHelp =>
      'Это заметка на будущее. ИИ прочитает её при следующем анализе фото («Перепроверить по фото»); сохранение формы ничего не отправляет и ни на что не влияет прямо сейчас.';

  @override
  String get frequencyValidation => 'Укажите число дней от 1 до 30';

  @override
  String get potSmall => 'Маленький (до 10 см)';

  @override
  String get potMedium => 'Средний (10–20 см)';

  @override
  String get potLarge => 'Большой (20–30 см)';

  @override
  String get potExtraLarge => 'Очень большой (30+ см)';

  @override
  String get locationSouthWindow => 'Южное окно';

  @override
  String get locationNorthWindow => 'Северное окно';

  @override
  String get locationEastWindow => 'Восточное окно';

  @override
  String get locationWestWindow => 'Западное окно';

  @override
  String get locationAwayFromWindow => 'Подальше от окна';

  @override
  String get locationBalcony => 'Балкон/лоджия';

  @override
  String get yes => 'Да';

  @override
  String get no => 'Нет';

  @override
  String get unknown => 'Не знаю';

  @override
  String get geminiGenericError => 'Что-то пошло не так. Попробуйте ещё раз.';

  @override
  String get geminiPlantNotFound => 'На фото не удалось распознать растение.';

  @override
  String get geminiQuotaError =>
      'Превышена квота Gemini API. Подождите некоторое время или проверьте лимиты в Google AI Studio.';

  @override
  String geminiApiError(int status) {
    return 'Ошибка обращения к Gemini API (HTTP $status). Проверьте API-ключ и попробуйте ещё раз.';
  }

  @override
  String geminiTimeoutError(int seconds) {
    return 'Gemini не ответил за $seconds сек. Проверьте подключение к интернету и попробуйте ещё раз.';
  }

  @override
  String get geminiNetworkError =>
      'Не удалось подключиться к Gemini. Проверьте интернет. Если вы находитесь в России или другой стране с ограничением доступа к сервису, включите VPN и повторите попытку.';

  @override
  String get geminiSecureConnectionError =>
      'Не удалось установить защищённое соединение с Gemini. Проверьте интернет и дату/время устройства.';

  @override
  String get geminiUnknownError => 'Неизвестная ошибка обращения к Gemini API.';

  @override
  String get notificationTitle => 'Напоминания о поливе';

  @override
  String get notificationDescription => 'Напоминания о поливе растений';

  @override
  String get notificationOpen => 'Открыть Floraqua';

  @override
  String notificationDueTitle(String plant) {
    return 'Пора полить: $plant';
  }

  @override
  String notificationFrequency(String frequency) {
    return 'Периодичность полива: раз в $frequency';
  }

  @override
  String calendarEventTitle(String plant) {
    return 'Полить: $plant';
  }

  @override
  String calendarBaseFrequency(String frequency) {
    return 'Базовый интервал: $frequency';
  }

  @override
  String calendarSeasonalFrequency(String frequency) {
    return 'Сезонный интервал: $frequency';
  }

  @override
  String calendarReminderTime(String time) {
    return 'Время напоминания: $time.';
  }

  @override
  String get calendarCheckSoil => 'Перед поливом проверьте грунт.';

  @override
  String calendarWaterAmount(String amount) {
    return 'Норма полива: $amount';
  }

  @override
  String get difficultyEasy => 'Легко';

  @override
  String get difficultyMedium => 'Средне';

  @override
  String get difficultyHard => 'Сложно';

  @override
  String get monthJanuary => 'января';

  @override
  String get monthFebruary => 'февраля';

  @override
  String get monthMarch => 'марта';

  @override
  String get monthApril => 'апреля';

  @override
  String get monthMay => 'мая';

  @override
  String get monthJune => 'июня';

  @override
  String get monthJuly => 'июля';

  @override
  String get monthAugust => 'августа';

  @override
  String get monthSeptember => 'сентября';

  @override
  String get monthOctober => 'октября';

  @override
  String get monthNovember => 'ноября';

  @override
  String get monthDecember => 'декабря';

  @override
  String wateringDaysShort(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count дн.',
      many: '$count дн.',
      few: '$count дн.',
      one: '$count дн.',
    );
    return '$_temp0';
  }

  @override
  String get themeSaveError => 'Не удалось сохранить тему. Попробуйте ещё раз.';

  @override
  String get localeSaveError =>
      'Не удалось сохранить язык. Попробуйте ещё раз.';

  @override
  String get openPhotoFullSize => 'Двойной клик — открыть в полный размер';
}
