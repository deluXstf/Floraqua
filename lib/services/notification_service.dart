import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../models/plant.dart';
import 'seasonal_watering.dart';

/// Локальные напоминания о поливе — аналог связки schedule + plyer из
/// Python-версии, но без постоянно работающего фонового потока: вместо
/// этого каждому растению соответствует ОДНО запланированное системное
/// уведомление на дату следующего полива, которое переживает закрытие
/// приложения (в отличие от Python-планировщика, работавшего только пока
/// процесс был жив).
///
/// ВАЖНО (проверено по официальной документации пакета, не наугад):
/// Windows НЕ поддерживает повторяющиеся уведомления — periodicallyShow()
/// там просто бросает UnsupportedError. Поэтому здесь всегда планируется
/// одно разовое (не повторяющееся) уведомление на конкретную дату/время,
/// а не "напоминай каждые N дней" — вместо этого уведомление
/// перепланируется заново при каждом изменении next_watering (полив,
/// редактирование, повторная проверка по фото).
///
/// Также на Windows отмена/чтение УЖЕ показанных уведомлений работает
/// по-настоящему только если приложение упаковано как MSIX — на обычной
/// debug/release сборке это не критично для нашего сценария (мы только
/// планируем БУДУЩИЕ уведомления и отменяем ещё не показанные, а не
/// запрашиваем историю уже показанных).
class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  int _reminderHour;
  int _reminderMinute;

  NotificationService({int reminderHour = 9, int reminderMinute = 0})
      : _reminderHour = reminderHour,
        _reminderMinute = reminderMinute {
    _validateReminderTime(reminderHour, reminderMinute);
  }

  int get reminderHour => _reminderHour;
  int get reminderMinute => _reminderMinute;

  String get reminderTimeLabel =>
      '${_reminderHour.toString().padLeft(2, '0')}:${_reminderMinute.toString().padLeft(2, '0')}';

  void setReminderTime(int hour, int minute) {
    _validateReminderTime(hour, minute);
    _reminderHour = hour;
    _reminderMinute = minute;
  }

  static void _validateReminderTime(int hour, int minute) {
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      throw RangeError('Некорректное время напоминания');
    }
  }

  /// Инициализация — вызвать один раз при старте приложения, до первого
  /// вызова scheduleWateringReminder/cancelReminder.
  Future<void> init() async {
    if (_initialized) return;

    tzdata.initializeTimeZones();
    try {
      final timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      // Не удалось определить локальный часовой пояс устройства — тихо
      // остаёмся на UTC по умолчанию. Уведомления в этом случае всё равно
      // придут, просто время может быть смещено на величину часового пояса
      // пользователя — не критично для функции "напомнить полить растение".
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings();
    const linuxSettings =
        LinuxInitializationSettings(defaultActionName: 'Открыть Floraqua');
    // GUID ни на что не завязан — просто уникальный идентификатор колбэка
    // активации уведомлений для этого конкретного приложения на Windows.
    const windowsSettings = WindowsInitializationSettings(
      appName: 'Floraqua',
      appUserModelId: 'Com.Floraqua.PlantGarden',
      guid: 'e6f5b7b0-2b8a-4d9e-9c4b-6f1a2d3e4f5a',
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
      linux: linuxSettings,
      windows: windowsSettings,
    );

    try {
      await _plugin.initialize(settings: initSettings);
      _initialized = true;
    } catch (e) {
      // Если инициализация плагина не удалась на какой-то платформе —
      // приложение не должно падать целиком из-за напоминаний. Просто
      // остаёмся в состоянии "уведомления недоступны" (_initialized=false),
      // все дальнейшие вызовы schedule/cancel тихо становятся no-op.
      _initialized = false;
    }
  }

  /// Запланировать (или перепланировать) напоминание о поливе для растения —
  /// в выбранное пользователем время в день plant.nextWatering. Если эта дата уже в прошлом
  /// (полив просрочен на момент вызова) — планируем на ближайшую минуту
  /// вперёд, а не отбрасываем уведомление молча.
  Future<void> scheduleWateringReminder(Plant plant) async {
    if (!_initialized) return;

    final now = tz.TZDateTime.now(tz.local);
    final frequency = SeasonalWatering.frequencyFor(
      plant.wateringFrequency,
      plant.nextWatering,
    );
    var scheduledDate = tz.TZDateTime(
      tz.local,
      plant.nextWatering.year,
      plant.nextWatering.month,
      plant.nextWatering.day,
      _reminderHour,
      _reminderMinute,
    );
    if (!scheduledDate.isAfter(now)) {
      scheduledDate = now.add(const Duration(minutes: 1));
    }

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'watering_reminders',
        'Напоминания о поливе',
        channelDescription: 'Напоминания о поливе растений',
        importance: Importance.high,
        priority: Priority.high,
      ),
      windows: WindowsNotificationDetails(),
    );

    try {
      await _plugin.zonedSchedule(
        id: plant.id,
        title: 'Пора полить: ${plant.displayName}',
        body: 'Периодичность полива: раз в $frequency дн.',
        scheduledDate: scheduledDate,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      // Сбой планирования одного уведомления не должен ломать остальную
      // работу с растением (сохранение и т.п.) — просто не будет
      // напоминания для этого конкретного растения.
    }
  }

  /// Отменить запланированное (ещё не показанное) напоминание — вызывается
  /// при удалении растения.
  Future<void> cancelReminder(int plantId) async {
    if (!_initialized) return;
    try {
      await _plugin.cancel(id: plantId);
    } catch (e) {
      // см. комментарий выше — не критично для остальной работы приложения
    }
  }
}
