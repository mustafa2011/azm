import 'dart:convert';
import 'dart:io';
import '../apis/pdf_api.dart';
import '../db/fatoora_db.dart';
import '../models/customers.dart';
import '../models/receipt.dart';
import '../models/settings.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'constants/utils.dart';

class PdfReceiptApi {
  static Future<Future<File>> generate(
      Receipt receipt, Setting seller, String title,
      {bool isReceipt = false}) async {
    var myTheme = ThemeData.withFont(
      base: Font.ttf(await rootBundle.load("assets/fonts/Cairo-Regular.ttf")),
      bold: Font.ttf(await rootBundle.load("assets/fonts/Cairo-Bold.ttf")),
    );
    final pdf = Document(theme: myTheme);
    pdf.addPage(Page(
      margin: const EdgeInsets.all(30),
      // pageFormat: PdfPageFormat.a4,
      build: (context) => Column(children: [
        buildHeader(receipt, seller, title, isReceipt),
        buildReceipt(receipt),
        buildLine(),
        buildFooter(seller)
      ]),
    ));

    return PdfApi.previewReceipt(receipt: receipt, pdf: pdf);
  }

  static Future<String> getCustomerName(int? id) async {
    Customer customer = await FatooraDB.instance.getCustomerById(id!);
    return customer.name;
  }

  static Widget buildFooter(Setting seller) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          SizedBox(width: 150,
          child: Column(children: [
            Text('المستلم',
                // textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(seller.name,
                // textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal)),
          ])),
          Text(''),
        ]);
  }

  static Widget buildHeader(
          Receipt receipt, Setting seller, String title, bool isReceipt) =>
      Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildLogo(seller),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(seller.seller,
                    textDirection: TextDirection.rtl,
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                Row(children: [
                  Text(seller.vatNumber,
                      textDirection: TextDirection.rtl,
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  SizedBox(width: 2 * PdfPageFormat.mm),
                  Text('رقم ضريبي',
                      textDirection: TextDirection.rtl,
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ]),
              ]),
              // buildCustomerAddress(receipt.customer),
            ],
          ),
          Text(title,
              textDirection: TextDirection.rtl,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text('${Utils.formatEstimate(receipt.id!)}',
              textDirection: TextDirection.rtl,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: PdfColors.red)),
        ],
      );

  static Widget buildLine() => Container(height: 1, color: PdfColors.grey);

  static Widget buildLogo(Setting seller) => Container(
      width: seller.logoWidth.toDouble(),
      height: seller.logoHeight.toDouble(),
      decoration: BoxDecoration(
          image: DecorationImage(
              fit: BoxFit.fill,
              image: MemoryImage(base64Decode(seller.logo)))));

  static Widget buildReceipt(Receipt receipt) {
    String receiptDate = Utils.formatShortDate(DateTime.parse(receipt.date));
    return Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        buildSimpleText(title: 'التاريخ', value: receiptDate),
        buildSimpleText(title: 'المبلغ', value: Utils.format(receipt.amount)),
      ]),
      SizedBox(height: 1 * PdfPageFormat.mm),
      buildSimpleText(title: 'استلمنا من', value: receipt.receivedFrom),
      SizedBox(height: 1 * PdfPageFormat.mm),
      buildSimpleText(title: 'مبلغاً وقدره', value: receipt.sumOf),
      SizedBox(height: 1 * PdfPageFormat.mm),
      buildSimpleText(title: 'طريقة الدفع', value: receipt.payType),
      SizedBox(height: 1 * PdfPageFormat.mm),
      receipt.payType == 'شيك'
          ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              buildSimpleText(title: 'على بنك', value: receipt.bank),
              buildSimpleText(title: 'وتاريخ', value: receipt.chequeDate),
              buildSimpleText(title: 'رقم', value: receipt.chequeNo),
            ])
          : receipt.payType == 'حوالة'
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                      buildSimpleText(title: 'على بنك', value: receipt.bank),
                      buildSimpleText(
                          title: 'وتاريخ', value: receipt.transferDate),
                      buildSimpleText(title: 'رقم', value: receipt.transferNo),
                    ])
              : Container(),
      receipt.payType == 'نقدا'
          ? Container()
          : SizedBox(height: 1 * PdfPageFormat.mm),
      buildSimpleText(title: 'وذلك عن', value: receipt.amountFor),
      SizedBox(height: 3 * PdfPageFormat.mm),
    ]);
  }

  static buildSimpleText({
    required String title,
    required String value,
  }) {
    final styleTitle = TextStyle(fontWeight: FontWeight.bold, fontSize: 14);
    const styleValue = TextStyle(fontSize: 14);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, textDirection: TextDirection.rtl, style: styleValue),
        SizedBox(width: 2 * PdfPageFormat.mm),
        Text(title, textDirection: TextDirection.rtl, style: styleTitle),
      ],
    );
  }
}
