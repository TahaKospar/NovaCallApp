import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:novacall/business_logic/contactCubit/contact_cubit.dart';
import 'package:novacall/business_logic/cubit/auth_cubit.dart';
import 'package:novacall/constants/strings/strings.dart';
import 'package:novacall/data/repository/contact_repository.dart';
import 'package:novacall/data/services/contactServices.dart';
import 'package:novacall/presentation/screens/SplashScreen.dart';
import 'package:novacall/presentation/screens/auth/loginScreen.dart';
import 'package:novacall/presentation/screens/auth/registerScreen.dart';
import 'package:novacall/presentation/screens/main/home.dart';

class AppRouter {
  late ContactRepository contactRepository;
  late ContactCubit contactCubit;
  late AuthCubit authCubit;
  AppRouter() {
    contactRepository = ContactRepository(Contactservices());
    contactCubit = ContactCubit(contactRepository);
    authCubit = AuthCubit();
  }
  Route? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splashScreen:
        return MaterialPageRoute(
          builder: (context) => BlocProvider.value(
            value: contactCubit,
            child: const Splashscreen(),
          ),
        );
      case loginScreen:
        return MaterialPageRoute(
          builder: (context) =>
              BlocProvider.value(value: authCubit, child: const LoginScreen()),
        );
      case registerScreen:
        return MaterialPageRoute(
          builder: (context) => BlocProvider.value(
            value: AuthCubit(),
            child: const RegisterScreen(),
          ),
        );
      case home:
        return MaterialPageRoute(
          builder: (context) =>
              BlocProvider.value(value: contactCubit, child: const HomePage()),
        );
      case profile:
        return MaterialPageRoute(
          builder: (context) =>
              BlocProvider.value(value: contactCubit, child: const HomePage()),
        );
      default:
        return MaterialPageRoute(
          builder: (context) => BlocProvider.value(
            value: contactCubit,
            child: Center(
              child: const Text("UnKnown", style: TextStyle(color: Colors.red)),
            ),
          ),
        );
    }
  }
}
