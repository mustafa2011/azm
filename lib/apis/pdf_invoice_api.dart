import 'dart:convert';
import 'dart:io';

import '../apis/pdf_api.dart';
import '../apis/qr_tag/invoice_date.dart';
import '../apis/qr_tag/invoice_tax_amount.dart';
import '../apis/qr_tag/invoice_total_amount.dart';
import '../apis/qr_tag/qr_encoder.dart';
import '../apis/qr_tag/seller.dart';
import '../apis/qr_tag/tax_number.dart';
import '../models/customers.dart';
import '../models/invoice.dart';
import '../models/settings.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import '../models/template.dart';
import 'constants/utils.dart';

class DefaultInvoiceTemp {
  static Future<Future<File>> generate(
      Invoice invoice,
      Customer customer,
      Setting seller,
      List<InvoiceLines> invoiceLines,
      String title,
      String subTitle,
      bool isPreview,
      {bool isEstimate = false}) async {
    var myTheme = ThemeData.withFont(
      base: Font.ttf(await rootBundle.load("assets/fonts/Cairo-Regular.ttf")),
      bold: Font.ttf(await rootBundle.load("assets/fonts/Cairo-Bold.ttf")),
    );
    final pdf = Document(theme: myTheme);
    final showPayMethod = await Utils.payMethod() == 'اظهار' ? true : false;
    pdf.addPage(MultiPage(
        margin: const EdgeInsets.all(30),
        build: (context) => [
              buildHeader(invoice, customer, seller, title, subTitle, isPreview,
                  isEstimate),
              SizedBox(height: 1 * PdfPageFormat.cm),
              buildInvoice(invoice, invoiceLines),
              // Divider(),
              buildTotal(invoice, seller, showPayMethod),
              buildTerms(seller),
            ],
        footer: (context) {
          return Container(
              alignment: Alignment.center,
              child: Text("صفحة ${context.pagesCount}/${context.pageNumber}: ",
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.black)));
        }));

    /*return PdfApi.previewDocument(
        name: '${invoice.invoiceNo}.pdf',
        pdf: pdf,
        invoiceMonth: invoice.date.substring(5, 7),
        invoiceYear: invoice.date.substring(0, 4));*/
    return PdfApi.previewDocument(invoice: invoice, pdf: pdf);
  }

  static Widget buildHeader(Invoice invoice, Customer customer, Setting seller,
          String title, String subTitle, bool isPreview, bool isEstimate) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            buildLogo(seller),
            buildTitle(invoice, title, subTitle),
          ]),
          Divider(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildInvoiceInfo(invoice, title, isPreview, isEstimate),
              Container(),
              // buildCustomerAddress(invoice.customer),
            ],
          ),
          SizedBox(height: 1 * PdfPageFormat.cm),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Container(
                width: 260,
                color: PdfColors.grey300,
                child: Text('بيانات المورد',
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
              ),
              buildSimpleText(title: 'اسم المورد:', value: seller.seller),
              buildSimpleText(title: 'الرقم الضريبي:', value: seller.vatNumber),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  buildSimpleText(
                      title: 'رقم المبنى:', value: seller.buildingNo),
                  buildSimpleText(title: 'الحي:', value: seller.district),
                  buildSimpleText(title: 'البلد:', value: seller.country),
                  buildSimpleText(
                      title: 'الرقم الإضافي للعنوان:',
                      value: seller.additionalNo),
                ]),
                SizedBox(width: 10),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  buildSimpleText(
                      title: 'رقم الاتصال:', value: seller.cellphone),
                  buildSimpleText(title: 'الشارع:', value: seller.streetName),
                  buildSimpleText(title: 'المدينة:', value: seller.city),
                  buildSimpleText(
                      title: 'الرمز البريدي:', value: seller.postalCode),
                ]),
              ]),
            ]),
            SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Container(
                width: 260,
                color: PdfColors.grey300,
                child: Text('بيانات العميل',
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
              ),
              buildSimpleText(title: 'اسم العميل:', value: customer.name),
              buildSimpleText(
                  title: 'الرقم الضريبي:', value: customer.vatNumber),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  buildSimpleText(
                      title: 'رقم المبنى:', value: customer.buildingNo),
                  buildSimpleText(title: 'الحي:', value: customer.district),
                  buildSimpleText(title: 'البلد:', value: customer.country),
                  buildSimpleText(
                      title: 'الرقم الإضافي للعنوان:',
                      value: customer.additionalNo),
                ]),
                SizedBox(width: 10),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  buildSimpleText(
                      title: 'رقم الاتصال:', value: customer.contactNumber),
                  buildSimpleText(title: 'الشارع:', value: customer.streetName),
                  buildSimpleText(title: 'المدينة:', value: customer.city),
                  buildSimpleText(
                      title: 'الرمز البريدي:', value: customer.postalCode),
                ]),
              ]),
            ]),
          ]),
        ],
      );

  static Widget buildCustomerAddress(Invoice invoice, Customer customer) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            customer.buildingNo,
            textDirection: TextDirection.rtl,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          // Text('customer.address', textDirection: TextDirection.rtl),
        ],
      );

  static Widget buildInvoiceInfo(
      Invoice invoice, String title, bool isPreview, bool isEstimate) {
    final titles = <String>[
      title == 'إشعار دائن'
          ? 'رقم الإشعار'
          : isEstimate
              ? 'رقم عرض السعر'
              : 'رقم الفاتورة',
      'التاريخ:',
      // 'تاريخ التوريد:',
    ];
    final data = <String>[
      invoice.invoiceNo,
      invoice.date,
      // invoice.supplyDate,
    ];

    return Column(
      children: List.generate(titles.length, (index) {
        final value = data[index];
        final title = titles[index];

        return buildText(title: title, value: value, width: 200);
      }),
    );
  }

  static Widget buildLogo(Setting seller) => Container(
      width: seller.logoWidth.toDouble(),
      height: seller.logoHeight.toDouble(),
      decoration: BoxDecoration(
          image: DecorationImage(
              fit: BoxFit.fill,
              image: MemoryImage(base64Decode(seller.logo)))));

  static Widget buildSupplierAddress(Setting seller) => Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(seller.seller,
              textDirection: TextDirection.rtl,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 1 * PdfPageFormat.mm),
          buildSimpleText(title: "الرقم الضريبي", value: seller.vatNumber),
        ],
      );

  static Widget buildTitle(Invoice invoice, String title, String subTitle) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            title,
            textDirection: TextDirection.rtl,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            subTitle,
            textDirection: TextDirection.rtl,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          // SizedBox(height: 0.8 * PdfPageFormat.cm),
        ],
      );

  static Widget buildInvoice(Invoice invoice, List<InvoiceLines> invoiceLines) {
    final data = invoiceLines.map((item) {
      final total = item.qty * item.price;
      return [
        '${Utils.format(total)}',
        '${Utils.formatPercent(0.15 * 100)}',
        '${Utils.format(item.price / 1.15)}',
        '${item.qty}',
        item.productName,
      ];
    }).toList();

    return Container(
        child: Column(children: [
      Container(
        padding: const EdgeInsets.all(2),
        color: PdfColors.grey300,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 2.5 * PdfPageFormat.cm,
              margin: const EdgeInsets.only(right: 2.25, left: 0),
              child: Column(children: [
                Text(
                  "الإجمالي",
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.black),
                ),
                Text(
                  "Total",
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.black),
                ),
              ]),
            ),
            Container(
              width: 2 * PdfPageFormat.cm,
              margin: const EdgeInsets.only(right: 2.25, left: 2.25),
              child: Column(children: [
                Text(
                  "الضريبة",
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.black),
                ),
                Text(
                  "VAT",
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.black),
                ),
              ]),
            ),
            Container(
              width: 2 * PdfPageFormat.cm,
              margin: const EdgeInsets.only(right: 2.25, left: 2.25),
              child: Column(children: [
                Text(
                  "السعر",
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.black),
                ),
                Text(
                  "Price",
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: PdfColors.black),
                ),
              ]),
            ),
            Container(
                width: 2 * PdfPageFormat.cm,
                margin: const EdgeInsets.only(right: 2.25, left: 2.25),
                child: Column(children: [
                  Text(
                    "الكمية",
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.black),
                  ),
                  Text(
                    "Qty",
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.black),
                  ),
                ])),
            Container(
                width: 9.5 * PdfPageFormat.cm,
                margin: const EdgeInsets.only(right: 0, left: 2.25),
                child: Column(children: [
                  Text(
                    "البيان",
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.black),
                  ),
                  Text(
                    "Description",
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: PdfColors.black),
                  ),
                ])),
          ],
        ),
      ),
      ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            return Container(
              // padding: const EdgeInsets.all(4),
              color: index % 2 == 1 ? PdfColors.grey100 : PdfColors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: 2.5 * PdfPageFormat.cm,
                    margin: const EdgeInsets.only(right: 2.25, left: 2.25),
                    child: buildPriceText(currency: '', value: data[index][0]),
                  ),
                  Container(
                    width: 1.5 * PdfPageFormat.cm,
                    margin: const EdgeInsets.only(right: 2.25, left: 2.25),
                    child: Text(
                      data[index][1],
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                  Container(
                    width: 2.5 * PdfPageFormat.cm,
                    margin: const EdgeInsets.only(right: 2.25, left: 2.25),
                    child: buildPriceText(currency: '', value: data[index][2]),
                  ),
                  Container(
                    width: 2 * PdfPageFormat.cm,
                    margin: const EdgeInsets.only(right: 2.25, left: 2.25),
                    child: Text(
                      data[index][3],
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                  Container(
                    width: 9.5 * PdfPageFormat.cm,
                    margin: const EdgeInsets.only(right: 0, left: 2.25),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        data[index][4],
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
      Container(height: 1.5, color: PdfColors.black),
      Container(height: 5, color: PdfColors.white),
    ]));
  }

  static Widget buildTotal(
      Invoice invoice, Setting seller, bool showPayMethod) {
    const vatPercent = 0.15;

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

    return Container(
      // alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Column(
              // crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                buildText(
                  title: 'الإجمالي الصافي بدون الضريبة',
                  value: Utils.format(netTotal),
                  unite: true,
                ),
                buildText(
                  title:
                      'ضريبة القيمة المضافة ${Utils.formatPercent(vatPercent * 100)} ',
                  value: Utils.format(vat),
                  unite: true,
                ),
                Divider(),
                buildText(
                  title: 'المبلغ المستحق',
                  titleStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                  value: Utils.format(total),
                  unite: true,
                ),
                showPayMethod
                    ? buildText(
                        title: 'طريقة الدفع',
                        titleStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                        value: invoice.paymentMethod,
                        unite: true,
                      )
                    : Container(),
              ],
            ),
          ),
          Spacer(flex: 3),
          Container(
            height: 100,
            width: 100,
            child: BarcodeWidget(
              barcode: Barcode.qrCode(),
              data: qrString,
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildTerms(Setting setting) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Divider(),
        buildText(title: 'الشروط والأحكام', value: ''),
        buildConditionText(text: setting.terms),
        Column(children: [
          buildConditionText(text: setting.terms1),
          // Comment this line @ version 1
          buildConditionText(text: setting.terms2),
          // Comment this line @ version 1
          buildConditionText(text: setting.terms3),
          // Comment this line @ version 1
          buildConditionText(text: setting.terms4),
          // Comment this line @ version 1
        ]),
      ],
    );
  }

  static Widget buildFooter(Invoice invoice) => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Divider(),
          SizedBox(height: 2 * PdfPageFormat.mm),
          buildSimpleText(
              title: 'جميع الأسعار تشمل ضريبة القيمة المضافة',
              value: Utils.formatPercent(0.15 * 100)),
          // SizedBox(height: 1 * PdfPageFormat.mm),
          // buildSimpleText(title: 'حسب العقد', value: invoice.supplier.paymentInfo),
        ],
      );

  static buildSimpleText({
    required String title,
    required String value,
  }) {
    final styleTitle = TextStyle(fontWeight: FontWeight.bold, fontSize: 10);
    const styleValue = TextStyle(fontSize: 10);

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(value, textDirection: TextDirection.rtl, style: styleValue),
        SizedBox(width: 2 * PdfPageFormat.mm),
        Text(title, textDirection: TextDirection.rtl, style: styleTitle),
      ],
    );
  }

  static buildText({
    required String title,
    required String value,
    double width = double.infinity,
    TextStyle? titleStyle,
    bool unite = false,
  }) {
    final style =
        titleStyle ?? TextStyle(fontWeight: FontWeight.bold, fontSize: 10);

    return Container(
      width: width,
      child: Row(
        children: [
          Text(value,
              textDirection: TextDirection.rtl, style: unite ? style : null),
          Expanded(
              child:
                  Text(title, textDirection: TextDirection.rtl, style: style)),
        ],
      ),
    );
  }

  static buildConditionText({
    required String text,
    double width = double.infinity,
    TextStyle? titleStyle,
  }) {
    final style = titleStyle ?? const TextStyle(fontSize: 10);

    return Container(
      width: width,
      child: Text('  * $text', textDirection: TextDirection.rtl, style: style),
    );
  }

  static buildPriceText({
    required String value,
    required String currency,
    double width = double.infinity,
    TextStyle? titleStyle,
  }) {
    final style = titleStyle ?? const TextStyle(fontSize: 10);

    return Container(
      width: width,
      child: Row(
        children: [
          Text(currency, textDirection: TextDirection.rtl, style: style),
          Expanded(
              child:
                  Text(value, textDirection: TextDirection.rtl, style: style)),
        ],
      ),
    );
  }
}

class InvoiceTemp1 {
  static double mm = PdfPageFormat.mm;

  static Future<Future<File>> generate(
      Invoice invoice,
      Customer customer,
      Setting seller,
      List<InvoiceLines> lines,
      int tempId,
      List<TemplateDetails> col) async {
    var myTheme = ThemeData.withFont(
      base: Font.ttf(await rootBundle.load("assets/fonts/arial.ttf")),
      bold: Font.ttf(await rootBundle.load("assets/fonts/arialbd.ttf")),
    );
    final pdf = Document(theme: myTheme);

    pdf.addPage(MultiPage(
        margin: const EdgeInsets.all(0),
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
              buildPage(seller, customer, invoice, lines, tempId, col),
            ],
        footer: (context) {
          return Container(alignment: Alignment.center, child: null);
        }));

    return PdfApi.previewDocument(invoice: invoice, pdf: pdf);
  }

  static String arabicNumber(String number) {
    String res = '';

    final arabic = [
      '٠',
      '١',
      '٢',
      '٣',
      '٤',
      '٥',
      '٦',
      '٧',
      '٨',
      '٩',
      '،',
      ',',
      ':',
      '-',
      '/',
      ' '
    ];
    for (int i = 0; i < number.length; i++) {
      if (number[i] == '0') res += arabic[0];
      if (number[i] == '1') res += arabic[1];
      if (number[i] == '2') res += arabic[2];
      if (number[i] == '3') res += arabic[3];
      if (number[i] == '4') res += arabic[4];
      if (number[i] == '5') res += arabic[5];
      if (number[i] == '6') res += arabic[6];
      if (number[i] == '7') res += arabic[7];
      if (number[i] == '8') res += arabic[8];
      if (number[i] == '9') res += arabic[9];
      if (number[i] == '.') res += arabic[10];
      if (number[i] == ',') res += arabic[11];
      if (number[i] == ':') res += arabic[12];
      if (number[i] == '-') res += arabic[13];
      if (number[i] == '/') res += arabic[14];
      if (number[i] == ' ') res += arabic[15];
    }
    return res;
  }

  static Widget lineX(double length,
      {double thickness = 1, double left = 0, double top = 0}) {
    return Container(
      width: length * mm,
      margin: EdgeInsets.only(left: left * mm, top: top * mm),
      child: Divider(height: 0, thickness: thickness),
    );
  }

  static Widget lineY(double length,
      {double thickness = 1, double left = 0, double top = 0}) {
    return Container(
      height: length * mm,
      margin: EdgeInsets.only(left: left * mm, top: top * mm),
      child: VerticalDivider(width: 0, thickness: thickness),
    );
  }

  static Widget qrCode(
      Setting seller, Invoice invoice, List<TemplateDetails> col,
      {double left = 10,
        double top = 10,
        double height = 100,
        double width = 100,
        int isVisible = 1}) {
    final line = col.map((col) {
      return [
        col.tempId,
        col.colName,
        col.colLeft,
        col.colTop,
        col.colWidth,
        col.colHeight,
        col.isVisible
      ];
    }).toList();
    for (int i = 0; i < line.length; i++) {
      if (line[i][1] == 'qrCode') {
        left = double.parse(line[i][2].toString());
        top = double.parse(line[i][3].toString());
        width = double.parse(line[i][4].toString());
        height = double.parse(line[i][5].toString());
        isVisible = int.parse(line[i][6].toString());
      }
    }
    final qrString = QRBarcodeEncoder.encode(
      Seller(seller.seller),
      TaxNumber(seller.vatNumber),
      InvoiceDate(invoice.date),
      InvoiceTotalAmount(invoice.total.toStringAsFixed(2)),
      InvoiceTaxAmount(invoice.totalVat.toStringAsFixed(2)),
    ).toString();
    return isVisible == 0 ? Container() : Container(
      height: height,
      width: width,
      color: PdfColors.white,
      margin: EdgeInsets.only(left: left, top: top),
      padding: const EdgeInsets.all(2),
      child: BarcodeWidget(
        barcode: Barcode.qrCode(),
        data: qrString,
      ),
    );
  }

  static Widget textSeller(
      Setting table, List<TemplateDetails> col, String colName,
      {bool isNumber = false, bool rtl = true}) {
    String text = '';
    double left = 0;
    double top = 0;
    double width = 50;
    double height = 13;
    double fontSize = 12;
    int isBold = 0;
    int isVisible = 1;
    String color = 'white';
    String borderColor = 'white';
    PdfColor? pdfColor;
    PdfColor? pdfBorderColor;
    if (isNumber) rtl = false;
    final line = col.map((col) {
      return [
        col.tempId,
        col.colName,
        col.colTop,
        col.colLeft,
        col.colWidth,
        col.colHeight,
        col.fontSize,
        col.isBold,
        col.backColor,
        col.borderColor,
        col.isVisible,
      ];
    }).toList();
    for (int i = 0; i < line.length; i++) {
      if (line[i][1] == colName) {
        top = double.parse(line[i][2].toString());
        left = double.parse(line[i][3].toString());
        width = double.parse(line[i][4].toString());
        height = double.parse(line[i][5].toString());
        fontSize = double.parse(line[i][6].toString());
        isBold = int.parse(line[i][7].toString());
        color = line[i][8].toString();
        borderColor = line[i][9].toString();
        isVisible = int.parse(line[i][10].toString());
      }
    }
    switch (colName) {
      case 'sellerName':
        text = isVisible == 0 ? '' : table.seller;
        break;
      case 'sellerVatNo':
        text = isVisible == 0 ? '' : table.vatNumber;
        break;
      case 'sellerCellphone':
        text = isVisible == 0 ? '' : table.cellphone;
        break;
      case 'sellerBuildingNo':
        text = isVisible == 0 ? '' : table.buildingNo;
        break;
      case 'sellerStreet':
        text = isVisible == 0 ? '' : table.streetName;
        break;
      case 'sellerDistrict':
        text = isVisible == 0 ? '' : table.district;
        break;
      case 'sellerCity':
        text = isVisible == 0 ? '' : table.city;
        break;
      case 'sellerCountry':
        text = isVisible == 0 ? '' : table.country;
        break;
      case 'sellerZipCode':
        text = isVisible == 0 ? '' : table.postalCode;
        break;
      case 'sellerAdditionalNo':
        text = isVisible == 0 ? '' : table.additionalNo;
        break;
      default:
        break;
    }
    switch (color) {
      case 'white':
        pdfColor = PdfColors.white;
        break;
      case 'black':
        pdfBorderColor = PdfColors.black;
        break;
      case 'grey':
        pdfColor = PdfColors.grey;
        break;
      case 'green':
        pdfColor = PdfColors.green;
        break;
      case 'blue':
        pdfColor = PdfColors.lightBlue;
        break;
      default:
        pdfColor = null;
        break;
    }
    switch (borderColor) {
      case 'white':
        pdfBorderColor = PdfColors.white;
        break;
      case 'black':
        pdfBorderColor = PdfColors.black;
        break;
      case 'grey':
        pdfBorderColor = PdfColors.grey;
        break;
      case 'green':
        pdfBorderColor = PdfColors.green;
        break;
      case 'blue':
        pdfBorderColor = PdfColors.lightBlue;
        break;
      default:
        pdfBorderColor = null;
        break;
    }
    return Container(
        width: width,
        height: height,
        // transform: Matrix4.rotationZ(360/180),
        decoration: BoxDecoration(
            color: pdfColor,
            border: pdfBorderColor == null
                ? null
                : Border.all(color: pdfBorderColor)),
        margin: EdgeInsets.only(left: left * mm, top: top * mm),
        child: Center(
            child: Text(text,
                textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: fontSize,
                    fontWeight:
                    isBold == 1 ? FontWeight.bold : FontWeight.normal))));
  }

  static Widget textCustomer(
      Customer table, List<TemplateDetails> col, String colName,
      {bool isNumber = false,
      bool rtl = true,
      }) {
    String text = '';
    double left = 0;
    double top = 0;
    double width = 50;
    double height = 13;
    double fontSize = 12;
    int isBold = 0;
    int isVisible = 1;
    String color = 'white';
    String borderColor = 'white';
    PdfColor? pdfColor;
    PdfColor? pdfBorderColor;
    if (isNumber) rtl = false;
    final line = col.map((col) {
      return [
        col.tempId,
        col.colName,
        col.colTop,
        col.colLeft,
        col.colWidth,
        col.colHeight,
        col.fontSize,
        col.isBold,
        col.backColor,
        col.borderColor,
        col.isVisible
      ];
    }).toList();
    for (int i = 0; i < line.length; i++) {
      if (line[i][1] == colName) {
        top = double.parse(line[i][2].toString());
        left = double.parse(line[i][3].toString());
        width = double.parse(line[i][4].toString());
        height = double.parse(line[i][5].toString());
        fontSize = double.parse(line[i][6].toString());
        isBold = int.parse(line[i][7].toString());
        color = line[i][8].toString();
        borderColor = line[i][9].toString();
        isVisible = int.parse(line[i][10].toString());
      }
    }
    switch (colName) {
      case 'customerName':
        text = isVisible == 0 ? '': table.name;
        break;
      case 'customerVatNo':
        text =  isVisible == 0 ? '': table.vatNumber;
        break;
      case 'customerCellphone':
        text =  isVisible == 0 ? '': table.contactNumber;
        break;
      case 'customerBuildingNo':
        text =  isVisible == 0 ? '': table.buildingNo;
        break;
      case 'customerStreet':
        text = isVisible == 0 ? '': table.streetName;
        break;
      case 'customerDistrict':
        text = isVisible == 0 ? '': table.district;
        break;
      case 'customerCity':
        text = isVisible == 0 ? '': table.city;
        break;
      case 'customerCountry':
        text = isVisible == 0 ? '': table.country;
        break;
      case 'customerZipCode':
        text = isVisible == 0 ? '': table.postalCode;
        break;
      case 'customerAdditionalNo':
        text = isVisible == 0 ? '': table.additionalNo;
        break;
      default:
        break;
    }
    switch (color) {
      case 'white':
        pdfColor = PdfColors.white;
        break;
      case 'black':
        pdfBorderColor = PdfColors.black;
        break;
      case 'grey':
        pdfColor = PdfColors.grey;
        break;
      case 'green':
        pdfColor = PdfColors.green;
        break;
      case 'blue':
        pdfColor = PdfColors.lightBlue;
        break;
      default:
        pdfColor = null;
        break;
    }
    switch (borderColor) {
      case 'white':
        pdfBorderColor = PdfColors.white;
        break;
      case 'black':
        pdfBorderColor = PdfColors.black;
        break;
      case 'grey':
        pdfBorderColor = PdfColors.grey;
        break;
      case 'green':
        pdfBorderColor = PdfColors.green;
        break;
      case 'blue':
        pdfBorderColor = PdfColors.lightBlue;
        break;
      default:
        pdfBorderColor = null;
        break;
    }
    return Container(
        width: width,
        height: height,
        // transform: Matrix4.rotationZ(360/180),
        decoration: BoxDecoration(
            color: pdfColor,
            border: pdfBorderColor == null
                ? null
                : Border.all(color: pdfBorderColor)),
        margin: EdgeInsets.only(left: left * mm, top: top * mm),
        child: Center(
            child: Text(text,
                textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: fontSize,
                    fontWeight:
                        isBold == 1 ? FontWeight.bold : FontWeight.normal))));
  }

  static Widget textInvoice(Invoice table, List<InvoiceLines> invoiceLines,
      List<TemplateDetails> col, String colName,
      {bool isNumber = false, bool rtl = true}) {
    String text = '';
    double left = 0;
    double top = 0;
    double topMargin = 0;
    double width = 50;
    double height = 13;
    double fontSize = 12;
    int isBold = 0;
    int isVisible = 1;
    String color = 'white';
    String borderColor = 'white';
    PdfColor? pdfColor;
    PdfColor? pdfBorderColor;
    if (isNumber) rtl = false;
    final line = col.map((col) {
      return [
        col.tempId,
        col.colName,
        col.colTop,
        col.colLeft,
        col.colWidth,
        col.colHeight,
        col.fontSize,
        col.isBold,
        col.backColor,
        col.borderColor,
        col.isVisible,
      ];
    }).toList();
    for (int i = 0; i < line.length; i++) {
      if (line[i][1] == colName) {
        top = double.parse(line[i][2].toString());
        left = double.parse(line[i][3].toString());
        width = double.parse(line[i][4].toString());
        height = double.parse(line[i][5].toString());
        fontSize = double.parse(line[i][6].toString());
        isBold = int.parse(line[i][7].toString());
        color = line[i][8].toString();
        borderColor = line[i][9].toString();
        isVisible = int.parse(line[i][10].toString());
      }
    }
    switch (colName) {
      case 'invoiceNo':
        text = isVisible == 0 ? '' : table.invoiceNo;
        break;
      case 'invoiceDate':
        text =  isVisible == 0 ? '' :Utils.formatShortDate(DateTime.parse(table.date));
        break;
      case 'totalDiscount':
        text =  isVisible == 0 ? '' :Utils.formatAmount(table.totalDiscount);
        topMargin = 18 * (invoiceLines.length - 1);
        break;
      case 'totalAmount':
        text =  isVisible == 0 ? '' :Utils.formatAmount(table.total - table.totalVat);
        topMargin = 18 * (invoiceLines.length - 1);
        break;
      case 'totalNetAmount':
        text =  isVisible == 0 ? '' :Utils.formatAmount(table.total);
        topMargin = 18 * (invoiceLines.length - 1);
        break;
      case 'totalVat':
        text =  isVisible == 0 ? '' :Utils.formatAmount(table.totalVat);
        topMargin = 18 * (invoiceLines.length - 1);
        break;
      case 'sumOfAmount':
        text =  isVisible == 0 ? '' :Utils.numToWord(Utils.formatAmount(table.total));
        topMargin = 18 * (invoiceLines.length - 1);
        break;
      default:
        break;
    }
    switch (color) {
      case 'white':
        pdfColor = PdfColors.white;
        break;
      case 'black':
        pdfColor = PdfColors.black;
        break;
      case 'grey':
        pdfColor = PdfColors.grey;
        break;
      case 'green':
        pdfColor = PdfColors.green;
        break;
      case 'blue':
        pdfColor = PdfColors.lightBlue;
        break;
      default:
        pdfColor = null;
        break;
    }
    switch (borderColor) {
      case 'white':
        pdfBorderColor = PdfColors.white;
        break;
      case 'black':
        pdfBorderColor = PdfColors.black;
        break;
      case 'grey':
        pdfBorderColor = PdfColors.grey;
        break;
      case 'green':
        pdfBorderColor = PdfColors.green;
        break;
      case 'blue':
        pdfBorderColor = PdfColors.lightBlue;
        break;
      default:
        pdfBorderColor = null;
        break;
    }
    return Container(
        width: width,
        height: height,
        // transform: Matrix4.rotationZ(360/180),
        decoration: BoxDecoration(
            color: pdfColor,
            border: pdfBorderColor == null
                ? null
                : Border.all(color: pdfBorderColor)),
        margin: EdgeInsets.only(left: left * mm, top: (top * mm) + topMargin),
        child: Center(
            child: Text(text,
                textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: fontSize,
                    fontWeight:
                        isBold == 1 ? FontWeight.bold : FontWeight.normal))));
  }

  static Widget textInvoiceLines(
      List<InvoiceLines> table, List<TemplateDetails> col, String colName,
      {bool isNumber = false, bool rtl = true}) {
    String text = '';
    double left = 0;
    double top = 0;
    double width = 50;
    double height = 13;
    double fontSize = 12;
    int isBold = 0;
    int isVisible = 1;
    String color = 'white';
    String borderColor = 'white';
    PdfColor? pdfColor;
    PdfColor? pdfBorderColor;
    if (isNumber) rtl = false;
    final line = col.map((col) {
      return [
        col.tempId,
        col.colName,
        col.colTop,
        col.colLeft,
        col.colWidth,
        col.colHeight,
        col.fontSize,
        col.isBold,
        col.backColor,
        col.borderColor,
        col.isVisible,
      ];
    }).toList();
    for (int i = 0; i < line.length; i++) {
      if (line[i][1] == colName) {
        top = double.parse(line[i][2].toString());
        left = double.parse(line[i][3].toString());
        width = double.parse(line[i][4].toString());
        height = double.parse(line[i][5].toString());
        fontSize = double.parse(line[i][6].toString());
        isBold = int.parse(line[i][7].toString());
        color = line[i][8].toString();
        borderColor = line[i][9].toString();
        isVisible = int.parse(line[i][10].toString());
      }
    }
    final invoiceLine = table.map((col) {
      double vat = 0.15;
      final priceWithoutVat = col.price / 1.15;
      final totalWithoutVat = priceWithoutVat * col.qty;
      final lineVat = totalWithoutVat * vat;
      final lineNet = (col.price * col.qty) - col.discount;
      return [
        col.barcode,
        col.productName,
        col.qty,
        Utils.formatAmount(priceWithoutVat),
        Utils.formatAmount(col.discount),
        Utils.formatAmount(vat * 100),
        Utils.formatAmount(lineVat),
        Utils.formatAmount(totalWithoutVat),
        Utils.formatAmount(lineNet),
      ];
    }).toList();

    switch (color) {
      case 'white':
        pdfColor = PdfColors.white;
        break;
      case 'black':
        pdfBorderColor = PdfColors.black;
        break;
      case 'grey':
        pdfColor = PdfColors.grey;
        break;
      case 'green':
        pdfColor = PdfColors.green;
        break;
      case 'blue':
        pdfColor = PdfColors.lightBlue;
        break;
      default:
        pdfColor = null;
        break;
    }
    switch (borderColor) {
      case 'white':
        pdfBorderColor = PdfColors.white;
        break;
      case 'black':
        pdfBorderColor = PdfColors.black;
        break;
      case 'grey':
        pdfBorderColor = PdfColors.grey;
        break;
      case 'green':
        pdfBorderColor = PdfColors.green;
        break;
      case 'blue':
        pdfBorderColor = PdfColors.lightBlue;
        break;
      default:
        pdfColor = null;
        break;
    }
    return ListView.builder(
        itemCount: table.length,
        itemBuilder: (context, index) {
          switch (colName) {
            case 'barcode':
              text = isVisible == 0 ? '' : invoiceLine[index][0].toString();
              break;
            case 'productName':
              text =  isVisible == 0 ? '' :invoiceLine[index][1].toString();
              break;
            case 'qty':
              text =  isVisible == 0 ? '' :invoiceLine[index][2].toString();
              break;
            case 'price':
              text =  isVisible == 0 ? '' :invoiceLine[index][3].toString();
              break;
            case 'discount':
              text =  isVisible == 0 ? '' :invoiceLine[index][4].toString();
              break;
            case 'vatLinePercent':
              text =  isVisible == 0 ? '' :invoiceLine[index][5].toString();
              break;
            case 'vatLineAmount':
              text =  isVisible == 0 ? '' :invoiceLine[index][6].toString();
              break;
            case 'totalLineAmount':
              text =  isVisible == 0 ? '' :invoiceLine[index][7].toString();
              break;
            case 'netLineAmount':
              text =  isVisible == 0 ? '' :invoiceLine[index][8].toString();
              break;
            default:
              break;
          }
          double extraTop = index + 1.5;
          switch (index) {
            case 1:
              extraTop = 2.5;
              break;
            case 2:
              extraTop = 3;
              break;
            case 3:
              extraTop = 3;
              break;
            case 4:
              extraTop = 3.5;
              break;
            default:
              break;
          }
          return Container(
              width: width,
              height: height,
              // transform: Matrix4.rotationZ(360/180),
              decoration: BoxDecoration(
                  color: pdfColor,
                  border: pdfBorderColor == null
                      ? null
                      : Border.all(color: pdfBorderColor)),
              margin: EdgeInsets.only(
                  left: left * mm, top: index > 0 ? extraTop : top * mm),
              child: Center(
                  child: Text(text,
                      textDirection:
                          rtl ? TextDirection.rtl : TextDirection.ltr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: isBold == 1
                              ? FontWeight.bold
                              : FontWeight.normal))));
        });
  }

  static Widget buildPage(Setting setting, Customer customer, Invoice invoice,
      List<InvoiceLines> lines, int tempId, List<TemplateDetails> col) {
    return Container(
      width: 600,
      height: 790,
      margin: const EdgeInsets.all(0),
      decoration: BoxDecoration(
          image: DecorationImage(
              fit: BoxFit.fill,
              image: MemoryImage(base64Decode(tempId == 1
                  ? setting.invoiceTemp1
                  : tempId == 2
                      ? setting.invoiceTemp2
                      : tempId == 3
                          ? setting.invoiceTemp3
                          : tempId == 4
                              ? setting.invoiceTemp4
                              : tempId == 5
                                  ? setting.invoiceTemp5
                                  : setting.invoiceTemp1)))),
      child: Stack(children: [
        qrCode(setting, invoice, col),
        textSeller(setting, col, 'sellerName'),
        textCustomer(customer, col, 'customerName'),
        textInvoice(invoice, lines, col, 'invoiceNo'),
        textCustomer(customer, col, 'customerCity'),
        textInvoice(invoice, lines, col, 'invoiceDate'),
        textCustomer(customer, col, 'customerVatNo'),
        textInvoiceLines(lines, col, 'barcode'),
        textInvoiceLines(lines, col, 'productName'),
        textInvoiceLines(lines, col, 'qty'),
        textInvoiceLines(lines, col, 'price'),
        textInvoiceLines(lines, col, 'discount'),
        textInvoiceLines(lines, col, 'barcode'),
        textInvoiceLines(lines, col, 'unit'),
        textInvoiceLines(lines, col, 'vatLinePercent'),
        textInvoiceLines(lines, col, 'vatLineAmount'),
        textInvoiceLines(lines, col, 'totalLineAmount'),
        textInvoiceLines(lines, col, 'netLineAmount'),
        textInvoice(invoice, lines, col, 'totalAmount'),
        textInvoice(invoice, lines, col, 'totalDiscount'),
        textInvoice(invoice, lines, col, 'totalVat'),
        textInvoice(invoice, lines, col, 'totalNetAmount'),
        textInvoice(invoice, lines, col, 'sumOfAmount'),
      ]),
    );
  }

  static Widget buildInvoice(Invoice invoice, List<InvoiceLines> line) {
    final data = line.map((item) {
      final priceNoVat = item.price / 1.15;
      final netTotal = (item.qty * item.price) - item.discount;
      final total = item.qty * item.price / 1.15;
      final disc = item.discount;
      return [
        '${Utils.formatAmount(netTotal)}',
        '${Utils.formatAmount(total * 0.15)}',
        '${Utils.formatAmount(15)}',
        '${Utils.formatAmount(total)}',
        '${Utils.formatAmount(disc)}',
        '${Utils.formatAmount(priceNoVat)}',
        '${item.qty}',
        item.productName,
        '${Utils.formatItemCode(item.id!)}',
      ];
    }).toList();

    return Container(
        child: Column(children: [
      Container(
        width: double.infinity,
        height: 40,
        decoration: BoxDecoration(
          color: PdfColors.white,
          border: Border.all(color: PdfColors.black),
        ),
        child: Row(children: [
          Container(
            width: 60,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: PdfColors.white,
              border: Border.all(color: PdfColors.black),
            ),
            child: Column(children: [
              Text(
                'الصافي',
                textDirection: TextDirection.rtl,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              ),
              Text(
                'Net Price',
                textDirection: TextDirection.ltr,
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
              ),
            ]),
          ),
          Container(
            width: 55,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: PdfColors.white,
              border: Border.all(color: PdfColors.black),
            ),
            child: Column(children: [
              Text(
                'قيمة الضريبة',
                textDirection: TextDirection.rtl,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              ),
              Text(
                'VAT',
                textDirection: TextDirection.ltr,
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
              ),
            ]),
          ),
          Container(
            width: 50,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: PdfColors.white,
              border: Border.all(color: PdfColors.black),
            ),
            child: Column(children: [
              Text(
                'ضريبة %',
                textDirection: TextDirection.rtl,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              ),
              Text(
                'VAT %',
                textDirection: TextDirection.ltr,
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
              ),
            ]),
          ),
          Container(
            width: 70,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: PdfColors.white,
              border: Border.all(color: PdfColors.black),
            ),
            child: Column(children: [
              Text(
                'السعر الإجمالي',
                textDirection: TextDirection.rtl,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              ),
              Text(
                'Total Price',
                textDirection: TextDirection.ltr,
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
              ),
            ]),
          ),
          Container(
            width: 40,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: PdfColors.white,
              border: Border.all(color: PdfColors.black),
            ),
            child: Column(children: [
              Text(
                'الخصم',
                textDirection: TextDirection.rtl,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              ),
              Text(
                'Disc.',
                textDirection: TextDirection.ltr,
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
              ),
            ]),
          ),
          Container(
            width: 60,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: PdfColors.white,
              border: Border.all(color: PdfColors.black),
            ),
            child: Column(children: [
              Text(
                'السعر',
                textDirection: TextDirection.rtl,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              ),
              Text(
                'PRICE',
                textDirection: TextDirection.ltr,
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
              ),
            ]),
          ),
          Container(
            width: 40,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: PdfColors.white,
              border: Border.all(color: PdfColors.black),
            ),
            child: Column(children: [
              Text(
                'الكمية',
                textDirection: TextDirection.rtl,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              ),
              Text(
                'QTY',
                textDirection: TextDirection.ltr,
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
              ),
            ]),
          ),
          Container(
            width: 110,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: PdfColors.white,
              border: Border.all(color: PdfColors.black),
            ),
            child: Column(children: [
              Text(
                'الشرح',
                textDirection: TextDirection.rtl,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              ),
              Text(
                'Description',
                textDirection: TextDirection.ltr,
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
              ),
            ]),
          ),
          Container(
            width: 50,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: PdfColors.white,
              border: Border.all(color: PdfColors.black),
            ),
            child: Column(children: [
              Text(
                'الرمز',
                textDirection: TextDirection.rtl,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              ),
              Text(
                'Item Code',
                textDirection: TextDirection.ltr,
                style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold),
              ),
            ]),
          ),
        ]),
      ),
      ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            return Row(children: [
              Container(
                  height: 30,
                  width: 60,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: PdfColors.white,
                    border: Border.all(color: PdfColors.black),
                  ),
                  child: Center(
                      child: Text(
                    data[index][0],
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ))),
              Container(
                  height: 30,
                  width: 55,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: PdfColors.white,
                    border: Border.all(color: PdfColors.black),
                  ),
                  child: Center(
                      child: Text(
                    data[index][1],
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ))),
              Container(
                  height: 30,
                  width: 50,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: PdfColors.white,
                    border: Border.all(color: PdfColors.black),
                  ),
                  child: Center(
                      child: Text(
                    data[index][2],
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.ltr,
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                  ))),
              Container(
                  height: 30,
                  width: 70,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: PdfColors.white,
                    border: Border.all(color: PdfColors.black),
                  ),
                  child: Center(
                      child: Text(
                    data[index][3],
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.ltr,
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                  ))),
              Container(
                  height: 30,
                  width: 40,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: PdfColors.white,
                    border: Border.all(color: PdfColors.black),
                  ),
                  child: Center(
                      child: Text(
                    data[index][4],
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.ltr,
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                  ))),
              Container(
                  height: 30,
                  width: 60,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: PdfColors.white,
                    border: Border.all(color: PdfColors.black),
                  ),
                  child: Center(
                      child: Text(
                    data[index][5],
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.ltr,
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                  ))),
              Container(
                  height: 30,
                  width: 40,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: PdfColors.white,
                    border: Border.all(color: PdfColors.black),
                  ),
                  child: Center(
                      child: Text(
                    data[index][6],
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.ltr,
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                  ))),
              Container(
                  height: 30,
                  width: 110,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: PdfColors.white,
                    border: Border.all(color: PdfColors.black),
                  ),
                  child: Center(
                      child: Text(
                    data[index][7],
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                  ))),
              Container(
                  height: 30,
                  width: 50,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: PdfColors.white,
                    border: Border.all(color: PdfColors.black),
                  ),
                  child: Center(
                      child: Text(
                    data[index][8],
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.ltr,
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                  ))),
            ]);
          }),
      Container(height: 1.5, color: PdfColors.black),
      Container(height: 5, color: PdfColors.white),
    ]));
  }
}
