// import '../apis/gsheets_api.dart';
import '../db/fatoora_db.dart';
import '../models/product.dart';
import '../models/settings.dart';
import '../screens/products_page.dart';
import '../widgets/app_colors.dart';
import '../widgets/product_form_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddEditProductPage extends StatefulWidget {
  final dynamic product;

  const AddEditProductPage({
    Key? key,
    this.product,
  }) : super(key: key);

  @override
  State<AddEditProductPage> createState() => _AddEditProductPageState();
}

class _AddEditProductPageState extends State<AddEditProductPage> {
  final _formKey = GlobalKey<FormState>();
  late String productName;
  late String barcode;
  late String unit;
  late num price;
  late String imgUrl;
  int workOffline = 0;

  @override
  void initState() {
    super.initState();
    productName = widget.product?.productName ?? '';
    barcode = widget.product?.barcode ?? '';
    unit = widget.product?.unit ?? '';
    price =widget.product?.price??0;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          actions: [buildButton()],
        ),
        body: Form(
          key: _formKey,
          child: ProductFormWidget(
            productName: productName,
            barcode: barcode,
            unit: unit,
            price: price,
            onChangedProductName: (productName) =>
                setState(() => this.productName = productName),
            onChangedBarcode: (barcode) =>
                setState(() => this.barcode = barcode),
            onChangedUnit: (unit) =>
                setState(() => this.unit = unit),
            onChangedPrice: (price) => setState(() => this.price = price),
          ),
        ),
      );

  Widget buildButton() {
    final isFormValid = productName.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: AppColor.background, backgroundColor: isFormValid ? AppColor.primary : Colors.grey.shade700,
        ),
        onPressed: addOrUpdateProduct,
        child: const Text('حفظ'),
      ),
    );
  }

  void addOrUpdateProduct() async {
    final isValid = _formKey.currentState!.validate();

    if (isValid) {
      final isUpdating = widget.product != null;

      if (isUpdating) {
        await updateProduct();
      } else {
        await addProduct();
      }

      Get.to(()=>const ProductsPage());
    }
  }

  Future updateProduct() async {
    List<Setting> setting;
    setting = await FatooraDB.instance.getAllSettings();
    if(setting.isNotEmpty){
      setState(() {
        workOffline = setting[0].workOffline;
      });
    }
    if (workOffline==1) {
      final product = widget.product.copy(
        productName: productName,
        barcode: barcode,
        unit: unit,
        price: price,
      );
      await FatooraDB.instance.updateProduct(product);
    }
  }

  Future addProduct() async {
    List<Setting> setting;
    setting = await FatooraDB.instance.getAllSettings();
    if(setting.isNotEmpty){
      setState(() {
        workOffline = setting[0].workOffline;
      });
    }

    if (workOffline==1) {
      final product = Product(
        productName: productName,
        barcode: barcode,
        unit: unit,
        price: price,
      );
      await FatooraDB.instance.createProduct(product);
    }
  }
}
