// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Meal Planner';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get copy => 'Copy';

  @override
  String get retry => 'Retry';

  @override
  String get signOut => 'Sign out';

  @override
  String get operationFailed => 'Operation failed. Please try again.';

  @override
  String get importFailed => 'Import failed. Please try again.';

  @override
  String get noInternet => 'No internet connection.';

  @override
  String get genericError => 'Something went wrong. Please try again.';

  @override
  String get permissionDenied =>
      'Database permission denied. Check Firestore security rules.';

  @override
  String get signInNotEnabled =>
      'Email/password sign-in is not enabled. Enable it in Firebase Console → Authentication → Sign-in method.';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get emailEmptyError => 'Enter your email';

  @override
  String get emailInvalidError => 'Enter a valid email';

  @override
  String get passwordEmptyError => 'Enter your password';

  @override
  String get passwordTooShortError => 'Password must be at least 6 characters';

  @override
  String get signIn => 'Sign In';

  @override
  String get loginSubtitle => 'Sign in to continue';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get register => 'Register';

  @override
  String get invalidCredentials => 'Invalid email or password.';

  @override
  String get tooManyAttempts => 'Too many attempts. Please try again later.';

  @override
  String get createAccount => 'Create Account';

  @override
  String get registerSubtitle => 'Start planning your meals today';

  @override
  String get confirmPasswordLabel => 'Confirm Password';

  @override
  String get confirmPasswordEmptyError => 'Confirm your password';

  @override
  String get passwordMismatchError => 'Passwords do not match';

  @override
  String get hasAccount => 'Already have an account?';

  @override
  String get emailInUse => 'An account with this email already exists.';

  @override
  String get invalidEmail => 'Invalid email address.';

  @override
  String get weakPassword => 'Password is too weak.';

  @override
  String get navPlan => 'Plan';

  @override
  String get navDishes => 'Dishes';

  @override
  String get navShopping => 'Shopping';

  @override
  String get navSettings => 'Settings';

  @override
  String get titleMealPlan => 'Meal Plan';

  @override
  String get titleDishes => 'Dishes';

  @override
  String get titleShopping => 'Shopping';

  @override
  String get titleSettings => 'Settings';

  @override
  String get addDishTooltip => 'Add dish';

  @override
  String get importCsvTooltip => 'Import from CSV';

  @override
  String get noDishesTitle => 'No dishes yet';

  @override
  String get noDishesDescription =>
      'Build your personal recipe library.\nTap the button below to add your first dish.';

  @override
  String get addDishButton => 'Add Dish';

  @override
  String get importStarterButton => 'Import starter dishes';

  @override
  String get importFromCsvButton => 'Import from CSV';

  @override
  String get importingIndicator => 'Importing…';

  @override
  String get loadDishesError => 'Could not load dishes.';

  @override
  String get all => 'All';

  @override
  String noFilteredDishes(String label) {
    return 'No \"$label\" dishes.';
  }

  @override
  String get importCsvDialogTitle => 'Import from CSV?';

  @override
  String importCsvDialogContent(num count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Found $countString dishes. They will be added to your library.',
      one: 'Found 1 dish. It will be added to your library.',
    );
    return '$_temp0';
  }

  @override
  String csvImportSuccess(num count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString dishes imported successfully.',
      one: '1 dish imported successfully.',
    );
    return '$_temp0';
  }

  @override
  String get importStarterDialogTitle => 'Import starter dishes?';

  @override
  String get importStarterDialogContent =>
      '7 breakfast dishes will be added to your library. Existing dishes with the same ID will be overwritten.';

  @override
  String get starterImportSuccess => '7 dishes imported successfully.';

  @override
  String get noDishesInFile => 'No dishes found in the selected file.';

  @override
  String get deleteDishTitle => 'Delete dish?';

  @override
  String deleteDishContent(String name) {
    return 'Delete \"$name\"? This cannot be undone.';
  }

  @override
  String get editTooltip => 'Edit';

  @override
  String get noIngredients => 'No ingredients listed.';

  @override
  String get ingredientsSection => 'Ingredients';

  @override
  String get instructionsSection => 'Instructions';

  @override
  String get nutritionPerServing => 'Nutrition per serving';

  @override
  String get caloriesLabel => 'Calories';

  @override
  String get proteinLabel => 'Protein';

  @override
  String get fatLabel => 'Fat';

  @override
  String get carbsLabel => 'Carbs';

  @override
  String get editDishTitle => 'Edit Dish';

  @override
  String get addDishTitle => 'Add Dish';

  @override
  String get dishNameLabel => 'Dish name';

  @override
  String get dishNameError => 'Enter a dish name';

  @override
  String get servingsLabel => 'Number of servings';

  @override
  String get servingsHelper => 'Base unit — 1 serving = 1 person';

  @override
  String get servingsError => 'Enter a number ≥ 1';

  @override
  String get labelsOptional => 'Labels (optional)';

  @override
  String get addIngredientLabel => 'Add ingredient';

  @override
  String get noIngredientsYet => 'No ingredients yet.';

  @override
  String get instructionsOptional => 'Instructions (optional)';

  @override
  String get addStep => 'Add step';

  @override
  String get noStepsAdded => 'No steps added.';

  @override
  String get stepPlaceholder => 'Describe the step…';

  @override
  String get removeStep => 'Remove step';

  @override
  String get saveDishButton => 'Save Dish';

  @override
  String get saveDishFailed => 'Failed to save dish. Please try again.';

  @override
  String get addIngredientTitle => 'Add Ingredient';

  @override
  String get editIngredientTitle => 'Edit Ingredient';

  @override
  String get searchDatabase => 'Search database';

  @override
  String changeProduct(String name) {
    return 'Change: $name';
  }

  @override
  String get ingredientNameLabel => 'Ingredient name';

  @override
  String get requiredError => 'Required';

  @override
  String get amountLabel => 'Amount';

  @override
  String get unitLabel => 'Unit';

  @override
  String get autoCalculatedNote =>
      'Nutrition auto-calculated per entered amount';

  @override
  String get caloriesKcalLabel => 'Calories (kcal)';

  @override
  String get proteinGLabel => 'Protein (g)';

  @override
  String get fatGLabel => 'Fat (g)';

  @override
  String get carbsGLabel => 'Carbs (g)';

  @override
  String get numberError => 'Enter a number ≥ 0';

  @override
  String get searchDatabaseTitle => 'Search database';

  @override
  String get searchProductsHint => 'Search products…';

  @override
  String get noProductsFound => 'No products found.';

  @override
  String get weekTab => 'Week';

  @override
  String get monTab => 'Mon';

  @override
  String get tueTab => 'Tue';

  @override
  String get wedTab => 'Wed';

  @override
  String get thuTab => 'Thu';

  @override
  String get friTab => 'Fri';

  @override
  String get satTab => 'Sat';

  @override
  String get sunTab => 'Sun';

  @override
  String get loadMealPlanError => 'Could not load meal plan.';

  @override
  String get previousWeek => 'Previous week';

  @override
  String get nextWeek => 'Next week';

  @override
  String get today => 'Today';

  @override
  String get moreOptions => 'More options';

  @override
  String get copyFromPreviousWeek => 'Copy from previous week';

  @override
  String get copyWeekDialogTitle => 'Copy previous week?';

  @override
  String copyWeekDialogContent(String thisRange, String prevRange) {
    return 'Replace $thisRange with dishes from $prevRange?';
  }

  @override
  String get weekCopied => 'Week copied!';

  @override
  String get noPreviousWeekDishes => 'Previous week has no dishes.';

  @override
  String get weeklyTotal => 'Weekly Total';

  @override
  String get kcal => 'kcal';

  @override
  String get emptySlot => 'Tap + to add a dish';

  @override
  String get remove => 'Remove';

  @override
  String get copyDayDialogTitle => 'Copy from previous week?';

  @override
  String copyDayDialogContent(String dayName, String date) {
    return 'Replace $dayName $date\'s dishes with last $dayName\'s dishes?';
  }

  @override
  String get dayCopied => 'Day copied!';

  @override
  String get noPreviousDayDishes => 'Previous week has no dishes for this day.';

  @override
  String get noDishesInLibrary => 'No dishes in library yet.';

  @override
  String get noMatches => 'No matches.';

  @override
  String get addDishDialogTitle => 'Add dish';

  @override
  String get searchDishesHint => 'Search dishes…';

  @override
  String get mealSlotsTitle => 'Meal Slots';

  @override
  String get rename => 'Rename';

  @override
  String get addSlot => 'Add Slot';

  @override
  String get renameSlotTitle => 'Rename Slot';

  @override
  String get addSlotTitle => 'Add Slot';

  @override
  String get slotNameLabel => 'Slot name';

  @override
  String get slotNameEmptyError => 'Name cannot be empty';

  @override
  String get slotNameExistsError => 'A slot with this name already exists';

  @override
  String get saveFailedSnackbar => 'Failed to save. Please try again.';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageUkrainian => 'Ukrainian';

  @override
  String get shoppingListTitle => 'Shopping List';

  @override
  String get comingSoon => 'Shopping List — coming soon';

  @override
  String get labelBreakfast => 'Breakfast';

  @override
  String get labelLunch => 'Lunch';

  @override
  String get labelDinner => 'Dinner';
}
