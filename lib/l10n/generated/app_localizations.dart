import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Floraqua'**
  String get appTitle;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @languageRussian.
  ///
  /// In en, this message translates to:
  /// **'Русский'**
  String get languageRussian;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Your garden, all in one place'**
  String get onboardingTitle1;

  /// No description provided for @onboardingDescription1.
  ///
  /// In en, this message translates to:
  /// **'Add your favorite plants and identify them from a photo. Floraqua keeps each plant\'s details and care information together.'**
  String get onboardingDescription1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Care that follows the seasons'**
  String get onboardingTitle2;

  /// No description provided for @onboardingDescription2.
  ///
  /// In en, this message translates to:
  /// **'Get care guidance and watering estimates for your plants. Always check the soil before watering.'**
  String get onboardingDescription2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Reminders on your schedule'**
  String get onboardingTitle3;

  /// No description provided for @onboardingDescription3.
  ///
  /// In en, this message translates to:
  /// **'Choose a convenient notification time. Plant identification requires your own Gemini API key, which is stored on this device.'**
  String get onboardingDescription3;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingFinish.
  ///
  /// In en, this message translates to:
  /// **'Continue to API key setup'**
  String get onboardingFinish;

  /// No description provided for @onboardingProgress.
  ///
  /// In en, this message translates to:
  /// **'{page} of {total}'**
  String onboardingProgress(int page, int total);

  /// No description provided for @onboardingSaveError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save the first-run setting. Please try again.'**
  String get onboardingSaveError;

  /// No description provided for @apiGetKeyTitle.
  ///
  /// In en, this message translates to:
  /// **'Get an API key'**
  String get apiGetKeyTitle;

  /// No description provided for @apiClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get apiClose;

  /// No description provided for @apiEnterKey.
  ///
  /// In en, this message translates to:
  /// **'Enter an API key'**
  String get apiEnterKey;

  /// No description provided for @apiSaveError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save the key on this device. Check permissions and try again.'**
  String get apiSaveError;

  /// No description provided for @apiDescription.
  ///
  /// In en, this message translates to:
  /// **'A personal Google Gemini API key is required to identify plants and provide care guidance.'**
  String get apiDescription;

  /// No description provided for @apiSecurityNotice.
  ///
  /// In en, this message translates to:
  /// **'Enter only your own key and never share it. A shared developer key must not be embedded in the app; that would require a server proxy.'**
  String get apiSecurityNotice;

  /// No description provided for @apiWhereGetKey.
  ///
  /// In en, this message translates to:
  /// **'Where can I get a key?'**
  String get apiWhereGetKey;

  /// No description provided for @apiKeyLabel.
  ///
  /// In en, this message translates to:
  /// **'Gemini API key'**
  String get apiKeyLabel;

  /// No description provided for @apiShowKey.
  ///
  /// In en, this message translates to:
  /// **'Show key'**
  String get apiShowKey;

  /// No description provided for @apiHideKey.
  ///
  /// In en, this message translates to:
  /// **'Hide key'**
  String get apiHideKey;

  /// No description provided for @commonContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get commonContinue;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @themeTitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get themeTitle;

  /// No description provided for @settingsSavedOnDevice.
  ///
  /// In en, this message translates to:
  /// **'This choice is saved on this device'**
  String get settingsSavedOnDevice;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'Use system setting'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'Version 1.1.0 (Flutter)'**
  String get appVersion;

  /// No description provided for @exportGardenTitle.
  ///
  /// In en, this message translates to:
  /// **'Export garden (.zip)'**
  String get exportGardenTitle;

  /// No description provided for @exportGardenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Plant data and photos for transfer or backup'**
  String get exportGardenSubtitle;

  /// No description provided for @importGardenTitle.
  ///
  /// In en, this message translates to:
  /// **'Import garden (.zip)'**
  String get importGardenTitle;

  /// No description provided for @importGardenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Replaces the current plant list'**
  String get importGardenSubtitle;

  /// No description provided for @calendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Watering calendar (.ics)'**
  String get calendarTitle;

  /// No description provided for @calendarSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Seasonal dates for Google, Outlook, and Apple calendars; exports must be refreshed manually'**
  String get calendarSubtitle;

  /// No description provided for @reminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Watering reminder time'**
  String get reminderTitle;

  /// No description provided for @reminderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Daily watering reminder at {time}'**
  String reminderSubtitle(String time);

  /// No description provided for @changeApiTitle.
  ///
  /// In en, this message translates to:
  /// **'Change API key'**
  String get changeApiTitle;

  /// No description provided for @changeApiSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter another personal Gemini key'**
  String get changeApiSubtitle;

  /// No description provided for @reminderSaved.
  ///
  /// In en, this message translates to:
  /// **'Reminders will arrive at {time}'**
  String reminderSaved(String time);

  /// No description provided for @reminderSaveError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save the reminder time. Please try again.'**
  String get reminderSaveError;

  /// No description provided for @exportDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Save garden export'**
  String get exportDialogTitle;

  /// No description provided for @exportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Garden exported'**
  String get exportSuccess;

  /// No description provided for @exportFailure.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t export the garden'**
  String get exportFailure;

  /// No description provided for @importConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Import garden'**
  String get importConfirmTitle;

  /// No description provided for @importConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Import will completely replace the current plant list with the archive contents. A backup of the current data will be saved first.\n\nContinue?'**
  String get importConfirmBody;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @importFileDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a garden export file'**
  String get importFileDialogTitle;

  /// No description provided for @importSuccess.
  ///
  /// In en, this message translates to:
  /// **'Garden imported'**
  String get importSuccess;

  /// No description provided for @importFailure.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t import the garden. Check that you selected a valid export file.'**
  String get importFailure;

  /// No description provided for @calendarSaveDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Save watering calendar'**
  String get calendarSaveDialogTitle;

  /// No description provided for @calendarSaved.
  ///
  /// In en, this message translates to:
  /// **'Calendar saved'**
  String get calendarSaved;

  /// No description provided for @calendarSaveFailure.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t create the calendar file'**
  String get calendarSaveFailure;

  /// No description provided for @changeApiConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'The current key will be removed. You must enter a new key before using the app again.'**
  String get changeApiConfirmBody;

  /// No description provided for @commonChange.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get commonChange;

  /// No description provided for @deleteApiKeyError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t remove the key. Please try again.'**
  String get deleteApiKeyError;

  /// No description provided for @gardenSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search plants by name...'**
  String get gardenSearchHint;

  /// No description provided for @viewGrid.
  ///
  /// In en, this message translates to:
  /// **'Grid'**
  String get viewGrid;

  /// No description provided for @viewList.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get viewList;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterNeedsWater.
  ///
  /// In en, this message translates to:
  /// **'Needs water'**
  String get filterNeedsWater;

  /// No description provided for @filterHealthy.
  ///
  /// In en, this message translates to:
  /// **'On schedule'**
  String get filterHealthy;

  /// No description provided for @gardenSettingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get gardenSettingsTooltip;

  /// No description provided for @addPlant.
  ///
  /// In en, this message translates to:
  /// **'Add plant'**
  String get addPlant;

  /// No description provided for @gardenLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the garden. Please try again.'**
  String get gardenLoadError;

  /// No description provided for @gardenSaveViewError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save the view setting'**
  String get gardenSaveViewError;

  /// No description provided for @gardenSaveWaterError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save watering'**
  String get gardenSaveWaterError;

  /// No description provided for @gardenSaveWaterFailure.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save watering. Please try again.'**
  String get gardenSaveWaterFailure;

  /// No description provided for @gardenHealthTitle.
  ///
  /// In en, this message translates to:
  /// **'Garden health'**
  String get gardenHealthTitle;

  /// No description provided for @gardenHealthScore.
  ///
  /// In en, this message translates to:
  /// **'{score}% of plants are on their watering schedule'**
  String gardenHealthScore(int score);

  /// No description provided for @healthyCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} on schedule} other{{count} on schedule}}'**
  String healthyCount(int count);

  /// No description provided for @dueCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} needs water} other{{count} need water}}'**
  String dueCount(int count);

  /// No description provided for @emptyGardenTitle.
  ///
  /// In en, this message translates to:
  /// **'Your garden starts here'**
  String get emptyGardenTitle;

  /// No description provided for @emptySearchTitle.
  ///
  /// In en, this message translates to:
  /// **'No plants found'**
  String get emptySearchTitle;

  /// No description provided for @emptyGardenDescription.
  ///
  /// In en, this message translates to:
  /// **'Add your first plant. Floraqua can identify it from a photo and help you care for it.'**
  String get emptyGardenDescription;

  /// No description provided for @emptySearchDescription.
  ///
  /// In en, this message translates to:
  /// **'Try changing your search or filter to see your plants.'**
  String get emptySearchDescription;

  /// No description provided for @addFirstPlant.
  ///
  /// In en, this message translates to:
  /// **'Add your first plant'**
  String get addFirstPlant;

  /// No description provided for @resetSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search and filters'**
  String get resetSearch;

  /// No description provided for @wateringFrequency.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Every {count} day} other{Every {count} days}}'**
  String wateringFrequency(int count);

  /// No description provided for @seasonSpring.
  ///
  /// In en, this message translates to:
  /// **'spring'**
  String get seasonSpring;

  /// No description provided for @seasonSummer.
  ///
  /// In en, this message translates to:
  /// **'summer'**
  String get seasonSummer;

  /// No description provided for @seasonAutumn.
  ///
  /// In en, this message translates to:
  /// **'autumn'**
  String get seasonAutumn;

  /// No description provided for @seasonWinter.
  ///
  /// In en, this message translates to:
  /// **'winter'**
  String get seasonWinter;

  /// No description provided for @plantDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Plant'**
  String get plantDetailsTitle;

  /// No description provided for @plantNotFound.
  ///
  /// In en, this message translates to:
  /// **'This plant could not be found.'**
  String get plantNotFound;

  /// No description provided for @plantActionsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get plantActionsTooltip;

  /// No description provided for @recheckPhoto.
  ///
  /// In en, this message translates to:
  /// **'Recheck from photo'**
  String get recheckPhoto;

  /// No description provided for @moreActions.
  ///
  /// In en, this message translates to:
  /// **'More actions'**
  String get moreActions;

  /// No description provided for @plantDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get plantDetails;

  /// No description provided for @deletePlantTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete plant?'**
  String get deletePlantTitle;

  /// No description provided for @deletePlantBody.
  ///
  /// In en, this message translates to:
  /// **'\"{plant}\" will be permanently deleted.'**
  String deletePlantBody(String plant);

  /// No description provided for @deletePlantMenu.
  ///
  /// In en, this message translates to:
  /// **'Delete plant'**
  String get deletePlantMenu;

  /// No description provided for @wateringLabel.
  ///
  /// In en, this message translates to:
  /// **'Watering'**
  String get wateringLabel;

  /// No description provided for @nextWateringDetails.
  ///
  /// In en, this message translates to:
  /// **'Next: {date} · reminder at {time}'**
  String nextWateringDetails(String date, String time);

  /// No description provided for @lastWatering.
  ///
  /// In en, this message translates to:
  /// **'Last watered'**
  String get lastWatering;

  /// No description provided for @historyCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} history entry} other{{count} history entries}}'**
  String historyCount(int count);

  /// No description provided for @markWatered.
  ///
  /// In en, this message translates to:
  /// **'Mark as watered'**
  String get markWatered;

  /// No description provided for @careConditions.
  ///
  /// In en, this message translates to:
  /// **'Care conditions'**
  String get careConditions;

  /// No description provided for @lightLabel.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightLabel;

  /// No description provided for @temperatureLabel.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get temperatureLabel;

  /// No description provided for @humidityLabel.
  ///
  /// In en, this message translates to:
  /// **'Humidity'**
  String get humidityLabel;

  /// No description provided for @difficultyLabel.
  ///
  /// In en, this message translates to:
  /// **'Care difficulty'**
  String get difficultyLabel;

  /// No description provided for @baseWateringInterval.
  ///
  /// In en, this message translates to:
  /// **'Base watering interval'**
  String get baseWateringInterval;

  /// No description provided for @estimatedWaterAmount.
  ///
  /// In en, this message translates to:
  /// **'Estimated amount'**
  String get estimatedWaterAmount;

  /// No description provided for @seasonCurrent.
  ///
  /// In en, this message translates to:
  /// **'Currently: {season}'**
  String seasonCurrent(String season);

  /// No description provided for @estimatedWaterFrequency.
  ///
  /// In en, this message translates to:
  /// **'Estimated: {frequency}'**
  String estimatedWaterFrequency(String frequency);

  /// No description provided for @careTips.
  ///
  /// In en, this message translates to:
  /// **'Care tips'**
  String get careTips;

  /// No description provided for @lastPhotoAssessment.
  ///
  /// In en, this message translates to:
  /// **'Last photo assessment'**
  String get lastPhotoAssessment;

  /// No description provided for @wateringHistory.
  ///
  /// In en, this message translates to:
  /// **'Watering history'**
  String get wateringHistory;

  /// No description provided for @watered.
  ///
  /// In en, this message translates to:
  /// **'Watered'**
  String get watered;

  /// No description provided for @myNotes.
  ///
  /// In en, this message translates to:
  /// **'My notes'**
  String get myNotes;

  /// No description provided for @placeAndPot.
  ///
  /// In en, this message translates to:
  /// **'Location and pot'**
  String get placeAndPot;

  /// No description provided for @potSize.
  ///
  /// In en, this message translates to:
  /// **'Pot size'**
  String get potSize;

  /// No description provided for @locationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationLabel;

  /// No description provided for @drainageHoles.
  ///
  /// In en, this message translates to:
  /// **'Drainage holes'**
  String get drainageHoles;

  /// No description provided for @notSpecified.
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get notSpecified;

  /// No description provided for @wateringDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Watering dates are a guide. Check soil moisture before watering.'**
  String get wateringDisclaimer;

  /// No description provided for @addPhotoPermissionError.
  ///
  /// In en, this message translates to:
  /// **'Allow access to {source} in your device settings.'**
  String addPhotoPermissionError(String source);

  /// No description provided for @permissionCamera.
  ///
  /// In en, this message translates to:
  /// **'the camera'**
  String get permissionCamera;

  /// No description provided for @permissionPhotos.
  ///
  /// In en, this message translates to:
  /// **'your photos'**
  String get permissionPhotos;

  /// No description provided for @loadingPhotoAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Analyzing photo...'**
  String get loadingPhotoAnalysis;

  /// No description provided for @plantAdded.
  ///
  /// In en, this message translates to:
  /// **'Plant added'**
  String get plantAdded;

  /// No description provided for @loadingPlantCheck.
  ///
  /// In en, this message translates to:
  /// **'Checking plant...'**
  String get loadingPlantCheck;

  /// No description provided for @photoSourceTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a plant'**
  String get photoSourceTitle;

  /// No description provided for @photoSourcePrompt.
  ///
  /// In en, this message translates to:
  /// **'Where would you like to get a photo?'**
  String get photoSourcePrompt;

  /// No description provided for @choosePhotoLibrary.
  ///
  /// In en, this message translates to:
  /// **'Choose from photo library'**
  String get choosePhotoLibrary;

  /// No description provided for @takePhotoNow.
  ///
  /// In en, this message translates to:
  /// **'Take a photo now'**
  String get takePhotoNow;

  /// No description provided for @deleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete plant?'**
  String get deleteConfirmTitle;

  /// No description provided for @wateringSaved.
  ///
  /// In en, this message translates to:
  /// **'Watering saved'**
  String get wateringSaved;

  /// No description provided for @waterNow.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get waterNow;

  /// No description provided for @wateringInProgress.
  ///
  /// In en, this message translates to:
  /// **'Watering...'**
  String get wateringInProgress;

  /// No description provided for @closeViewer.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeViewer;

  /// No description provided for @onboardingError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save onboarding. Please try again.'**
  String get onboardingError;

  /// No description provided for @plantEditorEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit plant'**
  String get plantEditorEditTitle;

  /// No description provided for @plantEditorNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New plant'**
  String get plantEditorNewTitle;

  /// No description provided for @plantNameOptional.
  ///
  /// In en, this message translates to:
  /// **'Name (optional)'**
  String get plantNameOptional;

  /// No description provided for @wateringFrequencyField.
  ///
  /// In en, this message translates to:
  /// **'Base watering interval (days)'**
  String get wateringFrequencyField;

  /// No description provided for @lastWateredDate.
  ///
  /// In en, this message translates to:
  /// **'Last watered date'**
  String get lastWateredDate;

  /// No description provided for @dateWillClear.
  ///
  /// In en, this message translates to:
  /// **'Date will be cleared'**
  String get dateWillClear;

  /// No description provided for @dateNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get dateNotSet;

  /// No description provided for @dateDoNotChange.
  ///
  /// In en, this message translates to:
  /// **'Keep current date'**
  String get dateDoNotChange;

  /// No description provided for @commonClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get commonClear;

  /// No description provided for @wateringIntervalHelp.
  ///
  /// In en, this message translates to:
  /// **'This is the base interval; the app adjusts it by season. The next watering date will be recalculated from the selected frequency and/or last-watered date.'**
  String get wateringIntervalHelp;

  /// No description provided for @notesForAiLabel.
  ///
  /// In en, this message translates to:
  /// **'Additional notes for AI (optional)'**
  String get notesForAiLabel;

  /// No description provided for @notesForAiHelp.
  ///
  /// In en, this message translates to:
  /// **'This note is saved for later. AI will read it the next time you check a photo; saving this form does not send it or change anything now.'**
  String get notesForAiHelp;

  /// No description provided for @frequencyValidation.
  ///
  /// In en, this message translates to:
  /// **'Enter a number of days from 1 to 30'**
  String get frequencyValidation;

  /// No description provided for @potSmall.
  ///
  /// In en, this message translates to:
  /// **'Small (up to 10 cm)'**
  String get potSmall;

  /// No description provided for @potMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium (10–20 cm)'**
  String get potMedium;

  /// No description provided for @potLarge.
  ///
  /// In en, this message translates to:
  /// **'Large (20–30 cm)'**
  String get potLarge;

  /// No description provided for @potExtraLarge.
  ///
  /// In en, this message translates to:
  /// **'Extra large (30+ cm)'**
  String get potExtraLarge;

  /// No description provided for @locationSouthWindow.
  ///
  /// In en, this message translates to:
  /// **'South-facing window'**
  String get locationSouthWindow;

  /// No description provided for @locationNorthWindow.
  ///
  /// In en, this message translates to:
  /// **'North-facing window'**
  String get locationNorthWindow;

  /// No description provided for @locationEastWindow.
  ///
  /// In en, this message translates to:
  /// **'East-facing window'**
  String get locationEastWindow;

  /// No description provided for @locationWestWindow.
  ///
  /// In en, this message translates to:
  /// **'West-facing window'**
  String get locationWestWindow;

  /// No description provided for @locationAwayFromWindow.
  ///
  /// In en, this message translates to:
  /// **'Away from a window'**
  String get locationAwayFromWindow;

  /// No description provided for @locationBalcony.
  ///
  /// In en, this message translates to:
  /// **'Balcony / loggia'**
  String get locationBalcony;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Don\'t know'**
  String get unknown;

  /// No description provided for @geminiGenericError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get geminiGenericError;

  /// No description provided for @geminiPlantNotFound.
  ///
  /// In en, this message translates to:
  /// **'No plant was detected in the photo.'**
  String get geminiPlantNotFound;

  /// No description provided for @geminiQuotaError.
  ///
  /// In en, this message translates to:
  /// **'Gemini API quota exceeded. Wait a while or check your limits in Google AI Studio.'**
  String get geminiQuotaError;

  /// No description provided for @geminiApiError.
  ///
  /// In en, this message translates to:
  /// **'Gemini API request failed (HTTP {status}). Please check your API key and try again.'**
  String geminiApiError(int status);

  /// No description provided for @geminiTimeoutError.
  ///
  /// In en, this message translates to:
  /// **'Gemini did not respond within {seconds} seconds. Check your internet connection and try again.'**
  String geminiTimeoutError(int seconds);

  /// No description provided for @geminiNetworkError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t connect to Gemini. Check your internet connection. If access to the service is restricted in your region, enable a VPN and try again.'**
  String get geminiNetworkError;

  /// No description provided for @geminiSecureConnectionError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t establish a secure connection to Gemini. Check your internet and device date/time.'**
  String get geminiSecureConnectionError;

  /// No description provided for @geminiUnknownError.
  ///
  /// In en, this message translates to:
  /// **'An unknown Gemini API error occurred.'**
  String get geminiUnknownError;

  /// No description provided for @notificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Watering reminders'**
  String get notificationTitle;

  /// No description provided for @notificationDescription.
  ///
  /// In en, this message translates to:
  /// **'Reminders to water your plants'**
  String get notificationDescription;

  /// No description provided for @notificationOpen.
  ///
  /// In en, this message translates to:
  /// **'Open Floraqua'**
  String get notificationOpen;

  /// No description provided for @notificationDueTitle.
  ///
  /// In en, this message translates to:
  /// **'Time to water: {plant}'**
  String notificationDueTitle(String plant);

  /// No description provided for @notificationFrequency.
  ///
  /// In en, this message translates to:
  /// **'Watering interval: every {frequency}'**
  String notificationFrequency(String frequency);

  /// No description provided for @calendarEventTitle.
  ///
  /// In en, this message translates to:
  /// **'Water: {plant}'**
  String calendarEventTitle(String plant);

  /// No description provided for @calendarBaseFrequency.
  ///
  /// In en, this message translates to:
  /// **'Base interval: {frequency}'**
  String calendarBaseFrequency(String frequency);

  /// No description provided for @calendarSeasonalFrequency.
  ///
  /// In en, this message translates to:
  /// **'Seasonal interval: {frequency}'**
  String calendarSeasonalFrequency(String frequency);

  /// No description provided for @calendarReminderTime.
  ///
  /// In en, this message translates to:
  /// **'Reminder time: {time}.'**
  String calendarReminderTime(String time);

  /// No description provided for @calendarCheckSoil.
  ///
  /// In en, this message translates to:
  /// **'Check the soil before watering.'**
  String get calendarCheckSoil;

  /// No description provided for @calendarWaterAmount.
  ///
  /// In en, this message translates to:
  /// **'Water amount: {amount}'**
  String calendarWaterAmount(String amount);

  /// No description provided for @difficultyEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get difficultyEasy;

  /// No description provided for @difficultyMedium.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get difficultyMedium;

  /// No description provided for @difficultyHard.
  ///
  /// In en, this message translates to:
  /// **'Challenging'**
  String get difficultyHard;

  /// No description provided for @monthJanuary.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get monthJanuary;

  /// No description provided for @monthFebruary.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get monthFebruary;

  /// No description provided for @monthMarch.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get monthMarch;

  /// No description provided for @monthApril.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get monthApril;

  /// No description provided for @monthMay.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get monthMay;

  /// No description provided for @monthJune.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get monthJune;

  /// No description provided for @monthJuly.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get monthJuly;

  /// No description provided for @monthAugust.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get monthAugust;

  /// No description provided for @monthSeptember.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get monthSeptember;

  /// No description provided for @monthOctober.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get monthOctober;

  /// No description provided for @monthNovember.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get monthNovember;

  /// No description provided for @monthDecember.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get monthDecember;

  /// No description provided for @wateringDaysShort.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} day} other{{count} days}}'**
  String wateringDaysShort(int count);

  /// No description provided for @themeSaveError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save the theme. Please try again.'**
  String get themeSaveError;

  /// No description provided for @localeSaveError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save the language setting. Please try again.'**
  String get localeSaveError;

  /// No description provided for @openPhotoFullSize.
  ///
  /// In en, this message translates to:
  /// **'Double-click to open full size'**
  String get openPhotoFullSize;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
