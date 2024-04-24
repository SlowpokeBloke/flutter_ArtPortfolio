import 'package:flutter/material.dart';

class CollectionDetailScreen extends StatelessWidget {
  const CollectionDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('CollectionDetailScreen')),
      body: Center(child: Text('Collection Detail Screen')),
    );
  }
}