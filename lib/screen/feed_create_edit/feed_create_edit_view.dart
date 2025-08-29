import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../untils/app_color.dart';
import '../../untils/app_string.dart';
import '../../untils/common_widget.dart';
import 'feed_create_edit_cubit.dart';
import 'feed_create_edit_state.dart';

class FeedCreateEditScreen extends StatefulWidget {
  final String? feedId;
  final String? existingCaption;
  final String? existingImage;

  const FeedCreateEditScreen({
    super.key,
    this.feedId,
    this.existingCaption,
    this.existingImage,
  });

  @override
  State<FeedCreateEditScreen> createState() => _FeedCreateEditScreenState();
}

class _FeedCreateEditScreenState extends State<FeedCreateEditScreen> {
  final TextEditingController _captionController = TextEditingController();
  String? _base64Image;

  @override
  void initState() {
    super.initState();
    _captionController.text = widget.existingCaption ?? '';
    _base64Image = widget.existingImage;
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.feedId != null;
    return BlocProvider(
      create: (_) => FeedCreateEditCubit(),
      child: Scaffold(
        backgroundColor: AppColors.greyColorShade100,
        appBar: AppBar(
          title:  CommonAppText(text:isEditing ? AppStrings.editFeed : AppStrings.createFeed ,fontWeight: FontWeight.bold,),
          centerTitle: true,
          backgroundColor: AppColors.whiteColorShade,
          foregroundColor: Colors.black87,
          elevation: 0.5,
        ),
        body: BlocConsumer<FeedCreateEditCubit, FeedState>(
          listener: (context, state) {
            if (state is FeedSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content:  CommonAppText(text:state.message,color: AppColors.whiteColorShade,)),
              );
              Navigator.pop(context);
            } else if (state is FeedError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content:  CommonAppText(text:state.error,color: AppColors.whiteColorShade,)),
              );
            } else if (state is FeedImageSelected) {
              setState(() => _base64Image = state.base64Image);
            }
          },
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => _showImagePickerOptions(context),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: AppColors.whiteColorShade,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: _base64Image != null
                              ? Image.memory(
                            base64Decode(_base64Image!),
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                          )
                              : Container(
                            width: double.infinity,
                            height: 200,
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.add_a_photo,
                                    size: 50, color: AppColors.greyColorShade),
                                SizedBox(height: 8),
                                CommonAppText(text:AppStrings.tabToAddImage,
                                    color: AppColors.greyColorShade,
                                    ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.whiteColorShade,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _captionController,
                        decoration: const InputDecoration(
                          labelText: AppStrings.writeYourCaption,
                          border: InputBorder.none,
                        ),
                        maxLines: 6,
                      ),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColorOne,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          final cubit = context.read<FeedCreateEditCubit>();
                          if (isEditing) {
                            cubit.editFeed(
                              feedId: widget.feedId!,
                              caption: _captionController.text.trim(),
                            );
                          } else {
                            cubit.createFeed(
                              caption: _captionController.text.trim(),
                            );
                          }
                        },
                        child:  CommonAppText(text:
                          isEditing ? AppStrings.updateFeed : AppStrings.createFeed,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (state is FeedLoading) ...[
                      const SizedBox(height: 16),
                      const CircularProgressIndicator(),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showImagePickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt, color: AppColors.greenColorShade),
              title: const  CommonAppText(text:AppStrings.takePhoto),
              onTap: () {
                Navigator.pop(ctx);
                context
                    .read<FeedCreateEditCubit>()
                    .pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: AppColors.blueColorShade),
              title: const  CommonAppText(text:AppStrings.chooseFromGallery),
              onTap: () {
                Navigator.pop(ctx);
                context
                    .read<FeedCreateEditCubit>()
                    .pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
}
