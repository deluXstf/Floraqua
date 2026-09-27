import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../models/plant.dart';
import '../l10n/l10n_extensions.dart';
import '../services/plant_store.dart';
import '../services/seasonal_watering.dart';
import '../theme/app_theme.dart';
import '../widgets/full_image_viewer.dart';
import '../widgets/gemini_status_dialogs.dart';
import '../widgets/plant_editor_sheet.dart';
import 'plant_details_screen.dart';

/// Координирует пользовательские действия над растениями.
/// Бизнес-данные остаются в [PlantStore], этот класс отвечает за UI-потоки.
class GardenPlantActions {
  final PlantStore store;

  const GardenPlantActions({required this.store});

  Future<void> addPlant(BuildContext context) async {
    final source = await showPlantImageSourcePicker(context);
    if (source == null || !context.mounted) return;

    XFile? photo;
    try {
      photo = await ImagePicker().pickImage(
        source: source,
        imageQuality: 90,
      );
    } on PlatformException {
      if (!context.mounted) return;
      final place = source == ImageSource.camera
          ? context.l10n.permissionCamera
          : context.l10n.permissionPhotos;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n.addPhotoPermissionError(place),
          ),
        ),
      );
      return;
    }
    if (photo == null || !context.mounted) return;

    final details = await showPlantDetailsSheet(context);
    if (details == null || !context.mounted) return;

    showGeminiLoadingDialog(context, context.l10n.loadingPhotoAnalysis);
    try {
      await store.addPlant(
        imagePath: photo.path,
        customName: details.customName,
        userNotes: details.userNotes,
        potSize: details.potSize,
        location: details.location,
        hasDrainage: details.hasDrainage,
      );
      if (!context.mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(context.l10n.plantAdded)));
    } catch (error) {
      if (!context.mounted) return;
      Navigator.of(context).pop();
      showGeminiErrorSnack(context, error);
    }
  }

  Future<void> recheckPlant(BuildContext context, Plant plant) async {
    final photo = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (photo == null || !context.mounted) return;

    showGeminiLoadingDialog(context, context.l10n.loadingPlantCheck);
    try {
      final result = await store.geminiService.assessWateringByPhoto(
        imageBytes: await photo.readAsBytes(),
        potSize: plant.potSize,
        location: plant.location,
        hasDrainage: plant.hasDrainage,
        userNotes: plant.userNotes,
      );

      final saved = await store.updatePlant(plant.id, (current) {
        final needsNow = result['needs_water_now'] as bool? ?? false;
        final now = DateTime.now();
        final frequency = SeasonalWatering.frequencyFor(
          current.wateringFrequency,
          now,
        );
        return current.copyWith(
          needsWaterNowDetected: needsNow,
          moistureNotes:
              result['moisture_notes'] as String? ?? current.moistureNotes,
          nextWatering: needsNow ? now : now.add(Duration(days: frequency)),
        );
      });

      if (!context.mounted) return;
      Navigator.of(context).pop();
      if (!saved) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.gardenSaveWaterFailure)),
        );
      }
    } catch (error) {
      if (!context.mounted) return;
      Navigator.of(context).pop();
      showGeminiErrorSnack(context, error);
    }
  }

  Future<void> editPlant(BuildContext context, Plant plant) async {
    final details = await showPlantDetailsSheet(
      context,
      initialName: plant.customName,
      initialNotes: plant.userNotes,
      initialPotSize: plant.potSize,
      initialLocation: plant.location,
      initialDrainage: plant.hasDrainage,
      initialFrequency: plant.wateringFrequency,
      initialLastWatered: plant.lastWatered,
      isEditing: true,
    );
    if (details == null) return;

    final saved = await store.updatePlant(plant.id, (current) {
      final newFrequency =
          details.wateringFrequency ?? current.wateringFrequency;
      final newLastWatered = details.clearLastWatered
          ? null
          : details.lastWatered ?? current.lastWatered;
      final scheduleAnchor = newLastWatered ?? DateTime.now();
      final effectiveFrequency =
          SeasonalWatering.frequencyFor(newFrequency, scheduleAnchor);
      final scheduleChanged = details.wateringFrequency != null ||
          details.lastWatered != null ||
          details.clearLastWatered;
      final nextWatering = scheduleChanged
          ? scheduleAnchor.add(Duration(days: effectiveFrequency))
          : current.nextWatering;

      return current.copyWith(
        customName: details.customName,
        userNotes: details.userNotes,
        potSize: details.potSize,
        location: details.location,
        hasDrainage: details.hasDrainage,
        wateringFrequency: newFrequency,
        lastWatered: newLastWatered,
        nextWatering: nextWatering,
      );
    });
    if (!saved && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.gardenSaveWaterFailure)),
      );
    }
  }

  Future<void> confirmDelete(BuildContext context, Plant plant) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.deletePlantTitle),
        content: Text(context.l10n.deletePlantBody(plant.displayName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: context.floraqua.error),
            child: Text(context.l10n.commonDelete),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final deleted = await store.deletePlant(plant.id);
      if (!deleted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.gardenSaveWaterFailure)),
        );
      }
    }
  }

  Future<void> openFullImage(BuildContext context, Plant plant) async {
    final path = plant.imagePath;
    if (path == null) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => FullImageViewer(imagePath: path),
      ),
    );
  }

  void openPlantDetails(BuildContext context, Plant plant) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PlantDetailsScreen(
          store: store,
          plantId: plant.id,
          onWater: () => store.waterPlant(plant.id),
          onEdit: () => editPlant(context, plant),
          onCheck: () => recheckPlant(context, plant),
          onDelete: () async {
            await confirmDelete(context, plant);
            if (store.getPlant(plant.id) == null && context.mounted) {
              Navigator.of(context).pop();
            }
          },
          onOpenFullImage: () => openFullImage(context, plant),
        ),
      ),
    );
  }
}

/// Спрашивает, откуда взять фотографию растения.
/// На iPhone использует привычное системное action sheet.
Future<ImageSource?> showPlantImageSourcePicker(BuildContext context) {
  if (Theme.of(context).platform == TargetPlatform.iOS) {
    return showCupertinoModalPopup<ImageSource>(
      context: context,
      builder: (sheetContext) => CupertinoActionSheet(
        title: Text(context.l10n.photoSourceTitle),
        message: Text(context.l10n.photoSourcePrompt),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => Navigator.of(sheetContext).pop(ImageSource.gallery),
            child: Text(context.l10n.choosePhotoLibrary),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.of(sheetContext).pop(ImageSource.camera),
            child: Text(context.l10n.takePhotoNow),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(sheetContext).pop(),
          child: Text(context.l10n.commonCancel),
        ),
      ),
    );
  }

  return showModalBottomSheet<ImageSource>(
    context: context,
    useSafeArea: true,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: Text(context.l10n.choosePhotoLibrary),
            onTap: () => Navigator.of(sheetContext).pop(ImageSource.gallery),
          ),
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: Text(context.l10n.takePhotoNow),
            onTap: () => Navigator.of(sheetContext).pop(ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.close),
            title: Text(context.l10n.commonCancel),
            onTap: () => Navigator.of(sheetContext).pop(),
          ),
        ],
      ),
    ),
  );
}
