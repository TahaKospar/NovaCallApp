import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';

import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  Future<void> _initZegoService({
    required String userID,
    required String userName,
  }) async {
    await ZegoUIKitPrebuiltCallInvitationService().init(
      appID: 624326593,
      appSign:
          "061cafbc1e8e09e8afb72e669b57cad3f231b8d0ad97ec073e8fa8858b2389f9",
      userID: userID,
      userName: userName,
      plugins: [ZegoUIKitSignalingPlugin()],
    );
  }

  Future<void> updateOnlineStatus(bool isOnline) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'isOnline': isOnline});
    } catch (_) {}
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());
    String message;
    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      String userId = credential.user!.uid;
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'isOnline': true,
      });

      await _initZegoService(
        userID: userId,
        userName: credential.user!.displayName ?? email.split('@')[0],
      );

      emit(AuthLoaded(credential));
    } on FirebaseAuthException catch (e) {
      if (e.code == "invalid-email" || e.code == "invalid-credential") {
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

      await FirebaseFirestore.instance.collection("users").doc(userId).set({
        "name": name,
        "email": email,
        "uid": userId,
        "photo": "",
        "isOnline": true,
        "blockedUsers": [],
      });

      await FirebaseAuth.instance.currentUser!.sendEmailVerification();

      await _initZegoService(userID: userId, userName: name);

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

  Future<void> logout() async {
    await updateOnlineStatus(false);
    ZegoUIKitPrebuiltCallInvitationService().uninit();
    await FirebaseAuth.instance.signOut();
    emit(AuthInitial());
  }
}