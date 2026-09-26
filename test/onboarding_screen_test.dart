import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plant_garden/screens/onboarding_screen.dart';

void main() {
  testWidgets('онбординг проходит три шага и вызывает сохранение один раз',
      (tester) async {
    var completed = 0;
    await tester.pumpWidget(
      MaterialApp(
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
}
