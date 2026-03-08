import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restoranapp/data/api/api_service.dart';
import 'package:restoranapp/data/local/local_database_service.dart';
import 'package:restoranapp/providers/detail/favorite_icon_provider.dart';
import 'package:restoranapp/providers/detail/restaurant_detail_provider.dart';
import 'package:restoranapp/providers/detail/readmore_provider.dart';
import 'package:restoranapp/providers/favorite/local_database_provider.dart';
import 'package:restoranapp/providers/home/restaurant_list_provider.dart';
import 'package:restoranapp/providers/home/restaurant_search_provider.dart';
import 'package:restoranapp/providers/main/index_nav_provider.dart';
import 'package:restoranapp/providers/main/reminder_provider.dart';
import 'package:restoranapp/providers/main/theme_provider.dart';
import 'package:restoranapp/screens/detail/detail_screen.dart';
import 'package:restoranapp/screens/main/main_screen.dart';
import 'package:restoranapp/services/http_service.dart';
import 'package:restoranapp/services/notification_service.dart';
import 'package:restoranapp/static/navigation_route.dart';
import 'package:restoranapp/style/theme/restaurant_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final notificationAppLaunchDetails = await notificationsPlugin
      .getNotificationAppLaunchDetails();

  String route = NavigationRoute.mainRoute.name;
  String? payload;

  if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
    final notificationResponse =
        notificationAppLaunchDetails!.notificationResponse;
    route = NavigationRoute.detailRoute.name;
    payload = notificationResponse?.payload;
  }

  runApp(
    MultiProvider(
      providers: [
        Provider(create: (context) => ApiServices()),
        Provider(create: (context) => LocalDatabaseService()),
        Provider(create: (context) => HttpService()),
        Provider(
          create: (context) => NotificationService(context.read<HttpService>())
            ..init()
            // todo-01-notif-07: configure the timezone
            ..configureLocalTimeZone(),
        ),
        ChangeNotifierProvider(create: (_) => ReadMoreProvider()),
  
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
        ChangeNotifierProvider(
          create: (context) =>
              ReminderProvider(context.read<NotificationService>()),
        ),
        ChangeNotifierProvider(create: (_) => FavoriteIconProvider()),
      ],
      child: MyApp(initialRoute: route, payload: payload),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  final String? payload;

  const MyApp({super.key, required this.initialRoute, this.payload});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Restoran App',
      theme: RestaurantTheme.lightTheme,
      darkTheme: RestaurantTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      initialRoute: initialRoute,
      routes: {
        NavigationRoute.mainRoute.name: (context) => const MainScreen(),
        NavigationRoute.detailRoute.name: (context) => DetailScreen(
          restaurantId:
              payload ?? ModalRoute.of(context)?.settings.arguments as String,
        ),
      },
    );
  }
}
