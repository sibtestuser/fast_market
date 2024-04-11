import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fast_market/login/provider/login_provider.dart';
import 'package:fast_market/main.dart';
import 'package:fast_market/model/product.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.title!),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(15),
                      height: 320,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        image: DecorationImage(
                            image: NetworkImage(
                              widget.product.imgUrl!,
                            ),
                            fit: BoxFit.cover),
                      ),
                      child: Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            switch (widget.product.isSale!) {
                              true => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                                  decoration: const BoxDecoration(color: Colors.red),
                                  child: const Text(
                                    '할인중',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              _ => Container()
                            }
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(widget.product.title!,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                              PopupMenuButton(
                                icon: const Icon(Icons.menu),
                                itemBuilder: (context) {
                                  return [
                                    PopupMenuItem(
                                      child: const Text('리뷰등록'),
                                      onTap: () {
                                        int reviewScore = 0;
                                        showDialog(
                                          barrierDismissible: false,
                                          context: context,
                                          builder: (context) {
                                            TextEditingController reviewTEC = TextEditingController();
                                            return StatefulBuilder(builder: (context, setState) {
                                              return AlertDialog(
                                                title: Text('리뷰등록'),
                                                content: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    TextField(
                                                      controller: reviewTEC,
                                                    ),
                                                    Row(
                                                      children: List.generate(
                                                        5,
                                                        (index) => IconButton(
                                                          onPressed: () {
                                                            setState(() {
                                                              reviewScore = index;
                                                            });
                                                          },
                                                          icon: Icon(
                                                            Icons.star,
                                                            color: index <= reviewScore ? Colors.orange : Colors.grey,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context).pop();
                                                    },
                                                    child: Text('취소'),
                                                  ),
                                                  Consumer(builder: (context, ref, child) {
                                                    final user = ref.read(userCredentialProvider);
                                                    return TextButton(
                                                      onPressed: () async {
                                                        if (reviewTEC.text.isNotEmpty)
                                                          await FirebaseFirestore.instance
                                                              .collection('product')
                                                              .doc('${widget.product.docID}')
                                                              .collection('reviews')
                                                              .add(
                                                            {
                                                              'uid': user?.uid ?? '',
                                                              'email': user?.email ?? '',
                                                              'review': reviewTEC.text.trim(),
                                                              'timestamp': Timestamp.now(),
                                                              'score': reviewScore + 1,
                                                            },
                                                          );
                                                        if (context.mounted) Navigator.of(context).pop();
                                                      },
                                                      child: Text('리뷰등록'),
                                                    );
                                                  }),
                                                ],
                                              );
                                            });
                                          },
                                        );
                                      },
                                    ),
                                    PopupMenuItem(child: Text('리뷰등록')),
                                  ];
                                },
                              )
                            ],
                          ),
                          const Text('제품 상세 정보'),
                          Text(widget.product.description!),
                          Row(
                            children: [
                              Text(
                                widget.product.price.toString(),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const Spacer(),
                              const Icon(
                                Icons.star,
                                color: Colors.orange,
                              ),
                              const Text('4.5'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    DefaultTabController(
                      length: 2,
                      child: Column(
                        children: [
                          const TabBar(tabs: [
                            Tab(
                              text: '제품상세',
                            ),
                            Tab(
                              text: '리뷰',
                            ),
                          ]),
                          SizedBox(
                            height: 500,
                            child: TabBarView(
                              children: [
                                Container(child: Text('제품 상세')),
                                StreamBuilder(
                                    stream: FirebaseFirestore.instance
                                        .collection('product')
                                        .doc('${widget.product.docID}')
                                        .collection('reviews')
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        final items = snapshot.data?.docs ?? [];
                                        return ListView.separated(
                                            itemBuilder: ((context, index) {
                                              return ListTile(
                                                title: Text(
                                                  '${items[index].data()['review']}',
                                                ),
                                              );
                                            }),
                                            separatorBuilder: (context, index) {
                                              return Divider();
                                            },
                                            itemCount: items.length);
                                      } else {
                                        return Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }
                                    }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () async {
                final db = FirebaseFirestore.instance;
                final dupItem = await db
                    .collection('cart')
                    .where('uid', isEqualTo: userCredential?.user?.uid ?? '')
                    .where('product.docId', isEqualTo: widget.product.docID)
                    .get();
                if (dupItem.docs.isNotEmpty) {
                  if (context.mounted) {
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              content: Text('이미 장바구니에 등록되어 있습니다.'),
                            ));
                  }
                  return;
                }
                //장바구니에 추가
                await db.collection('cart').add({
                  'uid': userCredential?.user?.uid ?? '',
                  'email': userCredential?.user?.email ?? '',
                  'timestamp': DateTime.now().millisecondsSinceEpoch,
                  'product': widget.product.toJson(),
                  'count': 1
                });
                if (context.mounted) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        content: Text('장바구니에 ${widget.product.title} 이 추가되었습니다'),
                      );
                    },
                  );
                }
              },
              child: Container(
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.red[100],
                ),
                child: const Center(
                  child: Text(
                    '장바구니',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
