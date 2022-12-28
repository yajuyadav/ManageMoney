import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:manage_money/auth_services.dart';
import 'package:manage_money/loginscreen.dart';
import 'package:manage_money/mainScreen.dart';
import 'package:native_admob_flutter/native_admob_flutter.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';


const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    'This channel is used for important notifications.', // description
    importance: Importance.high,
    playSound: true);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('A bg message just showed up :  ${message.messageId}');
}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await MobileAds.initialize();
  final AppOpenAd appOpenAd= AppOpenAd();
  if(!appOpenAd.isAvailable){
    await appOpenAd.load(unitId: 'ca-app-pub-4619363086776822/4438937990');
  }
  if(appOpenAd.isAvailable){
    await appOpenAd.show();
  }
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return OverlaySupport(
      child: MultiProvider(
        providers: [
          Provider<AuthService>(
            create: (_) => AuthService(FirebaseAuth.instance),
          ),
          StreamProvider(
            create: (context) =>
            context
                .read<AuthService>()
                .authStateChanges, initialData: null,
          ),
        ],
        child:MaterialApp(
          title: 'Flutter Demo',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            fontFamily: 'Questrial',
          ),
          home: MyHomePage(),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FirebaseAuth auth = FirebaseAuth.instance;
  late StreamSubscription subscription;
  void initState() {
    super.initState();

    subscription =
        Connectivity().onConnectivityChanged.listen(showConnectivitySnackBar);
  }
  @override
  void dispose() {
    subscription.cancel();

    super.dispose();
  }
  void showConnectivitySnackBar(ConnectivityResult result) {
    final hasInternet = result != ConnectivityResult.none;
    final message = hasInternet
        ? 'You are connected to the Internet'
        : 'You have no Internet';
    final color = hasInternet ? Colors.green : Colors.red;
    showSimpleNotification(
      Text('Internet Connectivity Update'),
      subtitle: Text(message),
      background: color,
    );
  }
  @override
  Widget build(BuildContext context) {
    if (auth.currentUser == null) {
      return loginscreen();
    } else {
      return mainscreen();
    }
  }
}

