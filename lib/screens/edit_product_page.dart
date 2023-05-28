// import '../apis/gsheets_api.dart';
import '../apis/constants/utils.dart';
import '../db/fatoora_db.dart';
import '../models/product.dart';
import '../models/settings.dart';
import '../screens/products_page.dart';
import '../widgets/app_colors.dart';
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
  final TextEditingController productName = TextEditingController();
  final TextEditingController barcode = TextEditingController();
  final TextEditingController unit = TextEditingController();
  final TextEditingController price = TextEditingController();
  final TextEditingController priceWithoutVat = TextEditingController();
  // late String productName;
  // late String barcode;
  // late String unit;
  // late num price;
  // late num priceWithoutVat;
  late String imgUrl;
  int workOffline = 0;

  @override
  void initState() {
    super.initState();
    productName.text = widget.product?.productName.toString() ?? '';
    barcode.text = widget.product?.barcode.toString() ?? '';
    unit.text = widget.product?.unit.toString() ?? '';
    price.text = Utils.formatPrice(widget.product?.price??0);
    priceWithoutVat.text =Utils.formatPrice(widget.product?.price??0/1.15);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          actions: [buildButton()],
        ),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildProductName(),
                const SizedBox(height: 4),
                buildBarcode(),
                const SizedBox(height: 4),
                buildUnit(),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(child: buildPriceWithoutVat()),
                    const SizedBox(width: 10),
                    Expanded(child: buildPrice()),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
  Widget buildProductName() => TextFormField(
    controller: productName,
    keyboardType: TextInputType.name,
    textAlign: TextAlign.center,
    autofocus: true,
    style: const TextStyle(
      color: AppColor.primary,
      fontWeight: FontWeight.bold,
      fontSize: 16,
    ),
    decoration: const InputDecoration(
      labelText: 'اسم المنتج',
    ),
    validator: (productName) => productName != null && productName.isEmpty
        ? 'يجب إدخال اسم الصنف'
        : null,
  );
  Widget buildBarcode() => TextFormField(
    controller: barcode,
    keyboardType: TextInputType.name,
    textAlign: TextAlign.center,
    style: const TextStyle(
      color: AppColor.primary,
      fontWeight: FontWeight.bold,
      fontSize: 16,
    ),
    decoration: const InputDecoration(
      labelText: 'كود المنتج',
    ),
    validator: (barcode) => barcode != null && barcode.isEmpty
        ? 'يجب إدخال كود الصنف'
        : null,
  );
  Widget buildUnit() => TextFormField(
    controller: unit,
    keyboardType: TextInputType.name,
    textAlign: TextAlign.center,
    style: const TextStyle(
      color: AppColor.primary,
      fontWeight: FontWeight.bold,
      fontSize: 16,
    ),
    decoration: const InputDecoration(
      labelText: 'الوحدة',
    ),
  );
  Widget buildPrice() => TextFormField(
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    controller: price,
    textAlign: TextAlign.center,
    onTap: () {
      var textValue = price.text;
      price.selection = TextSelection(
        baseOffset: 0,
        extentOffset: textValue.length,
      );
    },
    style: const TextStyle(
      color: AppColor.primary,
      fontWeight: FontWeight.bold,
      fontSize: 16,
    ),
    decoration: const InputDecoration(
      labelText: 'سعر المنتج شامل الضريبة',
    ),
    validator: (price) =>
    price == null || price == '' ? 'يجب إدخال سعر المنتج' : null,
    onChanged: (price) => setState(() {
      priceWithoutVat.text = Utils.formatPrice(num.parse(price)/1.15);
    }),
  );
  Widget buildPriceWithoutVat() => TextFormField(
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    controller: priceWithoutVat,
    textAlign: TextAlign.center,
    onTap: () {
      var textValue = priceWithoutVat.text;
      priceWithoutVat.selection = TextSelection(
        baseOffset: 0,
        extentOffset: textValue.length,
      );
    },
    style: const TextStyle(
      color: AppColor.primary,
      fontWeight: FontWeight.bold,
      fontSize: 16,
    ),
    decoration: const InputDecoration(
      labelText: 'سعر المنتج غير شامل الضريبة',
    ),
    onChanged: (priceWithoutVat) => setState(() {
      price.text = Utils.formatPrice(num.parse(priceWithoutVat)*1.15);
    }),
  );
  Widget buildButton() {
    // final isFormValid = productName.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: AppColor.background, backgroundColor: AppColor.primary,
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
        productName: productName.text,
        barcode: barcode.text,
        unit: unit.text,
        price: num.parse(price.text),
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
        productName: productName.text,
        barcode: barcode.text,
        unit: unit.text,
        price: num.parse(price.text),
      );
      await FatooraDB.instance.createProduct(product);
    }
  }

}
