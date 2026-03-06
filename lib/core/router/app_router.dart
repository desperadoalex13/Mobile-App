import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/firebase/firebase_providers.dart';
import '../../features/auth/presentation/auth_controller.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/dish_library/domain/dish_model.dart';
import '../../features/dish_library/presentation/dish_detail_screen.dart';
import '../../features/dish_library/presentation/dish_form_screen.dart';
import '../../features/dish_library/presentation/dish_library_screen.dart';
import '../../features/meal_plan/presentation/meal_plan_screen.dart';
import '../../features/shopping_list/presentation/shopping_list_screen.dart';

part 'app_routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = _AuthNotifier(ref);
  ref.onDispose(notifier.dispose);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: notifier,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);

      // Auth state not yet resolved — stay on splash
      if (authState.isLoading) return AppRoutes.splash;

      final isLoggedIn = authState.valueOrNull != null;
      final isAuthRoute = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register;
      final isSplash = state.matchedLocation == AppRoutes.splash;

      // Auth resolved — leave splash
      if (isSplash) return isLoggedIn ? AppRoutes.mealPlan : AppRoutes.login;

      if (!isLoggedIn && !isAuthRoute) return AppRoutes.login;
      if (isLoggedIn && isAuthRoute) return AppRoutes.mealPlan;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.dishDetail,
        name: 'dish-detail',
        builder: (context, state) =>
            DishDetailScreen(dish: state.extra as Dish),
      ),
      GoRoute(
        path: AppRoutes.dishForm,
        name: 'dish-form',
        builder: (context, state) =>
            DishFormScreen(dish: state.extra as Dish?),
      ),
      ShellRoute(
        builder: (context, state, child) => ScaffoldWithNavBar(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.mealPlan,
            name: 'meal-plan',
            builder: (context, state) => const MealPlanScreen(),
          ),
          GoRoute(
            path: AppRoutes.dishLibrary,
            name: 'dish-library',
            builder: (context, state) => const DishLibraryScreen(),
          ),
          GoRoute(
            path: AppRoutes.shoppingList,
            name: 'shopping-list',
            builder: (context, state) => const ShoppingListScreen(),
          ),
        ],
      ),
    ],
  );
});

/// Notifies GoRouter to re-evaluate redirect when auth state changes.
class _AuthNotifier extends ChangeNotifier {
  _AuthNotifier(Ref ref) {
    ref.listen(authStateProvider, (_, __) => notifyListeners());
  }
}

class ScaffoldWithNavBar extends ConsumerWidget {
  const ScaffoldWithNavBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    return Scaffold(
      appBar: AppBar(
        title: Text(_titleForLocation(location)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
            onPressed: () =>
                ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex(context),
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go(AppRoutes.mealPlan);
            case 1:
              context.go(AppRoutes.dishLibrary);
            case 2:
              context.go(AppRoutes.shoppingList);
          }
        },
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.calendar_today), label: 'Plan'),
          NavigationDestination(icon: Icon(Icons.menu_book), label: 'Dishes'),
          NavigationDestination(
              icon: Icon(Icons.shopping_cart), label: 'Shopping'),
        ],
      ),
    );
  }

  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith(AppRoutes.dishLibrary)) return 1;
    if (location.startsWith(AppRoutes.shoppingList)) return 2;
    return 0;
  }

  String _titleForLocation(String location) {
    if (location.startsWith(AppRoutes.dishLibrary)) return 'Dishes';
    if (location.startsWith(AppRoutes.shoppingList)) return 'Shopping';
    return 'Meal Plan';
  }
}
