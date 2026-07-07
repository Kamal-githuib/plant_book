import 'dart:io';
import 'package:flutter/material.dart';
import 'package:plant_book/provider/postdata_provider.dart';
import 'package:plant_book/provider/userdata_provider.dart';
import 'package:plant_book/styles/apptheme.dart';
import 'package:provider/provider.dart';

class UploadPostButton extends StatefulWidget {
  final TextEditingController captionController;
  final File? selectedImage;
  final VoidCallback onSuccess;

  const UploadPostButton({
    super.key,
    required this.captionController,
    required this.selectedImage,
    required this.onSuccess,
  });

  @override
  State<UploadPostButton> createState() => _UploadPostButtonState();
}

class _UploadPostButtonState extends State<UploadPostButton> {
  Future<void> _uploadPostData() async {
    final caption = widget.captionController.text.trim();
    final image = widget.selectedImage;

    if (caption.isEmpty || image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields and select an image"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final postsDataProvider = Provider.of<PostsDataProvider>(
      context,
      listen: false,
    );
    final userData = Provider.of<UserDataProvider>(context);
    final username = userData.username;
    await postsDataProvider.uploadPostData(
      caption: caption,
      image: image,
      username: username,
      profileImageUrl: userData.imageUrl,
      context: context,
      onSuccess: widget.onSuccess,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = context.watch<PostsDataProvider>().isSaving;

    return ElevatedButton(
      onPressed: isSaving ? null : () => _uploadPostData(),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.green,
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: isSaving
          ? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                color: AppTheme.lightGray,
                strokeWidth: 2.5,
              ),
            )
          : Text(
              'Upload Post',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.lightGray,
              ),
            ),
    );
  }
}
