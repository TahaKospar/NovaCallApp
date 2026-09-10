import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:novacall/business_logic/cubit/auth_cubit.dart';
import 'package:novacall/constants/icon/gif.dart';
import 'package:novacall/constants/strings/strings.dart';
import 'package:novacall/presentation/widgets/textField.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  GlobalKey<FormState> formState = GlobalKey();
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();


  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    confirmPassword.dispose();
    super.dispose();
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
                  "Register to NovaCall",
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
                      SizedBox(height: screenSize.height * 0.02),
                      Text("             Name"),
                      SizedBox(height: screenSize.height * 0.01),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Inputtext(
                          hintText: "Enter Name",
                          isPassword: false,
                          myController: name,
                        ),
                      ),
                      SizedBox(height: screenSize.height * 0.02),
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
                      SizedBox(height: screenSize.height * 0.02),
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
                      SizedBox(height: screenSize.height * 0.02),
                      Text("             Confirm Password"),
                      SizedBox(height: screenSize.height * 0.01),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Inputtext(
                          hintText: "Confirm Password",
                          isPassword: true,
                          myController: confirmPassword,
                        ),
                      ),
                      SizedBox(height: screenSize.height * 0.05),

                      BlocConsumer<AuthCubit, AuthState>(
                        listener: (context, state) {
                          if (state is AuthLoaded) {
                            AwesomeDialog(
                              context: context,
                              animType: AnimType.scale,
                              title: "Done",
                              desc: "Check Your Email Message",
                              dialogType: DialogType.success,
                            ).show();
                          } else if (state is AuthError) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(state.errorMessage),
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
                                if (password.text != confirmPassword.text) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Password do not match"),
                                      backgroundColor: Colors.red,
                                      duration: Duration(seconds: 3),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                  return;
                                } else {
                                  if (formState.currentState!.validate()) {
                                    BlocProvider.of<AuthCubit>(
                                      context,
                                    ).Register(
                                      name: name.text.trim(),
                                      email: email.text.trim(),
                                      password: password.text.trim(),
                                    );
                                  }
                                }
                              },
                              child: Text(
                                "Register",
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
                          Text("Have Account? "),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(
                                context,
                                loginScreen,
                              );
                            },
                            child: Text("Login"),
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
