import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shimmer/shimmer.dart';
import '../../untils/app_color.dart';
import '../../untils/app_string.dart';
import '../../untils/common_widget.dart';
import '../sign_up/sign_up_view.dart';

class ProfilePage extends StatelessWidget {
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  ProfilePage({super.key});

  Future<Map<String, dynamic>?> _getUserData() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint("Error fetching user data: $e");
      return null;
    }
  }

  Widget _buildProfileMenu({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.black54),
      title: CommonAppText(text:title,fontSize: 16),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.greyColorShade),
      onTap: onTap,
    );
  }

  Widget _buildShimmerProfile(Size size) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: size.width * 0.8,
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.whiteColorShade,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    height: 20,
                    width: 120,
                    color: AppColors.whiteColorShade,
                  ),
                ),
                const SizedBox(height: 6),
                Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    height: 16,
                    width: 180,
                    color: AppColors.whiteColorShade,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.whiteColorShade,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.greyColorShade100,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColorShade,
        elevation: 0,
        title: CommonAppText(
          text: AppStrings.profileTitle,
          color: AppColors.blackColorShade2,
          fontWeight: FontWeight.bold,
          // fontSize: 20,
          maxLine: 1,
          textAlignment: TextAlign.start,
        ),

        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.blackColorShade2),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildShimmerProfile(size);
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child:  CommonAppText(text:AppStrings.noUserData));
          }

          final userData = snapshot.data!;
          final profilePic = userData['profilePic'] ?? '';
          final name = userData['name'] ?? AppStrings.defaultUserName;
          final email = userData['email'] ?? AppStrings.noEmail;

          final base64Image = profilePic;
          ImageProvider profileImage;

          if (base64Image.isNotEmpty) {
            final base64Str = base64Image.split(',').last;
            final bytes = base64Decode(base64Str);
            profileImage = MemoryImage(bytes);
          } else {
            profileImage = const AssetImage('assets/default_avatar.png');
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  width: size.width * 0.8,
                  padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                  decoration: BoxDecoration(
                    color: AppColors.whiteColorShade,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: profilePic.isNotEmpty ? profileImage : null,
                        child: profilePic.isEmpty
                            ? const Icon(Icons.person, size: 50, color: AppColors.greyColorShade)
                            : null,
                      ),
                      const SizedBox(height: 16),
                      CommonAppText(
                        text: name,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        maxLine: 1,
                        textAlignment: TextAlign.start,
                      ),
                      const SizedBox(height: 6),
                      CommonAppText(
                        text: email,
                        fontSize: 16,
                        color: Colors.grey[600],
                        maxLine: 1,
                        textAlignment: TextAlign.start,
                      ),

                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.whiteColorShade,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildProfileMenu(
                        icon: Icons.edit,
                        title: AppStrings.editProfile,
                        onTap: () {
                          commonToast("This feature are underdevelopment");
                        },
                      ),
                      const Divider(height: 1),
                      _buildProfileMenu(
                        icon: Icons.logout,
                        title: AppStrings.logout,
                        color: Colors.redAccent,
                        onTap: () async {
                          final shouldLogout = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const  CommonAppText(text:AppStrings.confirmLogout),
                              content: const  CommonAppText(text:AppStrings.logoutMessage),
                              actions: [
                                ElevatedButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const  CommonAppText(text:AppStrings.no),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, true),
                                  child: const  CommonAppText(text:AppStrings.yes),
                                ),
                              ],
                            ),
                          );

                          if (shouldLogout == true) {
                            await FirebaseAuth.instance.signOut();
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) => SignUpPage()),
                                  (Route<dynamic> route) => false,
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
