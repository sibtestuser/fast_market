import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fast_market/home/camera_example_page.dart';
import 'package:fast_market/model/category.dart';
import 'package:fast_market/model/product.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class ProductAddScreen extends StatefulWidget {
  const ProductAddScreen({super.key});

  @override
  State<ProductAddScreen> createState() => _ProductAddState();
}

class _ProductAddState extends State<ProductAddScreen> {
  final _formKey = GlobalKey<FormState>();

  bool isSale = false;

  final db = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;
  Uint8List? imageData;
  XFile? image;

  Category? seletedCategory;

  TextEditingController titleTEC = TextEditingController();
  TextEditingController descTEC = TextEditingController();
  TextEditingController priceTEC = TextEditingController();
  TextEditingController stockTEC = TextEditingController();
  TextEditingController salePercentTEC = TextEditingController();
  List<Category> categoryItems = [];

  Future<List<Category>> _fetchCategories() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    final resp = await db.collection('category').get();
    for (var doc in resp.docs) {
      categoryItems.add(Category.fromJson(doc.data()).copyWith(docId: doc.id));
    }
    setState(() {
      if (categoryItems.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('카테고리를 먼저 추가')));
        return;
      }
      seletedCategory = categoryItems.first;
    });
    return categoryItems;
  }

  Future<Uint8List> imageCompressList(Uint8List list) async {
    var result = await FlutterImageCompress.compressWithList(list, quality: 50);
    return result;
  }

  Future<void> addMultiProducts() async {
    if (imageData != null && _formKey.currentState!.validate()) {
      final storegeRef = storage.ref().child('${DateTime.now().millisecondsSinceEpoch}_${image?.name ?? '??'}.jpg');
      try {
        final compressedData = await imageCompressList(imageData!);
        await storegeRef.putData(compressedData);
        final downloadLink = await storegeRef.getDownloadURL();
        for (int i = 0; i < 5; i++) {
          final sampleData = Product(
            title: titleTEC.text + i.toString(),
            description: descTEC.text,
            price: int.parse(priceTEC.text),
            stock: int.parse(stockTEC.text),
            saleRate: salePercentTEC.text.isNotEmpty ? double.parse(salePercentTEC.text) : 0,
            isSale: isSale,
            imgUrl: downloadLink,
            timestamp: DateTime.now().millisecondsSinceEpoch,
          );
          final doc = await db.collection('product').add(sampleData.toJson());
          doc.update({'docID': doc.id});
          await doc.collection('category').add(seletedCategory?.toJson() ?? {});
          final categoRef = db.collection('category').doc(seletedCategory?.docId);
          await categoRef.collection('products').add({'docID': doc.id});
        }

        context.pop();
      } catch (e) {
        print(e.toString());
      }
    }
  }

  Future<void> addProducts() async {
    if (imageData != null && _formKey.currentState!.validate()) {
      final storegeRef = storage.ref().child('${DateTime.now().millisecondsSinceEpoch}_${image?.name ?? '??'}.jpg');
      try {
        final compressedData = await imageCompressList(imageData!);
        await storegeRef.putData(compressedData);
        final downloadLink = await storegeRef.getDownloadURL();
        final sampleData = Product(
          title: titleTEC.text,
          description: descTEC.text,
          price: int.parse(priceTEC.text),
          stock: int.parse(stockTEC.text),
          saleRate: salePercentTEC.text.isNotEmpty ? double.parse(salePercentTEC.text) : 0,
          isSale: isSale,
          imgUrl: downloadLink,
          timestamp: DateTime.now().millisecondsSinceEpoch,
        );
        final doc = await db.collection('product').add(sampleData.toJson());
        doc.update({'docID': doc.id});
        await doc.collection('category').add(seletedCategory?.toJson() ?? {});
        final categoRef = db.collection('category').doc(seletedCategory?.docId);
        await categoRef.collection('products').add({'docID': doc.id});
        context.pop();
      } catch (e) {
        print(e.toString());
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '상품 추가',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const CameraExamplePage()));
            },
            icon: const Icon(Icons.camera_alt_outlined),
          ),
          IconButton(
            onPressed: () async {
              await addMultiProducts();
            },
            icon: const Icon(Icons.batch_prediction),
          ),
          IconButton(
            onPressed: () {
              addProducts();
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () async {
                  final ImagePicker picker = ImagePicker();
                  image = await picker.pickImage(source: ImageSource.gallery);
                  imageData = await image?.readAsBytes();
                  setState(() {});
                },
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    // alignment: Alignment.center,
                    height: 240,
                    width: 240,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: imageData == null
                        ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add),
                              Text('제품(상품) 이미지 추가'),
                            ],
                          )
                        : Image.memory(
                            imageData!,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  '기본정보',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: titleTEC,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: '상품명',
                        hintText: '제품명을 입력하세요',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '필수 입력 항목입니다';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    TextFormField(
                      controller: descTEC,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: '상품설명',
                      ),
                      maxLength: 254,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '필수 입력 항목입니다';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: priceTEC,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: '가격(단가)',
                        hintText: '1개 가격 입력',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '필수 입력 항목입니다';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: stockTEC,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: '수량',
                        hintText: '입고 및 재고 수량',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '필수 입력 항목입니다';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile.adaptive(
                      value: isSale,
                      onChanged: (value) {
                        setState(() {
                          isSale = value;
                        });
                      },
                      title: const Text('할인여부'),
                    ),
                    if (isSale)
                      TextFormField(
                        controller: salePercentTEC,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: '할인율',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          return null;
                        },
                      ),
                    const SizedBox(height: 16),
                    const Text(
                      '카테고리 선택',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    categoryItems.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 80.0),
                            child: DropdownButton(
                              value: seletedCategory,
                              items: categoryItems
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e.title!),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (object) {
                                setState(() {
                                  seletedCategory = object;
                                });
                              },
                              isExpanded: true,
                            ),
                          )
                        : const Center(
                            child: CircularProgressIndicator(),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
