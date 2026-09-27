import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

import '../models/plant.dart';
import 'gemini_service.dart';
import 'notification_service.dart';
import 'seasonal_watering.dart';

/// Слой данных — прямой порт PlantGardenApp (plant_garden_app.py,
/// Python-версия): загрузка/сохранение сада, CRUD над растениями, сохранение
/// фото с ресайзом. Вызовы к Gemini вынесены в отдельный GeminiService
/// (внедряется через конструктор) — та же граница ответственности, что и
/// в Python-версии, просто теперь она явно видна в сигнатуре класса, а не
/// просто "все методы в одном файле".
///
/// extends ChangeNotifier — идиоматичный Flutter-способ сообщить UI, что
/// данные изменились (аналога в Python-версии не было: там после каждого
/// изменения вызывался refresh_garden() вручную из main.py).
class PlantStore extends ChangeNotifier {
  final GeminiService geminiService;
  final NotificationService? notificationService;
  final Directory? supportDirectoryOverride;
  String localeCode;

  List<Plant> _plants = [];
  List<Plant> get plants => List.unmodifiable(_plants);

  Directory? _appDir;
  Directory? _imagesDir;
  File? _gardenFile;
  Future<void> _saveQueue = Future<void>.value();

  PlantStore({
    required this.geminiService,
    this.notificationService,
    this.supportDirectoryOverride,
    this.localeCode = 'ru',
  });

  Future<void> updateLocale(String code) async {
    if (code != 'ru' && code != 'en') return;
    localeCode = code;
    geminiService.localeCode = code;
    if (notificationService != null) {
      notificationService!.localeCode = code;
      for (final plant in _plants) {
        try {
          await notificationService!.scheduleWateringReminder(plant);
        } catch (error) {
          debugPrint('Could not refresh a reminder after changing language: $error');
        }
      }
    }
  }

  int get reminderHour => notificationService?.reminderHour ?? 9;
  int get reminderMinute => notificationService?.reminderMinute ?? 0;
  String get reminderTimeLabel =>
      notificationService?.reminderTimeLabel ?? '09:00';

  Future<void> updateReminderTime(int hour, int minute) async {
    notificationService?.setReminderTime(hour, minute);
    notifyListeners();
    for (final plant in _plants) {
      await notificationService?.scheduleWateringReminder(plant);
    }
  }

  /// Найти растение по id — единая точка поиска (аналог get_plant)
  Plant? getPlant(int id) {
    for (final p in _plants) {
      if (p.id == id) return p;
    }
    return null;
  }

  // ---------------------------------------------------------------------
  // Инициализация и пути — аналог self.app_dir/self.images_dir/self.garden_file
  // ---------------------------------------------------------------------

  Future<void> _ensureInitialized() async {
    if (_appDir != null) return;

    final support =
        supportDirectoryOverride ?? await getApplicationSupportDirectory();
    _appDir = Directory('${support.path}/plant_garden');
    await _appDir!.create(recursive: true);

    _imagesDir = Directory('${_appDir!.path}/plant_images');
    await _imagesDir!.create(recursive: true);

    _gardenFile = File('${_appDir!.path}/my_garden.json');
  }

  /// Загрузить сад с диска — вызвать один раз при старте приложения.
  /// При повреждении основного файла пробует восстановиться из .backup.
  Future<void> loadGarden() async {
    await _ensureInitialized();
    try {
      if (await _gardenFile!.exists()) {
        _plants = await _readPlantsFile(_gardenFile!);
      }
    } catch (e) {
      debugPrint('Ошибка загрузки основного файла сада: $e');
      final backupFile = File('${_gardenFile!.path}.backup');
      try {
        if (await backupFile.exists()) {
          _plants = await _readPlantsFile(backupFile);
          await backupFile.copy(_gardenFile!.path);
          debugPrint('Сад восстановлен из резервной копии');
        } else {
          _plants = [];
        }
      } catch (backupError) {
        debugPrint('Ошибка восстановления резервной копии: $backupError');
        _plants = [];
      }
    }
    await refreshSeasonalWatering(notify: false);
    notifyListeners();

    // Перепланируем напоминания для всего сада при каждом старте приложения —
    // на случай, если пользователь менял системное время, переустанавливал
    // приложение, или уведомление почему-то не сохранилось у ОС. Дешёвая
    // операция (локальный вызов плагина), безопасно делать при каждой загрузке.
    for (final plant in _plants) {
      await notificationService?.scheduleWateringReminder(plant);
    }
  }

  /// Сохранить сад на диск с резервной копией и восстановлением после сбоя.
  /// На Windows rename поверх существующего файла может завершиться ошибкой,
  /// поэтому целевой файл удаляется только после создания backup.
  Future<bool> _saveGarden() {
    final result = _saveQueue.then((_) => _saveGardenOnce());
    _saveQueue = result.then<void>((_) {}, onError: (_, __) {});
    return result;
  }

  Future<bool> _saveGardenOnce() async {
    await _ensureInitialized();
    final tempFile = File('${_gardenFile!.path}.tmp');
    final backupFile = File('${_gardenFile!.path}.backup');
    try {
      final jsonList = _plants.map((p) => p.toJson()).toList();
      await tempFile.writeAsString(
        const JsonEncoder.withIndent('  ').convert(jsonList),
        flush: true,
      );

      if (await _gardenFile!.exists()) {
        await _gardenFile!.copy(backupFile.path);
        await _gardenFile!.delete();
      }
      await tempFile.rename(_gardenFile!.path);
      return true;
    } catch (e) {
      debugPrint('Ошибка сохранения сада: $e');
      try {
        if (!await _gardenFile!.exists() && await backupFile.exists()) {
          await backupFile.copy(_gardenFile!.path);
        }
        if (await tempFile.exists()) await tempFile.delete();
      } catch (restoreError) {
        debugPrint('Не удалось восстановить файл сада после сбоя: $restoreError');
      }
      return false;
    }
  }

  Future<List<Plant>> _readPlantsFile(File file) async {
    final decoded = jsonDecode(await file.readAsString());
    if (decoded is! List) {
      throw const FormatException('Файл сада должен содержать JSON-массив');
    }
    final plants = <Plant>[];
    for (final item in decoded) {
      if (item is! Map<String, dynamic>) continue;
      try {
        plants.add(Plant.fromJson(item));
      } catch (e) {
        debugPrint('Пропущена повреждённая запись растения: $e');
      }
    }
    return plants;
  }

  // ---------------------------------------------------------------------
  // Сохранение фото — аналог save_plant_image (ресайз + перекодирование в JPEG)
  // ---------------------------------------------------------------------

  /// Сохранить фото растения рядом с данными приложения, с ресайзом до
  /// максимум 800×800 и перекодированием в JPEG (качество 85) — то же самое,
  /// что делает Pillow в Python-версии (thumbnail + save JPEG quality=85).
  Future<String?> _savePlantImage(String sourcePath, int plantId) async {
    await _ensureInitialized();
    try {
      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) return null;

      final bytes = await sourceFile.readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return null;

      // thumbnail-логика: уменьшаем, только если фото КРУПНЕЕ 800px по
      // большей стороне — как Pillow's img.thumbnail((800,800)) в Python-
      // версии, которая никогда не увеличивает маленькие фото, только
      // уменьшает большие. Без этой проверки copyResize растянул бы даже
      // маленькие исходники до 800px, теряя в качестве без необходимости.
      final maxDimension =
          decoded.width > decoded.height ? decoded.width : decoded.height;
      final resized = maxDimension > 800
          ? img.copyResize(
              decoded,
              width: decoded.width >= decoded.height ? 800 : null,
              height: decoded.height > decoded.width ? 800 : null,
              interpolation: img.Interpolation.linear,
            )
          : decoded;

      final jpegBytes = img.encodeJpg(resized, quality: 85);
      final destPath = '${_imagesDir!.path}/plant_$plantId.jpg';
      await File(destPath).writeAsBytes(jpegBytes);
      return destPath;
    } catch (e) {
      debugPrint('Ошибка сохранения изображения: $e');
      return null;
    }
  }

  // ---------------------------------------------------------------------
  // CRUD — прямой порт add_plant/water_plant/update_plant/delete_plant
  // ---------------------------------------------------------------------

  /// Добавить растение по фото. Бросает исключения GeminiService
  /// (QuotaExceededException/GeminiApiException/NetworkUnavailableException/
  /// PlantNotRecognizedException) — вызывающий код (UI) должен их поймать
  /// и показать понятное сообщение, точно как в Python-версии, где эти
  /// ошибки намеренно не перехватывались в add_plant().
  Future<Plant> addPlant({
    required String imagePath,
    String? customName,
    String? userNotes,
    String? potSize,
    String? location,
    String? hasDrainage,
  }) async {
    await _ensureInitialized();

    final bytes = await File(imagePath).readAsBytes();
    final info = await geminiService.identifyPlant(
      imageBytes: bytes,
      userNotes: userNotes,
      potSize: potSize,
      location: location,
      hasDrainage: hasDrainage,
    );

    final newId = _plants.isEmpty
        ? 1
        : _plants.map((p) => p.id).reduce((a, b) => a > b ? a : b) + 1;
    final savedImagePath = await _savePlantImage(imagePath, newId);

    final now = DateTime.now();
    final frequency = info['watering_frequency'] as int;
    final effectiveFrequency = SeasonalWatering.frequencyFor(frequency, now);
    final needsNow = info['needs_water_now'] as bool? ?? false;

    // Автоопределение полива: если ИИ решил, что растению уже нужен полив
    // прямо на фото при добавлении — next_watering сразу "сейчас" (аналог
    // той же логики в Python-версии).
    final nextWatering =
        needsNow ? now : now.add(Duration(days: effectiveFrequency));

    final plant = Plant(
      id: newId,
      name: info['name'] as String,
      customName: customName,
      scientificName: info['scientific_name'] as String? ?? '',
      imagePath: savedImagePath,
      wateringFrequency: frequency,
      wateringAmount: info['watering_amount'] as String? ??
          (localeCode == 'en' ? '200-300 ml' : '200-300 мл'),
      lightRequirements: info['light_requirements'] as String? ??
          (localeCode == 'en' ? 'Moderate light' : 'Умеренное освещение'),
      temperature: info['temperature'] as String? ?? '18-24°C',
      humidity: info['humidity'] as String? ??
          (localeCode == 'en' ? 'Medium' : 'Средняя'),
      careTips: info['care_tips'] as String? ??
          (localeCode == 'en' ? 'Regular care' : 'Регулярный уход'),
      difficulty: info['difficulty'] as String? ??
          (localeCode == 'en' ? 'moderate' : 'средне'),
      lastWatered: now,
      nextWatering: nextWatering,
      wateringHistory: [now],
      needsWaterNowDetected: needsNow,
      moistureNotes: info['moisture_notes'] as String? ?? '',
      potSize: potSize,
      location: location,
      hasDrainage: hasDrainage,
      userNotes: userNotes,
    );

    _plants.add(plant);
    final saved = await _saveGarden();
    if (!saved) {
      _plants.removeLast();
      if (savedImagePath != null) {
        try {
          final imageFile = File(savedImagePath);
          if (await imageFile.exists()) await imageFile.delete();
        } catch (imageError) {
          debugPrint('Не удалось удалить сиротское фото: $imageError');
        }
      }
      throw StateError('Не удалось сохранить растение на диск');
    }

    notifyListeners();
    await notificationService?.scheduleWateringReminder(plant);
    return plant;
  }

  /// Отметить полив — аналог water_plant()
  Future<bool> waterPlant(int id) async {
    final index = _plants.indexWhere((p) => p.id == id);
    if (index == -1) return false;

    final plant = _plants[index];
    final now = DateTime.now();
    final history = [...plant.wateringHistory, now];
    final effectiveFrequency = SeasonalWatering.frequencyFor(
      plant.wateringFrequency,
      now,
    );

    _plants[index] = plant.copyWith(
      lastWatered: now,
      nextWatering: now.add(Duration(days: effectiveFrequency)),
      needsWaterNowDetected: false,
      wateringHistory: history.length > 100
          ? history.sublist(history.length - 100)
          : history,
    );

    final saved = await _saveGarden();
    if (!saved) {
      _plants[index] = plant;
      return false;
    }

    notifyListeners();
    await notificationService?.scheduleWateringReminder(_plants[index]);
    return true;
  }

  /// Пересчитать будущие поливы при смене сезона. Базовая частота растения
  /// (wateringFrequency) не меняется; корректируется только следующая дата.
  /// Если у старой записи нет даты последнего полива, сохраняем её дату,
  /// чтобы не сдвигать напоминание вперёд при каждом запуске приложения.
  Future<void> refreshSeasonalWatering({bool notify = true}) async {
    final now = DateTime.now();
    final originalPlants = List<Plant>.of(_plants);
    var changed = false;
    final changedPlants = <Plant>[];

    for (var index = 0; index < _plants.length; index++) {
      final plant = _plants[index];
      final lastWatered = plant.lastWatered;
      if (lastWatered == null || plant.needsWaterNowDetected) continue;

      final effectiveFrequency = SeasonalWatering.frequencyFor(
        plant.wateringFrequency,
        now,
      );
      final nextWatering = lastWatered.add(Duration(days: effectiveFrequency));
      if (nextWatering.isAtSameMomentAs(plant.nextWatering)) continue;

      final updated = plant.copyWith(nextWatering: nextWatering);
      _plants[index] = updated;
      changedPlants.add(updated);
      changed = true;
    }

    if (!changed) {
      if (notify) notifyListeners();
      return;
    }
    if (!await _saveGarden()) {
      _plants = originalPlants;
      return;
    }
    if (notify) notifyListeners();
    for (final plant in changedPlants) {
      await notificationService?.scheduleWateringReminder(plant);
    }
  }

  /// Обновить поля растения (используется при редактировании) — аналог
  /// update_plant(). В Python это принимало произвольный Dict, здесь —
  /// функция-преобразователь над строго типизированной моделью (идиоматичнее
  /// для Dart, тот же смысл: "применить точечные изменения к растению").
  Future<bool> updatePlant(int id, Plant Function(Plant current) update) async {
    final index = _plants.indexWhere((p) => p.id == id);
    if (index == -1) return false;

    final original = _plants[index];
    _plants[index] = update(original);
    final saved = await _saveGarden();
    if (!saved) {
      _plants[index] = original;
      return false;
    }

    notifyListeners();
    // Перепланируем на новую дату — независимо от того, поменялась ли
    // именно она, это дёшево и гарантирует, что напоминание никогда не
    // разойдётся с реальным next_watering растения.
    await notificationService?.scheduleWateringReminder(_plants[index]);
    return true;
  }

  /// Удалить растение — аналог delete_plant(). Ошибка удаления файла фото
  /// не прерывает удаление растения из сада (то же поведение, что и в
  /// Python-версии) — только логируется для отладки.
  Future<bool> deletePlant(int id) async {
    final index = _plants.indexWhere((p) => p.id == id);
    if (index == -1) return false;

    final plant = _plants[index];
    _plants.removeAt(index);
    final saved = await _saveGarden();
    if (!saved) {
      _plants.insert(index, plant);
      return false;
    }

    notifyListeners();
    await notificationService?.cancelReminder(id);
    if (plant.imagePath != null) {
      try {
        final file = File(plant.imagePath!);
        if (await file.exists()) await file.delete();
      } catch (e) {
        debugPrint('Не удалось удалить файл фото ${plant.imagePath}: $e');
      }
    }
    return true;
  }

  /// Список растений, которым нужен полив прямо сейчас — аналог
  /// check_watering_needs()
  List<Plant> checkWateringNeeds() {
    final now = DateTime.now();
    return _plants.where((p) => !p.nextWatering.isAfter(now)).toList();
  }

  // ---------------------------------------------------------------------
  // Экспорт/импорт сада — прямой порт export_garden/import_garden
  // ---------------------------------------------------------------------

  /// Экспортировать весь сад (JSON с данными растений + все фото) в один
  /// .zip-файл — для переноса на другой компьютер или в качестве резервной
  /// копии. Сам файл сада и папка с картинками при этом не изменяются.
  Future<bool> exportGarden(String destZipPath) async {
    await _ensureInitialized();
    try {
      if (!await _saveGarden()) return false;

      final encoder = ZipFileEncoder();
      encoder.create(destZipPath);
      encoder.addFile(_gardenFile!, 'my_garden.json');

      if (await _imagesDir!.exists()) {
        await for (final entity in _imagesDir!.list()) {
          if (entity is File) {
            final filename = entity.uri.pathSegments.last;
            encoder.addFile(entity, 'plant_images/$filename');
          }
        }
      }

      encoder.close();
      return true;
    } catch (e) {
      debugPrint('Не удалось экспортировать сад: $e');
      return false;
    }
  }

  /// Импортировать сад из .zip, созданного exportGarden(). ПОЛНОСТЬЮ
  /// заменяет текущий список растений импортированным (текущие данные
  /// предварительно бэкапятся отдельным файлом — на случай, если что-то
  /// пойдёт не так или пользователь передумает).
  ///
  /// Пути к фото в импортированных данных перепривязываются на локальную
  /// папку картинок этого устройства (self._imagesDir), а не остаются
  /// указывающими на пути устройства, где делался экспорт — иначе
  /// фотографии растений просто не нашлись бы после переноса.
  Future<bool> importGarden(String srcZipPath) async {
    await _ensureInitialized();
    List<Plant>? previousPlants;
    List<int>? previousGardenBytes;
    final previousImageBytes = <String, List<int>?>{};
    try {
      if (await _gardenFile!.exists()) {
        previousGardenBytes = await _gardenFile!.readAsBytes();
      }
      final sourceFile = File(srcZipPath);
      if (!await sourceFile.exists() ||
          await sourceFile.length() > 50 * 1024 * 1024) {
        return false;
      }
      final bytes = await sourceFile.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);
      if (archive.length > 1000) return false;
      final expandedSize = archive.fold<int>(
        0,
        (total, entry) => total + entry.size,
      );
      if (expandedSize > 100 * 1024 * 1024) return false;

      ArchiveFile? gardenEntry;
      for (final entry in archive) {
        if (entry.name == 'my_garden.json') {
          gardenEntry = entry;
          break;
        }
      }
      if (gardenEntry == null) {
        debugPrint('В архиве не найден my_garden.json — это не экспорт сада');
        return false;
      }
      if (gardenEntry.size > 5 * 1024 * 1024) return false;

      final jsonStr = utf8.decode(gardenEntry.content as List<int>);
      final decoded = jsonDecode(jsonStr);
      if (decoded is! List || decoded.length > 500) return false;

      final importedPlants = <Plant>[];
      final importedIds = <int>{};
      for (final item in decoded) {
        if (item is! Map<String, dynamic>) return false;
        final id = item['id'];
        final frequency = item['watering_frequency'];
        if (id is! int || id <= 0 || !importedIds.add(id)) return false;
        if (frequency != null && frequency is! num) return false;
        importedPlants.add(Plant.fromJson(item));
      }
      final oldPlants = List<Plant>.of(_plants);
      previousPlants = oldPlants;

      // Бэкапим текущие данные перед заменой — с меткой времени, чтобы не
      // перезаписать уже существующий обычный .backup от save_garden().
      if (await _gardenFile!.exists()) {
        final backupPath =
            '${_appDir!.path}/my_garden_before_import_${DateTime.now().millisecondsSinceEpoch}.json';
        await _gardenFile!.copy(backupPath);
      }

      // Извлекаем фото из архива в локальную папку картинок. Сохраняем
      // прежнее содержимое файлов: при ошибке записи сада откатываем также фото.
      final importedPhotoNames = <String>{};
      for (final entry in archive) {
        if (entry.name.startsWith('plant_images/') && entry.isFile) {
          final filename = entry.name.split('/').last;
          final safeFilename =
              RegExp(r'^[A-Za-z0-9._-]{1,255}$').hasMatch(filename) &&
                  filename != '.' &&
                  filename != '..';
          if (!safeFilename || !importedPhotoNames.add(filename)) {
            throw const FormatException('Некорректное имя фото в архиве');
          }
          final outFile = File('${_imagesDir!.path}/$filename');
          previousImageBytes[filename] =
              await outFile.exists() ? await outFile.readAsBytes() : null;
          await outFile.writeAsBytes(entry.content as List<int>);
        }
      }

      // Перепривязываем пути к фото на локальную папку и не переносим в
      // импортируемые записи абсолютные пути устройства-источника.
      final relinkedPlants = importedPlants.map((p) {
        String? relinkedPath;
        if (p.imagePath != null) {
          final filename = p.imagePath!.split(RegExp(r'[\\/]')).last;
          final candidate = '${_imagesDir!.path}/$filename';
          relinkedPath = importedPhotoNames.contains(filename) &&
                  File(candidate).existsSync()
              ? candidate
              : null;
        }
        return Plant(
          id: p.id,
          name: p.name,
          customName: p.customName,
          scientificName: p.scientificName,
          imagePath: relinkedPath,
          wateringFrequency: p.wateringFrequency,
          wateringAmount: p.wateringAmount,
          lightRequirements: p.lightRequirements,
          temperature: p.temperature,
          humidity: p.humidity,
          careTips: p.careTips,
          difficulty: p.difficulty,
          lastWatered: p.lastWatered,
          nextWatering: p.nextWatering,
          wateringHistory: p.wateringHistory,
          needsWaterNowDetected: p.needsWaterNowDetected,
          moistureNotes: p.moistureNotes,
          lastNotified: p.lastNotified,
          potSize: p.potSize,
          location: p.location,
          hasDrainage: p.hasDrainage,
          userNotes: p.userNotes,
        );
      }).toList();

      _plants = relinkedPlants;
      final saved = await _saveGarden();
      if (!saved) {
        _plants = oldPlants;
        await _restoreGardenBytes(previousGardenBytes);
        await _restoreImportedImages(previousImageBytes);
        return false;
      }
      previousPlants = null;

      for (final plant in oldPlants) {
        await notificationService?.cancelReminder(plant.id);
      }
      notifyListeners();
      for (final plant in _plants) {
        await notificationService?.scheduleWateringReminder(plant);
      }
      return true;
    } catch (e) {
      if (previousPlants != null) _plants = previousPlants;
      await _restoreGardenBytes(previousGardenBytes);
      await _restoreImportedImages(previousImageBytes);
      debugPrint('Не удалось импортировать сад: $e');
      return false;
    }
  }

  Future<void> _restoreGardenBytes(List<int>? bytes) async {
    if (bytes == null) return;
    try {
      await _gardenFile!.writeAsBytes(bytes, flush: true);
    } catch (e) {
      debugPrint('Не удалось откатить JSON сада после импорта: $e');
    }
  }

  Future<void> _restoreImportedImages(Map<String, List<int>?> backups) async {
    for (final entry in backups.entries) {
      final file = File('${_imagesDir!.path}/${entry.key}');
      try {
        if (entry.value == null) {
          if (await file.exists()) await file.delete();
        } else {
          await file.writeAsBytes(entry.value!);
        }
      } catch (e) {
        debugPrint('Не удалось откатить импортированное фото ${entry.key}: $e');
      }
    }
  }

  // ---------------------------------------------------------------------
  // Календарь полива (.ics) — прямой порт export_watering_calendar
  // ---------------------------------------------------------------------

  /// Сформировать .ics-файл с датами полива на ближайший год. События
  /// перечисляются отдельно, чтобы интервал мог меняться вместе с сезоном.
  /// Открывается любым календарём, понимающим iCalendar (RFC 5545).
  Future<bool> exportWateringCalendar(String destIcsPath) async {
    String escape(String text) => text
        .replaceAll('\\', '\\\\')
        .replaceAll(';', '\\;')
        .replaceAll(',', '\\,')
        .replaceAll('\n', '\\n');

    try {
      final nowUtc = DateTime.now().toUtc();
      String twoDigits(int n) => n.toString().padLeft(2, '0');
      final dtStamp =
          '${nowUtc.year}${twoDigits(nowUtc.month)}${twoDigits(nowUtc.day)}'
          'T${twoDigits(nowUtc.hour)}${twoDigits(nowUtc.minute)}${twoDigits(nowUtc.second)}Z';

      final lines = <String>[
        'BEGIN:VCALENDAR',
        'VERSION:2.0',
        localeCode == 'en'
            ? 'PRODID:-//Floraqua//Floraqua App//EN'
            : 'PRODID:-//Floraqua//Floraqua App//RU',
        'CALSCALE:GREGORIAN',
        'METHOD:PUBLISH',
      ];

      final now = DateTime.now();
      final horizon = now.add(const Duration(days: 366));
      final reminderHour = notificationService?.reminderHour ?? 9;
      final reminderMinute = notificationService?.reminderMinute ?? 0;
      for (final plant in _plants) {
        var occurrence =
            plant.nextWatering.isBefore(now) ? now : plant.nextWatering;
        while (occurrence.isBefore(horizon)) {
          final startDate =
              '${occurrence.year}${twoDigits(occurrence.month)}${twoDigits(occurrence.day)}';
          final frequency = SeasonalWatering.frequencyFor(
              plant.wateringFrequency, occurrence);
          final summary = escape(localeCode == 'en'
              ? 'Water: ${plant.displayName}'
              : 'Полить: ${plant.displayName}');
          final descriptionParts = <String>[
            localeCode == 'en'
                ? 'Base interval: every ${plant.wateringFrequency} days'
                : 'Базовый интервал: ${plant.wateringFrequency} дн.',
            localeCode == 'en'
                ? 'Seasonal interval: every $frequency days'
                : 'Сезонный интервал: $frequency дн.',
            localeCode == 'en'
                ? 'Reminder time: $reminderTimeLabel.'
                : 'Время напоминания: $reminderTimeLabel.',
            localeCode == 'en'
                ? 'Check the soil before watering.'
                : 'Перед поливом проверьте грунт.',
          ];
          if (plant.wateringAmount.isNotEmpty) {
            descriptionParts.add(localeCode == 'en'
                ? 'Water amount: ${plant.wateringAmount}'
                : 'Норма полива: ${plant.wateringAmount}');
          }
          if (plant.scientificName.isNotEmpty) {
            descriptionParts.add(plant.scientificName);
          }

          lines.addAll([
            'BEGIN:VEVENT',
            'UID:plant-${plant.id}-$startDate@moy-sad.local',
            'DTSTAMP:$dtStamp',
            'DTSTART:${startDate}T${reminderHour.toString().padLeft(2, '0')}'
                '${reminderMinute.toString().padLeft(2, '0')}00',
            'SUMMARY:$summary',
            'DESCRIPTION:${escape(descriptionParts.join(' | '))}',
          ]);
          lines.add('END:VEVENT');
          occurrence = occurrence.add(Duration(days: frequency));
        }
      }

      lines.add('END:VCALENDAR');

      // \r\n — обязательное требование RFC 5545. В отличие от Python (где
      // текстовый режим файла сам транслирует "\n" в "\r\n", и там нельзя
      // было ещё раз вручную добавлять "\r\n" — вышло бы задвоение), Dart'овский
      // IOSink НЕ делает никакой автоматической трансляции переносов строк —
      // здесь "\r\n" нужно явно проставить самим, иначе получится обычный "\n".
      final sink = File(destIcsPath).openWrite(encoding: utf8);
      sink.write(lines.join(
          '\r\n')); // write() синхронный — void, не Future, await тут не нужен
      await sink.flush();
      await sink.close();
      return true;
    } catch (e) {
      debugPrint('Не удалось экспортировать календарь полива: $e');
      return false;
    }
  }
}
