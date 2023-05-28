const String tableProducts = 'products';

class ProductFields {
  static const String id = 'id';
  static const String productName = 'productName';
  static const String barcode = 'barcode';
  static const String unit = 'unit';
  static const String price = 'price';
  static int workOffline =0;

  static List<String> getProductsFields() =>
      [id, productName, barcode, unit, price];
}

class Product {
  int? id;
  String? productName;
  String? barcode;
  String? unit;
  num? price;

  Product({this.id,
    this.productName,
    this.barcode,
    this.unit,
    this.price,
  });

  Product copy({
    int? id,
    String? productName,
    String? barcode,
    String? unit,
    num? price,
  }) =>
      Product(
        id: id ?? this.id,
        productName: productName ?? this.productName,
        barcode: barcode ?? this.barcode,
        unit: unit ?? this.unit,
        price: price ?? this.price,
      );

  factory Product.fromJson(dynamic json) {
    return Product(
      id: json[ProductFields.id] as int,
      productName: json[ProductFields.productName],
      barcode: json[ProductFields.barcode],
      unit: json[ProductFields.unit],
      price: json[ProductFields.price] as num,
    );
  }

  Map<String, dynamic> toJson() => {
        ProductFields.id: id,
        ProductFields.productName: productName,
        ProductFields.barcode: barcode,
        ProductFields.unit: unit,
        ProductFields.price: price,
      };


}

