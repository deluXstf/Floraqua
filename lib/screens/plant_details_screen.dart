import 'dart:io';

import 'package:flutter/material.dart';

import '../models/plant.dart';
import '../services/plant_store.dart';
import '../services/seasonal_watering.dart';
import '../theme/app_theme.dart';
import '../widgets/watering_ring.dart';

class PlantDetailsScreen extends StatelessWidget {
  final PlantStore store;
  final int plantId;
  final VoidCallback? onWater;
  final VoidCallback? onEdit;
  final VoidCallback? onCheck;
  final VoidCallback? onDelete;
  final VoidCallback? onOpenFullImage;

  const PlantDetailsScreen({
    super.key,
    required this.store,
    required this.plantId,
    this.onWater,
    this.onEdit,
    this.onCheck,
    this.onDelete,
    this.onOpenFullImage,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final plant = store.getPlant(plantId);
        if (plant == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Растение')),
            body: const Center(child: Text('Растение больше не найдено.')),
          );
        }
        final now = DateTime.now();
        final frequency = SeasonalWatering.frequencyFor(
          plant.wateringFrequency,
          now,
        );
        final season = SeasonalWatering.seasonName(
          SeasonalWatering.seasonForDate(now),
        );

        return Scaffold(
          appBar: AppBar(
            title: Text(plant.displayName, maxLines: 1, overflow: TextOverflow.ellipsis),
            actions: [
              PopupMenuButton<String>(
                tooltip: 'Действия',
                onSelected: (action) {
                  switch (action) {
                    case 'edit':
                      onEdit?.call();
                      break;
                    case 'check':
                      onCheck?.call();
                      break;
                    case 'delete':
                      onDelete?.call();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  if (onEdit != null)
                    const PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        dense: true,
                        leading: Icon(Icons.edit_outlined),
                        title: Text('Изменить'),
                      ),
                    ),
                  if (onCheck != null)
                    const PopupMenuItem(
                      value: 'check',
                      child: ListTile(
                        dense: true,
                        leading: Icon(Icons.photo_camera_outlined),
                        title: Text('Перепроверить по фото'),
                      ),
                    ),
                  if (onDelete != null)
                    PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        dense: true,
                        leading: Icon(Icons.delete_outline, color: context.floraqua.error),
                        title: Text('Удалить растение'),
                      ),
                    ),
                ],
              ),
            ],
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 900;
              final content = _DetailsContent(
                plant: plant,
                frequency: frequency,
                season: season,
                reminderTimeLabel: store.reminderTimeLabel,
                onWater: onWater,
                onOpenFullImage: onOpenFullImage,
              );
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1040),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                    child: wide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(width: 360, child: content),
                              const SizedBox(width: 24),
                              Expanded(
                                child: _CareSections(
                                  plant: plant,
                                  frequency: frequency,
                                  season: season,
                                ),
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              content,
                              const SizedBox(height: 20),
                              _CareSections(
                                plant: plant,
                                frequency: frequency,
                                season: season,
                              ),
                            ],
                          ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _DetailsContent extends StatelessWidget {
  final Plant plant;
  final int frequency;
  final String season;
  final String reminderTimeLabel;
  final VoidCallback? onWater;
  final VoidCallback? onOpenFullImage;

  const _DetailsContent({
    required this.plant,
    required this.frequency,
    required this.season,
    required this.reminderTimeLabel,
    this.onWater,
    this.onOpenFullImage,
  });

  @override
  Widget build(BuildContext context) {
    final imagePath = plant.imagePath;
    final photoFile = imagePath != null && File(imagePath).existsSync()
        ? File(imagePath)
        : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onDoubleTap: photoFile != null ? onOpenFullImage : null,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: SizedBox(
              height: 280,
              child: photoFile != null
                  ? Image.file(
                      photoFile,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const _PhotoPlaceholder(),
                    )
                  : const _PhotoPlaceholder(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plant.displayName,
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      color: context.floraqua.textPrimary,
                    ),
                  ),
                  if (plant.scientificName.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      plant.scientificName,
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: context.floraqua.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            WateringRing(
              daysUntilWatering: _daysUntilWatering(plant.nextWatering),
              frequency: frequency,
              size: 58,
            ),
          ],
        ),
        const SizedBox(height: 14),
        _SummaryCard(
          icon: Icons.water_drop_outlined,
          title: 'Полив',
          value: 'Каждые $frequency дней · $season',
          detail:
              'Следующий: ${_formatDate(plant.nextWatering)} · уведомление в $reminderTimeLabel',
        ),
        if (plant.lastWatered != null) ...[
          const SizedBox(height: 8),
          _SummaryCard(
            icon: Icons.history,
            title: 'Последний полив',
            value: _formatDate(plant.lastWatered!),
            detail: '${plant.wateringHistory.length} записей в истории',
          ),
        ],
        const SizedBox(height: 14),
        FilledButton.icon(
          onPressed: onWater,
          icon: Icon(Icons.water_drop_outlined),
          label: const Text('Отметить полив'),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            backgroundColor: context.floraqua.primary,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _CareSections extends StatelessWidget {
  final Plant plant;
  final int frequency;
  final String season;

  const _CareSections({
    required this.plant,
    required this.frequency,
    required this.season,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionCard(
          title: 'Условия содержания',
          icon: Icons.tune,
          child: Column(
            children: [
              _DetailRow(
                icon: Icons.wb_sunny_outlined,
                label: 'Освещение',
                value: plant.lightRequirements,
              ),
              _DetailRow(
                icon: Icons.thermostat_outlined,
                label: 'Температура',
                value: plant.temperature,
              ),
              _DetailRow(
                icon: Icons.opacity_outlined,
                label: 'Влажность воздуха',
                value: plant.humidity,
              ),
              _DetailRow(
                icon: Icons.spa_outlined,
                label: 'Сложность ухода',
                value: plant.difficulty,
              ),
              _DetailRow(
                icon: Icons.water_outlined,
                label: 'Базовый интервал полива',
                value: 'Каждые ${plant.wateringFrequency} дней',
              ),
              _DetailRow(
                icon: Icons.local_drink_outlined,
                label: 'Ориентировочная норма',
                value: plant.wateringAmount,
              ),
              _DetailRow(
                icon: Icons.calendar_today_outlined,
                label: 'Сейчас, $season',
                value: 'Ориентировочно каждые $frequency дней',
                last: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (plant.careTips.isNotEmpty)
          _TextSection(
            title: 'Советы по уходу',
            icon: Icons.eco_outlined,
            text: plant.careTips,
            color: context.floraqua.primaryLight,
          ),
        if (plant.careTips.isNotEmpty && plant.moistureNotes.isNotEmpty)
          const SizedBox(height: 14),
        if (plant.moistureNotes.isNotEmpty)
          _TextSection(
            title: 'Оценка по последнему фото',
            icon: Icons.smart_toy_outlined,
            text: plant.moistureNotes,
            color: context.floraqua.aiBubble,
          ),
        if (plant.wateringHistory.isNotEmpty) ...[
          const SizedBox(height: 14),
          _SectionCard(
            title: 'История полива',
            icon: Icons.history,
            child: Column(
              children: [
                for (final date in plant.wateringHistory.reversed.take(10))
                  _DetailRow(
                    icon: Icons.check_circle_outline,
                    label: 'Полито',
                    value: _formatDate(date),
                    last: date == plant.wateringHistory.first,
                  ),
              ],
            ),
          ),
        ],
        if (plant.userNotes?.isNotEmpty ?? false) ...[
          const SizedBox(height: 14),
          _TextSection(
            title: 'Мои заметки',
            icon: Icons.sticky_note_2_outlined,
            text: plant.userNotes!,
            color: context.floraqua.surface,
          ),
        ],
        if ((plant.potSize?.isNotEmpty ?? false) ||
            (plant.location?.isNotEmpty ?? false) ||
            (plant.hasDrainage?.isNotEmpty ?? false)) ...[
          const SizedBox(height: 14),
          _SectionCard(
            title: 'Место и горшок',
            icon: Icons.yard_outlined,
            child: Column(
              children: [
                _DetailRow(
                  icon: Icons.crop_square,
                  label: 'Размер горшка',
                  value: plant.potSize ?? 'Не указано',
                ),
                _DetailRow(
                  icon: Icons.place_outlined,
                  label: 'Расположение',
                  value: plant.location ?? 'Не указано',
                ),
                _DetailRow(
                  icon: Icons.water_damage_outlined,
                  label: 'Дренажные отверстия',
                  value: plant.hasDrainage ?? 'Не указано',
                  last: true,
                ),
              ],
            ),
          ),
        ],
        Padding(
          padding: EdgeInsets.only(top: 12),
          child: Text(
            'График полива — ориентир. Перед поливом проверьте влажность грунта.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: context.floraqua.textSecondary),
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String detail;

  const _SummaryCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.floraqua.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.floraqua.divider),
      ),
      child: Row(
        children: [
          Icon(icon, color: context.floraqua.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 12, color: context.floraqua.textSecondary)),
                const SizedBox(height: 2),
                Text(value,
                    style: TextStyle(fontWeight: FontWeight.w700)),
                Text(detail,
                    style: TextStyle(
                        fontSize: 12, color: context.floraqua.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.floraqua.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.floraqua.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: context.floraqua.primary),
              const SizedBox(width: 8),
              Text(title,
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool last;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.last = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: context.floraqua.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 12, color: context.floraqua.textSecondary)),
                const SizedBox(height: 2),
                Text(value,
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TextSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final String text;
  final Color color;

  const _TextSection({
    required this.title,
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: context.floraqua.primaryDark),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: context.floraqua.primaryDark)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(text, style: TextStyle(height: 1.4)),
        ],
      ),
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder();

  @override
  Widget build(BuildContext context) => Container(
        color: context.floraqua.primaryLight,
        alignment: Alignment.center,
        child: Icon(Icons.local_florist_outlined,
            size: 64, color: context.floraqua.primary),
      );
}

int _daysUntilWatering(DateTime date) {
  final now = DateTime.now();
  return DateTime.utc(date.year, date.month, date.day)
      .difference(DateTime.utc(now.year, now.month, now.day))
      .inDays;
}

String _formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
