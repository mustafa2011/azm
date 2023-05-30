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
      base: Font.ttf(await rootBundle.load("assets/fonts/calibri.ttf")),
      bold: Font.ttf(await rootBundle.load("assets/fonts/calibrib.ttf")),
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
    return isVisible == 0
        ? Container()
        : BarcodeWidget(
            margin: EdgeInsets.only(left: left * mm, top: top * mm),
            padding: const EdgeInsets.all(4),
            height: height,
            width: width,
            barcode: Barcode.qrCode(
                errorCorrectLevel: BarcodeQRCorrectionLevel.high),
            data: qrString,
            // decoration: BoxDecoration(
            //   color: PdfColors.white,
            //   border: Border.all(color: PdfColors.grey600, width: 0.1),
            //   boxShadow: const [
            //     BoxShadow(
            //       color: PdfColors.grey400,
            //       offset: PdfPoint(0.5, 0.6),
            //     ),
            //   ],
            // ),
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
    Customer table,
    List<TemplateDetails> col,
    String colName, {
    bool isNumber = false,
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
        text = isVisible == 0 ? '' : table.name;
        break;
      case 'customerVatNo':
        text = isVisible == 0 ? '' : Utils.arabicNumber(table.vatNumber);
        break;
      case 'customerCellphone':
        text = isVisible == 0 ? '' : table.contactNumber;
        break;
      case 'customerBuildingNo':
        text = isVisible == 0 ? '' : table.buildingNo;
        break;
      case 'customerStreet':
        text = isVisible == 0 ? '' : table.streetName;
        break;
      case 'customerDistrict':
        text = isVisible == 0 ? '' : table.district;
        break;
      case 'customerCity':
        text = isVisible == 0 ? '' : table.city;
        break;
      case 'customerCountry':
        text = isVisible == 0 ? '' : table.country;
        break;
      case 'customerZipCode':
        text = isVisible == 0 ? '' : table.postalCode;
        break;
      case 'customerAdditionalNo':
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
        decoration: BoxDecoration(
            color: pdfColor,
            border: pdfBorderColor == null
                ? null
                : Border.all(color: pdfBorderColor)),
        margin: EdgeInsets.only(left: left * mm, top: top * mm),
        child: Align(
            alignment: Alignment.centerRight,
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
    String strMM = '';
    String strDD = '';
    String strYYYY = '';
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
    Alignment alignment = Alignment.centerLeft;
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
    String onlyDate = table.date.split(' ')[0];
    strYYYY = Utils.arabicNumber(onlyDate.split('-')[0]);
    strMM = Utils.arabicNumber(onlyDate.split('-')[1]);
    strDD = Utils.arabicNumber(onlyDate.split('-')[2]);
    switch (colName) {
      case 'customerAdditionalNo': // Todo: reserved for supply date fld
        text = isVisible == 0 ? '' : '$strYYYY- $strMM- $strDD';
        alignment = Alignment.centerRight;
        break;
      case 'customerZipCode': // Todo: reserved for time fld
        text = Utils.invoiceTime(table.date, printSecond: true);
        alignment = Alignment.centerRight;
        break;
      case 'invoiceNo':
        text = isVisible == 0 ? '' : Utils.arabicNumber(table.invoiceNo);
        alignment = Alignment.centerRight;
        break;
      case 'invoiceDate':
        text = isVisible == 0 ? '' : '$strYYYY- $strMM- $strDD';
        alignment = Alignment.centerRight;
        break;
      case 'totalDiscount':
        text =
            isVisible == 0 ? '' : Utils.formatArabicAmount(table.totalDiscount);
        // topMargin = 18 * (invoiceLines.length - 1);
        break;
      case 'totalAmount':
        text = isVisible == 0
            ? ''
            : Utils.formatArabicAmount(table.total - table.totalVat);
        // topMargin = 18 * (invoiceLines.length - 1);
        break;
      case 'totalNetAmount':
        text = isVisible == 0 ? '' : Utils.formatArabicAmount(table.total);
        // topMargin = 18 * (invoiceLines.length - 1);
        break;
      case 'totalVat':
        text = isVisible == 0 ? '' : Utils.formatArabicAmount(table.totalVat);
        // topMargin = 18 * (invoiceLines.length - 1);
        break;
      case 'sumOfAmount':
        text = isVisible == 0
            ? ''
            : Utils.formatArabicAmount(table.total - table.totalVat);
        // topMargin = 18 * (invoiceLines.length - 1);
        // text = isVisible == 0
        //     ? ''
        //     : Utils.numToWord(Utils.formatAmount(table.total));
        // topMargin = 18 * (invoiceLines.length - 1);
        break;
      default:
        break;
    }
    switch (color) {
      case 'white':
        pdfColor = PdfColors.white;
        break;
      case 'yellow':
        pdfColor = PdfColors.yellow;
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
        child: Align(
            alignment: alignment,
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
        Utils.formatArabicAmount(col.qty),
        Utils.formatArabicAmount(priceWithoutVat),
        Utils.formatArabicAmount(col.discount),
        Utils.formatArabicAmount(vat * 100),
        Utils.formatArabicAmount(lineVat),
        Utils.formatArabicAmount(totalWithoutVat),
        Utils.formatArabicAmount(lineNet),
        col.unit,
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
              text = isVisible == 0 ? '' : invoiceLine[index][1].toString();
              break;
            case 'qty':
              text = isVisible == 0 ? '' : invoiceLine[index][2].toString();
              break;
            case 'price':
              text = isVisible == 0 ? '' : invoiceLine[index][3].toString();
              break;
            case 'discount':
              text = isVisible == 0 ? '' : invoiceLine[index][4].toString();
              break;
            case 'vatLinePercent':
              text = isVisible == 0 ? '' : invoiceLine[index][5].toString();
              break;
            case 'vatLineAmount':
              text = isVisible == 0 ? '' : invoiceLine[index][6].toString();
              break;
            case 'totalLineAmount':
              text = isVisible == 0 ? '' : invoiceLine[index][7].toString();
              break;
            case 'netLineAmount':
              text = isVisible == 0 ? '' : invoiceLine[index][8].toString();
              break;
            case 'unit':
              text = isVisible == 0 ? '' : invoiceLine[index][9].toString();
              break;
            default:
              break;
          }
          double extraTop = index + 1;
          switch (index) {
            case 1:
              extraTop = 1;
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
              decoration: BoxDecoration(
                  color: pdfColor,
                  border: pdfBorderColor == null
                      ? null
                      : Border.all(color: pdfBorderColor)),
              margin: EdgeInsets.only(
                  left: left * mm, top: index > 0 ? extraTop : top * mm),
              child: Align(
                  alignment: colName == 'productName'
                      ? Alignment.centerRight
                      : Alignment.center,
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
    final backgroundImage = MemoryImage(base64Decode(tempId == 1
        ? setting.invoiceTemp1
        : tempId == 2
            ? setting.invoiceTemp2
            : tempId == 3
                ? setting.invoiceTemp3
                : tempId == 4
                    ? setting.invoiceTemp4
                    : tempId == 5
                        ? setting.invoiceTemp5
                        : setting.invoiceTemp1));
    return FullPage(
      ignoreMargins: true,
      child: Stack(children: [
        Image(backgroundImage),
        qrCode(setting, invoice, col),
        textSeller(setting, col, 'sellerName'),
        textCustomer(customer, col, 'customerName'),
        textCustomer(customer, col, 'customerStreet'),
        textInvoice(invoice, lines, col, 'invoiceNo'),
        textInvoice(invoice, lines, col, 'customerZipCode'),
        // reserved for time fld
        textInvoice(invoice, lines, col, 'customerAdditionalNo'),
        // reserved for supply date fld
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
    /*return Container(
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
        Image(image),
        qrCode(setting, invoice, col),
        textSeller(setting, col, 'sellerName'),
        textCustomer(customer, col, 'customerName'),
        textCustomer(customer, col, 'customerStreet'),
        textInvoice(invoice, lines, col, 'invoiceNo'),
        textInvoice(invoice, lines, col, 'customerZipCode'),
        // Todo: reserved for time fld
        textInvoice(invoice, lines, col, 'customerAdditionalNo'),
        // Todo: reserved for supply date fld
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
    );*/
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
