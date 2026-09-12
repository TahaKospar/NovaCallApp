import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

import 'package:novacall/business_logic/ThemeCubit.dart';
import 'package:novacall/business_logic/callHistoryCubit/call_history_cubit.dart';
import 'package:novacall/business_logic/contactCubit/contact_cubit.dart';
import 'package:novacall/business_logic/cubit/auth_cubit.dart';
import 'package:novacall/constants/strings/strings.dart';
import 'package:novacall/data/repository/contact_repository.dart';
import 'package:novacall/data/services/call_history_service.dart';
import 'package:novacall/data/services/contactServices.dart';
import 'package:novacall/presentation/screens/SplashScreen.dart';
import 'package:novacall/presentation/screens/auth/loginScreen.dart';
import 'package:novacall/presentation/screens/auth/registerScreen.dart';
import 'package:novacall/presentation/screens/main/home.dart';

const int zegoAppID = 624326593;
const String zegoAppSign =
    "061cafbc1e8e09e8afb72e669b57cad3f231b8d0ad97ec073e8fa8858b2389f9";

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await _requestAppPermissions();

  ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(navigatorKey);

  runApp(const MyApp());
}

Future<void> _requestAppPermissions() async {
  final permissions = [
    Permission.microphone,
    Permission.camera,
    Permission.notification,
  ];
  await permissions.request();
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _updateOnlineStatus(false);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      _updateOnlineStatus(true);
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _updateOnlineStatus(false);
    }
  }

  Future<void> _updateOnlineStatus(bool isOnline) async {
    try {
      final authCubit = context.read<AuthCubit>();
      await authCubit.updateOnlineStatus(isOnline);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final contactRepository = ContactRepository(Contactservices());

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: AuthCubit()),
        BlocProvider<ContactCubit>.value(
          value: ContactCubit(contactRepository),
        ),
        BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),
        BlocProvider<CallHistoryCubit>(create: (_) => CallHistoryCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'NovaCall',
            debugShowCheckedModeBanner: false,
            navigatorKey: navigatorKey,
            theme: ThemeData(
              brightness: Brightness.light,
              primarySwatch: Colors.blue,
              scaffoldBackgroundColor: Colors.white,
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              primarySwatch: Colors.blue,
              scaffoldBackgroundColor: Colors.black,
            ),
            themeMode: themeMode,
            initialRoute: splashScreen,
            routes: {
              splashScreen: (_) => const Splashscreen(),
              loginScreen: (_) => const LoginScreen(),
              registerScreen: (_) => const RegisterScreen(),
              home: (_) => const HomePage(),
            },
          );
        },
      ),
    );
  }
}

Future<void> initZegoService({
  required String userID,
  required String userName,
}) async {
  await ZegoUIKitPrebuiltCallInvitationService().init(
    appID: zegoAppID,
    appSign: zegoAppSign,
    userID: userID,
    userName: userName,
    plugins: [ZegoUIKitSignalingPlugin()],
    requireConfig: (ZegoCallInvitationData data) {
      final config = data.type == ZegoCallInvitationType.videoCall
          ? ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
          : ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall();

      config.duration.isVisible = true;
      config.audioVideoView.showUserNameOnView = true;
      config.audioVideoView.showMicrophoneStateOnView = true;
      config.topMenuBar.isVisible = true;

      return config;
    },
    invitationEvents: ZegoUIKitPrebuiltCallInvitationEvents(
      onInvitationUserStateChanged: (callUserList) {
        debugPrint('🔵 Invitation state changed: $callUserList');

        final service = CallHistoryService();
        service.updateLatestCallDuration();
      },
    ),
  );
}