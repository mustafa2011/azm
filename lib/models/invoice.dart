const String tableInvoices = 'invoices';
const String tableInvoiceLines = 'invoice_lines';

class InvoiceFields {
  static const String id = 'id';
  static const String invoiceNo = 'invoiceNo';
  static const String date = 'date';
  static const String supplyDate = 'supplyDate';
  static const String sellerId = 'sellerId';
  static const String total = 'total';
  static const String totalVat = 'totalVat';
  static const String totalDiscount = 'totalDiscount';
  static const String posted = 'posted';
  static const String payerId = 'payerId';
  static const String noOfLines = 'noOfLines';
  static const String project = 'project';
  static const String paymentMethod = 'paymentMethod';
  static const String template = 'template';

  static List<String> getInvoiceFields() => [
        id,
        invoiceNo,
        date,
        supplyDate,
        sellerId,
        total,
        totalVat,
        totalDiscount,
        posted,
        payerId,
        noOfLines,
        project,
        paymentMethod,
        template
      ];
}

class Invoice {
  final int? id;
  final String invoiceNo;
  final String date;
  final String supplyDate;
  final int? sellerId;
  final num total;
  final num totalVat;
  final num totalDiscount;
  final int posted;
  final int? payerId;
  final int noOfLines;
  final String project;
  final String paymentMethod;
  final String template;

  Invoice({
    this.id,
    this.invoiceNo = '',
    this.date = '',
    this.supplyDate = '',
    this.sellerId,
    this.total = 0.0,
    this.totalVat = 0.0,
    this.totalDiscount = 0.0,
    this.posted = 0,
    this.payerId,
    this.noOfLines = 0,
    this.project = '',
    this.paymentMethod = '',
    this.template = '',
  });

  Invoice copy({
    int? id,
    String? invoiceNo,
    String? date,
    String? supplyDate,
    int? sellerId,
    num? total,
    num? totalVat,
    num? totalDiscount,
    int? posted,
    int? payerId,
    int? noOfLines,
    String? project,
    String? paymentMethod,
    String? template,
  }) =>
      Invoice(
        id: id ?? this.id,
        invoiceNo: invoiceNo ?? this.invoiceNo,
        date: date ?? this.date,
        supplyDate: supplyDate ?? this.supplyDate,
        sellerId: sellerId ?? this.sellerId,
        total: total ?? this.total,
        totalVat: totalVat ?? this.totalVat,
        totalDiscount: totalDiscount ?? this.totalDiscount,
        posted: posted ?? this.posted,
        payerId: payerId ?? this.payerId,
        noOfLines: noOfLines ?? this.noOfLines,
        project: project ?? this.project,
        paymentMethod: paymentMethod ?? this.paymentMethod,
        template: template ?? this.template,
      );

  factory Invoice.fromJson(dynamic json) {
    return Invoice(
      id: json[InvoiceFields.id] as int,
      invoiceNo: json[InvoiceFields.invoiceNo] as String,
      date: json[InvoiceFields.date] as String,
      supplyDate: json[InvoiceFields.supplyDate] as String,
      sellerId: json[InvoiceFields.sellerId] as int,
      total: json[InvoiceFields.total] as num,
      totalVat: json[InvoiceFields.totalVat] as num,
      totalDiscount: json[InvoiceFields.totalDiscount] as num,
      posted: json[InvoiceFields.posted] as int,
      payerId: json[InvoiceFields.payerId] as int,
      noOfLines: json[InvoiceFields.noOfLines] as int,
      project: json[InvoiceFields.project] ?? '',
      paymentMethod: json[InvoiceFields.paymentMethod] ?? '',
      template: json[InvoiceFields.template] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        InvoiceFields.id: id,
        InvoiceFields.invoiceNo: invoiceNo,
        InvoiceFields.date: date,
        InvoiceFields.supplyDate: supplyDate,
        InvoiceFields.sellerId: sellerId,
        InvoiceFields.total: total,
        InvoiceFields.totalVat: totalVat,
        InvoiceFields.totalDiscount: totalDiscount,
        InvoiceFields.posted: posted,
        InvoiceFields.payerId: payerId,
        InvoiceFields.noOfLines: noOfLines,
        InvoiceFields.project: project,
        InvoiceFields.paymentMethod: paymentMethod,
        InvoiceFields.template: template,
      };

  String toParams() => "?id=$id"
      "&invoiceNo=$invoiceNo"
      "&date=$date"
      "&supplyDate=$supplyDate"
      "&sellerId=$sellerId"
      "&total=$total"
      "&totalVat=$totalVat"
      "&totalDiscount=$totalDiscount"
      "&posted=$posted"
      "&payerId=$payerId"
      "&noOfLines=$noOfLines"
      "&project=$project"
      "&paymentMethod=$paymentMethod"
      "&template=$template";
}

class InvoiceLinesFields {
  static const String recId = 'recId';
  static const String id = 'id';
  static const String productName = 'productName';
  static const String barcode = 'barcode';
  static const String unit = 'unit';
  static const String price = 'price';
  static const String discount = 'discount';
  static const String qty = 'qty';

  static List<String> getInvoiceLinesFields() =>
      [recId, id, productName, barcode, unit, price, discount, qty];
}

class InvoiceLines {
  final int? id;
  final int recId;
  final String productName;
  final String barcode;
  final String unit;
  final num price;
  final num discount;
  final num qty;

  InvoiceLines({
    this.id,
    required this.recId,
    required this.productName,
    this.barcode = '',
    this.unit = '',
    required this.price,
    this.discount = 0,
    this.qty = 1,
  });

  InvoiceLines copy({
    int? id,
    int? recId,
    String? productName,
    String? barcode,
    String? unit,
    num? price,
    num? discount,
    num? qty,
  }) =>
      InvoiceLines(
        id: id ?? this.id,
        recId: recId ?? this.recId,
        productName: productName ?? this.productName,
        barcode: productName ?? this.barcode,
        unit: productName ?? this.unit,
        price: price ?? this.price,
        discount: discount ?? this.discount,
        qty: qty ?? this.qty,
      );

  factory InvoiceLines.fromJson(dynamic json) {
    return InvoiceLines(
      id: json[InvoiceLinesFields.id] as int,
      recId: json[InvoiceLinesFields.recId] as int,
      productName: json[InvoiceLinesFields.productName],
      barcode: json[InvoiceLinesFields.barcode],
      unit: json[InvoiceLinesFields.unit],
      price: json[InvoiceLinesFields.price] as num,
      discount: json[InvoiceLinesFields.discount] as num,
      qty: json[InvoiceLinesFields.qty] as num,
    );
  }

  Map<String, dynamic> toJson() => {
        InvoiceLinesFields.id: id,
        InvoiceLinesFields.recId: recId,
        InvoiceLinesFields.productName: productName,
        InvoiceLinesFields.barcode: barcode,
        InvoiceLinesFields.unit: unit,
        InvoiceLinesFields.price: price,
        InvoiceLinesFields.discount: discount,
        InvoiceLinesFields.qty: qty,
      };

  String toParams() => "?id=$id"
      "&recId=$recId"
      "&productName=$productName"
      "&barcode=$barcode"
      "&unit=$unit"
      "&price=$price"
      "&discount=$discount"
      "&qty=$qty";
}
