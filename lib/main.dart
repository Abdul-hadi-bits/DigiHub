import 'package:digi_hub/Business_Logic/Utility.dart';
import 'package:digi_hub/Business_Logic/Global_States/userStatusCubit.dart';
import 'package:digi_hub/Data_Layer/Module/Cache_Memory_Module.dart';
import 'package:digi_hub/Data_Layer/Module/Local_noSql_Module.dart';
import 'package:digi_hub/Utillity/firebaes_api.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:digi_hub/Business_Logic/Global_States/internetCubit.dart';
import 'package:digi_hub/Data_Layer/Data_Providers/Local_Database_Provider.dart';
import 'package:digi_hub/Route/routing.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseApi().initNotifications();

  LocalDbProvider.getDatabase;
  CacheMemory.setCasheMemory(await SharedPreferences.getInstance());

  // File path to a file in the current directory
  await LocalMemory.initializeDb();

  requestNotificationPermissions();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    // systemNavigationBarColor: Colors.transparent, // navigation bar color
    statusBarColor: Colors.white,

    // systemNavigationBarContrastEnforced: true // status bar color
  ));

  runApp(MyApp());
}

Future<void> requestNotificationPermissions() async {
  final PermissionStatus status = await Permission.notification.request();
  if (status.isGranted) {
    // Notification permissions granted
  } else if (status.isDenied) {
    // Notification permissions denied
  } else if (status.isPermanentlyDenied) {
    // Notification permissions permanently denied, open app settings
    await openAppSettings();
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late InternetCubit _internetCubit;
  late AppRouter _route;
  late UserStatusCubit _userStatusCubit;

  @override
  void initState() {
    print("******* app initialized *********");

    _internetCubit = InternetCubit();
    _route = AppRouter(internetCubit: _internetCubit);
    // TODO: implement initState
    NetworkConnection(internetCubit: _internetCubit);

    super.initState();
  }

  @override
  void dispose() {
    print("******* app disposed *********");
    // TODO: implement dispose
    _internetCubit.close();
    _route.disposeEmailSignInCubit();
    super.dispose();
    _userStatusCubit.close();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:

        //Execute the code here when user come back the app.
        //In my case, I needed to show if user active or not,
        //  initState();

        print("in");

        break;
      case AppLifecycleState.paused:

        //Execute the code the when user leave the app
        // dispose();

        print("out");

        break;
      default:
        break;
    }
  }

  Future<String> getTokenForNotification() async {
    final _fireabseMessageing = FirebaseMessaging.instance;
    await _fireabseMessageing.requestPermission();
    final fCMToken = await _fireabseMessageing.getToken();
    print("Token is : $fCMToken");

    return fCMToken ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(
          value: _internetCubit,
        ),
      ],
      child: MaterialApp(
        themeMode: ThemeMode.light,
        theme: ThemeData(
          dialogTheme: DialogTheme(backgroundColor: Colors.white, elevation: 0),
          secondaryHeaderColor: Colors.white,
          dialogBackgroundColor: Colors.white,
        ),
        debugShowCheckedModeBanner: false,
        onGenerateRoute: _route.onGeneratedRoutes,
        // home: wrapper() ? const DigiHub() : const WellcomePage(),
      ),
    );
  }
}
