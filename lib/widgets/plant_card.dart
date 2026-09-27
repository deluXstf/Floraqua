import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import '../models/plant.dart';
import '../l10n/l10n_extensions.dart';
import '../services/seasonal_watering.dart';
import '../theme/app_theme.dart';
import 'watering_ring.dart';

/// Карточка растения — основной элемент главного экрана.
///
/// Дизайн-заметка (в сравнении с Python-версией): там скруглённое фото с
/// бейджами поверх него потребовало отдельного раунда правок — бейджи
/// рисовались отдельными Canvas-виджетами, из-за чего вокруг скруглений
/// была видна тёмная кайма (баг, который мы ловили несколько итераций).
/// Здесь то же самое — это просто Stack + ClipRRect + Container с
/// полупрозрачным фоном, никакого рукописного альфа-компоузинга не
/// требуется, Flutter сам корректно сводит слои с учётом прозрачности.
class PlantCard extends StatelessWidget {
  final Plant plant;
  final Future<bool> Function()? onWater;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onCheck;
  final VoidCallback? onOpenDetails;
  final VoidCallback? onOpenFullImage;
  final bool listMode;

  const PlantCard({
    super.key,
    required this.plant,
    this.onWater,
    this.onEdit,
    this.onDelete,
    this.onCheck,
    this.onOpenDetails,
    this.onOpenFullImage,
    this.listMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime.utc(now.year, now.month, now.day);
    final wateringDate = DateTime.utc(
      plant.nextWatering.year,
      plant.nextWatering.month,
      plant.nextWatering.day,
    );
    final daysUntilWatering = wateringDate.difference(today).inDays;
    final frequency =
        SeasonalWatering.frequencyFor(plant.wateringFrequency, now);
    final season = context.seasonLabel(SeasonalWatering.seasonForDate(now));
    final frequencyLabel =
        '${context.l10n.wateringFrequency(frequency)} · $season';
    if (listMode) {
      return _buildListCard(daysUntilWatering, frequencyLabel, season);
    }
    return SizedBox(
      height: 338,
      child: Container(
        decoration: BoxDecoration(
          color: context.floraqua.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          boxShadow: [
            BoxShadow(
              color: context.floraqua.shadow.withValues(alpha: 0.5),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PhotoWithBadges(
              plant: plant,
              daysUntilWatering: daysUntilWatering,
              onDoubleTap: onOpenFullImage,
              photoHeight: 144,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _NameAndRing(
                    plant: plant,
                    daysUntilWatering: daysUntilWatering,
                    compact: true,
                    height: 80,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.water_drop_outlined,
                          size: 15, color: context.floraqua.primary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          frequencyLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: context.floraqua.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _CompactCardActions(
                    onWater: onWater,
                    onOpenDetails: onOpenDetails,
                    onEdit: onEdit,
                    onCheck: onCheck,
                    onDelete: onDelete,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListCard(
    int daysUntilWatering,
    String frequencyLabel,
    String season,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final photoWidth =
            (constraints.maxWidth * 0.28).clamp(80.0, 156.0).toDouble();
        final contentPadding = constraints.maxWidth < 400
            ? const EdgeInsets.fromLTRB(8, 10, 8, 10)
            : const EdgeInsets.fromLTRB(16, 10, 12, 10);
        return SizedBox(
          height: 184,
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: context.floraqua.surface,
              borderRadius: BorderRadius.circular(AppRadius.card),
              boxShadow: [
                BoxShadow(
                  color: context.floraqua.shadow.withValues(alpha: 0.5),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                SizedBox(
                  width: photoWidth,
                  height: 184,
                  child: _PhotoWithBadges(
                    plant: plant,
                    daysUntilWatering: daysUntilWatering,
                    onDoubleTap: onOpenFullImage,
                    photoHeight: 184,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: contentPadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _NameAndRing(
                          plant: plant,
                          daysUntilWatering: daysUntilWatering,
                          compact: true,
                          height: 68,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          frequencyLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: context.floraqua.textSecondary,
                          ),
                        ),
                        if (plant.careTips.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Expanded(
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                plant.careTips,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: context.floraqua.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ] else
                          const Spacer(),
                        _CompactCardActions(
                          onWater: onWater,
                          onOpenDetails: onOpenDetails,
                          onEdit: onEdit,
                          onCheck: onCheck,
                          onDelete: onDelete,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PhotoWithBadges extends StatefulWidget {
  final Plant plant;
  final int daysUntilWatering;
  final VoidCallback? onDoubleTap;
  final double photoHeight;

  const _PhotoWithBadges({
    required this.plant,
    required this.daysUntilWatering,
    this.onDoubleTap,
    this.photoHeight = 148,
  });

  @override
  State<_PhotoWithBadges> createState() => _PhotoWithBadgesState();
}

class _PhotoWithBadgesState extends State<_PhotoWithBadges> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final (chipBg, chipFg) =
        context.floraqua.difficultyColors(widget.plant.difficulty);
    final statusColor =
        context.floraqua.wateringStatusColor(widget.daysUntilWatering);
    // Подсказку и значок увеличения показываем только если фото реально
    // можно открыть (не для заглушки-плейсхолдера без снимка) — иначе это
    // была бы подсказка про несуществующее действие.
    final canOpen = widget.onDoubleTap != null;

    final photoStack = SizedBox(
      height: widget.photoHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildPhoto(),
          // Статус-точка полива — верхний левый угол. В Python-версии для
          // этого пришлось городить отдельный порог бинаризации альфа-канала
          // под colorkey-прозрачность; здесь просто Container с обводкой.
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
            ),
          ),
          // Чип сложности — верхний правый угол
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: chipBg,
                borderRadius: BorderRadius.circular(AppRadius.chip),
              ),
              child: Text(
                _capitalize(widget.plant.difficulty),
                style: TextStyle(
                  color: chipFg,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Найдено по обратной связи: без явной подсказки не было понятно,
          // что по фото можно кликнуть дважды и открыть его на весь экран.
          // Значок проявляется плавно при наведении курсора (на touch-
          // устройствах, где наведения не существует, остаётся Tooltip —
          // он на мобильных платформах показывается по долгому нажатию).
          if (canOpen)
            IgnorePointer(
              child: AnimatedOpacity(
                opacity: _hovering ? 1 : 0,
                duration: const Duration(milliseconds: 150),
                child: Container(
                  color: Colors.black26,
                  alignment: Alignment.center,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Colors.black45,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.zoom_in,
                        color: Colors.white, size: 28),
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    return MouseRegion(
      onEnter: canOpen ? (_) => setState(() => _hovering = true) : null,
      onExit: canOpen ? (_) => setState(() => _hovering = false) : null,
      cursor: canOpen ? SystemMouseCursors.click : MouseCursor.defer,
      child: GestureDetector(
        onDoubleTap: widget.onDoubleTap,
        // Раньше здесь был AspectRatio(16:10) — высота фото росла
        // пропорционально ШИРИНЕ карточки, а на широком десктопном окне
        // карточка растягивается на всю ширину экрана, из-за чего фото
        // становилось огромным (сотни пикселей высотой). Фиксированная
        // высота не зависит от ширины окна — фото остаётся одного разумного
        // размера что на телефоне, что на широком десктопном окне.
        child: canOpen
            ? Tooltip(
                message: context.l10n.openPhotoFullSize,
                waitDuration: const Duration(milliseconds: 400),
                child: photoStack,
              )
            : photoStack,
      ),
    );
  }

  Widget _buildPhoto() {
    if (widget.plant.imagePath != null &&
        File(widget.plant.imagePath!).existsSync()) {
      return Image.file(
        File(widget.plant.imagePath!),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _placeholder(),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      color: context.floraqua.primaryLight,
      alignment: Alignment.center,
      child: const Text('🌱', style: TextStyle(fontSize: 48)),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
}

class _NameAndRing extends StatelessWidget {
  final Plant plant;
  final int daysUntilWatering;
  final bool compact;
  final double height;

  const _NameAndRing({
    required this.plant,
    required this.daysUntilWatering,
    this.compact = false,
    this.height = 64,
  });

  @override
  Widget build(BuildContext context) {
    final frequency = SeasonalWatering.frequencyFor(
      plant.wateringFrequency,
      DateTime.now(),
    );
    return SizedBox(
      // Высота фиксирована для ровной линии кнопок; карточка сетки даёт
      // дополнительный запас для двух строк имени и scientific name.
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plant.displayName,
                  style: TextStyle(
                    fontSize: compact ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: context.floraqua.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (plant.scientificName.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      plant.scientificName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: context.floraqua.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          WateringRing(
            daysUntilWatering: daysUntilWatering,
            frequency: frequency,
            size: compact ? 52 : 58,
          ),
        ],
      ),
    );
  }
}

class _CompactCardActions extends StatelessWidget {
  final Future<bool> Function()? onWater;
  final VoidCallback? onOpenDetails;
  final VoidCallback? onEdit;
  final VoidCallback? onCheck;
  final VoidCallback? onDelete;

  const _CompactCardActions({
    this.onWater,
    this.onOpenDetails,
    this.onEdit,
    this.onCheck,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 220) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _WateringActionButton(onWater: onWater, compact: true),
              IconButton(
                tooltip: context.l10n.plantDetails,
                onPressed: onOpenDetails,
                style: IconButton.styleFrom(
                  foregroundColor: context.floraqua.primaryDark,
                  side: BorderSide(color: context.floraqua.primaryLight),
                ),
                icon: const Icon(Icons.article_outlined),
              ),
              PopupMenuButton<_CardAction>(
                tooltip: context.l10n.moreActions,
                icon: const Icon(Icons.more_horiz),
                onSelected: _dispatch,
                itemBuilder: _menuItems,
              ),
            ],
          );
        }
        final compact = constraints.maxWidth < 340;
        return Row(
          children: [
            Expanded(
              child: _WateringActionButton(
                onWater: onWater,
                compact: false,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: compact
                  ? OutlinedButton(
                      onPressed: onOpenDetails,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 40),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        foregroundColor: context.floraqua.primaryDark,
                        side: BorderSide(color: context.floraqua.primaryLight),
                      ),
                      child: Text(context.l10n.plantDetails),
                    )
                  : OutlinedButton.icon(
                      onPressed: onOpenDetails,
                      icon: const Icon(Icons.article_outlined, size: 16),
                      label: Text(context.l10n.plantDetails),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 40),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        foregroundColor: context.floraqua.primaryDark,
                        side: BorderSide(color: context.floraqua.primaryLight),
                      ),
                    ),
            ),
            PopupMenuButton<_CardAction>(
              tooltip: context.l10n.moreActions,
              icon: const Icon(Icons.more_horiz),
              onSelected: _dispatch,
              itemBuilder: _menuItems,
            ),
          ],
        );
      },
    );
  }

  void _dispatch(_CardAction action) {
    switch (action) {
      case _CardAction.edit:
        onEdit?.call();
        break;
      case _CardAction.check:
        onCheck?.call();
        break;
      case _CardAction.delete:
        onDelete?.call();
        break;
    }
  }

  List<PopupMenuEntry<_CardAction>> _menuItems(BuildContext context) => [
        if (onEdit != null)
          PopupMenuItem(
            value: _CardAction.edit,
            child: ListTile(
              dense: true,
              leading: const Icon(Icons.edit_outlined),
              title: Text(context.l10n.commonEdit),
            ),
          ),
        if (onCheck != null)
          PopupMenuItem(
            value: _CardAction.check,
            child: ListTile(
              dense: true,
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(context.l10n.recheckPhoto),
            ),
          ),
        if (onDelete != null)
          PopupMenuItem(
            value: _CardAction.delete,
            child: ListTile(
              dense: true,
              leading:
                  Icon(Icons.delete_outline, color: context.floraqua.error),
              title: Text(context.l10n.deletePlantMenu),
            ),
          ),
      ];
}

enum _CardAction { edit, check, delete }

class _WateringActionButton extends StatefulWidget {
  final Future<bool> Function()? onWater;
  final bool compact;

  const _WateringActionButton({required this.onWater, required this.compact});

  @override
  State<_WateringActionButton> createState() => _WateringActionButtonState();
}

class _WateringActionButtonState extends State<_WateringActionButton> {
  Timer? _resetTimer;
  bool _justWatered = false;
  bool _working = false;

  @override
  void dispose() {
    _resetTimer?.cancel();
    super.dispose();
  }

  Future<void> _water() async {
    if (_working || widget.onWater == null) return;
    setState(() => _working = true);
    var succeeded = false;
    try {
      succeeded = await widget.onWater!();
    } finally {
      if (mounted) {
        setState(() {
          _working = false;
          _justWatered = succeeded;
        });
        if (succeeded) {
          _resetTimer?.cancel();
          _resetTimer = Timer(const Duration(milliseconds: 1200), () {
            if (mounted) setState(() => _justWatered = false);
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.floraqua;
    final icon = _working
        ? const SizedBox(
            key: ValueKey('watering-progress'),
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
        : Icon(
            _justWatered ? Icons.check_rounded : Icons.water_drop_outlined,
            key: ValueKey(_justWatered ? 'watered' : 'water'),
            size: widget.compact ? 20 : 16,
          );

    if (widget.compact) {
      return Tooltip(
        message:
            _justWatered ? context.l10n.wateringSaved : context.l10n.waterNow,
        child: IconButton(
          onPressed: _working ? null : _water,
          style: IconButton.styleFrom(
            backgroundColor: _justWatered ? palette.success : palette.primary,
            foregroundColor: Colors.white,
          ),
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            transitionBuilder: (child, animation) => ScaleTransition(
              scale: animation,
              child: child,
            ),
            child: icon,
          ),
        ),
      );
    }

    return FilledButton.icon(
      onPressed: _working ? null : _water,
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        transitionBuilder: (child, animation) => ScaleTransition(
          scale: animation,
          child: child,
        ),
        child: icon,
      ),
      label: AnimatedSwitcher(
        duration: const Duration(milliseconds: 160),
        child: Text(
          _working
              ? context.l10n.wateringInProgress
              : _justWatered
                  ? context.l10n.watered
                  : context.l10n.waterNow,
          key: ValueKey(
            _working
                ? 'watering'
                : _justWatered
                    ? 'watered'
                    : 'water',
          ),
        ),
      ),
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 40),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        backgroundColor: _justWatered ? palette.success : palette.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}
