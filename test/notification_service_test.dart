import 'package:flutter_test/flutter_test.dart';
import 'package:plant_garden/services/notification_service.dart';

void main() {
  test('по умолчанию уведомление назначено на 09:00', () {
    final service = NotificationService();

    expect(service.reminderHour, 9);
    expect(service.reminderMinute, 0);
    expect(service.reminderTimeLabel, '09:00');
  });

  test('можно задать конкретный час и минуту', () {
    final service = NotificationService()..setReminderTime(7, 15);

    expect(service.reminderHour, 7);
    expect(service.reminderMinute, 15);
    expect(service.reminderTimeLabel, '07:15');
  });

  test('время вне формата 24 часов отклоняется', () {
    final service = NotificationService();

    expect(
      () => service.setReminderTime(24, 0),
      throwsA(isA<RangeError>()),
    );
    expect(
      () => service.setReminderTime(8, 60),
      throwsA(isA<RangeError>()),
    );
  });
}
