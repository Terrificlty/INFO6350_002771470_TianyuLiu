import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:garagesale/post_detail.dart';

import 'new_post_activity.dart';

class BrowsePostsActivity extends StatefulWidget {

  final User user;

  const BrowsePostsActivity({super.key, required this.user});

  @override
  State<BrowsePostsActivity> createState() => _BrowsePostsActivityState();
}

class _BrowsePostsActivityState extends State<BrowsePostsActivity> {

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Garage Sale'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _firebaseAuth.signOut();
            },
          ),
        ],
      ),
      body:  _buildHomeScreenContent(user: widget.user),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add, color: Colors.black,),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NewPostActivity(user: widget.user)),
          );
        }
      ),
    );
  }

  Widget _buildHomeScreenContent({required User user}) => StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance.collection('items').where('userId', isEqualTo: user.uid).snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      if (snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}'));
      }
      return Padding(
        padding: const EdgeInsets.all(10),
        child: ListView.separated(
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final List<dynamic> images = doc['images'];
            final String imageUrl = images.isNotEmpty ? images[0] : '';
            return Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: imageUrl.isNotEmpty ? FutureBuilder(
                  future: precacheImage(NetworkImage(imageUrl), context),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasError) {
                        return const Icon(Icons.error, size: 50);
                      } else {
                        return Image.network(imageUrl, height: 50, width: 50, fit: BoxFit.cover,);
                      }
                    } else {
                      return const CircularProgressIndicator();
                    }
                  },
                ) : Image.asset('assets/default_img.png', height: 50, width: 50, fit: BoxFit.cover,),
                title: Text(doc['title'], style: Theme.of(context).textTheme.displayMedium,),
                subtitle: Text('\$${doc['price'].toStringAsFixed(2)}', style: Theme.of(context).textTheme.bodyLarge,),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => PostDetail(docId: doc.id),),);
                },
              ),
            );
          },
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemCount: snapshot.data!.docs.length,
        ),
      );
    },
  );
}