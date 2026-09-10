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
      final creditional = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      emit(AuthLoaded(creditional));
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
      final creditional = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await FirebaseFirestore.instance
          .collection("users")
          .doc(creditional.user!.uid)
          .set({
            "name": name,
            "email": email,
            "uid": creditional.user!.uid,
            "photo": "",
          });

      await FirebaseAuth.instance.currentUser!.sendEmailVerification();

      emit(AuthLoaded(creditional));
    } on FirebaseAuthException catch (e) {
      if (e.code == "email-already-in-use") {
        message = "The Email is arleady in use Try another Email";
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
