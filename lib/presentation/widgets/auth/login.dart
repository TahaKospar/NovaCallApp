import 'package:firebase_auth/firebase_auth.dart';

late bool isLoading;

class AuthServices {
  static Future<void> login(String email, String password) async {
    
    final creditional = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    await FirebaseAuth.instance.currentUser!.reload();
    isLoading = false;
  }
}
