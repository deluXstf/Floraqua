import 'dart:async';

import 'package:flutter/material.dart';

import '../models/garden_preferences.dart';
import '../models/plant.dart';
import '../services/plant_store.dart';
import '../services/secure_storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/garden_toolbar.dart';
import '../widgets/garden_overview.dart';
import '../widgets/plant_collection.dart';
import '../widgets/plant_card.dart';
import 'garden_plant_actions.dart';
import 'settings_screen.dart';

Future<void> _ignoreThemeChange(ThemeMode _) async {}

/// Главный экран — аналог PlantGardenGUI (main.py, Python-версия): сетка
/// карточек, поиск, фильтры, кнопка добавления. В отличие от Python-версии,
/// где после каждого изменения нужно было вручную звать refresh_garden(),
/// здесь PlantStore сам уведомляет экран об изменениях через ChangeNotifier
/// (см. ListenableBuilder ниже) — экран просто перестраивается сам.
class GardenScreen extends StatefulWidget {
  final PlantStore store;
  final SecureStorageService secureStorage;
  final ThemeMode themeMode;
  final Future<void> Function(ThemeMode) onThemeModeChanged;
  final VoidCallback onChangeApiKey;

  const GardenScreen({
    super.key,
    required this.store,
    required this.secureStorage,
    this.themeMode = ThemeMode.system,
    this.onThemeModeChanged = _ignoreThemeChange,
    required this.onChangeApiKey,
  });

  @override
  State<GardenScreen> createState() => _GardenScreenState();
}

class _GardenScreenState extends State<GardenScreen>
    with WidgetsBindingObserver {
  GardenFilter _filter = GardenFilter.all;
  GardenViewMode _viewMode = GardenViewMode.grid;
  String _searchQuery = '';
  bool _loading = true;
  late final GardenPlantActions _actions =
      GardenPlantActions(store: widget.store);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(widget.store.refreshSeasonalWatering());
    }
  }

  Future<void> _load() async {
    Object? loadError;
    try {
      await widget.store.loadGarden();
    } catch (error) {
      loadError = error;
      debugPrint('Не удалось загрузить сад: $error');
    }
    GardenViewMode? savedViewMode;
    try {
      final savedMode = await widget.secureStorage.loadGardenViewMode();
      for (final mode in GardenViewMode.values) {
        if (mode.name == savedMode) savedViewMode = mode;
      }
    } catch (e) {
      debugPrint('Не удалось загрузить вид сада: $e');
    }
    if (!mounted) return;
    final modeToApply = savedViewMode;
    setState(() {
      _loading = false;
      if (modeToApply != null) _viewMode = modeToApply;
    });
    if (loadError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось загрузить сад: $loadError')),
      );
    }
  }

  Future<void> _setViewMode(GardenViewMode mode) async {
    setState(() => _viewMode = mode);
    try {
      await widget.secureStorage.saveGardenViewMode(mode.name);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось сохранить вид сада')),
      );
    }
  }

  Widget _buildPlantCard(
    BuildContext context,
    Plant plant, {
    required bool listMode,
  }) {
    return PlantCard(
      plant: plant,
      listMode: listMode,
      onWater: () => _waterPlant(context, plant.id),
      onEdit: () => _actions.editPlant(context, plant),
      onDelete: () => _actions.confirmDelete(context, plant),
      onCheck: () => _actions.recheckPlant(context, plant),
      onOpenDetails: () => _actions.openPlantDetails(context, plant),
      onOpenFullImage: plant.imagePath == null
          ? null
          : () => _actions.openFullImage(context, plant),
    );
  }

  Future<bool> _waterPlant(BuildContext context, int id) async {
    try {
      final saved = await widget.store.waterPlant(id);
      if (!saved && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось сохранить полив')),
        );
      }
      return saved;
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при сохранении полива: $error')),
        );
      }
      return false;
    }
  }

  List<Plant> _filteredPlants() {
    final needsWaterIds =
        widget.store.checkWateringNeeds().map((p) => p.id).toSet();

    Iterable<Plant> result = widget.store.plants;
    switch (_filter) {
      case GardenFilter.needsWater:
        result = result.where((p) => needsWaterIds.contains(p.id));
        break;
      case GardenFilter.healthy:
        result = result.where((p) => !needsWaterIds.contains(p.id));
        break;
      case GardenFilter.all:
        break;
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((p) =>
          p.displayName.toLowerCase().contains(q) ||
          p.scientificName.toLowerCase().contains(q));
    }

    return result.toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: ListenableBuilder(
          listenable: widget.store,
          builder: (context, _) => Text(
            'FLORAQUA · ${widget.store.plants.length}',
            style: TextStyle(
              color: context.floraqua.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined),
            tooltip: 'Настройки',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => SettingsScreen(
                  store: widget.store,
                  secureStorage: widget.secureStorage,
                  themeMode: widget.themeMode,
                  onThemeModeChanged: widget.onThemeModeChanged,
                  onChangeApiKey: widget.onChangeApiKey,
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _actions.addPlant(context),
        backgroundColor: context.floraqua.primary,
        icon: Icon(Icons.add),
        label: const Text('Добавить растение'),
      ),
      body: Column(
        children: [
          ListenableBuilder(
            listenable: widget.store,
            builder: (context, _) => GardenHealthSummary(
              plants: widget.store.plants,
              needsWaterIds: widget.store
                  .checkWateringNeeds()
                  .map((plant) => plant.id)
                  .toSet(),
            ),
          ),
          GardenToolbar(
            filter: _filter,
            onFilterChanged: (filter) => setState(() => _filter = filter),
            viewMode: _viewMode,
            onViewModeChanged: _setViewMode,
            onSearchChanged: (query) => setState(() => _searchQuery = query),
          ),
          Expanded(
            child: ListenableBuilder(
              listenable: widget.store,
              builder: (context, _) {
                final plants = _filteredPlants();
                if (plants.isEmpty) {
                  return GardenEmptyState(
                    gardenIsEmpty: widget.store.plants.isEmpty,
                    onAddPlant: () => _actions.addPlant(context),
                    onResetFilters: () => setState(() {
                      _filter = GardenFilter.all;
                      _searchQuery = '';
                    }),
                  );
                }
                return PlantCollection(
                  plants: plants,
                  viewMode: _viewMode,
                  itemBuilder: (context, plant) => _buildPlantCard(
                      context, plant,
                      listMode: _viewMode == GardenViewMode.list),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
