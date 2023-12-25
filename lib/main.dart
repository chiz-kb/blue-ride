import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:blue_ride/google_map.dart';
import 'package:blue_ride/profile.dart';
import 'package:blue_ride/source_destination.dart';
import 'package:blue_ride/verify.dart';
import 'firebase_options.dart';
import 'login_page.dart';
import 'my_home_page.dart';
import 'package:geolocator/geolocator.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}


class _MyAppState extends State<MyApp> {
  locService() async{
 bool serviceEnabled;
  LocationPermission permission;
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) { 
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }
  
  if (permission == LocationPermission.deniedForever) {
    return Future.error(
      'Location permissions are permanently denied, we cannot request permissions.');
  } 
  
  }
  @override
  void initState(){
   locService();
    super.initState();
  }
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Color.fromARGB(255, 209, 168, 168),
      debugShowCheckedModeBanner: false,
      //home: LoginPage(),
       initialRoute: 'home',
        routes: {  
       'source' :(context) =>const SourceDestScreen(),
       'map':(context) => MapSample(),
       'home':(context) =>const MyHomePage(),
       'login': (context) => const LoginPage(),
       'verify': (context) => const MyVerify(),
       'profile': (context) =>const ProfilePage()
     },
    );
  }
}
 
   