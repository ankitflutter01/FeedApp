import 'dart:convert';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../untils/app_string.dart';
import 'sign_up_state.dart';

class SignUpCubit extends Cubit<SignUpState> {
  SignUpCubit() : super(SignUpInitial());

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool passwordVisible = false;
  bool confirmPasswordVisible = false;
  String name = '';
  String email = '';
  String password = '';
  String confirmPassword = '';
  File? profileImage;

  void updateData(){
    emit(SignUpUpdate());
  }

  // login user
  Future<void> loginUser(String email, String password) async {
    emit(SignUpLoading());
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      emit(SignUpSuccess(AppStrings.loginSuccessful));
    } catch (e) {
      emit(SignUpFailure(e.toString()));
    }
  }

  // register user
  Future<void> registerUser({
    required String name,
    required String email,
    required String password,
    required File profileImage,
  }) async {
    emit(SignUpLoading());
    try {
      UserCredential userCred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String userId = userCred.user!.uid;


      final bytes = await File(profileImage.path).readAsBytes();
      final base64Image = base64Encode(bytes);

      await _firestore.collection('users').doc(userId).set({
        'userId': userId,
        'name': name,
        'email': email,
        'profilePic': base64Image,
      });

      emit(SignUpSuccess(AppStrings.registrationSuccessful));
    } catch (e) {
      emit(SignUpFailure(e.toString()));
    }
  }
}
