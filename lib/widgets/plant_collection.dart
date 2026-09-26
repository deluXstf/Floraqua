import 'package:flutter/material.dart';

import '../models/garden_preferences.dart';
import '../models/plant.dart';

/// Отвечает только за раскладку уже отфильтрованных карточек растений.
/// Данные и действия остаются у родительского экрана.
class PlantCollection extends StatelessWidget {
  final List<Plant> plants;
  final GardenViewMode viewMode;
  final Widget Function(BuildContext context, Plant plant) itemBuilder;

  const PlantCollection({
    super.key,
    required this.plants,
    required this.viewMode,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (viewMode == GardenViewMode.list) {
          final listWidth =
              (constraints.maxWidth - 32).clamp(0.0, 920.0).toDouble();
          return Center(
            child: SizedBox(
              width: listWidth,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                itemCount: plants.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 14),
                itemBuilder: (context, index) =>
                    itemBuilder(context, plants[index]),
              ),
            ),
          );
        }

        const maxCardWidth = 420.0;
        const spacing = 16.0;
        const pageMargin = 16.0;
        const maxGridWidth = 1320.0;
        final availableWidth = (constraints.maxWidth - pageMargin * 2)
            .clamp(0.0, maxGridWidth)
            .toDouble();
        final columns = ((availableWidth + spacing) / (maxCardWidth + spacing))
            .floor()
            .clamp(1, 4);
        final cardWidth = ((availableWidth - (columns - 1) * spacing) / columns)
            .clamp(0.0, maxCardWidth)
            .toDouble();
        final rows = <List<Plant>>[];
        for (var i = 0; i < plants.length; i += columns) {
          rows.add(plants.sublist(
            i,
            i + columns > plants.length ? plants.length : i + columns,
          ));
        }

        return Center(
          child: SizedBox(
            width: availableWidth,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(0, 12, 0, 96),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: rows.map((row) {
                  final rowChildren = <Widget>[];
                  for (var i = 0; i < row.length; i++) {
                    if (i > 0) rowChildren.add(const SizedBox(width: spacing));
                    rowChildren.add(
                      SizedBox(
                        width: cardWidth,
                        child: itemBuilder(context, row[i]),
                      ),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: spacing),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: rowChildren,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}
