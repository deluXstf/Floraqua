import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plant_garden/screens/garden_plant_actions.dart';

void main() {
  for (final platform in [TargetPlatform.iOS, TargetPlatform.android]) {
    testWidgets('выбор источника фото доступен на $platform', (tester) async {
      ImageSource? selectedSource;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: platform),
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  selectedSource = await showPlantImageSourcePicker(context);
                },
                child: const Text('Добавить'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Добавить'));
      await tester.pumpAndSettle();
      expect(find.text('Выбрать из фотогалереи'), findsOneWidget);
      expect(find.text('Сделать фото сейчас'), findsOneWidget);

      await tester.tap(find.text('Сделать фото сейчас'));
      await tester.pumpAndSettle();
      expect(selectedSource, ImageSource.camera);
    });
  }
}
