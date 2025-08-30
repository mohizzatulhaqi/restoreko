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
import 'package:restoreko/services/settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final dbHelper = DatabaseHelper();
    await dbHelper.database;
    debugPrint('Database initialized successfully');
    
    final notificationService = NotificationService();
    await notificationService.initialize();
    
    final settingsService = SettingsService();
    await settingsService.initialize();
    
    if (settingsService.isDailyReminderEnabled) {
      await notificationService.scheduleLunchReminder();
    }
    
    debugPrint('Services initialized successfully');
  } catch (e) {
    debugPrint('Initialization error: $e');
  }

  runApp(const MyApp());
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
        Provider<RestaurantService>(create: (_) => restaurantService),
        ChangeNotifierProvider(
          create: (context) =>
              RestaurantProvider(service: context.read<RestaurantService>())
                ..fetchRestaurants(),
        ),
        ChangeNotifierProvider(
          create: (context) => RestaurantDetailProvider(
            service: context.read<RestaurantService>(),
          ),
        ),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ), 
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
