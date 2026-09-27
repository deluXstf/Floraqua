import 'package:flutter/widgets.dart';

import 'generated/app_localizations.dart';
import '../services/seasonal_watering.dart';

extension FloraquaLocalizations on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  String seasonLabel(PlantSeason season) => switch (season) {
        PlantSeason.spring => l10n.seasonSpring,
        PlantSeason.summer => l10n.seasonSummer,
        PlantSeason.autumn => l10n.seasonAutumn,
        PlantSeason.winter => l10n.seasonWinter,
      };
}
