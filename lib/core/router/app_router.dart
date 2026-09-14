import 'package:go_router/go_router.dart';
import '../../core/models/promotion_dto.dart';
import '../../core/models/tour_dto.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/bridge/presentation/screens/bridge_screens.dart';
import '../../features/turista/presentation/screens/turista_main_screen.dart';
import '../../features/turista/presentation/screens/games/wordle_game_screen.dart';
import '../../features/chofer/presentation/screens/assigned_trips_screen.dart';
import '../../features/chofer/presentation/screens/passenger_list_screen.dart';
import '../../features/chofer/presentation/screens/scan_qr_screen.dart';
import '../../features/chofer/presentation/screens/tourist_detail_screen.dart';
import '../../features/chofer/presentation/screens/trip_detail_screen.dart';
import '../../features/chofer/presentation/screens/active_trip_map_screen.dart';
import '../../features/negocios/presentation/screens/negocio_main_screen.dart';
import '../../features/admin/presentation/screens/admin_main_screen.dart';

import '../../features/admin/presentation/screens/tabs/admin_wordle_screen.dart';
import '../../features/admin/presentation/screens/tabs/admin_stickers_screen.dart';
import '../../features/admin/presentation/screens/tabs/admin_multimedia_screen.dart';

import '../../features/admin/presentation/screens/admin_add_tour_screen.dart';
import '../../features/admin/presentation/screens/admin_edit_tour_screen.dart';
import '../../features/admin/presentation/screens/admin_notifications_screen.dart';
import '../../features/admin/presentation/screens/admin_promo_review_screen.dart';
import '../../features/admin/presentation/screens/admin_scan_screen.dart';
import '../../features/admin/presentation/screens/admin_user_success_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/turista',
      builder: (context, state) => const TuristaMainScreen(),
      routes: [
        GoRoute(
          path: 'wordle',
          builder: (context, state) => const WordleGameScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/chofer',
      builder: (context, state) => const AssignedTripsScreen(),
      routes: [
        GoRoute(
          path: 'trip/:tripId',
          builder: (context, state) => TripDetailScreen(
            tripId: state.pathParameters['tripId']!,
          ),
        ),
        GoRoute(
          path: 'active-trip',
          builder: (context, state) {
            final String tripId = state.extra as String? ?? 't1';
            return ActiveTripMapScreen(tripId: tripId);
          },
        ),
        GoRoute(
          path: 'passengers/:tripId',
          builder: (context, state) => PassengerListScreen(
            tripId: state.pathParameters['tripId']!,
          ),
        ),
        GoRoute(
          path: 'scan',
          builder: (context, state) => const ScanQRScreen(),
        ),
        GoRoute(
          path: 'tourist/:touristId',
          builder: (context, state) => TouristDetailScreen(
            touristId: state.pathParameters['touristId']!,
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/negocios',
      builder: (context, state) => const NegocioMainScreen(),
    ),
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminMainScreen(),
      routes: [
        GoRoute(
          path: 'wordle',
          builder: (context, state) => const AdminWordleScreen(),
        ),
        GoRoute(
          path: 'stickers',
          builder: (context, state) => const AdminStickersScreen(),
        ),
        GoRoute(
          path: 'multimedia',
          builder: (context, state) => const AdminMultimediaScreen(),
        ),
        GoRoute(
          path: 'scan',
          builder: (context, state) => const AdminScanScreen(),
        ),
        GoRoute(
          path: 'notifications',
          builder: (context, state) => const AdminNotificationsScreen(),
        ),
        GoRoute(
          path: 'promo-review',
          builder: (context, state) => const AdminPromoReviewScreen(),
        ),
        GoRoute(
          path: 'add-tour',
          builder: (context, state) => const AdminAddTourScreen(),
        ),
        GoRoute(
          path: 'edit-tour',
          builder: (context, state) => const AdminEditTourScreen(),
        ),
        GoRoute(
          path: 'user-success',
          builder: (context, state) => const AdminUserSuccessScreen(),
        ),
      ],
    ),
  ],
);
