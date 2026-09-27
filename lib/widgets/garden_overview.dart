import 'package:flutter/material.dart';

import '../models/plant.dart';
import '../l10n/l10n_extensions.dart';
import '../theme/app_theme.dart';

/// Короткая сводка по расписанию полива. Это индикатор соблюдения графика,
/// а не медицинская диагностика состояния растений.
class GardenHealthSummary extends StatelessWidget {
  final List<Plant> plants;
  final Set<int> needsWaterIds;

  const GardenHealthSummary({
    super.key,
    required this.plants,
    required this.needsWaterIds,
  });

  @override
  Widget build(BuildContext context) {
    if (plants.isEmpty) return const SizedBox.shrink();
    final dueCount = needsWaterIds.length;
    final healthyCount = plants.length - dueCount;
    final score = (healthyCount / plants.length * 100).round();
    final palette = context.floraqua;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1320),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: palette.divider),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Russian count labels are wider than their English
                // counterparts.  At the previous 470px threshold the
                // summary still tried to fit both pills into a 730px test
                // viewport (after outer padding), causing a RenderFlex
                // overflow and pushing the garden content off-screen.
                final compact = constraints.maxWidth < 760;
                final summary = Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: palette.primaryLight,
                      ),
                      child: Icon(Icons.spa_rounded, color: palette.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.gardenHealthTitle,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            context.l10n.gardenHealthScore(score),
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: palette.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    if (!compact) ...[
                      const SizedBox(width: 12),
                      _CountPill(
                        icon: Icons.check_circle_outline,
                        label: context.l10n.healthyCount(healthyCount),
                        color: palette.success,
                      ),
                      const SizedBox(width: 8),
                      _CountPill(
                        icon: Icons.water_drop_outlined,
                        label: context.l10n.dueCount(dueCount),
                        color: dueCount > 0 ? palette.error : palette.success,
                      ),
                    ],
                  ],
                );
                if (!compact) return summary;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    summary,
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _CountPill(
                          icon: Icons.check_circle_outline,
                          label: context.l10n.healthyCount(healthyCount),
                          color: palette.success,
                        ),
                        _CountPill(
                          icon: Icons.water_drop_outlined,
                          label: context.l10n.dueCount(dueCount),
                          color: dueCount > 0 ? palette.error : palette.success,
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _CountPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _CountPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class GardenEmptyState extends StatelessWidget {
  final bool gardenIsEmpty;
  final VoidCallback onAddPlant;
  final VoidCallback onResetFilters;

  const GardenEmptyState({
    super.key,
    required this.gardenIsEmpty,
    required this.onAddPlant,
    required this.onResetFilters,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.floraqua;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 132,
                height: 132,
                decoration: BoxDecoration(
                  color: palette.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  gardenIsEmpty ? Icons.yard_rounded : Icons.search_off_rounded,
                  size: 64,
                  color: palette.primary,
                ),
              ),
              const SizedBox(height: 22),
              Text(
                gardenIsEmpty
                    ? context.l10n.emptyGardenTitle
                    : context.l10n.emptySearchTitle,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                gardenIsEmpty
                    ? context.l10n.emptyGardenDescription
                    : context.l10n.emptySearchDescription,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: palette.textSecondary,
                      height: 1.45,
                    ),
              ),
              const SizedBox(height: 20),
              if (gardenIsEmpty)
                FilledButton.icon(
                  onPressed: onAddPlant,
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                  label: Text(context.l10n.addFirstPlant),
                )
              else
                OutlinedButton.icon(
                  onPressed: onResetFilters,
                  icon: const Icon(Icons.filter_alt_off_outlined),
                  label: Text(context.l10n.resetSearch),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
