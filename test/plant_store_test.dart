import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:plant_garden/models/plant.dart';
import 'package:plant_garden/services/gemini_service.dart';
import 'package:plant_garden/services/notification_service.dart';
import 'package:plant_garden/services/plant_store.dart';
import 'package:plant_garden/services/seasonal_watering.dart';

import 'test_directory.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory supportDirectory;

  Future<void> writeGarden(List<Map<String, dynamic>> plants) async {
    final gardenDir = Directory('${supportDirectory.path}/plant_garden');
    await gardenDir.create(recursive: true);
    await File('${gardenDir.path}/my_garden.json')
        .writeAsString(jsonEncode(plants));
  }

  Map<String, dynamic> plantJson({int id = 1}) => Plant(
        id: id,
        name: 'Фикус $id',
        wateringFrequency: 10,
        lastWatered: DateTime.now().subtract(const Duration(days: 1)),
        nextWatering: DateTime.now().add(const Duration(days: 9)),
      ).toJson();

  setUp(() async {
    supportDirectory = await createProjectTestDirectory('plant_store_');
  });

  tearDown(() async {
    if (await supportDirectory.exists()) {
      await supportDirectory.delete(recursive: true);
    }
  });

  test('waterPlant schedules the current season interval and persists it',
      () async {
    await writeGarden([plantJson()]);
    final gemini = GeminiService(
      apiKey: 'test',
      client: MockClient((_) async => throw StateError('Unexpected HTTP call')),
    );
    final store = PlantStore(
      geminiService: gemini,
      supportDirectoryOverride: supportDirectory,
    );
    addTearDown(gemini.dispose);

    await store.loadGarden();
    final beforeWater = DateTime.now();
    expect(await store.waterPlant(1), isTrue);

    final watered = store.getPlant(1)!;
    final expectedDays = SeasonalWatering.frequencyFor(10, beforeWater);
    expect(watered.nextWatering.difference(watered.lastWatered!).inDays,
        expectedDays);
    expect(watered.needsWaterNowDetected, isFalse);

    final saved = jsonDecode(
      await File('${supportDirectory.path}/plant_garden/my_garden.json')
          .readAsString(),
    ) as List<dynamic>;
    expect(saved.single['watering_frequency'], 10);
    expect(DateTime.parse(saved.single['next_watering'] as String),
        watered.nextWatering);
  });

  test('import rejects duplicate plant IDs and keeps the current garden',
      () async {
    await writeGarden([plantJson()]);
    final gemini = GeminiService(
      apiKey: 'test',
      client: MockClient((_) async => throw StateError('Unexpected HTTP call')),
    );
    final store = PlantStore(
      geminiService: gemini,
      supportDirectoryOverride: supportDirectory,
    );
    addTearDown(gemini.dispose);
    await store.loadGarden();

    final duplicateData = jsonEncode([plantJson(id: 2), plantJson(id: 2)]);
    final gardenJson = File('${supportDirectory.path}/my_garden.json');
    await gardenJson.writeAsString(duplicateData);
    final zipPath = '${supportDirectory.path}/duplicate.zip';
    final encoder = ZipFileEncoder()..create(zipPath);
    encoder.addFile(gardenJson, 'my_garden.json');
    encoder.close();

    expect(await store.importGarden(zipPath), isFalse);
    expect(store.plants.map((p) => p.id), [1]);
  });

  test('watering calendar exports separate seasonal events', () async {
    await writeGarden([plantJson()]);
    final gemini = GeminiService(
      apiKey: 'test',
      client: MockClient((_) async => throw StateError('Unexpected HTTP call')),
    );
    final notifications = NotificationService();
    final store = PlantStore(
      geminiService: gemini,
      notificationService: notifications,
      supportDirectoryOverride: supportDirectory,
    );
    addTearDown(gemini.dispose);
    await store.loadGarden();
    await store.updateReminderTime(7, 15);

    final calendarPath = '${supportDirectory.path}/watering.ics';
    expect(await store.exportWateringCalendar(calendarPath), isTrue);
    final calendar = await File(calendarPath).readAsString();

    expect(calendar, contains('Сезонный интервал:'));
    expect(calendar, contains('T071500'));
    expect(
      calendar,
      matches(RegExp(r'^DTSTART:\d{8}T\d{6}\r?$', multiLine: true)),
    );
    expect(calendar, isNot(contains('RRULE:')));
  });
  test('восстанавливает сад из backup при повреждённом основном JSON', () async {
    await writeGarden([plantJson()]);
    final gardenDir = Directory('${supportDirectory.path}/plant_garden');
    await File('${gardenDir.path}/my_garden.json')
        .writeAsString('{ broken json');
    await File('${gardenDir.path}/my_garden.json.backup')
        .writeAsString(jsonEncode([plantJson(id: 7)]));

    final store = PlantStore(
      geminiService: GeminiService(
        apiKey: 'test',
        client: MockClient((_) async => throw StateError('Unexpected HTTP call')),
      ),
      supportDirectoryOverride: supportDirectory,
    );
    await store.loadGarden();

    expect(store.plants.single.id, 7);
    final restored = await File('${gardenDir.path}/my_garden.json').readAsString();
    expect(restored, contains('"id": 7'));
  });

}
