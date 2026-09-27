// The const-context lint differs between Flutter SDK versions for these
// intentionally static layout subtrees. Keep the test readable and portable.
// ignore_for_file: prefer_const_constructors, unnecessary_const

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plant_garden/l10n/generated/app_localizations.dart';
import 'package:plant_garden/models/plant.dart';
import 'package:plant_garden/widgets/plant_card.dart';
import 'package:plant_garden/widgets/watering_ring.dart';

Plant _plant({
  required int id,
  required String name,
  required String careTips,
  String scientificName = '',
}) =>
    Plant(
      id: id,
      name: name,
      scientificName: scientificName,
      wateringFrequency: 7,
      nextWatering: DateTime(2026, 10, 1),
      careTips: careTips,
    );

void main() {
  testWidgets('карточки одинаковой ширины имеют одинаковую высоту',
      (tester) async {
    var detailsOpened = false;
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(1.2)),
        child: MaterialApp(
          locale: const Locale('ru'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(1.2),
            ),
            child: child!,
          ),
          home: Scaffold(
            body: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 320,
                    child: PlantCard(
                      key: const ValueKey('short'),
                      plant: _plant(
                        id: 1,
                        name: 'Фикус',
                        careTips: 'Поливать умеренно.',
                      ),
                      onOpenDetails: () => detailsOpened = true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 320,
                    child: PlantCard(
                      key: const ValueKey('long'),
                      plant: _plant(
                        id: 2,
                        name:
                            'Очень длинное название растения, которое не должно растягивать карточку',
                        careTips:
                            List.filled(100, 'Подробная рекомендация по уходу')
                                .join(' '),
                        scientificName: 'Ficus elastica var. decora',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final shortSize = tester.getSize(find.byKey(const ValueKey('short')));
    final longSize = tester.getSize(find.byKey(const ValueKey('long')));
    expect(shortSize.height, longSize.height);
    final waterButtons = find.widgetWithText(FilledButton, 'Полить');
    final detailsButtons = find.text('Подробнее');
    expect(waterButtons, findsNWidgets(2));
    expect(detailsButtons, findsNWidgets(2));
    expect(
      tester.getTopLeft(waterButtons.at(0)).dy,
      tester.getTopLeft(waterButtons.at(1)).dy,
    );
    expect(
      tester.getTopLeft(detailsButtons.at(0)).dy,
      tester.getTopLeft(detailsButtons.at(1)).dy,
    );
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Подробнее').first);
    await tester.pump();
    expect(detailsOpened, isTrue);
  });

  testWidgets('горизонтальная карточка списка не вызывает overflow',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ru'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 640,
              child: PlantCard(
                listMode: true,
                plant: _plant(
                  id: 3,
                  name: 'Монстера',
                  careTips:
                      'Длинный совет по уходу для проверки обрезки текста.',
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(PlantCard)).height, 184);
    expect(tester.takeException(), isNull);
  });

  testWidgets('надпись о необходимости полива помещается в кольцо',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ru'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: const Center(
            child: WateringRing(
              daysUntilWatering: 0,
              frequency: 7,
              size: 52,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Полить'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('счётчик дней до полива показывает число, а не маркер #',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ru'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: const Center(
            child: WateringRing(
              daysUntilWatering: 3,
              frequency: 7,
              size: 52,
            ),
          ),
        ),
      ),
    );

    expect(find.text('3 дн.'), findsOneWidget);
    expect(find.text('#'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('после успешного полива кнопка показывает короткую анимацию',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ru'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 320,
              child: PlantCard(
                plant: _plant(id: 4, name: 'Монстера', careTips: ''),
                onWater: () async => true,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Полить'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Полито'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
