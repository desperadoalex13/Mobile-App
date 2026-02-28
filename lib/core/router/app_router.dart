import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/login_screen.dart';
import '../../features/meal_plan/presentation/meal_plan_screen.dart';
import '../../features/dish_library/presentation/dish_library_screen.dart';
import '../../features/shopping_list/presentation/shopping_list_screen.dart';

part 'app_routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.mealPlan,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
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

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
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
          NavigationDestination(icon: Icon(Icons.calendar_today), label: 'Plan'),
          NavigationDestination(icon: Icon(Icons.menu_book), label: 'Dishes'),
          NavigationDestination(icon: Icon(Icons.shopping_cart), label: 'Shopping'),
        ],
      ),
    );
  }
}
