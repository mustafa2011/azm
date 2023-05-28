import '../db/fatoora_db.dart';
import '../models/product.dart';
import '../models/settings.dart';
import '../screens/products_page.dart';
import '../widgets/app_colors.dart';
import '../widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

import 'edit_product_page.dart';

const C = 'ريال';

class ProductDetailPage extends StatefulWidget {
  final int productId;

  const ProductDetailPage({
    Key? key,
    required this.productId,
  }) : super(key: key);

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final f = NumberFormat("#,##0.00 $C", "ar_SA");
  late Product product;
  int? id;
  String? productName;
  String? barcode;
  num? price;
  String imgUrl = '';
  bool isLoading = false;
  int workOffline = 1;

  @override
  void initState() {
    super.initState();
    refreshProduct();
  }

  void messageBox(String? message) {

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('رسالة'),
          content: Text(message!),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            TextButton(
              child: const Text("نعم"),
              onPressed: () async {
                // setState(() =>isLoading = true);
                // await SheetApi.deleteProductById(widget.productId);
                await FatooraDB.instance.deleteProduct(product);
                int? count = await FatooraDB.instance.getProductsCount();
                if(count==0){
                  await FatooraDB.instance.deleteProductSequence();
                }
                // print(widget.productId);
                // setState(() =>isLoading = false);
                Get.to(()=>const ProductsPage());
              },
            ),
            TextButton(
              child: const Text("لا"),
              onPressed: () {
                Get.back();
              },
            ),
          ],
        );
      },
    );
  }

  Future refreshProduct() async {
    setState(() => isLoading = true);

    List<Setting> setting;
    setting = await FatooraDB.instance.getAllSettings();
    if(setting.isNotEmpty){
      setState(() {
        workOffline = setting[0].workOffline;
      });
    }

    if (workOffline==1) {
      product = await FatooraDB.instance.getProductById(widget.productId);
    }
    id = product.id;
    productName = product.productName;
    barcode = product.barcode;
    price = product.price;

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          foregroundColor: AppColor.primary,
          title: Text(
            'صفحة المنتج رقم $id',
            style: const TextStyle(
              color: AppColor.primary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [editButton(), deleteButton()],
        ),
        body: Container(
                color: AppColor.background,
                padding: const EdgeInsets.all(12),
                child: isLoading
                    ? const Center(child: Loading(),)
                    : ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    Row(
                      children: [
                        const Text(
                          "رقم المنتج",
                          style: TextStyle(
                            color: AppColor.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Text(
                          id.toString(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(thickness: 2),
                    Row(
                      children: [
                        const Text(
                          "كود المنتج",
                          style: TextStyle(
                            color: AppColor.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Text(
                            barcode.toString(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(thickness: 2),
                    Row(
                      children: [
                        const Text(
                          "اسم المنتج",
                          style: TextStyle(
                            color: AppColor.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Text(
                            productName.toString(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(thickness: 2),
                    Row(
                      children: [
                        const Text(
                          "سعر المنتج",
                          style: TextStyle(
                            color: AppColor.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Text(
                          price.toString(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(thickness: 2),
                  ],
                ),
              ),
      );

  Widget editButton() => IconButton(
      icon: const Icon(Icons.edit_outlined),
      onPressed: () async {
        if (isLoading) return;

        await Get.to(()=>AddEditProductPage(product: product));

        refreshProduct();
      });

  Widget deleteButton() => IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () async {
          // await ProductsDatabase.instance.delete(widget.productId);
          var result = messageBox('سوف يتم حذف هذا المنتج من قواعد البيانات\n\nهل أنت متأكد من هذا الإجراء');
          return result;
        },
      );
}
