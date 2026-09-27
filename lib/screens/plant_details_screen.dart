import 'dart:io';

import 'package:flutter/material.dart';

import '../models/plant.dart';
import '../l10n/l10n_extensions.dart';
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
            appBar: AppBar(title: Text(context.l10n.plantDetailsTitle)),
            body: Center(child: Text(context.l10n.plantNotFound)),
          );
        }
        final now = DateTime.now();
        final frequency = SeasonalWatering.frequencyFor(
          plant.wateringFrequency,
          now,
        );
        final season = context.seasonLabel(SeasonalWatering.seasonForDate(now));

        return Scaffold(
          appBar: AppBar(
            title: Text(plant.displayName,
                maxLines: 1, overflow: TextOverflow.ellipsis),
            actions: [
              PopupMenuButton<String>(
                tooltip: context.l10n.plantActionsTooltip,
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
                    PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        dense: true,
                        leading: const Icon(Icons.edit_outlined),
                        title: Text(context.l10n.commonEdit),
                      ),
                    ),
                  if (onCheck != null)
                    PopupMenuItem(
                      value: 'check',
                      child: ListTile(
                        dense: true,
                        leading: const Icon(Icons.photo_camera_outlined),
                        title: Text(context.l10n.recheckPhoto),
                      ),
                    ),
                  if (onDelete != null)
                    PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        dense: true,
                        leading: Icon(Icons.delete_outline,
                            color: context.floraqua.error),
                        title: Text(context.l10n.deletePlantMenu),
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
          title: context.l10n.wateringLabel,
          value: '${context.l10n.wateringFrequency(frequency)} · $season',
          detail: context.l10n.nextWateringDetails(
            _formatDate(context, plant.nextWatering),
            reminderTimeLabel,
          ),
        ),
        if (plant.lastWatered != null) ...[
          const SizedBox(height: 8),
          _SummaryCard(
            icon: Icons.history,
            title: context.l10n.lastWatering,
            value: _formatDate(context, plant.lastWatered!),
            detail: context.l10n.historyCount(plant.wateringHistory.length),
          ),
        ],
        const SizedBox(height: 14),
        FilledButton.icon(
          onPressed: onWater,
          icon: const Icon(Icons.water_drop_outlined),
          label: Text(context.l10n.markWatered),
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
          title: context.l10n.careConditions,
          icon: Icons.tune,
          child: Column(
            children: [
              _DetailRow(
                icon: Icons.wb_sunny_outlined,
                label: context.l10n.lightLabel,
                value: plant.lightRequirements,
              ),
              _DetailRow(
                icon: Icons.thermostat_outlined,
                label: context.l10n.temperatureLabel,
                value: plant.temperature,
              ),
              _DetailRow(
                icon: Icons.opacity_outlined,
                label: context.l10n.humidityLabel,
                value: plant.humidity,
              ),
              _DetailRow(
                icon: Icons.spa_outlined,
                label: context.l10n.difficultyLabel,
                value: _localizeDifficulty(context, plant.difficulty),
              ),
              _DetailRow(
                icon: Icons.water_outlined,
                label: context.l10n.baseWateringInterval,
                value: context.l10n.wateringFrequency(plant.wateringFrequency),
              ),
              _DetailRow(
                icon: Icons.local_drink_outlined,
                label: context.l10n.estimatedWaterAmount,
                value: plant.wateringAmount,
              ),
              _DetailRow(
                icon: Icons.calendar_today_outlined,
                label: context.l10n.seasonCurrent(season),
                value: context.l10n.estimatedWaterFrequency(
                  context.l10n.wateringFrequency(frequency),
                ),
                last: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (plant.careTips.isNotEmpty)
          _TextSection(
            title: context.l10n.careTips,
            icon: Icons.eco_outlined,
            text: plant.careTips,
            color: context.floraqua.primaryLight,
          ),
        if (plant.careTips.isNotEmpty && plant.moistureNotes.isNotEmpty)
          const SizedBox(height: 14),
        if (plant.moistureNotes.isNotEmpty)
          _TextSection(
            title: context.l10n.lastPhotoAssessment,
            icon: Icons.smart_toy_outlined,
            text: plant.moistureNotes,
            color: context.floraqua.aiBubble,
          ),
        if (plant.wateringHistory.isNotEmpty) ...[
          const SizedBox(height: 14),
          _SectionCard(
            title: context.l10n.wateringHistory,
            icon: Icons.history,
            child: Column(
              children: [
                for (final date in plant.wateringHistory.reversed.take(10))
                  _DetailRow(
                    icon: Icons.check_circle_outline,
                    label: context.l10n.watered,
                    value: _formatDate(context, date),
                    last: date == plant.wateringHistory.first,
                  ),
              ],
            ),
          ),
        ],
        if (plant.userNotes?.isNotEmpty ?? false) ...[
          const SizedBox(height: 14),
          _TextSection(
            title: context.l10n.myNotes,
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
            title: context.l10n.placeAndPot,
            icon: Icons.yard_outlined,
            child: Column(
              children: [
                _DetailRow(
                  icon: Icons.crop_square,
                  label: context.l10n.potSize,
                  value: _localizePotSize(context, plant.potSize),
                ),
                _DetailRow(
                  icon: Icons.place_outlined,
                  label: context.l10n.locationLabel,
                  value: _localizeLocation(context, plant.location),
                ),
                _DetailRow(
                  icon: Icons.water_damage_outlined,
                  label: context.l10n.drainageHoles,
                  value: _localizeDrainage(context, plant.hasDrainage),
                  last: true,
                ),
              ],
            ),
          ),
        ],
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(
            context.l10n.wateringDisclaimer,
            textAlign: TextAlign.center,
            style:
                TextStyle(fontSize: 12, color: context.floraqua.textSecondary),
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
                    style: const TextStyle(fontWeight: FontWeight.w700)),
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
                  style: const TextStyle(
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
                    style: const TextStyle(fontWeight: FontWeight.w600)),
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
          Text(text, style: const TextStyle(height: 1.4)),
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

String _formatDate(BuildContext context, DateTime date) =>
    MaterialLocalizations.of(context).formatMediumDate(date);

String _localizeDifficulty(BuildContext context, String value) =>
    switch (value.toLowerCase()) {
      'легко' || 'easy' => context.l10n.difficultyEasy,
      'сложно' || 'challenging' || 'hard' => context.l10n.difficultyHard,
      'средне' || 'moderate' || 'medium' => context.l10n.difficultyMedium,
      _ => value,
    };

String _localizePotSize(BuildContext context, String? value) => switch (value) {
      'Маленький' ||
      'Маленький (до 10 см)' ||
      'Small (up to 10 cm)' =>
        context.l10n.potSmall,
      'Средний' ||
      'Средний (10-20 см)' ||
      'Средний (10–20 см)' ||
      'Medium (10–20 cm)' =>
        context.l10n.potMedium,
      'Большой' ||
      'Большой (20-30 см)' ||
      'Большой (20–30 см)' ||
      'Large (20–30 cm)' =>
        context.l10n.potLarge,
      'Очень большой' ||
      'Очень большой (30+ см)' ||
      'Extra large (30+ cm)' =>
        context.l10n.potExtraLarge,
      null || '' => context.l10n.notSpecified,
      _ => value,
    };

String _localizeLocation(BuildContext context, String? value) =>
    switch (value) {
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
      null || '' => context.l10n.notSpecified,
      _ => value,
    };

String _localizeDrainage(BuildContext context, String? value) =>
    switch (value) {
      'Да' || 'Yes' => context.l10n.yes,
      'Нет' || 'No' => context.l10n.no,
      'Не знаю' || "Don't know" => context.l10n.unknown,
      null || '' => context.l10n.notSpecified,
      _ => value,
    };
