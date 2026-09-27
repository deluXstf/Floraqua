import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plant_garden/l10n/generated/app_localizations.dart';
import 'package:plant_garden/models/plant.dart';
import 'package:plant_garden/screens/garden_screen.dart';
import 'package:plant_garden/services/gemini_service.dart';
import 'package:plant_garden/services/plant_store.dart';
import 'package:plant_garden/services/secure_storage_service.dart';

class _MemorySecureStorage extends SecureStorageService {
  String? viewMode;

  @override
  Future<String?> loadGardenViewMode() async => viewMode;

  @override
  Future<void> saveGardenViewMode(String mode) async {
    viewMode = mode;
  }
}

class _MemoryPlantStore extends PlantStore {
  _MemoryPlantStore() : super(geminiService: GeminiService(apiKey: 'test-key'));

  final _items = <Plant>[];

  @override
  List<Plant> get plants => List.unmodifiable(_items);

  @override
  Future<void> loadGarden() async {}

  @override
  List<Plant> checkWateringNeeds() =>
      _items.where((plant) => plant.needsWaterBySchedule()).toList();

  @override
  Future<Plant> addPlant({
    required String imagePath,
    String? customName,
    String? userNotes,
    String? potSize,
    String? location,
    String? hasDrainage,
  }) async {
    final now = DateTime.now();
    final plant = Plant(
      id: _items.isEmpty ? 1 : _items.last.id + 1,
      name: 'Фикус',
      customName: customName,
      imagePath:
          null, // Не запускаем платформенное чтение файлов в widget-test.
      wateringFrequency: 7,
      lastWatered: now,
      nextWatering: now.add(const Duration(days: 7)),
      wateringHistory: [now],
    );
    _items.add(plant);
    notifyListeners();
    return plant;
  }

  @override
  Future<bool> waterPlant(int id) async {
    final index = _items.indexWhere((plant) => plant.id == id);
    if (index < 0) return false;
    final plant = _items[index];
    final now = DateTime.now();
    _items[index] = plant.copyWith(
      lastWatered: now,
      nextWatering: now.add(const Duration(days: 7)),
      wateringHistory: [...plant.wateringHistory, now],
      needsWaterNowDetected: false,
    );
    notifyListeners();
    return true;
  }

  @override
  Future<bool> deletePlant(int id) async {
    final index = _items.indexWhere((plant) => plant.id == id);
    if (index < 0) return false;
    _items.removeAt(index);
    notifyListeners();
    return true;
  }
}

Future<void> _settle(WidgetTester tester) async {
  for (var frame = 0; frame < 60; frame++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (!tester.binding.hasScheduledFrame) return;
  }
  throw StateError('UI не пришёл в стабильное состояние за 6 секунд.');
}

void main() {
  testWidgets('добавить растение, полить с карточки и удалить его',
      (tester) async {
    final store = _MemoryPlantStore();
    addTearDown(() => store.geminiService.dispose());
    addTearDown(store.dispose);
    final secureStorage = _MemorySecureStorage();

    await tester.pumpWidget(MaterialApp(
      locale: const Locale('ru'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: GardenScreen(
        store: store,
        secureStorage: secureStorage,
        onChangeApiKey: () {},
      ),
    ));
    await _settle(tester);

    await tester.tap(find.byTooltip('Список'));
    await _settle(tester);
    expect(secureStorage.viewMode, 'list');
    await tester.tap(find.byTooltip('Сетка'));
    await _settle(tester);

    await store.addPlant(imagePath: 'unused.jpg', customName: 'Мой фикус');
    await _settle(tester);
    expect(find.text('Мой фикус'), findsOneWidget);
    expect(store.plants, hasLength(1));

    await tester.enterText(find.byType(TextField), 'не существует');
    await _settle(tester);
    expect(store.plants, hasLength(1));
    expect(find.text('Ничего не найдено'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'фикус');
    await _settle(tester);
    expect(find.text('Мой фикус'), findsOneWidget);

    await tester.tap(find.byTooltip('Список'));
    await _settle(tester);
    expect(find.text('Мой фикус'), findsOneWidget);

    await tester.tap(find.text('Полить'));
    await _settle(tester);
    expect(store.plants.single.lastWatered, isNotNull);
    expect(store.plants.single.wateringHistory, hasLength(2));

    await tester.tap(find.byTooltip('Другие действия'));
    await _settle(tester);
    await tester.tap(find.text('Удалить растение'));
    await _settle(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Удалить'));
    await _settle(tester);

    expect(store.plants, isEmpty);
    expect(find.text('Здесь скоро будет ваш сад'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
