import 'package:eazyworld_app/features/character/presentation/pages/character_details_page.dart';
import 'package:eazyworld_app/features/character/presentation/pages/home_page.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  AppRouter._();

  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/details',
        builder: (context, state) => const CharacterDetailsPage(),
      ),
    ],
  );
}