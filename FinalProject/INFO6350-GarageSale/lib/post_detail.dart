import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:page_view_indicators/circle_page_indicator.dart';

class PostDetail extends StatefulWidget {

  final String docId;

  const PostDetail({super.key, required this.docId});

  @override
  State<PostDetail> createState() => _PostDetailState();
}

class _PostDetailState extends State<PostDetail> {

  final db = FirebaseFirestore.instance;
  final PageController controller = PageController();
  final ValueNotifier<int> _pageNotifier = ValueNotifier<int>(0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.red,),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder(future: _getProductDetail(), builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          Map<String, dynamic> doc = snapshot.data as Map<String, dynamic>;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPageView(doc),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(doc["title"],),
                    ),
                    const SizedBox(width: 16),
                    Text("\$${doc["price"]}",),
                  ],
                ),
                const SizedBox(height: 16),
                Text("Description"),
                const SizedBox(height: 8),
                Padding(padding: const EdgeInsets.only(left: 16), child: Text(doc["description"],),),
                const SizedBox(height: 16),
              ],
            ),
          );
        }),
      ),
    );
  }

  Future<Map<String, dynamic>> _getProductDetail() async {
    DocumentSnapshot doc = await db.collection('items').doc(widget.docId).get();
    return doc.data() as Map<String, dynamic>;
  }

  _buildPageView(Map<String, dynamic> doc) => SizedBox(height: 300, child: Column(
    children: [
      Expanded(child: PageView(
        controller: controller,
        children: <Widget>[
          for (var img in doc["images"])
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child:  Image.network(img.toString(), fit: BoxFit.cover),
            )
        ], onPageChanged: (index) {
        setState(() {
          _pageNotifier.value = index;
        });
      },)),
      Center(
        child: CirclePageIndicator(
          currentPageNotifier: _pageNotifier,
          itemCount: doc["images"].length,
        ),
      )
    ],),
  );

}