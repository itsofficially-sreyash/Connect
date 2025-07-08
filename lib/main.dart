import 'package:connect/config/theme/app_theme.dart';
import 'package:connect/data/repositories/chat_repository.dart';
import 'package:connect/data/services/service_locator.dart';
import 'package:connect/firebase_options.dart';
import 'package:connect/logic/cubits/auth/auth_cubit.dart';
import 'package:connect/logic/cubits/auth/auth_state.dart';
import 'package:connect/logic/observer/app_life_cycle_observer.dart';
import 'package:connect/presentation/screens/auth/login_screen.dart';
import 'package:connect/presentation/screens/home_screen.dart';
import 'package:connect/router/app_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  await setupServiceLocator();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  late AppLifeCycleObserver _lifeCycleObserver;

  @override
  void initState() {
    getIt<AuthCubit>().stream.listen((state) {
      if (state.status == AuthStatus.authenticated && state.user != null){
        _lifeCycleObserver = AppLifeCycleObserver(userId: state.user!.uid, chatRepository: getIt<ChatRepository>());
      }
      WidgetsBinding.instance.addObserver(_lifeCycleObserver);
    });
    super.initState();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: MaterialApp(
        navigatorKey: getIt<AppRouter>().navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'Connect Us',
        theme: AppTheme.lightTheme,
        home: BlocBuilder<AuthCubit, AuthState>(
            bloc: getIt<AuthCubit>(),
            builder: (context, state) {
              if (state.status == AuthStatus.initial){
                return Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              } if (state.status == AuthStatus.authenticated){
                return HomeScreen();
              }
              return LoginScreen();
            }),
      ),
    );
  }
}


//base repository
//getit
//cubit
