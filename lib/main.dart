import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restoranapp/data/api/api_service.dart';
import 'package:restoranapp/data/local/local_database_service.dart';
import 'package:restoranapp/providers/detail/favorite_icon_provider.dart';
import 'package:restoranapp/providers/detail/restaurant_detail_provider.dart';
import 'package:restoranapp/providers/favorite/local_database_provider.dart';
import 'package:restoranapp/providers/home/restaurant_list_provider.dart';
import 'package:restoranapp/providers/home/restaurant_search_provider.dart';
import 'package:restoranapp/providers/main/index_nav_provider.dart';
import 'package:restoranapp/providers/main/reminder_provider.dart';
import 'package:restoranapp/providers/main/theme_provider.dart';
import 'package:restoranapp/screens/detail/detail_screen.dart';
import 'package:restoranapp/screens/main/main_screen.dart';
import 'package:restoranapp/services/notification_service.dart';
import 'package:restoranapp/static/navigation_route.dart';
import 'package:restoranapp/style/theme/restaurant_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final notificationAppLaunchDetails = await flutterLocalNotificationsPlugin
      .getNotificationAppLaunchDetails();

  String route = NavigationRoute.mainRoute.name;
  String? payload;

  if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
    final notificationResponse =
        notificationAppLaunchDetails!.notificationResponse;
    route = NavigationRoute.detailRoute.name;
    payload = notificationResponse?.payload;
  }

  await NotificationService.init();
  await NotificationService.requestPermission();
  runApp(
    MultiProvider(
      providers: [
        Provider(create: (context) => ApiServices()),
        Provider(create: (context) => LocalDatabaseService()),
        ChangeNotifierProvider(create: (context) => IndexNavProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(
          create: (context) =>
              RestaurantListProvider(context.read<ApiServices>()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              RestaurantDetailProvider(context.read<ApiServices>()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              RestaurantSearchProvider(context.read<ApiServices>()),
        ),

        ChangeNotifierProvider(
          create: (context) =>
              LocalDatabaseProvider(context.read<LocalDatabaseService>()),
        ),
        ChangeNotifierProvider(create: (_) => ReminderProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteIconProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Restoran App',
      theme: RestaurantTheme.lightTheme,
      darkTheme: RestaurantTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      initialRoute: NavigationRoute.mainRoute.name,
      routes: {
        NavigationRoute.mainRoute.name: (context) => const MainScreen(),
        NavigationRoute.detailRoute.name: (context) => DetailScreen(
          restaurantId: ModalRoute.of(context)?.settings.arguments as String,
        ),
      },
    );
  }
}
