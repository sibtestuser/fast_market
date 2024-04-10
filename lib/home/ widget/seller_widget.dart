import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fast_market/model/product.dart';
import 'package:flutter/material.dart';

Future addCategories(String title) async {
  final db = FirebaseFirestore.instance;
  final ref = db.collection('category');
  await ref.add({"title": title});
}

Future<List<Product>> fetchProduct() async {
  final db = FirebaseFirestore.instance;
  final resp = await db.collection('product').orderBy('timestamp').get();
  List<Product> items = [];
  for (var doc in resp.docs) {
    final item = Product.fromJson(doc.data());
    final realItem = item.copyWith(docID: doc.id);
    items.add(item);
  }
  return items;
}

Stream<QuerySnapshot> streamProduct(String query) {
  //StreamSubscription? _keyStream;

  final db = FirebaseFirestore.instance;

  if (query.isNotEmpty) {
    return db.collection('product').orderBy('title').startAt([query]).endAt([query + '\uf8ff']).snapshots();
    // return db.collection('product').where('title', isEqualTo: query).snapshots();
  }
  return db.collection('product').orderBy('timestamp').snapshots();

  //yield* controller.stream;
}

class SellerWidget extends StatefulWidget {
  const SellerWidget({super.key});

  @override
  State<SellerWidget> createState() => _SellerWidgetState();
}

class _SellerWidgetState extends State<SellerWidget> {
  TextEditingController textEditingController = TextEditingController();

  update(Product item) async {
    final db = FirebaseFirestore.instance;
    final ref = db.collection('product').doc(item.docID);
    await ref.update(item.copyWith(title: 'meat', price: 200, stock: 100, isSale: false).toJson());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SearchBar(
            controller: textEditingController,
            leading: Icon(Icons.search),
            onChanged: (string) {
              setState(() {});
            },
            hintText: '상품명 입력',
          ),
          const SizedBox(height: 16),
          ButtonBar(
            children: [
              ElevatedButton(
                onPressed: () async {
                  List<String> categories = ['정육', '과일', '과자', '아이스크림', '유제품', '라면', '생수', '빵/쿠키'];
                  final ref = FirebaseFirestore.instance.collection('category');
                  final tmp = await ref.get();
                  for (var element in tmp.docs) {
                    await element.reference.delete(); //중복 제거
                  }
                  for (var element in categories) {
                    await ref.add({'title': element});
                  }
                },
                child: const Text('카테고리 일괄등록'),
              ),
              ElevatedButton(
                onPressed: () {
                  TextEditingController tec = TextEditingController();
                  showAdaptiveDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        content: TextField(
                          controller: tec,
                        ),
                        actions: [
                          TextButton(
                            onPressed: () async {
                              if (tec.text.isNotEmpty) {
                                await addCategories(tec.text.trim());
                                if (context.mounted) {
                                  Navigator.of(context).pop();
                                }
                              }
                            },
                            child: Text('등록'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('취소'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text('카테고리 등록'),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Text(
              '상품목록',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          Expanded(
            child: StreamBuilder(
                stream: streamProduct(textEditingController.text),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final items = snapshot.data?.docs
                        .map((e) => Product.fromJson(e.data() as Map<String, dynamic>).copyWith(docID: e.id))
                        .toList();
                    return ListView.builder(
                      itemCount: items?.length,
                      itemBuilder: (BuildContext context, int index) {
                        final item = items?[index];
                        return GestureDetector(
                          onTap: () {
                            print(item?.docID);
                          },
                          child: Container(
                            margin: const EdgeInsets.all(10),
                            height: 120,
                            child: Row(
                              children: [
                                Container(
                                  width: 120,
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: NetworkImage(item?.imgUrl ??
                                          'https://www.google.com/imgres?q=%EB%B0%B0%EB%AF%BC%20%ED%85%85%20%EC%9D%B4%EB%AF%B8%EC%A7%80&imgurl=https%3A%2F%2Fimg1.daumcdn.net%2Fthumb%2FC500x500%2F%3Ffname%3Dhttp%3A%2F%2Ft1.daumcdn.net%2Fbrunch%2Fservice%2Fuser%2FdEi4%2Fimage%2FKOcbAT_PYNbu8Llw7E_wULIdkCc.png&imgrefurl=https%3A%2F%2Fbrunch.co.kr%2F%40eunmee910%2F62&docid=4NwdZupRjcWbLM&tbnid=r6ZAJl6G45NTlM&vet=12ahUKEwjz36v147GFAxVOoK8BHdguBlYQM3oECBcQAA..i&w=500&h=500&hcb=2&ved=2ahUKEwjz36v147GFAxVOoK8BHdguBlYQM3oECBcQAA'),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 10.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              item?.title ?? '제품명',
                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                            ),
                                            PopupMenuButton(
                                              itemBuilder: (context) {
                                                return [
                                                  PopupMenuItem(child: Text('리뷰')),
                                                  PopupMenuItem(
                                                    child: Text('수정하기'),
                                                    onTap: () async {
                                                      await update(item!);
                                                    },
                                                  ),
                                                  PopupMenuItem(
                                                    child: Text('삭제'),
                                                    onTap: () async {
                                                      final db = FirebaseFirestore.instance;
                                                      print('doc ID ==');
                                                      print(item?.docID);
                                                      final productCategory = await db
                                                          .collection('product')
                                                          .doc(item?.docID)
                                                          .collection('category')
                                                          .get();
                                                      final foo = productCategory.docs.first;
                                                      final categoriId = foo.data()['docId'];
                                                      final bar = await db
                                                          .collection('category')
                                                          .doc(categoriId)
                                                          .collection('products')
                                                          .where('docID', isEqualTo: item?.docID)
                                                          .get();
                                                      for (var element in bar.docs) {
                                                        element.reference.delete();
                                                      }
                                                      await FirebaseFirestore.instance
                                                          .collection('product')
                                                          .doc(item?.docID)
                                                          .delete();
                                                    },
                                                  ),
                                                ];
                                              },
                                            ),
                                          ],
                                        ),
                                        Text('${item?.price} 원'),
                                        Text(switch (item?.isSale) { true => '할인중', false => '할인없음', _ => '??' }),
                                        Text('재고수량 : ${item?.stock} 개'),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }),
          ),
        ],
      ),
    );
  }
}
