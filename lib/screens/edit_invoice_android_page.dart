import 'dart:convert';
import 'dart:ui';

import 'package:dropdown_search/dropdown_search.dart';

import '../apis/constants/utils.dart';
import '../apis/pdf_receipt.dart';

import '../apis/qr_tag/invoice_date.dart';
import '../apis/qr_tag/invoice_tax_amount.dart';
import '../apis/qr_tag/invoice_total_amount.dart';
import '../apis/qr_tag/seller.dart';
import '../apis/qr_tag/tax_number.dart';

import '../apis/qr_tag/qr_encoder.dart';
import '../db/fatoora_db.dart';
import '../models/customers.dart';
import '../models/invoice.dart';
import '../models/product.dart';
import '../models/purchase.dart';
import '../models/settings.dart';
import '../models/template.dart';
import '../widgets/app_colors.dart';
import '../widgets/widget.dart';
import '../widgets/loading.dart';
import '../widgets/product_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf_render/pdf_render.dart' as rr;
import 'dart:developer';
import 'dart:io';
import 'package:qr_code_scanner/qr_code_scanner.dart' as sc;
import 'package:sunmi_printer_plus/column_maker.dart';
import 'package:sunmi_printer_plus/enums.dart';
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';
import 'package:sunmi_printer_plus/sunmi_style.dart';

import '../apis/pdf_invoice_api.dart';
import 'invoices_page.dart';

const fontStyle = TextStyle(
    color: AppColor.primary, fontWeight: FontWeight.bold, fontSize: 12);

class AddEditInvoiceAndroidPage extends StatefulWidget {
  final bool? isCreditNote;
  final bool? isPurchases;
  final dynamic product;
  final Invoice? invoice;
  final Purchase? purchase;
  final String? template;

  const AddEditInvoiceAndroidPage({
    Key? key,
    this.isCreditNote,
    this.isPurchases,
    this.product,
    this.invoice,
    this.purchase,
    this.template,
  }) : super(key: key);

  @override
  State<AddEditInvoiceAndroidPage> createState() =>
      _AddEditInvoiceAndroidPageState();
}

class _AddEditInvoiceAndroidPageState extends State<AddEditInvoiceAndroidPage> {
  List<String> payMethod = ['شبكة', 'كاش', 'آجل', 'حوالة'];
  List<String> temp = ['نموذج 1', 'نموذج 2']; //, 'نموذج 3', 'نموذج 4', 'نموذج 5'];
  String? selectedPayMethod = Utils.defPayMethod;
  String? selectedTemp;
  int? tempId;
  sc.Barcode? qResult;
  sc.QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool scanned = false;

  TextEditingController textQRCode = TextEditingController();

  final _key1 = GlobalKey<FormState>();
  final _key2 = GlobalKey<FormState>();
  late int recId;
  late int newId; // This id for new invoice id in cloud database
  late int id; // this is existing invoice id will be retrieved from widget
  late final Customer payer;
  late final Setting seller;
  late final Setting vendor;
  late final Setting vendorVatNumber;
  late final String project;
  late final String date;
  late final String supplyDate;
  late List<InvoiceLines> items = [];
  late List<InvoiceLines> lines = [];
  late List<TemplateDetails> template = [];
  late List<Invoice> dailyInvoices = [];
  late List<String> customers = [];
  String invoiceNo = '';
  int counter = 0;

  // bool isSimplifiedTaxInvoice = false;
  bool isPreview = false;
  bool isEstimate = false;

  final TextEditingController _productName = TextEditingController();
  final TextEditingController _qty = TextEditingController();
  final TextEditingController _invoiceNo = TextEditingController();
  final TextEditingController _totalPrice = TextEditingController();
  final TextEditingController _price = TextEditingController();
  final TextEditingController _discount = TextEditingController();
  final TextEditingController _priceWithoutVat = TextEditingController();
  final TextEditingController _payer = TextEditingController();
  final TextEditingController _payerVatNumber = TextEditingController();
  final TextEditingController _vendor = TextEditingController();
  final TextEditingController _details = TextEditingController();
  final TextEditingController _vendorVatNumber = TextEditingController();
  final TextEditingController _totalPurchases = TextEditingController();
  final TextEditingController _vatPurchases = TextEditingController();
  final TextEditingController _project = TextEditingController();
  final TextEditingController _date = TextEditingController();
  final TextEditingController _supplyDate = TextEditingController();
  final FocusNode focusNode = FocusNode();

  num total = 0.0;
  num totalDiscount = 0.0;
  int cardQty = 1;

  bool noProductFound = true;
  bool isManualInvoice = true;
  bool isLoading = false;
  List<Product> products = [];
  List<String> productsList = [];
  int workOffline = 1;
  int curPayerId = 1;
  String curProject = '';
  String curDate = Utils.formatDate(DateTime.now());
  String curSupplyDate = Utils.formatDate(DateTime.now());
  bool printerConnected = false;
  String sellerAddress = '';
  String payerAddress = '';
  String newPayerAddress = '';
  String language = 'Arabic';
  String? activity;
  String? device = "Sunmi";

  @override
  void initState() {
    super.initState();
    selectedTemp = widget.template ?? 'نموذج 1';
    getTemp(selectedTemp!);
    getInvoice();
    focusNode.requestFocus();
  }

  Future<bool?> getSunmiPrinter() async {
    final bool? result = await SunmiPrinter.bindingPrinter();
    return result;
  }

  Future getInvoice() async {
    FatooraDB db = FatooraDB.instance;
    try {
      setState(() => isLoading = true);
      var user = await db.getAllSettings();
      int uid = user[0].id as int;
      language = user[0].language;
      device = user[0].freeText4;
      activity = user[0].freeText5;
      if (Platform.isAndroid) {
        if (device == "Sunmi") {
          await getSunmiPrinter()
              .then((bool? isBind) => setState(() => printerConnected = isBind!));
        }
      }
      seller = user[0];

      int? purchasesCount = await FatooraDB.instance.getPurchasesCount();
      int? invoicesCount = await FatooraDB.instance.getInvoicesCount();
      int? countCustomers = await FatooraDB.instance.getCustomerCount();

      if (widget.invoice != null) {
        curPayerId = widget.invoice!.payerId!;
        curProject = widget.invoice!.project;
        curDate = widget.invoice!.date;
        curSupplyDate = widget.invoice!.supplyDate;
        selectedPayMethod = widget.invoice!.paymentMethod;
        invoiceNo = widget.invoice!.invoiceNo;
      }

      id = widget.isPurchases == true
          ? widget.purchase == null
          ? purchasesCount == 0
          ? 1
          : (await db.getNewPurchaseId())! + 1
          : widget.purchase!.id!
          : widget.invoice != null
          ? widget.invoice!.id!
          : invoicesCount == 0
          ? 1
          : (await db.getNewInvoiceId())! + 1;
      payer = countCustomers == 0
          ? await FatooraDB.instance.getCustomerById(1)
          : await FatooraDB.instance.getCustomerById(curPayerId);
      if (widget.isPurchases == false) {
        _payer.text = '${payer.id}-${payer.name}';
        _payerVatNumber.text = payer.vatNumber;
        _project.text = curProject;
        _date.text = curDate;
        _supplyDate.text = curSupplyDate;
        _invoiceNo.text = invoiceNo;
      } else {
        if (widget.purchase == null) {
          _vendor.text = '';
          _vendorVatNumber.text = '';
          _date.text = Utils.formatDate(DateTime.now());
          _totalPurchases.text = '';
          _vatPurchases.text = '';
          _details.text = '';
        } else {
          Purchase purchase = await FatooraDB.instance.getPurchaseById(id);
          _vendor.text = purchase.vendor;
          _vendorVatNumber.text = purchase.vendorVatNumber;
          _date.text = purchase.date;
          _totalPurchases.text = Utils.formatNoCurrency(purchase.total);
          _vatPurchases.text = Utils.formatNoCurrency(purchase.totalVat);
          _details.text = purchase.details;
        }
      }

      List<Customer> list = await FatooraDB.instance.getAllCustomers();
      customers.clear();
      for (int i = 0; i < list.length; i++) {
        customers.add("${list[i].id}-${list[i].name}");
      }

      recId = id;

      /// to generate a unique invoice no declare the user who create this invoice
      if (widget.isCreditNote!) {
        invoiceNo = '$uid-$recId-CR';
      }

      ///  Initialize Invoice lines
      if (widget.invoice != null) {
        items = await db.getInvoiceLinesById(recId);
        for (int i = 0; i < items.length; i++) {
          total = total + (items[i].qty * items[i].price) - items[i].discount;
          totalDiscount = totalDiscount + items[i].discount;
        }
      }

      /// Initialize products list offLine/onLine
      if (workOffline == 1) {
        await db.getAllProducts().then((list) {
          products = list;
          for (int i = 0; i < products.length; i++) {
            productsList.add('${products[i].id!}-${products[i].productName!}');
          }
        });
        if (products.isEmpty) {
          noProductFound = true;
        } else {
          noProductFound = false;
        }
      }

      /// Initialize invoice form controller header
      _totalPrice.text = '0.00';
      _price.text = '0.00';
      _discount.text = '0.00';
      _priceWithoutVat.text = '0.00';
      _qty.text = activity == "OilServices" ? '0.00' : '1';
      _invoiceNo.text = invoiceNo;

      sellerAddress += seller.buildingNo;
      sellerAddress += seller.buildingNo.isNotEmpty ? ' ' : '';
      sellerAddress += seller.streetName.isNotEmpty ? seller.streetName : '';
      sellerAddress += seller.district.isNotEmpty ? '-${seller.district}' : '';
      sellerAddress += seller.city.isNotEmpty ? '-${seller.city}' : '';
      sellerAddress += seller.country.isNotEmpty ? '-${seller.country}' : '';

      payerAddress += payer.buildingNo;
      payerAddress += payer.buildingNo.isNotEmpty ? ' ' : '';
      payerAddress += payer.streetName.isNotEmpty ? payer.streetName : '';
      payerAddress += payer.district.isNotEmpty ? '-${payer.district}' : '';
      payerAddress += payer.city.isNotEmpty ? '-${payer.city}' : '';
      payerAddress += payer.country.isNotEmpty ? '-${payer.country}' : '';

      setState(() {
        isLoading = false;
      });
    } on Exception catch (e) {
      messageBox(e.toString());
    }
  }

  pw.Text oneLineText(String text,
      {pw.TextAlign textAlign = pw.TextAlign.center,
        double fontSize = 10,
        bool isBold = false}) =>
      pw.Text(
        text,
        textDirection: pw.TextDirection.rtl,
        textAlign: textAlign,
        style: pw.TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal),
      );

  pw.Row twoLineText(
      String leftText,
      String rightText, {
        double fontSize = 10,
        bool isBold = false,
      }) =>
      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
        pw.Text(
          leftText,
          textDirection: pw.TextDirection.rtl,
          textAlign: pw.TextAlign.left,
          style: pw.TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal),
        ),
        pw.Text(
          rightText,
          textDirection: pw.TextDirection.rtl,
          textAlign: pw.TextAlign.right,
          style: pw.TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal),
        )
      ]);

  Future<ByteData?> byteInvoice() async {
    var myTheme = pw.ThemeData.withFont(
      base: pw.Font.ttf(await rootBundle.load("assets/fonts/Tahoma.ttf")),
      bold: pw.Font.ttf(await rootBundle.load("assets/fonts/arialbd.ttf")),
    );
    final pdf = pw.Document(theme: myTheme);
    final Directory docDir = await getTemporaryDirectory();
    String filePath = '${docDir.path}/text.pdf';
    int payerId = int.parse(_payer.text.split("-")[0]);
    Customer payer = await FatooraDB.instance.getCustomerById(payerId);
    Invoice invoice = Invoice(
      invoiceNo: invoiceNo,
      date: _date.text,
      supplyDate: _supplyDate.text,
      sellerId: seller.id,
      project: _project.text,
      total: total,
      totalDiscount: totalDiscount,
      totalVat: total - (total / 1.15),
      posted: 0,
      payerId: payerId,
      noOfLines: items.length,
    );
    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.roll57
          .applyMargin(left: 0, top: 0, right: 20, bottom: 0),
      build: (context) => pw.Center(
          child: pw.Column(children: [
            buildLogo(seller),
            oneLineText('فاتورة ضريبية مبسطة'),
            oneLineText('البائع:${seller.seller}'),
            oneLineText('VAT: ${seller.vatNumber}'),
            oneLineText('المشتري:${payer.name}'),
            oneLineText('VAT: ${payer.vatNumber}'),
            buildInvoice(items),
            pw.Divider(),
            buildTotal(invoice, seller),
            pw.Divider(),
            buildTerms(invoice, seller),
          ])),
      // pw.SizedBox(height: 10),
    ));

    final bytes = await pdf.save();
    File file;
    file = File(filePath);
    await file.writeAsBytes(bytes);

    final doc = await rr.PdfDocument.openFile(filePath);
    var page = await doc.getPage(1);
    var imgPDF = await page.render(
        width: (page.width * 2.6).toInt(), height: (page.height * 2.6).toInt());
    var img = await imgPDF.createImageDetached();
    var textBytes = await img.toByteData(format: ImageByteFormat.png);

    return textBytes;
  }

  pw.Widget buildTerms(Invoice invoice, Setting seller) {
    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          oneLineText(seller.terms),
          oneLineText('Invoice # ${invoice.invoiceNo}'),
          oneLineText(invoice.date),
          pw.SizedBox(height: 30),
        ]);
  }

  pw.Widget buildTotal(Invoice invoice, Setting seller) {
    final netTotal = invoice.total / 1.15;
    final vat = invoice.totalVat;
    final total = invoice.total;
    final qrString = QRBarcodeEncoder.encode(
      Seller(seller.seller),
      TaxNumber(seller.vatNumber),
      InvoiceDate(invoice.date),
      InvoiceTotalAmount(invoice.total.toStringAsFixed(2)),
      InvoiceTaxAmount(invoice.totalVat.toStringAsFixed(2)),
    ).toString();

    return pw.Column(
      children: [
        twoLineText(Utils.formatNoCurrency(netTotal), 'الإجمالي بدون الضريبة'),
        twoLineText(Utils.formatNoCurrency(vat), 'الضريبة'),
        twoLineText(Utils.formatNoCurrency(total), 'المبلغ المستحق'),
        pw.SizedBox(height: 10),
        pw.Container(
          height: 75,
          width: 75,
          child: pw.BarcodeWidget(
            barcode: pw.Barcode.qrCode(),
            data: qrString,
          ),
        ),
      ],
    );
  }

  pw.Widget buildInvoice(List<InvoiceLines> invoiceLines) {
    final data = invoiceLines.map((item) {
      final total =
          '${Utils.formatPrice((item.qty * item.price) - item.discount)}';
      final line2 = '${Utils.formatPrice(item.price)} × ${item.qty}';
      return [
        total,
        line2,
        item.productName,
      ];
    }).toList();

    return pw.Center(
        child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Divider(),
              twoLineText("الإجمالي", "البيان", isBold: true),
              pw.Divider(),
              pw.ListView.builder(
                itemCount: data.length,
                itemBuilder: (pw.Context context, int index) =>
                    pw.Column(children: [
                      twoLineText("", data[index][2]),
                      twoLineText(data[index][0], data[index][1]),
                      pw.SizedBox(height: 5),
                    ]),
              ),
            ]));
  }

  Future<void> printTicket() async {
    double total = 0;
    if (device == "Sunmi") {
      int newPayerId = int.parse(_payer.text.split("-")[0]);
      Customer newPayer = await FatooraDB.instance.getCustomerById(newPayerId);
      newPayerAddress += newPayer.buildingNo;
      newPayerAddress += newPayer.buildingNo.isNotEmpty ? ' ' : '';
      newPayerAddress +=
      newPayer.streetName.isNotEmpty ? newPayer.streetName : '';
      newPayerAddress +=
      newPayer.district.isNotEmpty ? '-${newPayer.district}' : '';
      newPayerAddress += newPayer.city.isNotEmpty ? '-${newPayer.city}' : '';
      newPayerAddress +=
      newPayer.country.isNotEmpty ? '-${newPayer.country}' : '';

      await SunmiPrinter.initPrinter();
      await SunmiPrinter.startTransactionPrint(true);
      await SunmiPrinter.printImage(base64Decode(seller.logo));
      await SunmiPrinter.lineWrap(1);
      await SunmiPrinter.printText(seller.seller,
          style: SunmiStyle(
              fontSize: SunmiFontSize.LG, align: SunmiPrintAlign.CENTER));
      await SunmiPrinter.printText(sellerAddress,
          style: SunmiStyle(
              bold: true,
              fontSize: SunmiFontSize.SM,
              align: SunmiPrintAlign.CENTER));

      if (seller.showVat == 1) {
        await SunmiPrinter.printText('الرقم الضريبي  ${seller.vatNumber}',
            style: SunmiStyle(
                fontSize: SunmiFontSize.MD, align: SunmiPrintAlign.CENTER));
      }

      await SunmiPrinter.line();

      /// Printing customer name and vat number.
      await SunmiPrinter.printText('العميل: ${newPayer.name}',
          style: SunmiStyle(
              bold: true,
              fontSize: SunmiFontSize.MD,
              align: SunmiPrintAlign.RIGHT));
      await SunmiPrinter.printText(newPayerAddress,
          style: SunmiStyle(
              bold: true,
              fontSize: SunmiFontSize.SM,
              align: SunmiPrintAlign.RIGHT));
      await SunmiPrinter.printText('الرقم الضريبي  ${newPayer.vatNumber}',
          style: SunmiStyle(
              fontSize: SunmiFontSize.MD, align: SunmiPrintAlign.RIGHT));
      await SunmiPrinter.line();

      /// Printing invoice lines ...');
      for (int i = 0; i <= items.length - 1; i++) {
        await SunmiPrinter.printText(items[i].productName,
            style: SunmiStyle(align: SunmiPrintAlign.RIGHT));
        await SunmiPrinter.printRow(cols: [
          ColumnMaker(
              text:
              '${Utils.formatPrice((items[i].qty * items[i].price) - items[i].discount)}',
              width: 15,
              align: SunmiPrintAlign.LEFT),
          ColumnMaker(
              text: '${Utils.formatPrice(items[i].price)}x${items[i].qty}',
              width: 15,
              align: SunmiPrintAlign.RIGHT),
        ]);

        await SunmiPrinter.lineWrap(1);
        total = total + ((items[i].qty * items[i].price) - items[i].discount);
      }
      await SunmiPrinter.line();
      double netTotal = total / 1.15;
      double vat = total - netTotal;

      if (seller.showVat == 1) {
        await SunmiPrinter.printText(
            'الإجمالي الصافي   ${Utils.formatPrice(netTotal)}',
            style: SunmiStyle(
                fontSize: SunmiFontSize.MD, align: SunmiPrintAlign.LEFT));
        await SunmiPrinter.printText('الضريبة 15%   ${Utils.formatPrice(vat)}',
            style: SunmiStyle(
                fontSize: SunmiFontSize.MD, align: SunmiPrintAlign.LEFT));
      }

      await SunmiPrinter.printText(
          'الإجمالي المستحق   ${Utils.formatPrice(total)}',
          style: SunmiStyle(
              fontSize: SunmiFontSize.MD,
              bold: true,
              align: SunmiPrintAlign.LEFT));
      await SunmiPrinter.printText('الدفع $selectedPayMethod',
          style: SunmiStyle(
              fontSize: SunmiFontSize.MD,
              bold: true,
              align: SunmiPrintAlign.LEFT));

      final qrString = QRBarcodeEncoder.encode(
        Seller(seller.seller),
        TaxNumber(seller.vatNumber),
        InvoiceDate(Utils.formatDate(DateTime.now())),
        InvoiceTotalAmount(total.toStringAsFixed(2)),
        InvoiceTaxAmount(vat.toStringAsFixed(2)),
      ).toString();
      await SunmiPrinter.lineWrap(1);
      await SunmiPrinter.printQRCode(qrString, size: 4);
      await SunmiPrinter.lineWrap(1);
      await SunmiPrinter.line();
      await SunmiPrinter.printText(seller.terms,
          style: SunmiStyle(
              fontSize: SunmiFontSize.SM, align: SunmiPrintAlign.CENTER));
      await SunmiPrinter.printText('Invoice # $invoiceNo',
          style: SunmiStyle(
              fontSize: SunmiFontSize.SM, align: SunmiPrintAlign.CENTER));
      await SunmiPrinter.printText('${Utils.formatDate(DateTime.now())}',
          style: SunmiStyle(
              fontSize: SunmiFontSize.SM, align: SunmiPrintAlign.CENTER));
      await SunmiPrinter.lineWrap(3);
      await SunmiPrinter.cut();
      await SunmiPrinter.exitTransactionPrint(true);
    }
  }

  pw.Container buildLogo(Setting seller) => pw.Container(
      width: seller.logoWidth.toDouble(),
      height: seller.logoHeight.toDouble(),
      decoration: pw.BoxDecoration(
          image: pw.DecorationImage(
              fit: pw.BoxFit.fill,
              image: pw.MemoryImage(base64Decode(seller.logo)))));

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

  void confirmSave() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تأكيد الحفظ'),
          content: const Text('تمت عملية الحفظ بنجاح'),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            TextButton(
              child: const Text("موافق"),
              onPressed: () {
                Get.to(() => const InvoicesPage());
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    resizeToAvoidBottomInset: false,
    appBar: AppBar(
      title: Center(
        child: Text(
          widget.isCreditNote!
              ? language == 'Arabic'
              ? 'إشعار دائن'
              : 'Credit Note'
              : widget.isPurchases!
              ? language == 'Arabic'
              ? 'فاتورة مشتريات'
              : 'Purchases Invoice'
              : language == 'Arabic'
              ? 'فاتورة'
              : 'Invoice',
          style: const TextStyle(
              color: AppColor.primary,
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
      ),
      actions: [
        Platform.isAndroid &&
            (device == "Sunmi" ||
                device == "Handheld" ||
                device == "Portable")
            ? buildButtonSave()
            : widget.isPurchases == true
            ? buildButtonSave()
            : Container(),
        widget.isPurchases == true ? Container() : buildButtonPreview(),
        /*widget.isPurchases == true
                ? Container()
                : activity == "OilServices"
                    ? Container()
                    : buildSwitch(),*/
      ],
    ),
    body: isLoading
        ? const Center(child: Loading())
        : widget.isPurchases!
        ? buildPurchaseInvoiceBody()
        : buildBody(),
  );

  Widget buildBody() => Stack(
    children: [
      /// Product card list
      Positioned(
        top: 0,
        child: isManualInvoice
            ? SingleChildScrollView(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  child: Form(
                    key: _key1,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: buildInvoiceDate()),
                            Utils.space(0, 5),
                            Expanded(child: buildInvoiceTemp()),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(child: buildInvoiceNo()),
                            Utils.space(0, 5),
                            Expanded(child: buildPayMethod()),
                          ],
                        ),
                        buildPayer(),
                      ],
                    ),
                  ),
                ),
                Utils.space(2, 0),
                NewFrame(
                    title: 'بيانات سطور الفاتورة',
                    child: Column(
                      children: [
                        buildProductName(),
                        Row(
                          children: [
                            SizedBox(width: 60, child: buildQty()),
                            Utils.space(0, 2),
                            activity == "OilServices"
                                ? Container()
                                : Expanded(
                                child: buildPriceWithoutVat()),
                            activity == "OilServices"
                                ? Container()
                                : Utils.space(0, 1),
                            activity == "OilServices"
                                ? Container()
                                : Expanded(child: buildPrice()),
                            activity == "OilServices"
                                ? Container()
                                : Utils.space(0, 2),
                            activity == "OilServices"
                                ? Expanded(child: buildTotalPrice())
                                : Container(),
                            // Expanded(child: buildDiscount()),
                            Expanded(child: buildDiscount()),
                            buildInsertButton(),
                          ],
                        ),
                        Utils.space(2, 0),
                        Container(
                          height: 40,
                          color: Colors.grey,
                          padding: const EdgeInsets.only(
                              right: 5, left: 5),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                widget.isCreditNote!
                                    ? "تفاصيل الإشعار الدائن"
                                    : language == 'Arabic'
                                    ? "البيان"
                                    : "DESC",
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white),
                              ),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: [
                                  Text(
                                    language == 'Arabic'
                                        ? 'الإجمالي'
                                        : 'TOTAL',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white),
                                  ),
                                  Utils.space(0, 2),
                                  Text(
                                    widget.isCreditNote!
                                        ? "- ${total.toStringAsFixed(2)}"
                                        : total.toStringAsFixed(2),
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: widget.isCreditNote!
                                            ? Colors.red
                                            : Colors.white),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height *
                              0.3,
                          padding: const EdgeInsets.only(
                              right: 0, left: 0),
                          child: ListView.builder(
                              itemCount: items.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  color: index % 2 == 1
                                      ? AppColor.background
                                      : Colors.white,
                                  child: Column(
                                    children: [
                                      Utils.space(0, 1),
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.start,
                                        children: [
                                          Utils.space(0, 1),
                                          Expanded(
                                            child: Align(
                                                alignment: Alignment
                                                    .centerRight,
                                                child: Text(
                                                  items[index]
                                                      .productName,
                                                  textDirection:
                                                  TextDirection
                                                      .rtl,
                                                  style:
                                                  const TextStyle(
                                                      fontSize:
                                                      12,
                                                      color: Colors
                                                          .black),
                                                )),
                                          ),
                                          Utils.space(0, 1),
                                          Expanded(
                                            child: Row(
                                              children: [
                                                Row(
                                                  children: [
                                                    NewButton(
                                                      backgroundColor:
                                                      Colors.grey,
                                                      icon: Icons.add,
                                                      padding: 2,
                                                      iconSize: 25,
                                                      onTap: () =>
                                                          _addQuantity(
                                                              index),
                                                    ),
                                                    SizedBox(
                                                        width: 40,
                                                        child: Text(
                                                          items[index]
                                                              .qty
                                                              .toStringAsFixed(
                                                              2),
                                                          textAlign:
                                                          TextAlign
                                                              .center,
                                                          style: const TextStyle(
                                                              fontSize: 12,
                                                              // fontWeight: FontWeight.w900,
                                                              color: Colors.black),
                                                        )),
                                                    NewButton(
                                                      backgroundColor:
                                                      Colors.grey,
                                                      icon: Icons
                                                          .remove,
                                                      padding: 2,
                                                      iconSize: 25,
                                                      onTap: () =>
                                                          _removeQuantity(
                                                              index),
                                                    ),
                                                  ],
                                                ),
                                                Utils.space(0, 1),
                                                Expanded(
                                                    child: Text(
                                                      items[index]
                                                          .price
                                                          .toStringAsFixed(
                                                          2),
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color: widget
                                                              .isCreditNote!
                                                              ? Colors.red
                                                              : Colors
                                                              .black),
                                                    )),
                                                Utils.space(0, 1),
                                                Expanded(
                                                    child: Text(
                                                      (items[index].qty *
                                                          (items[index]
                                                              .price))
                                                          .toStringAsFixed(
                                                          2),
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color: widget
                                                              .isCreditNote!
                                                              ? Colors.red
                                                              : Colors
                                                              .black),
                                                    )),
                                              ],
                                            ),
                                          ),

                                          ///Remove item from list
                                          NewButton(
                                            backgroundColor:
                                            Colors.grey,
                                            padding: 2,
                                            icon: Icons.clear,
                                            iconSize: 25,
                                            onTap: () async {
                                              setState(() {
                                                num lineTotal =
                                                    items[index].qty *
                                                        items[index]
                                                            .price;
                                                total =
                                                    total - lineTotal;
                                                items.removeAt(index);
                                              });
                                            },
                                          ),
                                          Utils.space(0, 1),
                                        ],
                                      ),
                                      Utils.space(0, 1),
                                      const Divider(
                                        thickness: 1,
                                        height: 0,
                                      ),
                                    ],
                                  ),
                                );
                              }),
                        ),
                      ],
                    )),
              ],
            ),
          ),
        )
            : Column(
          children: [
            SingleChildScrollView(
              child: SizedBox(
                // height: MediaQuery.of(context).size.height * 0.50,
                width: MediaQuery.of(context).size.width,
                child: noProductFound
                    ? Center(
                  child: Text(
                    language == 'Arabic'
                        ? 'لا يوجد لديك منتجات مسجلة'
                        : 'No products recorded',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 16,
                        color: AppColor.background),
                  ),
                )
                    : Column(
                  children: [
                    Container(
                      color: AppColor.primary,
                      height:
                      MediaQuery.of(context).size.height *
                          0.40,
                      child: StaggeredGridView.countBuilder(
                        padding: const EdgeInsets.all(2),
                        itemCount: products.length,
                        staggeredTileBuilder: (index) =>
                        const StaggeredTile.fit(1),
                        crossAxisCount: 4,
                        mainAxisSpacing: 0,
                        crossAxisSpacing: 2,
                        itemBuilder: (context, index) {
                          final product = products[index];

                          return InkWell(
                            onTap: () async {
                              bool found = false;
                              for (int i = 0;
                              i < items.length;
                              i++) {
                                if (items[i].productName ==
                                    (product.productName
                                        .toString())) {
                                  found = true;
                                  break;
                                }
                              }
                              setState(() {
                                if (!found) {
                                  items.add(InvoiceLines(
                                    productName: product
                                        .productName
                                        .toString(),
                                    qty: 1,
                                    price: product.price!,
                                    recId: recId,
                                  ));
                                }
                                total = 0;
                                for (int i = 0;
                                i < items.length;
                                i++) {
                                  total = total +
                                      ((items[i].qty) *
                                          items[i].price);
                                }
                              });
                            },
                            child:
                            ProductCardWidgetToBeInvoiced(
                                product: product,
                                index: index),
                          );
                        },
                      ),
                    ),
                    Container(
                      color: AppColor.background,
                      child: Column(
                        children: [
                          Utils.space(2, 0),
                          NewFrame(
                              title: 'بيانات سطور الفاتورة',
                              child: Column(
                                children: [
                                  Container(
                                    height: 40,
                                    color: Colors.grey,
                                    padding:
                                    const EdgeInsets.only(
                                        right: 5, left: 5),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment
                                          .spaceBetween,
                                      children: [
                                        Text(
                                          widget.isCreditNote!
                                              ? "تفاصيل الإشعار الدائن"
                                              : language ==
                                              'Arabic'
                                              ? "البيان"
                                              : "DESC",
                                          style:
                                          const TextStyle(
                                              fontSize: 12,
                                              fontWeight:
                                              FontWeight
                                                  .w800,
                                              color: Colors
                                                  .white),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .center,
                                          children: [
                                            Text(
                                              language ==
                                                  'Arabic'
                                                  ? 'الإجمالي'
                                                  : 'TOTAL',
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight:
                                                  FontWeight
                                                      .w800,
                                                  color: Colors
                                                      .white),
                                            ),
                                            Utils.space(0, 2),
                                            Text(
                                              widget.isCreditNote!
                                                  ? "- ${total.toStringAsFixed(2)}"
                                                  : total
                                                  .toStringAsFixed(
                                                  2),
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight:
                                                  FontWeight
                                                      .w800,
                                                  color: widget
                                                      .isCreditNote!
                                                      ? Colors
                                                      .red
                                                      : Colors
                                                      .white),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    height:
                                    MediaQuery.of(context)
                                        .size
                                        .height *
                                        0.3,
                                    padding:
                                    const EdgeInsets.only(
                                        right: 0, left: 0),
                                    child: ListView.builder(
                                        itemCount: items.length,
                                        itemBuilder:
                                            (context, index) {
                                          return Container(
                                            color: index % 2 ==
                                                1
                                                ? AppColor
                                                .background
                                                : Colors.white,
                                            child: Column(
                                              children: [
                                                Utils.space(
                                                    0, 1),
                                                Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .start,
                                                  children: [
                                                    Utils.space(
                                                        0, 1),
                                                    Expanded(
                                                      child: Align(
                                                          alignment: Alignment.centerRight,
                                                          child: Text(
                                                            items[index].productName,
                                                            textDirection:
                                                            TextDirection.rtl,
                                                            style:
                                                            const TextStyle(fontSize: 12, color: Colors.black),
                                                          )),
                                                    ),
                                                    Utils.space(
                                                        0, 1),
                                                    Expanded(
                                                      child:
                                                      Row(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              NewButton(
                                                                backgroundColor: Colors.grey,
                                                                icon: Icons.add,
                                                                padding: 2,
                                                                iconSize: 25,
                                                                onTap: () => _addQuantity(index),
                                                              ),
                                                              SizedBox(
                                                                  width: 40,
                                                                  child: Text(
                                                                    items[index].qty.toStringAsFixed(2),
                                                                    textAlign: TextAlign.center,
                                                                    style: const TextStyle(
                                                                        fontSize: 12,
                                                                        // fontWeight: FontWeight.w900,
                                                                        color: Colors.black),
                                                                  )),
                                                              NewButton(
                                                                backgroundColor: Colors.grey,
                                                                icon: Icons.remove,
                                                                padding: 2,
                                                                iconSize: 25,
                                                                onTap: () => _removeQuantity(index),
                                                              ),
                                                            ],
                                                          ),
                                                          Utils.space(
                                                              0,
                                                              1),
                                                          Expanded(
                                                              child: Text(
                                                                items[index].price.toStringAsFixed(2),
                                                                style:
                                                                TextStyle(fontSize: 12, color: widget.isCreditNote! ? Colors.red : Colors.black),
                                                              )),
                                                          Utils.space(
                                                              0,
                                                              1),
                                                          Expanded(
                                                              child: Text(
                                                                (items[index].qty * (items[index].price)).toStringAsFixed(2),
                                                                style:
                                                                TextStyle(fontSize: 12, color: widget.isCreditNote! ? Colors.red : Colors.black),
                                                              )),
                                                        ],
                                                      ),
                                                    ),

                                                    ///Remove item from list
                                                    NewButton(
                                                      backgroundColor:
                                                      Colors
                                                          .grey,
                                                      padding:
                                                      2,
                                                      icon: Icons
                                                          .clear,
                                                      iconSize:
                                                      25,
                                                      onTap:
                                                          () async {
                                                        setState(
                                                                () {
                                                              num lineTotal =
                                                                  items[index].qty * items[index].price;
                                                              total =
                                                                  total - lineTotal;
                                                              items.removeAt(
                                                                  index);
                                                            });
                                                      },
                                                    ),
                                                    Utils.space(
                                                        0, 1),
                                                  ],
                                                ),
                                                Utils.space(
                                                    0, 1),
                                                const Divider(
                                                  thickness: 1,
                                                  height: 0,
                                                ),
                                              ],
                                            ),
                                          );
                                        }),
                                  ),
                                ],
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

    ],
  );

  Widget buildButtonSave() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor:
          isManualInvoice ? AppColor.primary : AppColor.background,
          backgroundColor:
          isManualInvoice ? AppColor.background : AppColor.primary,
        ),
        onPressed: saveAndPrint,
        child: widget.isPurchases == true
            ? Text(language == 'Arabic' ? 'حفظ' : 'Save')
            : Text(language == 'Arabic' ? 'حفظ/طباعة' : 'Print'),
      ),
    );
  }

  Widget buildButtonPreview() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor:
          isManualInvoice ? AppColor.primary : AppColor.background,
          backgroundColor:
          isManualInvoice ? AppColor.background : AppColor.primary,
        ),
        onPressed: printPreview,
        child: Text(language == 'Arabic' ? 'عرض' : 'View'),
      ),
    );
  }

  Widget buildButtonEstimate() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor:
          isManualInvoice ? AppColor.primary : AppColor.background,
          backgroundColor:
          isManualInvoice ? AppColor.background : AppColor.primary,
        ),
        onPressed: printEstimate,
        child: Text(language == 'Arabic' ? 'عرض سعر' : 'Estimate'),
      ),
    );
  }

  Widget buildButtonPost() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor:
          isManualInvoice ? AppColor.primary : AppColor.background,
          backgroundColor:
          isManualInvoice ? AppColor.background : AppColor.primary,
        ),
        onPressed: () async {
          String message =
              'لن يمكنك تعديل/حذف هذه الفاتورة بعد عملية الترحيل\nهل أنت متأكد من هذا الإجراء';
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('رسالة'),
                content: Text(message),
                actions: <Widget>[
                  // usually buttons at the bottom of the dialog
                  TextButton(
                    child: const Text("نعم"),
                    onPressed: () async {
                      if (widget.invoice != null) {
                        Invoice invoice = Invoice(
                          id: id,
                          invoiceNo: invoiceNo,
                          date: Utils.formatDate(DateTime.now()),
                          sellerId: seller.id,
                          total: total,
                          totalDiscount: totalDiscount,
                          totalVat: total - (total / 1.15),
                          posted: 1,
                          payerId: payer.id,
                          noOfLines: items.length,
                        );
                        await FatooraDB.instance.updateInvoice(invoice);
                        await FatooraDB.instance.deleteInvoiceLines(id);
                        for (int i = 0; i < items.length; i++) {
                          await FatooraDB.instance
                              .createInvoiceLines(items[i], items[i].recId);
                        }

                        // Get.to(() => const InvoicesPage());
                      } else {
                        messageBox('يجب حفظ الفاتورة قبل الترحيل');
                      }
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
        },
        child: const Text('ترحيل'),
      ),
    );
  }

  Widget buildSwitch() => Switch(
      value: isManualInvoice,
      activeColor: isManualInvoice ? AppColor.background : null,
      inactiveThumbColor: isManualInvoice ? null : AppColor.primary,
      onChanged: (value) => setState(() => isManualInvoice = value));

  Widget buildProductName() => DropdownSearch<String>(
    popupProps: const PopupProps.menu(
      showSearchBox: true,
      showSelectedItems: true,
      searchFieldProps: TextFieldProps(),
    ),
    dropdownDecoratorProps: DropDownDecoratorProps(
      baseStyle: fontStyle,
      dropdownSearchDecoration: InputDecoration(
        labelText: language == 'Arabic' ? 'المنتج' : 'Product',
      ),
    ),
    items: productsList,
    onChanged: (val) async {
      int productId = int.parse(val!.split('-')[0]);
      Product prod = await FatooraDB.instance.getProductById(productId);
      num? productPrice = prod.price;
      setState(() {
        _productName.text = val;
        // _price.text = Utils.formatNoCurrency(productPrice!);
        _price.text = (productPrice!.toString());
        _priceWithoutVat.text = Utils.formatNoCurrency(productPrice / 1.15);
      });
    },
    selectedItem: _productName.text,
  );

  Widget buildInvoiceDate() => TextFormField(
    controller: _date,
    style: fontStyle,
    decoration: InputDecoration(
      labelText: language == 'Arabic' ? 'التاريخ' : 'Date',
      prefixIcon: InkWell(onTap: _selectDate, child: const Icon(Icons.date_range),),
    ),
    validator: (invoiceNo) =>
    invoiceNo == null || invoiceNo == '' ? 'يجب إدخال التاريخ' : null,
  );

  Widget buildInvoiceNo() => TextFormField(
    controller: _invoiceNo,
    autofocus: true,
    onTap: () {
      var textValue = _invoiceNo.text;
      _invoiceNo.selection = TextSelection(
        baseOffset: 0,
        extentOffset: textValue.length,
      );
    },
    style: fontStyle,
    decoration: InputDecoration(
      labelText: language == 'Arabic' ? 'رقم الفاتورة' : 'Invoice No',
    ),
    validator: (invoiceNo) => invoiceNo == null || invoiceNo == ''
        ? 'يجب إدخال رقم الفاتورة'
        : null,
  );

  Widget buildQty() => TextFormField(
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    controller: _qty,
    onTap: () {
      var textValue = _qty.text;
      _qty.selection = TextSelection(
        baseOffset: 0,
        extentOffset: textValue.length,
      );
    },
    style: fontStyle,
    decoration: InputDecoration(
      labelText: activity == "OilServices"
          ? language == 'Arabic'
          ? 'الكمية/اللترات'
          : 'Qty/Litre'
          : language == 'Arabic'
          ? 'الكمية'
          : 'Qty',
    ),
    validator: (qty) =>
    qty == null || qty == '' ? 'يجب إدخال الكمية' : null,
    onChanged: (value) => _totalPrice.text =
    "${Utils.formatNoCurrency(num.parse(value) * num.parse(_price.text))}",
  );

  Widget buildPrice() => TextFormField(
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    controller: _price,
    onTap: () {
      var textValue = _price.text;
      _price.selection = TextSelection(
        baseOffset: 0,
        extentOffset: textValue.length,
      );
    },
    style: fontStyle,
    decoration: InputDecoration(
      labelText:
      language == 'Arabic' ? 'السعر مع الضريبة' : 'Price VAT Included',
    ),
    validator: (price) =>
    price == null || price == '' ? 'يجب إدخال سعر المنتج' : null,
    onChanged: (value) => _priceWithoutVat.text =
    "${Utils.formatNoCurrency(num.parse(value) / 1.15)}",
  );

  Widget buildDiscount() => TextFormField(
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    controller: _discount,
    onTap: () {
      var textValue = _discount.text;
      _discount.selection = TextSelection(
        baseOffset: 0,
        extentOffset: textValue.length,
      );
    },
    style: fontStyle,
    decoration: InputDecoration(
      labelText: language == 'Arabic' ? 'الخصم' : 'Discount',
    ),
  );

  Widget buildTotalPrice() => TextFormField(
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    controller: _totalPrice,
    onTap: () {
      var textValue = _totalPrice.text;
      _totalPrice.selection = TextSelection(
        baseOffset: 0,
        extentOffset: textValue.length,
      );
    },
    style: fontStyle,
    decoration: InputDecoration(
      labelText: language == 'Arabic' ? 'المبلغ' : 'Paid Amount',
    ),
    validator: (price) =>
    price == null || price == '' ? 'يجب ادخال المبلغ' : null,
    onChanged: (value) => _qty.text =
    "${Utils.formatNoCurrency(num.parse(value) / num.parse(_price.text))}",
  );

  Widget buildPriceWithoutVat() => TextFormField(
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    controller: _priceWithoutVat,
    onTap: () {
      var textValue = _priceWithoutVat.text;
      _priceWithoutVat.selection = TextSelection(
        baseOffset: 0,
        extentOffset: textValue.length,
      );
    },
    style: fontStyle,
    decoration: InputDecoration(
      labelText:
      language == 'Arabic' ? 'السعر بدون ضريبة' : 'Price VAT Excluded',
    ),
    validator: (price) =>
    price == null || price == '' ? 'يجب إدخال سعر المنتج' : null,
    onChanged: (value) =>
    _price.text = "${Utils.formatNoCurrency(num.parse(value) * 1.15)}",
  );

  Widget buildInsertButton() => Padding(
    padding: const EdgeInsets.only(top: 20),
    child: InkWell(
      onTap: () async {
        String price = _price.text.replaceAll(',', '');
        int productId = int.parse(_productName.text.split('-')[0]);
        String barcode =
        await FatooraDB.instance.getProductBarcode(productId);
        String unit = await FatooraDB.instance.getProductUnit(productId);
        if (_productName.text != '' &&
            num.parse(_qty.text) > 0 &&
            num.parse(price) >= 0) {
          setState(() {
            items.add(InvoiceLines(
              productName: num.parse(price) == 0
                  ? '${_productName.text.split('-')[1]}- مجاناً'
                  : _productName.text.split('-')[1],
              barcode: barcode,
              unit: unit,
              qty: num.parse(_qty.text.toString()),
              price: num.parse(price),
              discount: num.parse(_discount.text),
              recId: recId,
            ));
            num lineTotal = (num.parse(_qty.text) * num.parse(price)) -
                num.parse(_discount.text);
            num lineDiscount = num.parse(_discount.text);
            total = total + lineTotal;
            totalDiscount = totalDiscount + lineDiscount;
            _productName.clear();
            _qty.text = activity == "OilServices" ? '0.00' : '1';
            _price.text = '0.00';
            _discount.text = '0.00';
            _totalPrice.text = '0.00';
            _priceWithoutVat.text = '0.00';
            focusNode.requestFocus();
          });
        }
      },
      child: const Icon(
        Icons.add_shopping_cart_sharp,
        size: 40,
        color: AppColor.primary,
      ),
    ),
  );

  Widget buildPurchaseInvoiceBody() => Container(
    height: MediaQuery.of(context).size.height * 0.90,
    width: MediaQuery.of(context).size.width,
    padding: const EdgeInsets.all(20),
    child: Form(
      key: _key2,
      child: Column(
        children: [
          buildVendor(),
          Row(
            children: [
              Expanded(child: buildVendorVatNumber()),
              Utils.space(0, 4),
              Expanded(child: buildDate()),
            ],
          ),
          Row(
            children: [
              Expanded(child: buildTotalPurchases()),
              Utils.space(0, 4),
              Expanded(child: buildVatPurchases()),
            ],
          ),
          buildDetails(),
          Center(
            child: Utils.isHandScanner
                ? Container()
                : Platform.isWindows
                ? Container()
                : ElevatedButton(
              onPressed: () {
                controller!.resumeCamera();
              },
              child: Text(language == 'Arabic'
                  ? 'اعادة تشغيل القارئ'
                  : 'Restart Scanner'),
            ),
          ),
          Expanded(
              child: Utils.isHandScanner
                  ? _buildQRText()
                  : _buildQrView(context)),
        ],
      ),
    ),
  );

  Widget _buildQRText() => TextField(
    controller: textQRCode,
    focusNode: focusNode,
    textAlign: TextAlign.center,
    style: const TextStyle(fontSize: 12),
    // readOnly: true,
    decoration: const InputDecoration(
      labelText: 'كود الكيو آر',
    ),
    onChanged:
    textQRCode.text.isNotEmpty ? _getQRData(textQRCode.text) : null,
  );

  _getQRData(String qrStr) {
    final qrString = QRBarcodeEncoder.toBase64Decode(qrStr);
    // String tagString = qrString.substring(0,2).toString();
    List<int> bytes = utf8.encode(qrString);
    int sellerLength = bytes[1].toInt();
    int taxNumberLength = bytes[sellerLength + 3].toInt();
    int dateLength = bytes[sellerLength + taxNumberLength + 5].toInt();
    int totalLength =
    bytes[sellerLength + taxNumberLength + dateLength + 7].toInt();
    int vatLength =
    bytes[sellerLength + taxNumberLength + dateLength + totalLength + 9]
        .toInt();
    List<int> sellerBytes = [];
    List<int> taxNumberBytes = [];
    List<int> dateBytes = [];
    List<int> totalBytes = [];
    List<int> vatBytes = [];
    for (int i = 0; i < sellerLength; i++) {
      sellerBytes.add(bytes[i + 2]);
    }
    int j = sellerLength + 2;
    for (int i = j; i < j + taxNumberLength; i++) {
      taxNumberBytes.add(bytes[i + 2]);
    }
    int k = j + taxNumberLength + 2;
    for (int i = k; i < k + dateLength; i++) {
      dateBytes.add(bytes[i + 2]);
    }
    int l = k + dateLength + 2;
    for (int i = l; i < l + totalLength; i++) {
      totalBytes.add(bytes[i + 2]);
    }
    int m = l + totalLength + 2;
    for (int i = m; i < m + vatLength; i++) {
      vatBytes.add(bytes[i + 2]);
    }

    _vendor.text = (utf8.decode(sellerBytes));
    _vendorVatNumber.text = (utf8.decode(taxNumberBytes));
    _date.text = (utf8.decode(dateBytes));
    _totalPurchases.text = (utf8.decode(totalBytes));
    _vatPurchases.text = (utf8.decode(vatBytes));

    textQRCode.text = "";
    focusNode.requestFocus();
  }

  Widget buildVendor() => TextFormField(
    controller: _vendor,
    keyboardType: TextInputType.name,
    style: fontStyle,
    decoration: InputDecoration(
      labelText: language == 'Arabic' ? 'اسم المورد' : 'Vendor Name',
    ),
    validator: (value) =>
    value != null && value.isEmpty ? 'يجب إدخال اسم المورد' : null,
  );

  Widget buildDetails() => TextFormField(
    controller: _details,
    keyboardType: TextInputType.name,
    maxLines: 3,
    style: fontStyle,
    decoration: InputDecoration(
      labelText: language == 'Arabic' ? 'التفاصيل' : 'Details',
    ),
  );

  Widget buildVendorVatNumber() => TextFormField(
    controller: _vendorVatNumber,
    keyboardType: TextInputType.number,
    style: fontStyle,
    decoration: InputDecoration(
      labelText:
      language == 'Arabic' ? 'الرقم الضريبي للمورد' : 'Vendor VAT No',
    ),
    validator: (value) => value != null && value.length != 15
        ? 'يجب إدخال الرقم الضريبي للمورد 15 رقم'
        : null,
  );

  Widget buildTotalPurchases() => TextFormField(
    controller: _totalPurchases,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    style: fontStyle,
    decoration: InputDecoration(
      labelText: language == 'Arabic' ? 'إجمالي الفاتورة' : 'Total Invoice',
    ),
    validator: (value) =>
    value!.isEmpty ? 'يجب إدخال إجمالي الفاتورة' : null,
    onChanged: (value) => _vatPurchases.text =
    "${Utils.formatNoCurrency(num.parse(_totalPurchases.text) - (num.parse(_totalPurchases.text) / 1.15))}",
  );

  Widget buildVatPurchases() => TextFormField(
    controller: _vatPurchases,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    style: fontStyle,
    decoration: InputDecoration(
      labelText:
      language == 'Arabic' ? 'ضريبة القيمة المضافة' : 'VAT Amount',
    ),
    readOnly: true,
  );

  Widget buildPayer() => DropdownSearch<String>(
    popupProps:
    const PopupProps.menu(showSearchBox: true, showSelectedItems: true),
    dropdownDecoratorProps: DropDownDecoratorProps(
      baseStyle: fontStyle,
      dropdownSearchDecoration: InputDecoration(
          label: Text(language == 'Arabic' ? 'العميل' : 'Customer')),
    ),
    items: customers,
    onChanged: (val) async {
      int id = int.parse(val!.split("-")[0]);
      Customer changedPayer = await FatooraDB.instance.getCustomerById(id);
      setState(() {
        _payer.text = val;
        _payerVatNumber.text = changedPayer.vatNumber;
      });
    },
    selectedItem: _payer.text,
  );

  Widget buildPayMethod() => DropdownSearch<String>(
    popupProps: PopupProps.menu(
        showSelectedItems: true,
        constraints:
        BoxConstraints(maxHeight: Platform.isAndroid ? 225 : 200)),
    dropdownDecoratorProps: DropDownDecoratorProps(
        baseStyle: fontStyle,
        dropdownSearchDecoration: InputDecoration(
            label: Text(language == 'Arabic' ? 'الدفع: ' : 'Pay method '))),
    items: payMethod,
    onChanged: (val) => setState(() {
      selectedPayMethod = val;
    }),
    selectedItem: selectedPayMethod,
  );

  Widget buildInvoiceTemp() => DropdownSearch<String>(
    popupProps: PopupProps.menu(
        showSelectedItems: true,
        constraints:
        BoxConstraints(maxHeight: Platform.isAndroid ? 225 : 240)),
    dropdownDecoratorProps: DropDownDecoratorProps(
        baseStyle: fontStyle,
        dropdownSearchDecoration: InputDecoration(
            label: Text(language == 'Arabic' ? 'النموذج: ' : 'Temp'))),
    items: temp,
    onChanged: (val) {
      selectedTemp = val!;
      getTemp(selectedTemp!);
    },
    selectedItem: selectedTemp,
  );

  Widget buildPayerVatNumber() => Text(
    _payerVatNumber.text,
    style: fontStyle,
  );

  Widget buildProject() => TextFormField(
    controller: _project,
    keyboardType: TextInputType.name,
    style: fontStyle,
    decoration: InputDecoration(
      labelText: language == 'Arabic' ? 'اسم المشروع' : 'Project Name',
    ),
    // onChanged: onChangedPayer,
  );

  _selectDate() async {
    String invoiceTime = Utils.invoiceTime(_date.text);
    DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2021),
        lastDate: DateTime(2055));
    if (picked != null) {
      setState(() => _date.text = '${Utils.formatDate(picked).toString()} $invoiceTime');
    }
  }

  _selectSupplyDate() async {
    DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2021),
        lastDate: DateTime(2055));
    if (picked != null) {
      setState(() => _supplyDate.text = Utils.formatDate(picked));
    }
  }

  Widget buildDate() => InkWell(
    onTap: () => _selectDate(),
    child: IgnorePointer(
      child: TextFormField(
        controller: _date,
        keyboardType: TextInputType.text,
        style: fontStyle,
        decoration: InputDecoration(
          labelText:
          language == 'Arabic' ? 'تاريخ الفاتورة' : 'Invoice Date',
        ),
        // onChanged: onChangedPayer,
      ),
    ),
  );

  Widget buildSupplyDate() => InkWell(
    onTap: () => _selectSupplyDate(),
    child: IgnorePointer(
      child: TextFormField(
        controller: _supplyDate,
        keyboardType: TextInputType.text,
        style: fontStyle,
        decoration: InputDecoration(
          labelText: language == 'Arabic' ? 'تاريخ التوريد' : 'Supply Date',
        ),
        // onChanged: onChangedPayer,
      ),
    ),
  );

  void saveAndPrint() {
    setState(() {
      isPreview = false;
    });
    addOrUpdateInvoice();
  }

  void printPreview() {
    setState(() {
      isPreview = true;
      isEstimate = false;
    });
    addOrUpdateInvoice();
  }

  void printEstimate() {
    setState(() {
      isEstimate = true;
      isPreview = false;
    });
    addOrUpdateInvoice();
  }

  /// To add/update invoice to database
  void addOrUpdateInvoice() async {
    if (widget.isPurchases == false) {
      final isValid = Platform.isAndroid
          ? true
          : isManualInvoice
          ? _key1.currentState!.validate()
          : true;
      final hasLines = items.isNotEmpty ? true : false;

      if (!hasLines) {
        messageBox('يجب إدخال سطور للفاتورة');
      }

      if (isValid && hasLines) {
        final isUpdating = widget.invoice != null;
        setState(() {
          isLoading = true;
        });

        if (isUpdating) {
          await updateInvoice();
        } else {
          await addInvoice();
        }
        if (!isPreview && !isEstimate) {
          printTicket();
        }
        setState(() {
          isLoading = false;
        });

        // Get.to(() => const InvoicesPage());
      }
    } else {
      final isValid = _key2.currentState!.validate();
      if (isValid) {
        final isUpdating = widget.purchase != null;

        setState(() {
          isLoading = true;
        });
        if (isUpdating) {
          await updateInvoice();
        } else {
          await addInvoice();
        }
        setState(() {
          isLoading = false;
        });
        confirmSave();
      }
    }
  }

  Future updateInvoice() async {
    if (widget.isPurchases == false) {
      int payerId = int.parse(_payer.text.split("-")[0]);
      Customer currentPayer = await FatooraDB.instance.getCustomerById(payerId);
      Invoice invoice = Invoice(
        id: id,
        invoiceNo: _invoiceNo.text,
        date: _date.text,
        supplyDate: _supplyDate.text,
        sellerId: seller.id,
        project: _project.text,
        total: total,
        totalDiscount: totalDiscount,
        totalVat: total - (total / 1.15),
        posted: 0,
        payerId: payerId,
        noOfLines: items.length,
        paymentMethod: selectedPayMethod!,
        template: selectedTemp!,
      );

      await FatooraDB.instance.updateInvoice(invoice);
      await FatooraDB.instance.deleteInvoiceLines(id);

      for (int i = 0; i < items.length; i++) {
        await FatooraDB.instance.createInvoiceLines(items[i], items[i].recId);
      }
      // getTemp(selectedTemp);
      Utils.isA4Invoice && isEstimate
          ? await InvoiceTemp1.generate(
          invoice, currentPayer, seller, items, tempId!, template)
          : Utils.isA4Invoice && isPreview
          ? await InvoiceTemp1.generate(
          invoice, currentPayer, seller, items, tempId!, template)
          : await PdfReceipt.generate(
          invoice,
          currentPayer,
          seller,
          items,
          invoice.posted == 1
              ? 'فاتورة مبيعات ضريبية مرحلة'
              : 'فاتورة مبيعات ضريبية',
          invoice.project,
          Utils.isProVersion,
          isPreview);
    } else {
      String newTtl = _totalPurchases.text.replaceAll(',', '');
      num ttl = num.parse(newTtl);
      Purchase purchase = Purchase(
        id: id,
        date: _date.text,
        vendor: _vendor.text,
        vendorVatNumber: _vendorVatNumber.text,
        total: ttl,
        totalVat: ttl - (ttl / 1.15),
        details: _details.text,
      );
      await FatooraDB.instance.updatePurchase(purchase);
    }
  }

  Future addInvoice() async {
    if (widget.isPurchases == false) {
      int payerId = int.parse(_payer.text.split("-")[0]);
      Customer currentPayer = await FatooraDB.instance.getCustomerById(payerId);
      Invoice invoice = Invoice(
        invoiceNo: _invoiceNo.text,
        date: _date.text,
        supplyDate: _supplyDate.text,
        sellerId: seller.id,
        project: _project.text,
        total: total,
        totalDiscount: totalDiscount,
        totalVat: total - (total / 1.15),
        posted: 0,
        payerId: payerId,
        noOfLines: items.length,
        paymentMethod: selectedPayMethod!,
        template: selectedTemp!,
      );
      await FatooraDB.instance.createInvoice(invoice);

      for (int i = 0; i < items.length; i++) {
        await FatooraDB.instance.createInvoiceLines(items[i], items[i].recId);
      }
      // getTemp(selectedTemp);
      Utils.isA4Invoice && isEstimate
          ? await InvoiceTemp1.generate(
          invoice, currentPayer, seller, items, tempId!, template)
          : Utils.isA4Invoice && isPreview
          ? await InvoiceTemp1.generate(
          invoice, currentPayer, seller, items, tempId!, template)
          : await PdfReceipt.generate(
          invoice,
          currentPayer,
          seller,
          items,
          invoice.posted == 1
              ? 'فاتورة مبيعات ضريبية مرحلة'
              : 'فاتورة مبيعات ضريبية',
          invoice.project,
          Utils.isProVersion,
          isPreview);
      // }
    } else {
      num ttl = num.parse(_totalPurchases.text);
      Purchase purchase = Purchase(
        date: _date.text,
        vendor: _vendor.text,
        vendorVatNumber: _vendorVatNumber.text,
        total: ttl,
        totalVat: ttl - (ttl / 1.15),
        details: _details.text,
      );
      await FatooraDB.instance.createPurchase(purchase);
    }
  }

  _addQuantity(int index) {
    setState(() {
      {
        num newQty = items[index].qty;
        String productName = items[index].productName;
        String barcode = items[index].barcode;
        String unit = items[index].unit;
        num price = items[index].price;
        num discount = items[index].discount;
        items.insert(
            index,
            InvoiceLines(
              productName: productName,
              barcode: barcode,
              unit: unit,
              qty: newQty + 1,
              price: price,
              discount: discount,
              recId: recId,
            ));
        items.removeAt(index + 1);
      }
      total = 0;
      totalDiscount = 0;
      for (int i = 0; i < items.length; i++) {
        total = total + (((items[i].qty) * items[i].price) - items[i].discount);
        totalDiscount = totalDiscount + items[i].discount;
      }
    });
  }

  _removeQuantity(int index) {
    setState(() {
      {
        num newQty = items[index].qty;
        String productName = items[index].productName;
        num price = items[index].price;
        num discount = items[index].discount;
        if (newQty > 1) {
          items.insert(
              index,
              InvoiceLines(
                // id: index,
                productName: productName,
                qty: newQty - 1,
                price: price,
                discount: discount,
                recId: recId,
              ));
          items.removeAt(index + 1);
        }
      }
      total = 0;
      totalDiscount = 0;
      for (int i = 0; i < items.length; i++) {
        total = total + (((items[i].qty) * items[i].price) - items[i].discount);
        totalDiscount = totalDiscount + items[i].discount;
      }
    });
  }

  /// Start and build QR code scanner
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid && widget.isPurchases == true) {
      if (!Utils.isHandScanner) {
        controller!.pauseCamera();
        controller!.resumeCamera();
      }
    }
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
        MediaQuery.of(context).size.height < 400)
        ? 200.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return Platform.isAndroid
        ? sc.QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: sc.QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    )
        : Container();
  }

  void _onQRViewCreated(sc.QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        qResult = scanData;
        final qrString = QRBarcodeEncoder.toBase64Decode(qResult!.code!);

        // String tagString = qrString.substring(0,2).toString();
        List<int> bytes = utf8.encode(qrString);
        int sellerLength = bytes[1].toInt();
        int taxNumberLength = bytes[sellerLength + 3].toInt();
        int dateLength = bytes[sellerLength + taxNumberLength + 5].toInt();
        int totalLength =
        bytes[sellerLength + taxNumberLength + dateLength + 7].toInt();
        int vatLength =
        bytes[sellerLength + taxNumberLength + dateLength + totalLength + 9]
            .toInt();
        List<int> sellerBytes = [];
        List<int> taxNumberBytes = [];
        List<int> dateBytes = [];
        List<int> totalBytes = [];
        List<int> vatBytes = [];
        for (int i = 0; i < sellerLength; i++) {
          sellerBytes.add(bytes[i + 2]);
        }
        int j = sellerLength + 2;
        for (int i = j; i < j + taxNumberLength; i++) {
          taxNumberBytes.add(bytes[i + 2]);
        }
        int k = j + taxNumberLength + 2;
        for (int i = k; i < k + dateLength; i++) {
          dateBytes.add(bytes[i + 2]);
        }
        int l = k + dateLength + 2;
        for (int i = l; i < l + totalLength; i++) {
          totalBytes.add(bytes[i + 2]);
        }
        int m = l + totalLength + 2;
        for (int i = m; i < m + vatLength; i++) {
          vatBytes.add(bytes[i + 2]);
        }

        _vendor.text = (utf8.decode(sellerBytes));
        _vendorVatNumber.text = (utf8.decode(taxNumberBytes));
        _date.text = (utf8.decode(dateBytes));
        _totalPurchases.text = (utf8.decode(totalBytes));
        _vatPurchases.text = (utf8.decode(vatBytes));

        controller.stopCamera();
      });
    });
  }

  void _onPermissionSet(
      BuildContext context, sc.QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  changeToCashCustomer() {
    setState(() {
      _payer.text = "1-عميل نقدي";
    });
  }

  /// End of QR code scanner

  Future<void> getTemp(String selectedTemp) async {
    switch (selectedTemp) {
      case 'نموذج 1':
        tempId = 1;
        template = await FatooraDB.instance.getTemplateById(tempId!);
        break;
      case 'نموذج 2':
        tempId = 2;
        template = await FatooraDB.instance.getTemplateById(tempId!);
        break;
      // case 'نموذج 3':
      //   tempId = 3;
      //   template = await FatooraDB.instance.getTemplateById(tempId!);
      //   break;
      // case 'نموذج 4':
      //   tempId = 4;
      //   template = await FatooraDB.instance.getTemplateById(tempId!);
      //   break;
      // case 'نموذج 5':
      //   tempId = 5;
      //   template = await FatooraDB.instance.getTemplateById(tempId!);
      //   break;
      default:
        break;
    }
  }
}
