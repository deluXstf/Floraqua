import 'package:flutter/material.dart';

import '../models/garden_preferences.dart';
import '../theme/app_theme.dart';

/// Элементы управления поиском, фильтром и способом отображения сада.
class GardenToolbar extends StatelessWidget {
  final GardenFilter filter;
  final ValueChanged<GardenFilter> onFilterChanged;
  final GardenViewMode viewMode;
  final ValueChanged<GardenViewMode> onViewModeChanged;
  final ValueChanged<String> onSearchChanged;

  const GardenToolbar({
    super.key,
    required this.filter,
    required this.onFilterChanged,
    required this.viewMode,
    required this.onViewModeChanged,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1320),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final search = TextField(
                    decoration: InputDecoration(
                      hintText: 'Поиск по названию растения...',
                      prefixIcon: Icon(Icons.search),
                      filled: true,
                      fillColor: context.floraqua.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                    onChanged: onSearchChanged,
                  );
                  final viewSelector = ToggleButtons(
                    isSelected: [
                      viewMode == GardenViewMode.grid,
                      viewMode == GardenViewMode.list,
                    ],
                    onPressed: (index) => onViewModeChanged(
                      index == 0 ? GardenViewMode.grid : GardenViewMode.list,
                    ),
                    constraints:
                        const BoxConstraints(minWidth: 42, minHeight: 42),
                    borderRadius: BorderRadius.circular(12),
                    borderColor: context.floraqua.divider,
                    selectedBorderColor: context.floraqua.primary,
                    fillColor: context.floraqua.primaryLight,
                    color: context.floraqua.textSecondary,
                    selectedColor: context.floraqua.primaryDark,
                    children: const [
                      Tooltip(
                        message: 'Сетка',
                        child: Icon(Icons.grid_view_rounded, size: 20),
                      ),
                      Tooltip(
                        message: 'Список',
                        child: Icon(Icons.view_agenda_outlined, size: 20),
                      ),
                    ],
                  );

                  if (constraints.maxWidth < 480) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        search,
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: viewSelector,
                        ),
                      ],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(child: search),
                      const SizedBox(width: 10),
                      viewSelector,
                    ],
                  );
                },
              ),
            ),
          ),
        ),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1320),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                children: [
                  _FilterChip(
                    label: 'Все',
                    selected: filter == GardenFilter.all,
                    onTap: () => onFilterChanged(GardenFilter.all),
                  ),
                  _FilterChip(
                    label: 'К поливу',
                    selected: filter == GardenFilter.needsWater,
                    onTap: () => onFilterChanged(GardenFilter.needsWater),
                  ),
                  _FilterChip(
                    label: 'Здоровы',
                    selected: filter == GardenFilter.healthy,
                    onTap: () => onFilterChanged(GardenFilter.healthy),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: context.floraqua.primary,
      labelStyle: TextStyle(
        color: selected ? Colors.white : context.floraqua.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      backgroundColor: context.floraqua.chipInactive,
      side: BorderSide.none,
    );
  }
}
