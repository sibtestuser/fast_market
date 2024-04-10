import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:fast_market/home/%20widget/seller_widget.dart';
import 'package:fast_market/home/product_detail_screen.dart';
import 'package:fast_market/model/category.dart';
import 'package:fast_market/model/product.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  PageController pageController = PageController();
  int bannerIndex = 0;
  //카테고리 목록 가져오기
  Stream<QuerySnapshot<Map<String, dynamic>>> streamCategories() {
    return FirebaseFirestore.instance.collection('category').snapshots();
  }

  Future<List<Product>> fetchSaleProduct() async {
    final dbRef = FirebaseFirestore.instance.collection('product');
    final saleItems = await dbRef.where('isSale', isEqualTo: true).orderBy('saleRate').get();
    List<Product> products = [];
    for (var element in saleItems.docs) {
      final item = Product.fromJson(element.data());
      final copyItem = item.copyWith(docID: element.id);
      products.add(copyItem);
    }
    return products;
  }

  List<Category> categoryItems = [];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            height: 140,
            color: Colors.white,
            margin: EdgeInsets.only(bottom: 8),
            child: PageView(
              controller: pageController,
              children: [
                Container(
                  child: Image.asset('assets/images/fastcampus_logo.png'),
                ),
                Container(
                  child: Image.asset('assets/images/fastcampus_logo.png'),
                ),
                Container(
                  child: Image.asset('assets/images/fastcampus_logo.png'),
                ),
              ],
              onPageChanged: (index) {
                setState(() {
                  bannerIndex = index;
                });
              },
            ),
          ),
          DotsIndicator(
            dotsCount: 3,
            position: bannerIndex,
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            margin: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '카테고리',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('더보기'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                //Todo 카테고리 목록을 받아오는 위젯
                Container(
                  height: 200,
                  child: StreamBuilder<QuerySnapshot<Map>>(
                    stream: streamCategories(),
                    builder: (BuildContext context, snapshot) {
                      if (snapshot.hasData) {
                        categoryItems.clear();
                        final docs = snapshot.data;
                        final docItem = docs?.docs ?? [];

                        docItem.map((e) {
                          categoryItems.add(Category(docId: e.id, title: e.data()['title']));
                        }).toList();

                        return GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
                          itemCount: categoryItems.length,
                          itemBuilder: (context, index) {
                            final item = categoryItems[index];
                            return Column(
                              children: [
                                const CircleAvatar(
                                  radius: 24,
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  item.title ?? '카테고리',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            );
                          },
                        );
                      }
                      return const CircularProgressIndicator();
                    },
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 24),
            padding: const EdgeInsets.only(left: 16, top: 8, bottom: 16),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('오늘의 특가', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    TextButton(
                      onPressed: () {},
                      child: Text('더보기'),
                    )
                  ],
                ),
                Container(
                  height: 240,
                  // color: Colors.orange,
                  child: FutureBuilder(
                      future: fetchProduct(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final items = snapshot.data ?? [];
                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final item = items[index];
                              return GestureDetector(
                                onTap: () {
                                  context.go('/product', extra: item);
                                  // Navigator.of(context).push(
                                  //     MaterialPageRoute(builder: (context) => ProductDetailScreen(product: item)));
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        margin: EdgeInsets.only(right: 15),
                                        width: 160,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
                                          color: Colors.grey,
                                          image: DecorationImage(
                                            fit: BoxFit.cover,
                                            image: NetworkImage(
                                              item.imgUrl ?? '',
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      item.title ?? '',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                    ),
                                    Text(
                                      item.price.toString() + '원',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                    Text(
                                      '${(item.price! - (item.price! * (item.saleRate! / 100))).toStringAsFixed(0)} 원',
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                                    ),
                                  ],
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
          ),
        ],
      ),
    );
  }
}
