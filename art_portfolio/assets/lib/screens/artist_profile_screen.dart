import 'package:flutter/material.dart';

class ArtistProfileScreen extends StatelessWidget {
  const ArtistProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ArtistProfileScreen')),
      body: Center(child: Text('Artist Profile Screen')),
    );
  }
}