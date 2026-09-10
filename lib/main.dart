import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:novacall/presentation/widgets/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(NovaCall(appRouter: AppRouter()));
}

class NovaCall extends StatelessWidget {
  final AppRouter appRouter;
  const NovaCall({super.key, required this.appRouter});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateRoute: appRouter.generateRoute,
    );
  }
}
