// inside of main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart'; // Assuming this file is directly under the 'lib' directory
import 'services/authentication_service.dart'; // Update the import path as necessary

import 'screens/artist_profile_screen.dart';
import 'screens/collection_detail_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/messaging_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/user_profile_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Wrapping MaterialApp with MultiProvider to provide the AuthenticationService
    return MultiProvider(
      providers: [
        StreamProvider<User?>.value(
          value: FirebaseAuth.instance.authStateChanges(),
          initialData: null,
        ),
        Provider<AuthenticationService>(
          create: (_) => AuthenticationService(),
        ),
      ],
      child: MaterialApp(
        title: 'Artfolio',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        // Use a Builder to access the context below the MultiProvider
        home: Builder(builder: (context) {
          return AuthenticationWrapper();
        }),
        // Define routes
        routes: {
          '/login': (context) => LoginScreen(),
          '/register': (context) => RegistrationScreen(),
          '/home': (context) => HomeScreen(),
          //'/artist_profile': (context) => ArtistProfileScreen(),
          '/collection_detail': (context) => CollectionDetailScreen(),
          '/edit_profile': (context) => EditProfileScreen(),
          //'/messaging': (context) => MessagingScreen(),
          '/user_profile': (context) => UserProfileScreen(),
        },
      ),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    // If the user is not signed in, show the LoginScreen.
    // If the user is signed in, show the HomeScreen.
    return user != null ? HomeScreen() : LoginScreen();
  }
}