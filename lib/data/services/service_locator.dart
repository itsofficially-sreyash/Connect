import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect/data/repositories/auth_repository.dart';
import 'package:connect/data/repositories/chat_repository.dart';
import 'package:connect/data/repositories/contact_repository.dart';
import 'package:connect/firebase_options.dart';
import 'package:connect/logic/cubits/auth/auth_cubit.dart';
import 'package:connect/logic/cubits/chat/chat_cubit.dart';
import 'package:connect/router/app_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  getIt.registerLazySingleton(() => AppRouter());
  getIt.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton(() => AuthRepository());
  getIt.registerLazySingleton(() => ContactRepository());
  getIt.registerLazySingleton(() => ChatRepository());
  getIt.registerLazySingleton(
    () => AuthCubit(authRepository: AuthRepository()),
  );

  getIt.registerFactory(
    () => ChatCubit(
      chatRepository: ChatRepository(),
      currentUserId: getIt<FirebaseAuth>().currentUser!.uid,
    ),
  );
}
