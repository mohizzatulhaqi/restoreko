import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pages/restaurant_list_page.dart';
import 'providers/restaurant_provider.dart';
import 'providers/restaurant_detail_provider.dart';
import 'services/restaurant_service.dart';

void main() {
  runApp(MyApp());
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
        ChangeNotifierProvider(
          create: (_) => RestaurantProvider(service: restaurantService)
            ..fetchRestaurants(),
        ),
        ChangeNotifierProvider(
          create: (_) => RestaurantDetailProvider(service: restaurantService),
        ),
      ],
      child: MaterialApp(
        title: 'Restoreko',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.system,
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
        home: RestaurantListPage(),
      ),
    );
  }
}
