import 'dart:io';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'take_picture_page.dart';

class NewPostActivity extends StatefulWidget {
  final User user;
  const NewPostActivity({super.key, required this.user});

  @override
  State<NewPostActivity> createState() => _NewPostActivityState();
}

class _NewPostActivityState extends State<NewPostActivity> {

  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  List<File> _images = [];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text('HyperGarageSale'),
        // actions: [
          // GestureDetector(
          //   child: Padding(padding: EdgeInsets.all(20), child: Center(
          //     child: Text('publish'),
          //   ),),
          //   onTap: () {
          //     postNewItem();
          //   },
          // ),

        // ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          children: [
            Form(key:_formKey, child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16,),
                _buildTitleForm(),
                const SizedBox(height: 16,),
                _buildPriceForm(),
                const SizedBox(height: 16,),
                _buildDescForm(),
                const SizedBox(height: 16,),
                _buildAddPhotoWidget(),
                const SizedBox(height: 16,),
                if (_images.isNotEmpty)
                  _buildImagesGridView(),
                const SizedBox(height: 16,),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(child: const Text('Post New Item'),
                    onPressed: () {
                      postNewItem();
                    },
                  ),
                ),
              ],
            ))

          ],
        ),
      ),
    );
  }

  _buildImagesGridView() => GridView.builder(
    shrinkWrap: true,
    itemCount: _images.length,
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
    ),
    itemBuilder: (context, index) {
      return Image.file(_images[index], height: 100, width: 100, fit: BoxFit.cover,);
    },
  );

  _buildAddPhotoWidget() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      TextButton.icon(icon: const Icon(Icons.photo_library),label: const Text('Select Image'),
        onPressed: () {
          _pickImage(ImageSource.gallery);
        },
      ),
      TextButton.icon(icon: const Icon(Icons.camera_alt),label: const Text('Take Photo'),
        onPressed: () {
          _pickImage(ImageSource.camera);
        },
      ),
    ],
  );

  _buildTitleForm() => TextFormField(
    controller: _titleController,
    decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder(), filled: true, hintText: 'Enter title of the item'),
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'Please enter title of the item';
      }
      return null;
    },
  );

  _buildPriceForm() => TextFormField(
    controller: _priceController,
    decoration: const InputDecoration(labelText: 'Price', border: OutlineInputBorder(), filled: true, hintText: 'Enter price'),
    keyboardType: TextInputType.number,
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'Please enter price';
      }
      return null;
    },
  );

  _buildDescForm() => TextFormField(
    controller: _descriptionController,
    maxLines: 3,
    decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder(), filled: true, hintText: 'Enter description of the item'),
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'Please enter description of the item';
      }
      return null;
    },
  );

  Future<void> _pickImage(ImageSource source) async {
    if (source == ImageSource.camera) {
      final cameras = await availableCameras();
      final imagePath = await Navigator.push(context, MaterialPageRoute(builder: (context) => TakePicturePage(cameraDescription: cameras.first,),),);
      if (imagePath != null) {
        setState(() {
          _images.add(File(imagePath));
        });
      }
    } else {
      final resultList = await ImagePicker().pickMultiImage(maxHeight: 960, maxWidth: 960,);
      if (resultList != null) {
        setState(() {
          _images.addAll(resultList.map((xFile) => File(xFile.path)).toList());
        });
      }
    }
  }

  Future<void> postNewItem() async {
    if (_formKey.currentState!.validate() && _images.isNotEmpty) {
      double? price;
      try {
        price = double.parse(_priceController.text);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid price'),),);
        return;
      }

      try {
        final newPost = await FirebaseFirestore.instance.collection('items').add({
          'title': _titleController.text,
          'price': price,
          'description': _descriptionController.text,
          'userId': widget.user.uid,
          'images': [],
        });

        await _uploadImages(newPost.id);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add Success!'),),);
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('An error occurred while submitting the post: $e'),),);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields and add at least one image'),),);
    }

  }

  Future<void> _uploadImages(String postId) async {
    for (var i = 0; i < _images.length; i++) {
      final ref = FirebaseStorage.instance.ref().child('posts/$postId/images/img_$i.jpg');
      await ref.putFile(_images[i]);
      final String imageUrl = await ref.getDownloadURL();
      FirebaseFirestore.instance.doc('items/$postId').update({"images": FieldValue.arrayUnion([imageUrl])});
    }
  }

}