import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:novacall/business_logic/cubit/auth_cubit.dart';
import 'package:novacall/constants/icon/gif.dart';
import 'package:novacall/constants/strings/strings.dart';

import 'package:novacall/presentation/widgets/textField.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  GlobalKey<FormState> formState = GlobalKey();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Widget forgetPassword(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: TextButton(
        onPressed: () async {
          if (email.text == "") {
            AwesomeDialog(
              context: context,
              animType: AnimType.leftSlide,
              dialogType: DialogType.error,
              title: "Email is Empty",
              desc: "Please Enter Email First",
              btnOkOnPress: () {},
            ).show();
            return;
          }
          try {
            await FirebaseAuth.instance.sendPasswordResetEmail(
              email: email.text,
            );
            if (!mounted) return;
            AwesomeDialog(
              context: context,
              animType: AnimType.leftSlide,
              dialogType: DialogType.info,
              title: "Reset password is Send",
              desc: "Check Your Account Reset password is Send",
              btnOkOnPress: () {},
            ).show();
          } on FirebaseAuthException catch (e) {
            if (e.code ==
                "firebase_auth/network-request-failed] A network error (such as timeout, interrupted connection or unreachable host) has occurred") {
              AwesomeDialog(
                context: context,
                animType: AnimType.leftSlide,
                dialogType: DialogType.error,
                title: "No internet",
                desc: "Please Check Your Internet Connection",
                btnOkOnPress: () {},
              ).show();
            }
          } catch (e) {
            print("======================================");
            print(e);
          }
        },
        child: Text("Forget Password"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        width: screenSize.width,
        height: screenSize.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 45, 95, 185),
              Color.fromARGB(255, 70, 117, 204),
              Color.fromARGB(255, 100, 145, 230),
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              children: [
                SizedBox(height: screenSize.width * 0.3),
                Text(
                  "Login to NovaCall",
                  style: TextStyle(
                    fontSize: screenSize.width * 0.07,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.9),
                        offset: const Offset(0, 9),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenSize.width * 0.09),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: screenSize.width * 0.35,
                    height: screenSize.width * 0.35,
                    child: gif(),
                  ),
                ),
                Form(
                  key: formState,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(height: screenSize.height * 0.03),
                      Text("             Email"),
                      SizedBox(height: screenSize.height * 0.01),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Inputtext(
                          hintText: "Enter Email",
                          isPassword: false,
                          myController: email,
                        ),
                      ),
                      SizedBox(height: screenSize.height * 0.03),
                      Text("             Password"),
                      SizedBox(height: screenSize.height * 0.01),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Inputtext(
                          hintText: "Enter Password",
                          isPassword: true,
                          myController: password,
                        ),
                      ),
                      forgetPassword(context),
                      SizedBox(height: screenSize.height * 0.1),
                      BlocConsumer<AuthCubit, AuthState>(
                        listener: (context, state) {
                          if (state is AuthLoaded) {
                            if (FirebaseAuth
                                .instance
                                .currentUser!
                                .emailVerified) {
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                home,
                                (route) => false,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Welcome back"),
                                  backgroundColor: Colors.grey,
                                  duration: Duration(seconds: 2),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            } else {
                              AwesomeDialog(
                                context: context,
                                animType: AnimType.rightSlide,
                                dialogType: DialogType.error,
                                title: "Email Not Verified",
                                btnOkOnPress: () {},
                                desc: "please Verify from your account first",
                              ).show();
                            }
                          } else if (state is AuthError) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  state.errorMessage,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.redAccent,
                                duration: Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                        builder: (context, state) {
                          if (state is AuthLoading) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            );
                          }

                          return Center(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                fixedSize: Size(150, 20),
                                backgroundColor: Color.fromARGB(
                                  255,
                                  45,
                                  95,
                                  185,
                                ),
                              ),
                              onPressed: () {
                                if (formState.currentState!.validate()) {
                                  BlocProvider.of<AuthCubit>(context).login(
                                    email: email.text.trim(),
                                    password: password.text.trim(),
                                  );
                                }
                              },
                              child: Text(
                                "Login",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          );
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text("Create Account? "),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(
                                context,
                                registerScreen,
                              );
                            },
                            child: Text("Register"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
