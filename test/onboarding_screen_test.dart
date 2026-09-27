import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plant_garden/l10n/generated/app_localizations.dart';
import 'package:plant_garden/screens/onboarding_screen.dart';

void main() {
  testWidgets('онбординг проходит три шага и вызывает сохранение один раз',
      (tester) async {
    var completed = 0;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ru'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: OnboardingScreen(
          onComplete: () async {
            completed++;
          },
        ),
      ),
    );

    expect(find.text('Ваш сад — в одном месте'), findsOneWidget);
    await tester.tap(find.text('Дальше'));
    await tester.pumpAndSettle();
    expect(find.text('Уход с учётом сезона'), findsOneWidget);

    await tester.tap(find.text('Дальше'));
    await tester.pumpAndSettle();
    expect(find.text('Напоминания под ваш ритм'), findsOneWidget);

    await tester.tap(find.text('Перейти к настройке ключа'));
    await tester.pumpAndSettle();
    expect(completed, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('кнопка пропуска завершает онбординг', (tester) async {
    var completed = false;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ru'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: OnboardingScreen(
          onComplete: () async {
            completed = true;
          },
        ),
      ),
    );

    await tester.tap(find.text('Пропустить'));
    await tester.pumpAndSettle();

    expect(completed, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('язык можно выбрать прямо при первом запуске', (tester) async {
    var localeCode = 'ru';
    var selected = '';
    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, setState) => MaterialApp(
          locale: Locale(localeCode),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: OnboardingScreen(
            localeCode: localeCode,
            onComplete: () async {},
            onLocaleCodeChanged: (code) async {
              selected = code;
              setState(() => localeCode = code);
            },
          ),
        ),
      ),
    );

    expect(find.text('Ваш сад — в одном месте'), findsOneWidget);
    await tester.tap(find.byType(DropdownButton<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('English').last);
    await tester.pumpAndSettle();

    expect(selected, 'en');
    expect(find.text('Your garden, all in one place'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
