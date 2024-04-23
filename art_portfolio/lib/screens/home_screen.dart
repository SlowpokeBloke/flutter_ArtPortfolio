import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/collection.dart';
import '../models/artwork.dart';

class HomeScreen extends StatelessWidget {
  final User currentUser;
  final List<Collection> collections;
  final List<Artwork> works;
  final List<User> artists; // If using User model for artists

  const HomeScreen({
    Key? key,
    required this.currentUser,
    required this.collections,
    required this.works,
    required this.artists,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${currentUser.firstName}\'s Gallery'),
        leading: Icon(Icons.collections),
        actions: [
          IconButton(
            icon: Icon(Icons.message),
            onPressed: () {
              // Navigate to messages screen
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // "Collections" Section
            _buildSectionTitle(context, 'Collections'),
            _buildHorizontalList(
              context,
              collections.map((collection) => _buildCollectionCard(context, collection)).toList(),
            ),

            // "Works" Section
            _buildSectionTitle(context, 'Works'),
            _buildHorizontalList(
              context,
              works.map((work) => _buildWorkCard(context, work)).toList(),
            ),

            // "Artists" Section
            _buildSectionTitle(context, 'Artists'),
            _buildHorizontalList(
              context,
              artists.map((artist) => _buildArtistCard(context, artist)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(title, style: Theme.of(context).textTheme.headline6),
    );
  }

  Widget _buildHorizontalList(BuildContext context, List<Widget> items) {
    return Container(
      height: 200, // Adjust as needed for your design
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: items,
      ),
    );
  }

  // Widget _buildCollectionCard(BuildContext context, Collection collection) {
  //   return Card(
  //     child: InkWell(
  //       onTap: () {
  //         // Handle tap, navigate to collection detail
  //       },
  //       child: Column(
  //         children: <Widget>[
  //           Expanded(child: Image.network(collection.featuredImageUrl, fit: BoxFit.cover)),
  //           Padding(
  //             padding: const EdgeInsets.all(8.0),
  //             child: Text(collection.title),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildWorkCard(BuildContext context, Artwork work) {
    return Card(
      child: InkWell(
        onTap: () {
          // Handle tap, navigate to artwork detail
        },
        child: Image.network(work.imageUrl, fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildArtistCard(BuildContext context, User artist) {
    return CircleAvatar(
      backgroundImage: NetworkImage(artist.profileImageUrl),
      // Handle tap if needed
    );
  }
}
