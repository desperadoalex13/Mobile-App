// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get appTitle => 'Планувальник харчування';

  @override
  String get cancel => 'Скасувати';

  @override
  String get save => 'Зберегти';

  @override
  String get delete => 'Видалити';

  @override
  String get edit => 'Редагувати';

  @override
  String get copy => 'Копіювати';

  @override
  String get retry => 'Повторити';

  @override
  String get signOut => 'Вийти';

  @override
  String get operationFailed => 'Операція не вдалася. Спробуйте ще раз.';

  @override
  String get importFailed => 'Імпорт не вдався. Спробуйте ще раз.';

  @override
  String get noInternet => 'Немає підключення до інтернету.';

  @override
  String get genericError => 'Щось пішло не так. Спробуйте ще раз.';

  @override
  String get permissionDenied =>
      'Відмовлено в доступі до бази даних. Перевірте правила безпеки Firestore.';

  @override
  String get signInNotEnabled =>
      'Вхід через email/пароль не увімкнено. Увімкніть у Firebase Console → Authentication → Sign-in method.';

  @override
  String get emailLabel => 'Електронна пошта';

  @override
  String get passwordLabel => 'Пароль';

  @override
  String get emailEmptyError => 'Введіть електронну пошту';

  @override
  String get emailInvalidError => 'Введіть правильну електронну пошту';

  @override
  String get passwordEmptyError => 'Введіть пароль';

  @override
  String get passwordTooShortError => 'Пароль має містити не менше 6 символів';

  @override
  String get signIn => 'Увійти';

  @override
  String get loginSubtitle => 'Увійдіть, щоб продовжити';

  @override
  String get noAccount => 'Немає облікового запису?';

  @override
  String get register => 'Зареєструватися';

  @override
  String get invalidCredentials => 'Невірна пошта або пароль.';

  @override
  String get tooManyAttempts => 'Забагато спроб. Повторіть пізніше.';

  @override
  String get createAccount => 'Створити обліковий запис';

  @override
  String get registerSubtitle => 'Почніть планувати харчування сьогодні';

  @override
  String get confirmPasswordLabel => 'Підтвердіть пароль';

  @override
  String get confirmPasswordEmptyError => 'Підтвердіть пароль';

  @override
  String get passwordMismatchError => 'Паролі не збігаються';

  @override
  String get hasAccount => 'Вже є обліковий запис?';

  @override
  String get emailInUse => 'Обліковий запис з цією поштою вже існує.';

  @override
  String get invalidEmail => 'Невірна електронна пошта.';

  @override
  String get weakPassword => 'Пароль занадто слабкий.';

  @override
  String get navPlan => 'Меню';

  @override
  String get navDishes => 'Страви';

  @override
  String get navShopping => 'Покупки';

  @override
  String get navSettings => 'Налаштування';

  @override
  String get titleMealPlan => 'План харчування';

  @override
  String get titleDishes => 'Страви';

  @override
  String get titleShopping => 'Покупки';

  @override
  String get titleSettings => 'Налаштування';

  @override
  String get addDishTooltip => 'Додати страву';

  @override
  String get importCsvTooltip => 'Імпорт з CSV';

  @override
  String get noDishesTitle => 'Страв поки немає';

  @override
  String get noDishesDescription =>
      'Створіть особисту бібліотеку рецептів.\nНатисніть кнопку нижче, щоб додати першу страву.';

  @override
  String get addDishButton => 'Додати страву';

  @override
  String get importStarterButton => 'Імпортувати початкові страви';

  @override
  String get importFromCsvButton => 'Імпортувати з CSV';

  @override
  String get importingIndicator => 'Імпортування…';

  @override
  String get loadDishesError => 'Не вдалося завантажити страви.';

  @override
  String get all => 'Всі';

  @override
  String noFilteredDishes(String label) {
    return 'Немає страв «$label».';
  }

  @override
  String get importCsvDialogTitle => 'Імпортувати з CSV?';

  @override
  String importCsvDialogContent(num count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Знайдено $countString страви. Будуть додані до бібліотеки.',
      one: 'Знайдено 1 страву. Буде додано до бібліотеки.',
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
      other: '$countString страви успішно імпортовано.',
      one: '1 страву успішно імпортовано.',
    );
    return '$_temp0';
  }

  @override
  String get importStarterDialogTitle => 'Імпортувати початкові страви?';

  @override
  String importStarterDialogContent(num count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString початкових страв',
      one: '1 початкову страву',
    );
    return '$_temp0 буде додано до вашої бібліотеки. Існуючі страви з тим самим ID будуть перезаписані.';
  }

  @override
  String starterImportSuccess(num count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString страви успішно імпортовано.',
      one: '1 страву успішно імпортовано.',
    );
    return '$_temp0';
  }

  @override
  String get noDishesInFile => 'Страви у вибраному файлі не знайдені.';

  @override
  String get deleteDishTitle => 'Видалити страву?';

  @override
  String deleteDishContent(String name) {
    return 'Видалити «$name»? Це неможливо скасувати.';
  }

  @override
  String get editTooltip => 'Редагувати';

  @override
  String get noIngredients => 'Інгредієнти не вказані.';

  @override
  String get ingredientsSection => 'Інгредієнти';

  @override
  String get instructionsSection => 'Приготування';

  @override
  String get nutritionPerServing => 'Харчова цінність на порцію';

  @override
  String get caloriesLabel => 'Калорії';

  @override
  String get proteinLabel => 'Білки';

  @override
  String get fatLabel => 'Жири';

  @override
  String get carbsLabel => 'Вуглеводи';

  @override
  String get editDishTitle => 'Редагувати страву';

  @override
  String get addDishTitle => 'Додати страву';

  @override
  String get dishNameLabel => 'Назва страви';

  @override
  String get dishNameError => 'Введіть назву страви';

  @override
  String get servingsLabel => 'Кількість порцій';

  @override
  String get servingsHelper => 'Базова одиниця — 1 порція = 1 людина';

  @override
  String get servingsError => 'Введіть число ≥ 1';

  @override
  String get labelsOptional => 'Мітки (необов\'язково)';

  @override
  String get addIngredientLabel => 'Додати інгредієнт';

  @override
  String get noIngredientsYet => 'Інгредієнтів поки немає.';

  @override
  String get instructionsOptional => 'Приготування (необов\'язково)';

  @override
  String get addStep => 'Додати крок';

  @override
  String get noStepsAdded => 'Кроки ще не додані.';

  @override
  String get stepPlaceholder => 'Опишіть крок…';

  @override
  String get removeStep => 'Видалити крок';

  @override
  String get saveDishButton => 'Зберегти страву';

  @override
  String get saveDishFailed => 'Не вдалося зберегти страву. Спробуйте ще раз.';

  @override
  String get addIngredientTitle => 'Додати інгредієнт';

  @override
  String get editIngredientTitle => 'Редагувати інгредієнт';

  @override
  String get searchDatabase => 'Пошук у базі';

  @override
  String changeProduct(String name) {
    return 'Змінити: $name';
  }

  @override
  String get ingredientNameLabel => 'Назва інгредієнта';

  @override
  String get requiredError => 'Обов\'язково';

  @override
  String get amountLabel => 'Кількість';

  @override
  String get unitLabel => 'Одиниця';

  @override
  String get autoCalculatedNote =>
      'Харчова цінність розраховується автоматично за введеною кількістю';

  @override
  String get caloriesKcalLabel => 'Калорії (ккал)';

  @override
  String get proteinGLabel => 'Білки (г)';

  @override
  String get fatGLabel => 'Жири (г)';

  @override
  String get carbsGLabel => 'Вуглеводи (г)';

  @override
  String get numberError => 'Введіть число ≥ 0';

  @override
  String get searchDatabaseTitle => 'Пошук у базі';

  @override
  String get searchProductsHint => 'Пошук продуктів…';

  @override
  String get noProductsFound => 'Продуктів не знайдено.';

  @override
  String get localSection => 'Локальна база';

  @override
  String get onlineSection => 'Онлайн-результати';

  @override
  String get searchingOnline => 'Пошук онлайн…';

  @override
  String get weekTab => 'Тиждень';

  @override
  String get monTab => 'Пн';

  @override
  String get tueTab => 'Вт';

  @override
  String get wedTab => 'Ср';

  @override
  String get thuTab => 'Чт';

  @override
  String get friTab => 'Пт';

  @override
  String get satTab => 'Сб';

  @override
  String get sunTab => 'Нд';

  @override
  String get loadMealPlanError => 'Не вдалося завантажити план харчування.';

  @override
  String get previousWeek => 'Попередній тиждень';

  @override
  String get nextWeek => 'Наступний тиждень';

  @override
  String get today => 'Сьогодні';

  @override
  String get moreOptions => 'Більше параметрів';

  @override
  String get copyFromPreviousWeek => 'Копіювати з попереднього тижня';

  @override
  String get copyWeekDialogTitle => 'Копіювати попередній тиждень?';

  @override
  String copyWeekDialogContent(String thisRange, String prevRange) {
    return 'Замінити $thisRange стравами з $prevRange?';
  }

  @override
  String get weekCopied => 'Тиждень скопійовано!';

  @override
  String get noPreviousWeekDishes => 'У попередньому тижні немає страв.';

  @override
  String get weeklyTotal => 'Тижнева сума';

  @override
  String get kcal => 'ккал';

  @override
  String get emptySlot => 'Натисніть + щоб додати страву';

  @override
  String get remove => 'Видалити';

  @override
  String get copyDayDialogTitle => 'Копіювати з попереднього тижня?';

  @override
  String copyDayDialogContent(String dayName, String date) {
    return 'Замінити страви $dayName $date стравами минулого $dayName?';
  }

  @override
  String get dayCopied => 'День скопійовано!';

  @override
  String get noPreviousDayDishes =>
      'У попередньому тижні немає страв для цього дня.';

  @override
  String get noDishesInLibrary => 'Бібліотека страв порожня.';

  @override
  String get noMatches => 'Нічого не знайдено.';

  @override
  String get addDishDialogTitle => 'Додати страву';

  @override
  String get searchDishesHint => 'Пошук страв…';

  @override
  String get mealSlotsTitle => 'Прийоми їжі';

  @override
  String get rename => 'Перейменувати';

  @override
  String get addSlot => 'Додати прийом';

  @override
  String get renameSlotTitle => 'Перейменувати прийом';

  @override
  String get addSlotTitle => 'Додати прийом';

  @override
  String get slotNameLabel => 'Назва прийому';

  @override
  String get slotNameEmptyError => 'Назва не може бути порожньою';

  @override
  String get slotNameExistsError => 'Прийом з такою назвою вже існує';

  @override
  String get saveFailedSnackbar => 'Не вдалося зберегти. Спробуйте ще раз.';

  @override
  String get languageTitle => 'Мова';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageUkrainian => 'Українська';

  @override
  String get shoppingListTitle => 'Список покупок';

  @override
  String get shoppingListEmpty =>
      'Поки немає товарів. Додайте страви до плану харчування, щоб сформувати список покупок.';

  @override
  String get loadShoppingListError => 'Не вдалося завантажити список покупок.';

  @override
  String get copyShoppingList => 'Копіювати список';

  @override
  String get shoppingListCopied => 'Список покупок скопійовано в буфер обміну.';

  @override
  String get labelBreakfast => 'Сніданок';

  @override
  String get labelLunch => 'Обід';

  @override
  String get labelDinner => 'Вечеря';
}
