import 'dart:async';
import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:wildberries/model/notifiers/filter_notifier.dart';
import 'package:wildberries/model/notifiers/offers_notifier.dart';
import 'package:wildberries/model/notifiers/wishlist_notifier.dart';
import 'package:wildberries/widgets/allWidgets.dart';
import 'package:wildberries/widgets/root_screen.dart';
import 'package:provider/provider.dart';

import 'model/notifiers/bannerAd_notifier.dart';
import 'model/notifiers/brands_notifier.dart';
import 'model/notifiers/cart_notifier.dart';
import 'model/notifiers/notifications_notifier.dart';
import 'model/notifiers/orders_notifier.dart';
import 'model/notifiers/products_notifier.dart';
import 'model/notifiers/userData_notifier.dart';
import 'model/services/auth_service.dart';
import 'screens/getstarted_screens/splash_screen.dart';
import 'utils/colors.dart';
import 'widgets/provider.dart';

StreamingSharedPreferences preferences;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // WidgetsFlutterBinding.ensureInitialized();
  preferences = await StreamingSharedPreferences.instance;
  Firebase.initializeApp();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  runApp(MaterialApp(home: Splash()));
}

final FirebaseAnalytics analytics = FirebaseAnalytics();

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return exit(0);
        }

        // Once complete
        if (snapshot.connectionState == ConnectionState.done) {
          return MyProvider(
            // auth: AuthService(),
            child: AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.dark,
                systemNavigationBarIconBrightness: Brightness.dark,
              ),
              child: Splash(),
            ),
          );
        }
        return MaterialApp(home: HomeController());
      },
    );
  }
}

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    // Pointing the video controller to our local asset.
    _controller = VideoPlayerController.asset('assets/images/splash.mp4')
      ..initialize().then((_) {
        // Once the video has been loaded we play the video and set looping to true.
        _controller.play();
        _controller.setLooping(true);
        _controller.setVolume(0.0);
        _controller.play();
        // Ensure the first frame is shown after the video is initialized.
        setState(() {});
      });
    Timer(Duration(seconds: 5), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomeController()));
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: MColors.mainColor,
      child: Center(
        child: SizedBox(
          width: _controller.value.size?.width ?? 0,
          height: 300,
          child: VideoPlayer(_controller),
        ),
      ),
    );
  }
}

class HomeController extends StatefulWidget {
  const HomeController({Key key}) : super(key: key);

  @override
  _HomeControllerState createState() => _HomeControllerState();
}

class _HomeControllerState extends State<HomeController> {
  @override
  Widget build(BuildContext context) {
    // final AuthService auth = MyProvider.of(context).auth;

    return MaterialApp(
      home: Scaffold(body: AfterSplash()),
    );
  }
}

class AfterSplash extends StatefulWidget {
  @override
  _AfterSplashState createState() => _AfterSplashState();
}

class _AfterSplashState extends State<AfterSplash> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Wildberries",
      theme: ThemeData(
        accentColor: MColors.primaryPurple,
        primaryColor: MColors.primaryPurple,
      ),
      debugShowCheckedModeBanner: false,
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => ProductsNotifier(),
          ),
          ChangeNotifierProvider(
            create: (context) => WishlistNotifier(),
          ),
          ChangeNotifierProvider(
            create: (context) => CategoryNotifier(),
          ),
          ChangeNotifierProvider(
            create: (context) => BrandsNotifier(),
          ),
          ChangeNotifierProvider(
            create: (context) => CartNotifier(),
          ),
          ChangeNotifierProvider(
            create: (context) => UserDataProfileNotifier(),
          ),
          ChangeNotifierProvider(
            create: (context) => UserDataAddressNotifier(),
          ),
          ChangeNotifierProvider(
            create: (context) => OrderListNotifier(),
          ),
          ChangeNotifierProvider(
            create: (context) => NotificationsNotifier(),
          ),
          ChangeNotifierProvider(
            create: (context) => BannerAdNotifier(),
          ),
          ChangeNotifierProvider(
            create: (context) => FiltersNotifier(),
          ),
          ChangeNotifierProvider(
            create: (context) => OffersNotifier(),
          )
        ],
        child: RootScreen(),
      ),
    );
  }
}
//Latest Commit 11 May 2022
