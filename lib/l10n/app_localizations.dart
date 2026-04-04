import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_uk.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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
    Locale('uk')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Meal Planner'**
  String get appTitle;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @operationFailed.
  ///
  /// In en, this message translates to:
  /// **'Operation failed. Please try again.'**
  String get operationFailed;

  /// No description provided for @importFailed.
  ///
  /// In en, this message translates to:
  /// **'Import failed. Please try again.'**
  String get importFailed;

  /// No description provided for @noInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection.'**
  String get noInternet;

  /// No description provided for @genericError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get genericError;

  /// No description provided for @permissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Database permission denied. Check Firestore security rules.'**
  String get permissionDenied;

  /// No description provided for @signInNotEnabled.
  ///
  /// In en, this message translates to:
  /// **'Email/password sign-in is not enabled. Enable it in Firebase Console → Authentication → Sign-in method.'**
  String get signInNotEnabled;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @emailEmptyError.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get emailEmptyError;

  /// No description provided for @emailInvalidError.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get emailInvalidError;

  /// No description provided for @passwordEmptyError.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordEmptyError;

  /// No description provided for @passwordTooShortError.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShortError;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get loginSubtitle;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccount;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password.'**
  String get invalidCredentials;

  /// No description provided for @tooManyAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please try again later.'**
  String get tooManyAttempts;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start planning your meals today'**
  String get registerSubtitle;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPasswordLabel;

  /// No description provided for @confirmPasswordEmptyError.
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get confirmPasswordEmptyError;

  /// No description provided for @passwordMismatchError.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordMismatchError;

  /// No description provided for @hasAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get hasAccount;

  /// No description provided for @emailInUse.
  ///
  /// In en, this message translates to:
  /// **'An account with this email already exists.'**
  String get emailInUse;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address.'**
  String get invalidEmail;

  /// No description provided for @weakPassword.
  ///
  /// In en, this message translates to:
  /// **'Password is too weak.'**
  String get weakPassword;

  /// No description provided for @navPlan.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get navPlan;

  /// No description provided for @navDishes.
  ///
  /// In en, this message translates to:
  /// **'Dishes'**
  String get navDishes;

  /// No description provided for @navShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get navShopping;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @titleMealPlan.
  ///
  /// In en, this message translates to:
  /// **'Meal Plan'**
  String get titleMealPlan;

  /// No description provided for @titleDishes.
  ///
  /// In en, this message translates to:
  /// **'Dishes'**
  String get titleDishes;

  /// No description provided for @titleShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get titleShopping;

  /// No description provided for @titleSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get titleSettings;

  /// No description provided for @addDishTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add dish'**
  String get addDishTooltip;

  /// No description provided for @importCsvTooltip.
  ///
  /// In en, this message translates to:
  /// **'Import from CSV'**
  String get importCsvTooltip;

  /// No description provided for @noDishesTitle.
  ///
  /// In en, this message translates to:
  /// **'No dishes yet'**
  String get noDishesTitle;

  /// No description provided for @noDishesDescription.
  ///
  /// In en, this message translates to:
  /// **'Build your personal recipe library.\nTap the button below to add your first dish.'**
  String get noDishesDescription;

  /// No description provided for @addDishButton.
  ///
  /// In en, this message translates to:
  /// **'Add Dish'**
  String get addDishButton;

  /// No description provided for @importStarterButton.
  ///
  /// In en, this message translates to:
  /// **'Import starter dishes'**
  String get importStarterButton;

  /// No description provided for @importFromCsvButton.
  ///
  /// In en, this message translates to:
  /// **'Import from CSV'**
  String get importFromCsvButton;

  /// No description provided for @importingIndicator.
  ///
  /// In en, this message translates to:
  /// **'Importing…'**
  String get importingIndicator;

  /// No description provided for @loadDishesError.
  ///
  /// In en, this message translates to:
  /// **'Could not load dishes.'**
  String get loadDishesError;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @noFilteredDishes.
  ///
  /// In en, this message translates to:
  /// **'No \"{label}\" dishes.'**
  String noFilteredDishes(String label);

  /// No description provided for @importCsvDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Import from CSV?'**
  String get importCsvDialogTitle;

  /// No description provided for @importCsvDialogContent.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Found 1 dish. It will be added to your library.} other{Found {count} dishes. They will be added to your library.}}'**
  String importCsvDialogContent(num count);

  /// No description provided for @csvImportSuccess.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 dish imported successfully.} other{{count} dishes imported successfully.}}'**
  String csvImportSuccess(num count);

  /// No description provided for @importStarterDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Import starter dishes?'**
  String get importStarterDialogTitle;

  /// No description provided for @importStarterDialogContent.
  ///
  /// In en, this message translates to:
  /// **'7 breakfast dishes will be added to your library. Existing dishes with the same ID will be overwritten.'**
  String get importStarterDialogContent;

  /// No description provided for @starterImportSuccess.
  ///
  /// In en, this message translates to:
  /// **'7 dishes imported successfully.'**
  String get starterImportSuccess;

  /// No description provided for @noDishesInFile.
  ///
  /// In en, this message translates to:
  /// **'No dishes found in the selected file.'**
  String get noDishesInFile;

  /// No description provided for @deleteDishTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete dish?'**
  String get deleteDishTitle;

  /// No description provided for @deleteDishContent.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"? This cannot be undone.'**
  String deleteDishContent(String name);

  /// No description provided for @editTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editTooltip;

  /// No description provided for @noIngredients.
  ///
  /// In en, this message translates to:
  /// **'No ingredients listed.'**
  String get noIngredients;

  /// No description provided for @ingredientsSection.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get ingredientsSection;

  /// No description provided for @instructionsSection.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get instructionsSection;

  /// No description provided for @nutritionPerServing.
  ///
  /// In en, this message translates to:
  /// **'Nutrition per serving'**
  String get nutritionPerServing;

  /// No description provided for @caloriesLabel.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get caloriesLabel;

  /// No description provided for @proteinLabel.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get proteinLabel;

  /// No description provided for @fatLabel.
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get fatLabel;

  /// No description provided for @carbsLabel.
  ///
  /// In en, this message translates to:
  /// **'Carbs'**
  String get carbsLabel;

  /// No description provided for @editDishTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Dish'**
  String get editDishTitle;

  /// No description provided for @addDishTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Dish'**
  String get addDishTitle;

  /// No description provided for @dishNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Dish name'**
  String get dishNameLabel;

  /// No description provided for @dishNameError.
  ///
  /// In en, this message translates to:
  /// **'Enter a dish name'**
  String get dishNameError;

  /// No description provided for @servingsLabel.
  ///
  /// In en, this message translates to:
  /// **'Number of servings'**
  String get servingsLabel;

  /// No description provided for @servingsHelper.
  ///
  /// In en, this message translates to:
  /// **'Base unit — 1 serving = 1 person'**
  String get servingsHelper;

  /// No description provided for @servingsError.
  ///
  /// In en, this message translates to:
  /// **'Enter a number ≥ 1'**
  String get servingsError;

  /// No description provided for @labelsOptional.
  ///
  /// In en, this message translates to:
  /// **'Labels (optional)'**
  String get labelsOptional;

  /// No description provided for @addIngredientLabel.
  ///
  /// In en, this message translates to:
  /// **'Add ingredient'**
  String get addIngredientLabel;

  /// No description provided for @noIngredientsYet.
  ///
  /// In en, this message translates to:
  /// **'No ingredients yet.'**
  String get noIngredientsYet;

  /// No description provided for @instructionsOptional.
  ///
  /// In en, this message translates to:
  /// **'Instructions (optional)'**
  String get instructionsOptional;

  /// No description provided for @addStep.
  ///
  /// In en, this message translates to:
  /// **'Add step'**
  String get addStep;

  /// No description provided for @noStepsAdded.
  ///
  /// In en, this message translates to:
  /// **'No steps added.'**
  String get noStepsAdded;

  /// No description provided for @stepPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Describe the step…'**
  String get stepPlaceholder;

  /// No description provided for @removeStep.
  ///
  /// In en, this message translates to:
  /// **'Remove step'**
  String get removeStep;

  /// No description provided for @saveDishButton.
  ///
  /// In en, this message translates to:
  /// **'Save Dish'**
  String get saveDishButton;

  /// No description provided for @saveDishFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save dish. Please try again.'**
  String get saveDishFailed;

  /// No description provided for @addIngredientTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Ingredient'**
  String get addIngredientTitle;

  /// No description provided for @editIngredientTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Ingredient'**
  String get editIngredientTitle;

  /// No description provided for @searchDatabase.
  ///
  /// In en, this message translates to:
  /// **'Search database'**
  String get searchDatabase;

  /// No description provided for @changeProduct.
  ///
  /// In en, this message translates to:
  /// **'Change: {name}'**
  String changeProduct(String name);

  /// No description provided for @ingredientNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Ingredient name'**
  String get ingredientNameLabel;

  /// No description provided for @requiredError.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get requiredError;

  /// No description provided for @amountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amountLabel;

  /// No description provided for @unitLabel.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unitLabel;

  /// No description provided for @autoCalculatedNote.
  ///
  /// In en, this message translates to:
  /// **'Nutrition auto-calculated per entered amount'**
  String get autoCalculatedNote;

  /// No description provided for @caloriesKcalLabel.
  ///
  /// In en, this message translates to:
  /// **'Calories (kcal)'**
  String get caloriesKcalLabel;

  /// No description provided for @proteinGLabel.
  ///
  /// In en, this message translates to:
  /// **'Protein (g)'**
  String get proteinGLabel;

  /// No description provided for @fatGLabel.
  ///
  /// In en, this message translates to:
  /// **'Fat (g)'**
  String get fatGLabel;

  /// No description provided for @carbsGLabel.
  ///
  /// In en, this message translates to:
  /// **'Carbs (g)'**
  String get carbsGLabel;

  /// No description provided for @numberError.
  ///
  /// In en, this message translates to:
  /// **'Enter a number ≥ 0'**
  String get numberError;

  /// No description provided for @searchDatabaseTitle.
  ///
  /// In en, this message translates to:
  /// **'Search database'**
  String get searchDatabaseTitle;

  /// No description provided for @searchProductsHint.
  ///
  /// In en, this message translates to:
  /// **'Search products…'**
  String get searchProductsHint;

  /// No description provided for @noProductsFound.
  ///
  /// In en, this message translates to:
  /// **'No products found.'**
  String get noProductsFound;

  /// No description provided for @weekTab.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get weekTab;

  /// No description provided for @monTab.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get monTab;

  /// No description provided for @tueTab.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tueTab;

  /// No description provided for @wedTab.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wedTab;

  /// No description provided for @thuTab.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thuTab;

  /// No description provided for @friTab.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get friTab;

  /// No description provided for @satTab.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get satTab;

  /// No description provided for @sunTab.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sunTab;

  /// No description provided for @loadMealPlanError.
  ///
  /// In en, this message translates to:
  /// **'Could not load meal plan.'**
  String get loadMealPlanError;

  /// No description provided for @previousWeek.
  ///
  /// In en, this message translates to:
  /// **'Previous week'**
  String get previousWeek;

  /// No description provided for @nextWeek.
  ///
  /// In en, this message translates to:
  /// **'Next week'**
  String get nextWeek;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @moreOptions.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get moreOptions;

  /// No description provided for @copyFromPreviousWeek.
  ///
  /// In en, this message translates to:
  /// **'Copy from previous week'**
  String get copyFromPreviousWeek;

  /// No description provided for @copyWeekDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Copy previous week?'**
  String get copyWeekDialogTitle;

  /// No description provided for @copyWeekDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Replace {thisRange} with dishes from {prevRange}?'**
  String copyWeekDialogContent(String thisRange, String prevRange);

  /// No description provided for @weekCopied.
  ///
  /// In en, this message translates to:
  /// **'Week copied!'**
  String get weekCopied;

  /// No description provided for @noPreviousWeekDishes.
  ///
  /// In en, this message translates to:
  /// **'Previous week has no dishes.'**
  String get noPreviousWeekDishes;

  /// No description provided for @weeklyTotal.
  ///
  /// In en, this message translates to:
  /// **'Weekly Total'**
  String get weeklyTotal;

  /// No description provided for @kcal.
  ///
  /// In en, this message translates to:
  /// **'kcal'**
  String get kcal;

  /// No description provided for @emptySlot.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add a dish'**
  String get emptySlot;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @copyDayDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Copy from previous week?'**
  String get copyDayDialogTitle;

  /// No description provided for @copyDayDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Replace {dayName} {date}\'s dishes with last {dayName}\'s dishes?'**
  String copyDayDialogContent(String dayName, String date);

  /// No description provided for @dayCopied.
  ///
  /// In en, this message translates to:
  /// **'Day copied!'**
  String get dayCopied;

  /// No description provided for @noPreviousDayDishes.
  ///
  /// In en, this message translates to:
  /// **'Previous week has no dishes for this day.'**
  String get noPreviousDayDishes;

  /// No description provided for @noDishesInLibrary.
  ///
  /// In en, this message translates to:
  /// **'No dishes in library yet.'**
  String get noDishesInLibrary;

  /// No description provided for @noMatches.
  ///
  /// In en, this message translates to:
  /// **'No matches.'**
  String get noMatches;

  /// No description provided for @addDishDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Add dish'**
  String get addDishDialogTitle;

  /// No description provided for @searchDishesHint.
  ///
  /// In en, this message translates to:
  /// **'Search dishes…'**
  String get searchDishesHint;

  /// No description provided for @mealSlotsTitle.
  ///
  /// In en, this message translates to:
  /// **'Meal Slots'**
  String get mealSlotsTitle;

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// No description provided for @addSlot.
  ///
  /// In en, this message translates to:
  /// **'Add Slot'**
  String get addSlot;

  /// No description provided for @renameSlotTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename Slot'**
  String get renameSlotTitle;

  /// No description provided for @addSlotTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Slot'**
  String get addSlotTitle;

  /// No description provided for @slotNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Slot name'**
  String get slotNameLabel;

  /// No description provided for @slotNameEmptyError.
  ///
  /// In en, this message translates to:
  /// **'Name cannot be empty'**
  String get slotNameEmptyError;

  /// No description provided for @slotNameExistsError.
  ///
  /// In en, this message translates to:
  /// **'A slot with this name already exists'**
  String get slotNameExistsError;

  /// No description provided for @saveFailedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Failed to save. Please try again.'**
  String get saveFailedSnackbar;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageUkrainian.
  ///
  /// In en, this message translates to:
  /// **'Ukrainian'**
  String get languageUkrainian;

  /// No description provided for @shoppingListTitle.
  ///
  /// In en, this message translates to:
  /// **'Shopping List'**
  String get shoppingListTitle;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Shopping List — coming soon'**
  String get comingSoon;

  /// No description provided for @labelBreakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get labelBreakfast;

  /// No description provided for @labelLunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get labelLunch;

  /// No description provided for @labelDinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get labelDinner;
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
      <String>['en', 'uk'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'uk':
      return AppLocalizationsUk();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
