// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Floraqua';

  @override
  String get languageLabel => 'Language';

  @override
  String get languageRussian => 'Русский';

  @override
  String get languageEnglish => 'English';

  @override
  String get onboardingTitle1 => 'Your garden, all in one place';

  @override
  String get onboardingDescription1 =>
      'Add your favorite plants and identify them from a photo. Floraqua keeps each plant\'s details and care information together.';

  @override
  String get onboardingTitle2 => 'Care that follows the seasons';

  @override
  String get onboardingDescription2 =>
      'Get care guidance and watering estimates for your plants. Always check the soil before watering.';

  @override
  String get onboardingTitle3 => 'Reminders on your schedule';

  @override
  String get onboardingDescription3 =>
      'Choose a convenient notification time. Plant identification requires your own Gemini API key, which is stored on this device.';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingFinish => 'Continue to API key setup';

  @override
  String onboardingProgress(int page, int total) {
    return '$page of $total';
  }

  @override
  String get onboardingSaveError =>
      'Couldn\'t save the first-run setting. Please try again.';

  @override
  String get apiGetKeyTitle => 'Get an API key';

  @override
  String get apiClose => 'Close';

  @override
  String get apiEnterKey => 'Enter an API key';

  @override
  String get apiSaveError =>
      'Couldn\'t save the key on this device. Check permissions and try again.';

  @override
  String get apiDescription =>
      'A personal Google Gemini API key is required to identify plants and provide care guidance.';

  @override
  String get apiSecurityNotice =>
      'Enter only your own key and never share it. A shared developer key must not be embedded in the app; that would require a server proxy.';

  @override
  String get apiWhereGetKey => 'Where can I get a key?';

  @override
  String get apiKeyLabel => 'Gemini API key';

  @override
  String get apiShowKey => 'Show key';

  @override
  String get apiHideKey => 'Hide key';

  @override
  String get commonContinue => 'Continue';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get themeTitle => 'Appearance';

  @override
  String get settingsSavedOnDevice => 'This choice is saved on this device';

  @override
  String get themeSystem => 'Use system setting';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get appVersion => 'Version 1.1.0 (Flutter)';

  @override
  String get exportGardenTitle => 'Export garden (.zip)';

  @override
  String get exportGardenSubtitle =>
      'Plant data and photos for transfer or backup';

  @override
  String get importGardenTitle => 'Import garden (.zip)';

  @override
  String get importGardenSubtitle => 'Replaces the current plant list';

  @override
  String get calendarTitle => 'Watering calendar (.ics)';

  @override
  String get calendarSubtitle =>
      'Seasonal dates for Google, Outlook, and Apple calendars; exports must be refreshed manually';

  @override
  String get reminderTitle => 'Watering reminder time';

  @override
  String reminderSubtitle(String time) {
    return 'Daily watering reminder at $time';
  }

  @override
  String get changeApiTitle => 'Change API key';

  @override
  String get changeApiSubtitle => 'Enter another personal Gemini key';

  @override
  String reminderSaved(String time) {
    return 'Reminders will arrive at $time';
  }

  @override
  String get reminderSaveError =>
      'Couldn\'t save the reminder time. Please try again.';

  @override
  String get exportDialogTitle => 'Save garden export';

  @override
  String get exportSuccess => 'Garden exported';

  @override
  String get exportFailure => 'Couldn\'t export the garden';

  @override
  String get importConfirmTitle => 'Import garden';

  @override
  String get importConfirmBody =>
      'Import will completely replace the current plant list with the archive contents. A backup of the current data will be saved first.\n\nContinue?';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonEdit => 'Edit';

  @override
  String get importFileDialogTitle => 'Choose a garden export file';

  @override
  String get importSuccess => 'Garden imported';

  @override
  String get importFailure =>
      'Couldn\'t import the garden. Check that you selected a valid export file.';

  @override
  String get calendarSaveDialogTitle => 'Save watering calendar';

  @override
  String get calendarSaved => 'Calendar saved';

  @override
  String get calendarSaveFailure => 'Couldn\'t create the calendar file';

  @override
  String get changeApiConfirmBody =>
      'The current key will be removed. You must enter a new key before using the app again.';

  @override
  String get commonChange => 'Change';

  @override
  String get deleteApiKeyError => 'Couldn\'t remove the key. Please try again.';

  @override
  String get gardenSearchHint => 'Search plants by name...';

  @override
  String get viewGrid => 'Grid';

  @override
  String get viewList => 'List';

  @override
  String get filterAll => 'All';

  @override
  String get filterNeedsWater => 'Needs water';

  @override
  String get filterHealthy => 'On schedule';

  @override
  String get gardenSettingsTooltip => 'Settings';

  @override
  String get addPlant => 'Add plant';

  @override
  String get gardenLoadError => 'Couldn\'t load the garden. Please try again.';

  @override
  String get gardenSaveViewError => 'Couldn\'t save the view setting';

  @override
  String get gardenSaveWaterError => 'Couldn\'t save watering';

  @override
  String get gardenSaveWaterFailure =>
      'Couldn\'t save watering. Please try again.';

  @override
  String get gardenHealthTitle => 'Garden health';

  @override
  String gardenHealthScore(int score) {
    return '$score% of plants are on their watering schedule';
  }

  @override
  String healthyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count on schedule',
      one: '$count on schedule',
    );
    return '$_temp0';
  }

  @override
  String dueCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count need water',
      one: '$count needs water',
    );
    return '$_temp0';
  }

  @override
  String get emptyGardenTitle => 'Your garden starts here';

  @override
  String get emptySearchTitle => 'No plants found';

  @override
  String get emptyGardenDescription =>
      'Add your first plant. Floraqua can identify it from a photo and help you care for it.';

  @override
  String get emptySearchDescription =>
      'Try changing your search or filter to see your plants.';

  @override
  String get addFirstPlant => 'Add your first plant';

  @override
  String get resetSearch => 'Clear search and filters';

  @override
  String wateringFrequency(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Every $count days',
      one: 'Every $count day',
    );
    return '$_temp0';
  }

  @override
  String get seasonSpring => 'spring';

  @override
  String get seasonSummer => 'summer';

  @override
  String get seasonAutumn => 'autumn';

  @override
  String get seasonWinter => 'winter';

  @override
  String get plantDetailsTitle => 'Plant';

  @override
  String get plantNotFound => 'This plant could not be found.';

  @override
  String get plantActionsTooltip => 'Actions';

  @override
  String get recheckPhoto => 'Recheck from photo';

  @override
  String get moreActions => 'More actions';

  @override
  String get plantDetails => 'Details';

  @override
  String get deletePlantTitle => 'Delete plant?';

  @override
  String deletePlantBody(String plant) {
    return '\"$plant\" will be permanently deleted.';
  }

  @override
  String get deletePlantMenu => 'Delete plant';

  @override
  String get wateringLabel => 'Watering';

  @override
  String nextWateringDetails(String date, String time) {
    return 'Next: $date · reminder at $time';
  }

  @override
  String get lastWatering => 'Last watered';

  @override
  String historyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count history entries',
      one: '$count history entry',
    );
    return '$_temp0';
  }

  @override
  String get markWatered => 'Mark as watered';

  @override
  String get careConditions => 'Care conditions';

  @override
  String get lightLabel => 'Light';

  @override
  String get temperatureLabel => 'Temperature';

  @override
  String get humidityLabel => 'Humidity';

  @override
  String get difficultyLabel => 'Care difficulty';

  @override
  String get baseWateringInterval => 'Base watering interval';

  @override
  String get estimatedWaterAmount => 'Estimated amount';

  @override
  String seasonCurrent(String season) {
    return 'Currently: $season';
  }

  @override
  String estimatedWaterFrequency(String frequency) {
    return 'Estimated: $frequency';
  }

  @override
  String get careTips => 'Care tips';

  @override
  String get lastPhotoAssessment => 'Last photo assessment';

  @override
  String get wateringHistory => 'Watering history';

  @override
  String get watered => 'Watered';

  @override
  String get myNotes => 'My notes';

  @override
  String get placeAndPot => 'Location and pot';

  @override
  String get potSize => 'Pot size';

  @override
  String get locationLabel => 'Location';

  @override
  String get drainageHoles => 'Drainage holes';

  @override
  String get notSpecified => 'Not specified';

  @override
  String get wateringDisclaimer =>
      'Watering dates are a guide. Check soil moisture before watering.';

  @override
  String addPhotoPermissionError(String source) {
    return 'Allow access to $source in your device settings.';
  }

  @override
  String get permissionCamera => 'the camera';

  @override
  String get permissionPhotos => 'your photos';

  @override
  String get loadingPhotoAnalysis => 'Analyzing photo...';

  @override
  String get plantAdded => 'Plant added';

  @override
  String get loadingPlantCheck => 'Checking plant...';

  @override
  String get photoSourceTitle => 'Add a plant';

  @override
  String get photoSourcePrompt => 'Where would you like to get a photo?';

  @override
  String get choosePhotoLibrary => 'Choose from photo library';

  @override
  String get takePhotoNow => 'Take a photo now';

  @override
  String get deleteConfirmTitle => 'Delete plant?';

  @override
  String get wateringSaved => 'Watering saved';

  @override
  String get waterNow => 'Water';

  @override
  String get wateringInProgress => 'Watering...';

  @override
  String get closeViewer => 'Close';

  @override
  String get onboardingError => 'Couldn\'t save onboarding. Please try again.';

  @override
  String get plantEditorEditTitle => 'Edit plant';

  @override
  String get plantEditorNewTitle => 'New plant';

  @override
  String get plantNameOptional => 'Name (optional)';

  @override
  String get wateringFrequencyField => 'Base watering interval (days)';

  @override
  String get lastWateredDate => 'Last watered date';

  @override
  String get dateWillClear => 'Date will be cleared';

  @override
  String get dateNotSet => 'Not set';

  @override
  String get dateDoNotChange => 'Keep current date';

  @override
  String get commonClear => 'Clear';

  @override
  String get wateringIntervalHelp =>
      'This is the base interval; the app adjusts it by season. The next watering date will be recalculated from the selected frequency and/or last-watered date.';

  @override
  String get notesForAiLabel => 'Additional notes for AI (optional)';

  @override
  String get notesForAiHelp =>
      'This note is saved for later. AI will read it the next time you check a photo; saving this form does not send it or change anything now.';

  @override
  String get frequencyValidation => 'Enter a number of days from 1 to 30';

  @override
  String get potSmall => 'Small (up to 10 cm)';

  @override
  String get potMedium => 'Medium (10–20 cm)';

  @override
  String get potLarge => 'Large (20–30 cm)';

  @override
  String get potExtraLarge => 'Extra large (30+ cm)';

  @override
  String get locationSouthWindow => 'South-facing window';

  @override
  String get locationNorthWindow => 'North-facing window';

  @override
  String get locationEastWindow => 'East-facing window';

  @override
  String get locationWestWindow => 'West-facing window';

  @override
  String get locationAwayFromWindow => 'Away from a window';

  @override
  String get locationBalcony => 'Balcony / loggia';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get unknown => 'Don\'t know';

  @override
  String get geminiGenericError => 'Something went wrong. Please try again.';

  @override
  String get geminiPlantNotFound => 'No plant was detected in the photo.';

  @override
  String get geminiQuotaError =>
      'Gemini API quota exceeded. Wait a while or check your limits in Google AI Studio.';

  @override
  String geminiApiError(int status) {
    return 'Gemini API request failed (HTTP $status). Please check your API key and try again.';
  }

  @override
  String geminiTimeoutError(int seconds) {
    return 'Gemini did not respond within $seconds seconds. Check your internet connection and try again.';
  }

  @override
  String get geminiNetworkError =>
      'Couldn\'t connect to Gemini. Check your internet connection. If access to the service is restricted in your region, enable a VPN and try again.';

  @override
  String get geminiSecureConnectionError =>
      'Couldn\'t establish a secure connection to Gemini. Check your internet and device date/time.';

  @override
  String get geminiUnknownError => 'An unknown Gemini API error occurred.';

  @override
  String get notificationTitle => 'Watering reminders';

  @override
  String get notificationDescription => 'Reminders to water your plants';

  @override
  String get notificationOpen => 'Open Floraqua';

  @override
  String notificationDueTitle(String plant) {
    return 'Time to water: $plant';
  }

  @override
  String notificationFrequency(String frequency) {
    return 'Watering interval: every $frequency';
  }

  @override
  String calendarEventTitle(String plant) {
    return 'Water: $plant';
  }

  @override
  String calendarBaseFrequency(String frequency) {
    return 'Base interval: $frequency';
  }

  @override
  String calendarSeasonalFrequency(String frequency) {
    return 'Seasonal interval: $frequency';
  }

  @override
  String calendarReminderTime(String time) {
    return 'Reminder time: $time.';
  }

  @override
  String get calendarCheckSoil => 'Check the soil before watering.';

  @override
  String calendarWaterAmount(String amount) {
    return 'Water amount: $amount';
  }

  @override
  String get difficultyEasy => 'Easy';

  @override
  String get difficultyMedium => 'Moderate';

  @override
  String get difficultyHard => 'Challenging';

  @override
  String get monthJanuary => 'January';

  @override
  String get monthFebruary => 'February';

  @override
  String get monthMarch => 'March';

  @override
  String get monthApril => 'April';

  @override
  String get monthMay => 'May';

  @override
  String get monthJune => 'June';

  @override
  String get monthJuly => 'July';

  @override
  String get monthAugust => 'August';

  @override
  String get monthSeptember => 'September';

  @override
  String get monthOctober => 'October';

  @override
  String get monthNovember => 'November';

  @override
  String get monthDecember => 'December';

  @override
  String wateringDaysShort(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '$count day',
    );
    return '$_temp0';
  }

  @override
  String get themeSaveError => 'Couldn\'t save the theme. Please try again.';

  @override
  String get localeSaveError =>
      'Couldn\'t save the language setting. Please try again.';

  @override
  String get openPhotoFullSize => 'Double-click to open full size';
}
