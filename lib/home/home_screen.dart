import 'package:fast_market/home/%20widget/home_widget.dart';
import 'package:fast_market/home/%20widget/seller_widget.dart';

import 'package:fast_market/home/product_add_screen.dart';
import 'package:fast_market/login/provider/login_provider.dart';
import 'package:fast_market/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _menu_index = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('패캠마트'),
        centerTitle: true,
        actions: [
          if (_menu_index == 0)
            IconButton(
              onPressed: () {},
              icon: const Icon(CupertinoIcons.search),
            ),
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
            icon: const Icon(Icons.logout_outlined),
          ),
        ],
      ),
      body: IndexedStack(
        index: _menu_index,
        children: [
          HomeWidget(),
          SellerWidget(),
        ],
      ),
      floatingActionButton: Consumer(builder: (context, ref, child) {
        final user = ref.watch(userCredentialProvider);
        return switch (_menu_index) {
          0 => FloatingActionButton(
              onPressed: () {
                final uid = user?.uid;
                // Navigator.of(context).push(MaterialPageRoute(builder: (context) => CartScreen(uid: '')));
                if (uid == null) {
                  return;
                }
                context.go('/cart/$uid');
              },
              child: const Icon(Icons.shopping_cart_outlined),
            ),
          1 => FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProductAddScreen()));
              },
              child: const Icon(Icons.add),
            ),
          _ => Container()
        };
      }),
      bottomNavigationBar: NavigationBar(
        height: 70,
        selectedIndex: _menu_index,
        onDestinationSelected: (value) {
          setState(() {
            _menu_index = value;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.store_outlined),
            label: '홈',
          ),
          NavigationDestination(
            icon: Icon(Icons.store_outlined),
            label: '사장님',
          )
        ],
      ),
    );
  }
}
