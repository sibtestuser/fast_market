import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fast_market/firebase_options.dart';
import 'package:fast_market/home/cart_screen.dart';
import 'package:fast_market/home/product_add_screen.dart';
import 'package:fast_market/home/home_screen.dart';
import 'package:fast_market/home/product_detail_screen.dart';
import 'package:fast_market/login/login_screen.dart';
import 'package:fast_market/login/sign_up_screen.dart';
import 'package:fast_market/model/product.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_storage/firebase_storage.dart';

List<CameraDescription> cameras = [];
UserCredential? userCredential;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  cameras = await availableCameras();

  if (kDebugMode) {
    try {
      await FirebaseAuth.instance.useAuthEmulator('127.0.0.1', 9099);
      FirebaseFirestore.instance.useFirestoreEmulator('127.0.0.1', 8080);
      FirebaseStorage.instance.useStorageEmulator('127.0.0.1', 9199);
    } catch (e) {}
  }
  runApp(ProviderScope(
    child: FastMarket(),
  ));
}

class FastMarket extends StatelessWidget {
  FastMarket({super.key});
  final router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => HomeScreen(),
        routes: [
          GoRoute(
            path: 'cart/:uid',
            builder: (context, state) => CartScreen(uid: state.pathParameters['uid'] ?? ''),
          ),
          GoRoute(
            path: 'product',
            builder: (context, state) {
              return ProductDetailScreen(product: state.extra as Product);
            },
          ),
          GoRoute(
            path: 'product/add',
            builder: (context, state) => ProductDetailScreen(product: state.extra as Product),
          )
        ],
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginScreen(),
      ),
      GoRoute(
        path: '/sign_up',
        builder: (context, state) => SignUpScreen(),
      )
    ],
  );
  // This widget is the root of your application.P
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '패캠마트',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
