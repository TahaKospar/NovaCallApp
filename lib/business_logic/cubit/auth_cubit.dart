import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  Future<void> login({required String email, required String password}) async {
    emit(AuthLoading());
    String message;
    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      
      String userId = credential.user!.uid;
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'isOnline': true,
      });

      emit(AuthLoaded(credential));
    } on FirebaseAuthException catch (e) {
      if (e.code == "invalid-email") {
        message = "Error Data";
      } else if (e.code == "invalid-credential") {
        message = "Error Data";
      } else {
        message = "Error ${e.code}";
      }
      emit(AuthError(message));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> Register({
    required String name,
    required String email,
    required String password,
  }) async {
    String message;
    emit(AuthLoading());
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      String userId = credential.user!.uid;

      // حفظ بيانات اليوزر مع تعيين حالة الـ isOnline بـ true فور التسجيل
      await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .set({
            "name": name,
            "email": email,
            "uid": userId,
            "photo": "",
            "isOnline": true, // <--- ضفناها هنا عشان يتسجل أونلاين من البداية
          });

      await FirebaseAuth.instance.currentUser!.sendEmailVerification();

      emit(AuthLoaded(credential));
    } on FirebaseAuthException catch (e) {
      if (e.code == "email-already-in-use") {
        message = "The Email is already in use Try another Email";
      } else if (e.code == "weak-password") {
        message = "Weak Password";
      } else {
        message = "${e.code}";
      }
      emit(AuthError(message));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}