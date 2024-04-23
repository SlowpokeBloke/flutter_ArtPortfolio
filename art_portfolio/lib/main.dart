import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'services/firebase_options.dart';
import 'services/authentication_service.dart'; // Ensure you have this import
import 'screens/login_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/home_screen.dart';
import 'screens/user_profile_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/artist_profile_screen.dart';
import 'screens/collection_detail_screen.dart';
import 'screens/messaging_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    FirebaseInitializer(
      child: Provider<AuthenticationService>(
        create: (context) => AuthenticationService(),
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Artfolio',
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/register': (context) => const RegistrationScreen(),
        // '/home': (context) => const HomeScreen(),
        '/profile': (context) => const UserProfileScreen(),
        '/edit_profile': (context) => const EditProfileScreen(),
        '/artist_profile': (context) => const ArtistProfileScreen(),
        '/collection_detail': (context) => const CollectionDetailScreen(),
        '/messaging': (context) => const MessagingScreen(),
      },
    );
  }
}

class FirebaseInitializer extends StatefulWidget {
  final Widget child;

  FirebaseInitializer({required this.child});

  @override
  _FirebaseInitializerState createState() => _FirebaseInitializerState();
}

class _FirebaseInitializerState extends State<FirebaseInitializer> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text("Error initializing Firebase"),
              ),
            ),
          );
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return widget.child;
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return MaterialApp(
          home: Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
      },
    );
  }
}
