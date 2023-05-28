import 'package:fatoora/models/product.dart';
import '../apis/constants/utils.dart';
import '/db/fatoora_db.dart';
import '/models/settings.dart';
import '/widgets/widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'edit_product_page.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({Key? key}) : super(key: key);

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  FatooraDB db = FatooraDB.instance;
  late int uid;
  bool isLoading = false;
  List<Product> products = [];
  late List<Setting> user;
  bool noProductFount = false;
  int workOffline = 0;
  String language = 'Arabic';

  @override
  void initState() {
    super.initState();
    refreshData();
  }

  @override
  void dispose() {
    super.dispose();
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
              child: const Text("موافق"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future getProductsList() async {
    try {
      setState(() => isLoading = true);

      List<Setting> setting;
      setting = await FatooraDB.instance.getAllSettings();
      if (setting.isNotEmpty) {
        setState(() {
          workOffline = setting[0].workOffline;
        });
      }
      if (workOffline == 1) {
        await FatooraDB.instance.getAllProducts().then((list) {
          products = list;
        });
      }
      if (products.isEmpty) {
        setState(() {
          noProductFount = true;
        });
      }

      setState(() => isLoading = false);
    } on Exception catch (e) {
      messageBox(e.toString());
    }
  }

  Future refreshData() async {
    language = await Utils.language();
    getProductsList();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 1,
      child: Scaffold(
          body: NewForm(
            title: 'شاشة المنتجات',
            icon: Icons.refresh,
            onIconTab: refreshData,
            isLoading: isLoading,
            action: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                NewButton(
                  text: "إضافة منتج",
                  iconSize: 20,
                  icon: Icons.add,
                  onTap: () => Get.to(() => const AddEditProductPage()),
                ),
              ],
            ),
            tab: TabBar(
              isScrollable: true,
              indicatorWeight: 10.0,
              labelStyle: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
              indicatorPadding: const EdgeInsets.only(bottom: 0),
              onTap: (val) {},
              tabs: const [
                Text('جميع المنتجات'),
                // Text(''),
                // Text(''),
              ],
            ),
            child: TableProduct(product: products),
          )),
    );
  }
}