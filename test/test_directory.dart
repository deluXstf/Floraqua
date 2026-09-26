import 'dart:io';

/// Создаёт изолированную writable папку рядом с тестовым проектом.
/// Избегаем Directory.systemTemp: в некоторых Windows-конфигурациях его
/// проверка прав/антивирусная фильтрация может задерживать запуск теста.
Future<Directory> createProjectTestDirectory(String prefix) async {
  final separator = Platform.pathSeparator;
  final parent = Directory(
    '${Directory.current.path}${separator}.dart_tool${separator}floraqua_test_data',
  );
  await parent.create(recursive: true);

  return parent.createTemp('${prefix}_');
}
