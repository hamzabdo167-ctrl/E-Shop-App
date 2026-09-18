import 'package:final_project/firebase_options.dart';
import 'package:final_project/screens/login_screen.dart';
import 'package:final_project/screens/main_screen.dart';
import 'package:final_project/screens/splash_screen.dart';
import 'package:final_project/services/api_services.dart';
import 'package:final_project/services/cart_cubit.dart';
import 'package:final_project/services/favorites_cubit.dart';
import 'package:final_project/services/products_cubit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<ProductsCubit>(
              create: (context) => ProductsCubit(ApiService())..getProducts(),
            ),
            BlocProvider<CartCubit>(create: (context) => CartCubit()),
            BlocProvider<FavoritesCubit>(create: (context) => FavoritesCubit()),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            initialRoute: '/',
            routes: {
              '/': (context) => const SplashScreen(),
              '/authCheck': (context) => const AuthWrapper(),
              '/main': (context) => const MainScreen(),
              '/login': (context) => const LoginScreen(),
            },
          ),
        );
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return const MainScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
