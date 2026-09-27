import 'package:flutter/material.dart';

import '../l10n/l10n_extensions.dart';
import '../theme/app_theme.dart';

Future<PlantFormData?> showPlantDetailsSheet(
  BuildContext context, {
  String? initialName,
  String? initialNotes,
  String? initialPotSize,
  String? initialLocation,
  String? initialDrainage,
  int? initialFrequency,
  DateTime? initialLastWatered,
  bool isEditing = false,
}) {
  return showModalBottomSheet<PlantFormData>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.floraqua.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => PlantDetailsSheet(
      initialName: initialName,
      initialNotes: initialNotes,
      initialPotSize: initialPotSize,
      initialLocation: initialLocation,
      initialDrainage: initialDrainage,
      initialFrequency: initialFrequency,
      initialLastWatered: initialLastWatered,
      isEditing: isEditing,
    ),
  );
}

/// Данные, введённые в форме добавления/редактирования — аналог полей,
/// которые main.py собирал вручную из виджетов диалога add_plant().
class PlantFormData {
  final String? customName;
  final String? userNotes;
  final String? potSize;
  final String? location;
  final String? hasDrainage;
  // Только для редактирования (см. isEditing в PlantDetailsSheet) — то, что
  // РЕАЛЬНО влияет на кольцо полива на карточке. Раньше форма редактирования
  // не давала их поправить вообще, поэтому "Изменить" никак не отражалось на
  // кольце, как бы пользователь ни менял текстовые заметки.
  final int? wateringFrequency;
  final DateTime? lastWatered;
  final bool clearLastWatered;

  const PlantFormData({
    this.customName,
    this.userNotes,
    this.potSize,
    this.location,
    this.hasDrainage,
    this.wateringFrequency,
    this.lastWatered,
    this.clearLastWatered = false,
  });
}

class PlantDetailsSheet extends StatefulWidget {
  final String? initialName;
  final String? initialNotes;
  final String? initialPotSize;
  final String? initialLocation;
  final String? initialDrainage;
  final int? initialFrequency;
  final DateTime? initialLastWatered;
  final bool isEditing;

  const PlantDetailsSheet({
    super.key,
    this.initialName,
    this.initialNotes,
    this.initialPotSize,
    this.initialLocation,
    this.initialDrainage,
    this.initialFrequency,
    this.initialLastWatered,
    this.isEditing = false,
  });

  @override
  State<PlantDetailsSheet> createState() => _PlantDetailsSheetState();
}

class _PlantDetailsSheetState extends State<PlantDetailsSheet> {
  late final _nameController = TextEditingController(text: widget.initialName);
  late final _notesController =
      TextEditingController(text: widget.initialNotes);
  late final _frequencyController =
      TextEditingController(text: widget.initialFrequency?.toString());

  static const _potSizeOptions = [
    'Маленький (до 10 см)',
    'Средний (10-20 см)',
    'Большой (20-30 см)',
    'Очень большой (30+ см)',
  ];
  static const _locationOptions = [
    'Южное окно',
    'Северное окно',
    'Восточное окно',
    'Западное окно',
    'Подальше от окна',
    'Балкон/лоджия',
  ];
  static const _drainageOptions = ['Да', 'Нет', 'Не знаю'];

  String? _potSize;
  String? _location;
  String? _drainage;
  DateTime? _lastWatered;
  bool _clearLastWatered = false;
  String? _frequencyError;

  @override
  void initState() {
    super.initState();
    _potSize = widget.initialPotSize;
    _location = widget.initialLocation;
    _drainage = widget.initialDrainage;
    _lastWatered = widget.initialLastWatered;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    _frequencyController.dispose();
    super.dispose();
  }

  Future<void> _pickLastWateredDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _lastWatered ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _lastWatered = picked;
        _clearLastWatered = false;
      });
    }
  }

  void _submit() {
    int? frequency;
    if (widget.isEditing) {
      final raw = _frequencyController.text.trim();
      frequency = int.tryParse(raw);
      if (frequency == null || frequency < 1 || frequency > 30) {
        setState(() => _frequencyError = context.l10n.frequencyValidation);
        return;
      }
    }

    Navigator.of(context).pop(PlantFormData(
      customName: _nameController.text.trim().isEmpty
          ? null
          : _nameController.text.trim(),
      userNotes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      potSize: _potSize,
      location: _location,
      hasDrainage: _drainage,
      wateringFrequency: frequency,
      lastWatered: _lastWatered,
      clearLastWatered: _clearLastWatered,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.isEditing
                  ? context.l10n.plantEditorEditTitle
                  : context.l10n.plantEditorNewTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: context.l10n.plantNameOptional,
                border: const OutlineInputBorder(),
              ),
            ),
            if (widget.isEditing) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _frequencyController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: context.l10n.wateringFrequencyField,
                  border: const OutlineInputBorder(),
                  errorText: _frequencyError,
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _pickLastWateredDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: context.l10n.lastWateredDate,
                    border: const OutlineInputBorder(),
                    suffixIcon: const Icon(Icons.calendar_today, size: 18),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _lastWatered != null
                              ? '${_lastWatered!.day}.${_lastWatered!.month}.${_lastWatered!.year}'
                              : _clearLastWatered
                                  ? context.l10n.dateWillClear
                                  : widget.initialLastWatered == null
                                      ? context.l10n.dateNotSet
                                      : context.l10n.dateDoNotChange,
                        ),
                      ),
                      if (widget.initialLastWatered != null &&
                          !_clearLastWatered)
                        TextButton(
                          onPressed: () => setState(() {
                            _lastWatered = null;
                            _clearLastWatered = true;
                          }),
                          child: Text(context.l10n.commonClear),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 4),
                child: Text(
                  context.l10n.wateringIntervalHelp,
                  style: TextStyle(
                    fontSize: 11,
                    color: context.floraqua.textSecondary,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            _buildDropdown(context.l10n.potSize, _potSizeOptions, _potSize,
                (v) => setState(() => _potSize = v)),
            const SizedBox(height: 12),
            _buildDropdown(context.l10n.locationLabel, _locationOptions,
                _location, (v) => setState(() => _location = v)),
            const SizedBox(height: 12),
            _buildDropdown(context.l10n.drainageHoles, _drainageOptions,
                _drainage, (v) => setState(() => _drainage = v)),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: context.l10n.notesForAiLabel,
                border: const OutlineInputBorder(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 4),
              child: Text(
                context.l10n.notesForAiHelp,
                style: TextStyle(
                  fontSize: 11,
                  color: context.floraqua.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: context.floraqua.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _submit,
                child: Text(context.l10n.commonContinue),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> options, String? value,
      ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: options
          .map((o) => DropdownMenuItem(
                value: o,
                child: Text(_localizedOption(context, o)),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }
}

String _localizedOption(BuildContext context, String value) => switch (value) {
      'Маленький (до 10 см)' || 'Small (up to 10 cm)' => context.l10n.potSmall,
      'Средний (10-20 см)' ||
      'Средний (10–20 см)' ||
      'Medium (10–20 cm)' =>
        context.l10n.potMedium,
      'Большой (20-30 см)' ||
      'Большой (20–30 см)' ||
      'Large (20–30 cm)' =>
        context.l10n.potLarge,
      'Очень большой (30+ см)' ||
      'Extra large (30+ cm)' =>
        context.l10n.potExtraLarge,
      'Южное окно' || 'South-facing window' => context.l10n.locationSouthWindow,
      'Северное окно' ||
      'North-facing window' =>
        context.l10n.locationNorthWindow,
      'Восточное окно' ||
      'East-facing window' =>
        context.l10n.locationEastWindow,
      'Западное окно' ||
      'West-facing window' =>
        context.l10n.locationWestWindow,
      'Подальше от окна' ||
      'Away from a window' =>
        context.l10n.locationAwayFromWindow,
      'Балкон/лоджия' ||
      'Балкон / лоджия' ||
      'Balcony / loggia' =>
        context.l10n.locationBalcony,
      'Да' || 'Yes' => context.l10n.yes,
      'Нет' || 'No' => context.l10n.no,
      'Не знаю' || "Don't know" => context.l10n.unknown,
      _ => value,
    };
