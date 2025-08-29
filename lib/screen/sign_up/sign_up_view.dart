import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:practical_task/screen/home/home_screen.dart';
import 'package:practical_task/screen/sign_up/sign_up_cubit.dart';
import 'package:practical_task/screen/sign_up/sign_up_state.dart';
import 'package:practical_task/untils/common_widget.dart';

import '../../untils/app_color.dart' show AppColors;
import '../../untils/app_string.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  bool isLogin = true;
  String name = '';
  String email = '';
  String password = '';
  String confirmPassword = '';
  File? profileImage;

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt, color: AppColors.greenColorShade),
                title: const CommonAppText(text: AppStrings.takePhoto),
                onTap: () async {
                  final picked = await ImagePicker().pickImage(
                    source: ImageSource.camera,
                  );
                  if (picked != null) {
                    setState(() => profileImage = File(picked.path));
                  }
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: AppColors.blueColorShade),
                title: const CommonAppText(text: AppStrings.chooseFromGallery),
                onTap: () async {
                  final picked = await ImagePicker().pickImage(
                    source: ImageSource.gallery,
                  );
                  if (picked != null) {
                    setState(() => profileImage = File(picked.path));
                  }
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (!isLogin) {
      if (profileImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: CommonAppText(text: AppStrings.selectProfilePicture,color: AppColors.whiteColorShade,),
          ),
        );
        return;
      }
      if (password != confirmPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: CommonAppText(text: AppStrings.passwordsDoNotMatch,color: AppColors.whiteColorShade,),
          ),
        );
        return;
      }
    }

    final cubit = context.read<SignUpCubit>();
    if (isLogin) {
      cubit.loginUser(email, password);
    } else {
      cubit.registerUser(
        name: name,
        email: email,
        password: password,
        profileImage: profileImage!,
      );
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: AppColors.amberColor),
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      hintText: label,
      hintStyle: const TextStyle(color: Colors.white54),
      errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      filled: true,
      fillColor: Colors.white.withOpacity(0.1),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.amberColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SignUpCubit(),
      child: Scaffold(
        body: Container(
          height: MediaQuery.sizeOf(context).height,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.primaryColorOne, AppColors.blackColorShade],
            ),
          ),
          child: SafeArea(
            child: BlocConsumer<SignUpCubit, SignUpState>(
              listener: (context, state) {
                if (state is SignUpSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: CommonAppText(text: state.message,color: AppColors.whiteColorShade,)),
                  );
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                    (Route<dynamic> route) => false,
                  );
                } else if (state is SignUpFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: CommonAppText(text: state.error,color: AppColors.whiteColorShade,)),
                  );
                }
              },
              builder: (context, state) {
                final signUpCubit = BlocProvider.of<SignUpCubit>(context);
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 30,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 30),
                        CommonAppText(
                          text:
                              isLogin
                                  ? AppStrings.welcomeBack
                                  : AppStrings.createAccount,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppColors.whiteColorShade,
                          maxLine: 1,
                          textAlignment: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        CommonAppText(
                          text:
                              isLogin
                                  ? AppStrings.loginToContinue
                                  : AppStrings.signUpToGetStarted,
                          fontSize: 16,
                          color: Colors.white70,
                          maxLine: 2,
                          textAlignment: TextAlign.center,
                        ),
                        const SizedBox(height: 30),
                        if (!isLogin)
                          GestureDetector(
                            onTap: _pickImage,
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.white24,
                              backgroundImage:
                                  profileImage != null
                                      ? FileImage(profileImage!)
                                      : null,
                              child:
                                  profileImage == null
                                      ? const Icon(
                                        Icons.add_a_photo,
                                        size: 40,
                                        color: AppColors.whiteColorShade,
                                      )
                                      : null,
                            ),
                          ),
                        const SizedBox(height: 20),
                        Column(
                          children: [
                            if (!isLogin)
                              TextFormField(
                                decoration: _inputDecoration(
                                  AppStrings.name,
                                  Icons.person,
                                ),
                                onSaved: (val) => name = val!,
                                validator:
                                    (val) =>
                                        val!.isEmpty
                                            ? AppStrings.enterYourName
                                            : null,
                              ),
                            if (!isLogin) const SizedBox(height: 15),
                            TextFormField(
                              decoration: _inputDecoration(
                                AppStrings.email,
                                Icons.email,
                              ),
                              keyboardType: TextInputType.emailAddress,
                              onSaved: (val) => email = val!,
                              validator:
                                  (val) =>
                                      val!.contains('@')
                                          ? null
                                          : AppStrings.enterValidEmail,
                            ),
                            const SizedBox(height: 15),
                            TextFormField(
                              decoration: _inputDecoration(
                                AppStrings.password,
                                Icons.lock,
                              ).copyWith(
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    signUpCubit.passwordVisible ? Icons
                                        .visibility : Icons.visibility_off,
                                    color: AppColors.amberColor,
                                  ),
                                  onPressed: () {
                                      signUpCubit.passwordVisible =
                                      !signUpCubit.passwordVisible;
                                      signUpCubit.updateData();
                                  },
                                ),
                              ),
                              obscureText: !signUpCubit
                                  .passwordVisible,
                              onSaved: (val) => password = val!,
                              validator:
                                  (val) =>
                                      val!.length < 6
                                          ? AppStrings.passwordTooShort
                                          : null,
                            ),
                            if (!isLogin) const SizedBox(height: 15),
                            if (!isLogin)
                              TextFormField(
                                decoration: _inputDecoration(
                                  AppStrings.confirmPassword,
                                  Icons.lock_outline,
                                ).copyWith(
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      signUpCubit.confirmPasswordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: AppColors.amberColor,
                                    ),
                                    onPressed: () {
                                      signUpCubit.confirmPasswordVisible =
                                      !signUpCubit.confirmPasswordVisible;
                                      signUpCubit.updateData();
                                    },
                                  ),
                                ),
                                obscureText: !signUpCubit
                                    .confirmPasswordVisible,
                                onSaved: (val) => confirmPassword = val!,
                                validator:
                                    (val) =>
                                val!.length < 6
                                    ? AppStrings.passwordTooShort
                                    : null,
                              ),
                            const SizedBox(height: 25),
                            state is SignUpLoading
                                ? const CircularProgressIndicator(
                                  color: AppColors.whiteColorShade,
                                )
                                : ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.whiteColorShade,
                                    foregroundColor: Colors.black87,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 15,
                                      horizontal: 80,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () => _submit(context),
                                  child: CommonAppText(
                                    text:
                                        isLogin
                                            ? AppStrings.login
                                            : AppStrings.signUp,
                                  ),
                                ),
                            const SizedBox(height: 15),
                            TextButton(
                              onPressed:
                                  () => setState(() => isLogin = !isLogin),
                              child: CommonAppText(
                                text:
                                    isLogin
                                        ? AppStrings.createNewAccount
                                        : AppStrings.alreadyHaveAccount,
                                color: AppColors.whiteColorShade,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
