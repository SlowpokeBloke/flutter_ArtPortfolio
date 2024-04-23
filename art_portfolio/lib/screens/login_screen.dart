// screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/authentication_service.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController _emailController = TextEditingController();
    final TextEditingController _passwordController = TextEditingController();
    final authService = Provider.of<AuthenticationService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: "Password"),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await authService.signInWithEmailPassword(
                    _emailController.text,
                    _passwordController.text,
                  );
                  Navigator.of(context).pushReplacementNamed('/home'); // Navigate to home on successful login
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("Failed to log in. Please try again."),
                  ));
                }
              },
              child: Text("Login"),
            ),
            SizedBox(height: 20), // Spacing between login button and the register link
            GestureDetector(
              onTap: () {
                // Navigate to the registration screen
                Navigator.of(context).pushNamed('/register');
              },
              child: Text(
                "Not registered yet? Sign up here!",
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
