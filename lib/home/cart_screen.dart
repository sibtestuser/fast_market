import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fast_market/model/product.dart';
import 'package:flutter/material.dart';

class CartScreen extends StatefulWidget {
  final String uid;
  const CartScreen({super.key, required this.uid});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  Stream<QuerySnapshot<Map<String, dynamic>>> streamCartItems() {
    return FirebaseFirestore.instance
        .collection('cart')
        .where('uid', isEqualTo: widget.uid)
        .orderBy('timestamp')
        .snapshots();
  }

  int totalPrice = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('장바구니'),
        //  centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                  stream: streamCartItems(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<Cart> items = snapshot.data?.docs.map(
                            (e) {
                              final foo = Cart.fromJson(e.data());

                              return foo.copyWith(cartDocId: e.id);
                            },
                          ).toList() ??
                          [];

                      return ListView.separated(
                        // shrinkWrap: true,
                        separatorBuilder: (context, index) => const Divider(),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final price = (item.product?.isSale ?? false)
                              ? ((item.product!.price!) * ((100 - item.product!.saleRate!) / 100)) * (item.count ?? 1)
                              : item.product!.price! * (item.count ?? 1);
                          totalPrice += price.toInt();
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Row(
                              children: [
                                Container(
                                  height: 120,
                                  width: 120,
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: NetworkImage(item.product!.imgUrl!),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 15.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('${items[index].product?.title}'),
                                            IconButton(
                                              onPressed: () {
                                                FirebaseFirestore.instance
                                                    .collection('cart')
                                                    .doc(item.cartDocId)
                                                    .delete();
                                              },
                                              icon: Icon(Icons.delete),
                                            ),
                                          ],
                                        ),
                                        Text('${price.toStringAsFixed(0)} 원'),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            IconButton(
                                              onPressed: () {
                                                int count = item.count ?? 1;
                                                count--;
                                                if (count <= 1) {
                                                  count = 1;
                                                }
                                                FirebaseFirestore.instance
                                                    .collection('cart')
                                                    .doc('${item.cartDocId}')
                                                    .update({'count': count});
                                              },
                                              icon: Icon(Icons.remove_circle_outline),
                                            ),
                                            Text('${item.count} '),
                                            IconButton(
                                                onPressed: () async {
                                                  // final sameStuff = await FirebaseFirestore.instance
                                                  //     .collection('cart')
                                                  //     .where('uid', isEqualTo: widget.uid)
                                                  //     .where('product.title', isEqualTo: item.product?.title)
                                                  //     .get();

                                                  // final newCount = item.count! + 1;
                                                  // final ref = await FirebaseFirestore.instance
                                                  //     .collection('cart')
                                                  //     .where('uid', isEqualTo: widget.uid)
                                                  //     .where('title', isEqualTo: item.product?.title)
                                                  //     .get();

                                                  // if (ref.docs.isNotEmpty) {
                                                  //   for (var e in ref.docs) {
                                                  //     int newcount = Cart.fromJson(e.data()).count! + 1;
                                                  //     FirebaseFirestore.instance
                                                  //         .collection('cart')
                                                  //         .doc(e.id)
                                                  //         .update({'count': newcount});
                                                  //   }
                                                  // } else {
                                                  //   int count = item.count ?? 1;
                                                  //   count++;

                                                  //   FirebaseFirestore.instance
                                                  //       .collection('cart')
                                                  //       .doc('${item.cartDocId}')
                                                  //       .update({'count': count});
                                                  // }
                                                  int count = item.count ?? 1;
                                                  count++;

                                                  FirebaseFirestore.instance
                                                      .collection('cart')
                                                      .doc('${item.cartDocId}')
                                                      .update({'count': count});
                                                },
                                                icon: Icon(Icons.add_circle_outline)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }
                    return const CircularProgressIndicator();
                  }),
            ),
            const Divider(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '합계',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  StreamBuilder(
                      stream: streamCartItems(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          List<Cart> items = snapshot.data?.docs.map(
                                (e) {
                                  final foo = Cart.fromJson(e.data());
                                  return foo.copyWith(cartDocId: e.id);
                                },
                              ).toList() ??
                              [];
                          double totlaPrice = 0;
                          for (var e in items) {
                            if (e.product?.isSale ?? false) {
                              totlaPrice +=
                                  ((e.product?.price ?? 0) * ((100 - e.product!.saleRate!) / 100) * (e.count ?? 1));
                            } else {
                              totalPrice += (e.product?.price ?? 0) * (e.count ?? 1);
                            }
                          }
                          return Text(
                            '${totlaPrice.toStringAsFixed(0)}',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                          );
                        }
                        return Text('0 원');
                      })
                ],
              ),
            ),
            Container(
              height: 72,
              decoration: BoxDecoration(
                color: Colors.red[100],
              ),
              child: Center(
                child: Text(
                  '배달주문',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
