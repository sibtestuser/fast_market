import 'package:fast_market/home/cart_screen.dart';
import 'package:fast_market/home/home_screen.dart';
import 'package:fast_market/home/product_detail_screen.dart';
import 'package:fast_market/login/login_screen.dart';
import 'package:fast_market/login/provider/login_provider.dart';
import 'package:fast_market/login/sign_up_screen.dart';
import 'package:fast_market/model/product.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  //final authState = ref.watch(userCredentialProvider);
  return GoRouter(
    initialLocation: '/login',
    //  refreshListenable:  ,
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
    redirect: (context, state) {
      /**
      * Your Redirection Logic Code  Here..........
      */
      final authState = ref.watch(authProvider);
      String? retunUrl = null;
      authState.when(
        data: (user) {
          if (user == null) {
            print('user is not login');
            retunUrl = '/login';
          } else if (state.fullPath == '/login') {
            print('user login');
            retunUrl = '/';
          } else {
            retunUrl = null;
          }
        },
        error: ((error, stackTrace) => print(error)),
        loading: () {
          print('로딩중');
        },
      );

      // if (authState == null) {
      //   return '/login';
      // } else if (state.fullPath == '/login') {
      //   return '/';
      // } else {
      //   return null;
      // }
      return retunUrl;
    },
  );
});
