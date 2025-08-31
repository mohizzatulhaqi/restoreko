import 'dart:async' show runZonedGuarded;
import 'package:workmanager/workmanager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restoreko/pages/favorite_restaurant_page.dart';
import 'package:restoreko/pages/setting_page.dart';
import 'pages/restaurant_list_page.dart';
import 'providers/restaurant_provider.dart';
import 'providers/restaurant_detail_provider.dart';
import 'services/restaurant_service.dart';
import 'package:restoreko/providers/favorite_provider.dart';
import 'package:restoreko/database/database_helper.dart';
import 'package:restoreko/providers/theme_provider.dart';
import 'package:restoreko/services/notification_service.dart';
import 'package:restoreko/providers/settings_provider.dart';
import 'package:restoreko/services/background_service.dart';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case "dailyRestaurantRecommendation":
        await BackgroundService.scheduleDailyNotification();
        break;
      default:
        debugPrint("Unknown task: $task");
    }
    return Future.value(true);
  });
}

Future<void> _initializeApp() async {
  const enableWorkmanager = bool.fromEnvironment(
    'ENABLE_WORKMANAGER',
    defaultValue: true,
  );

  debugPrint('Starting app initialization...');

  try {
    // Initialize database
    debugPrint('Initializing database...');
    final dbHelper = DatabaseHelper();
    await dbHelper.database;
    debugPrint('✓ Database initialized successfully');

    // Initialize notification service
    debugPrint('Initializing notification service...');
    final notificationService = NotificationService();
    await notificationService.initialize();
    debugPrint('✓ Notification service initialized');

    // Initialize settings provider
    debugPrint('Loading settings...');
    final settingsProvider = SettingsProvider();
    await settingsProvider.loadSettings();
    debugPrint('✓ Settings loaded');

    // Initialize background service and WorkManager
    if (enableWorkmanager) {
      debugPrint('Initializing background services...');
      try {
        await BackgroundService.initialize();

        if (settingsProvider.isDailyReminderEnabled) {
          debugPrint('Scheduling daily notifications...');
          await BackgroundService.scheduleDailyNotification();
        } else {
          debugPrint('Cancelling any scheduled notifications...');
          await BackgroundService.cancelDailyNotification();
        }
        debugPrint('✓ Background services initialized');
      } catch (e, stackTrace) {
        debugPrint('⚠️ Error initializing background services: $e');
        debugPrint('Stack trace: $stackTrace');
      }
    } else {
      debugPrint('Background services are disabled');
    }

    debugPrint('✓ All services initialized successfully');
  } catch (e, stackTrace) {
    debugPrint('❌ Critical initialization error: $e');
    debugPrint('Stack trace: $stackTrace');
  }
}

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      _initializeApp();

      runApp(const MyApp());
    },
    (error, stackTrace) {
      debugPrint('Uncaught error in main zone: $error');
      debugPrint('Stack trace: $stackTrace');
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const brandColor = Color(0xFFFF6F00);

    final lightScheme = ColorScheme.fromSeed(
      seedColor: brandColor,
      brightness: Brightness.light,
    );

    final darkScheme = ColorScheme.fromSeed(
      seedColor: brandColor,
      brightness: Brightness.dark,
    );

    final baseTextTheme = GoogleFonts.poppinsTextTheme();
    final restaurantService = RestaurantService();
    
    return MultiProvider(
      providers: [
        Provider<RestaurantService>(
          create: (_) => restaurantService,
        ),
        ChangeNotifierProvider(
          create: (context) => RestaurantProvider(service: restaurantService)
            ..fetchRestaurants(),
        ),
        ChangeNotifierProvider(
          create: (context) => RestaurantDetailProvider(service: restaurantService),
        ),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => SettingsProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Restoreko',
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.isDarkMode
                ? ThemeMode.dark
                : ThemeMode.light,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: lightScheme,
              scaffoldBackgroundColor: const Color(0xFFF8F8F8),
              textTheme: baseTextTheme,
              appBarTheme: AppBarTheme(
                backgroundColor: lightScheme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                centerTitle: false,
                titleTextStyle: baseTextTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              cardTheme: CardThemeData(
                color: Colors.white,
                elevation: 0,
                surfaceTintColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: lightScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: darkScheme,
              scaffoldBackgroundColor: const Color(0xFF111315),
              textTheme: GoogleFonts.poppinsTextTheme(
                ThemeData(brightness: Brightness.dark).textTheme,
              ),
              appBarTheme: AppBarTheme(
                backgroundColor: darkScheme.surface,
                foregroundColor: darkScheme.onSurface,
                elevation: 0,
                centerTitle: false,
              ),
              cardTheme: CardThemeData(
                color: darkScheme.surface,
                elevation: 0,
                surfaceTintColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkScheme.primary,
                  foregroundColor: darkScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: darkScheme.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            home: const MainNavigation(),
          );
        },
      ),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const RestaurantListPage(),
    const FavoritesPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Colors.grey[600],
          selectedLabelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w400,
            fontSize: 12,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.restaurant),
              activeIcon: Icon(Icons.restaurant),
              label: 'Restoran',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_outline),
              activeIcon: Icon(Icons.favorite),
              label: 'Favorit',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Pengaturan',
            ),
          ],
        ),
      ),
    );
  }
}
