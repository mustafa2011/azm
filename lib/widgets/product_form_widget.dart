import 'package:flutter/material.dart';

import 'app_colors.dart';

class ProductFormWidget extends StatelessWidget {
  final String? productName;
  final String? barcode;
  final String? unit;
  final num price;
  final ValueChanged<String> onChangedProductName;
  final ValueChanged<String> onChangedBarcode;
  final ValueChanged<String> onChangedUnit;
  final ValueChanged<num> onChangedPrice;

  const ProductFormWidget({
    Key? key,
    this.productName = '',
    this.barcode = '',
    this.unit = '',
    this.price = 0.0,
    required this.onChangedProductName,
    required this.onChangedBarcode,
    required this.onChangedUnit,
    required this.onChangedPrice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
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
              buildPrice(),
            ],
          ),
        ),
      );

  Widget buildProductName() => TextFormField(
    initialValue: productName,
    keyboardType: TextInputType.name,
    textAlign: TextAlign.center,
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
    onChanged: onChangedProductName,
  );

  Widget buildBarcode() => TextFormField(
        initialValue: barcode,
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
        onChanged: onChangedBarcode,
      );

  Widget buildUnit() => TextFormField(
        initialValue: unit,
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
        onChanged: onChangedUnit,
      );

  Widget buildPrice() => TextFormField(
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        initialValue: price.toString(),
        textAlign: TextAlign.center,
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
        onChanged: (price) => onChangedPrice(num.parse(price)),
      );

}
