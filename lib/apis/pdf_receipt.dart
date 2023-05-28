import 'dart:convert';

import '../apis/pdf_api.dart';
import '../apis/qr_tag/invoice_date.dart';
import '../apis/qr_tag/invoice_tax_amount.dart';
import '../apis/qr_tag/invoice_total_amount.dart';
import '../apis/qr_tag/qr_encoder.dart';
import '../apis/qr_tag/seller.dart';
import '../apis/qr_tag/tax_number.dart';
import '../db/fatoora_db.dart';
import '../models/customers.dart';
import '../models/invoice.dart';
import '../models/settings.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'constants/utils.dart';

class PdfReceipt {
  static Future<void> generate(
      Invoice invoice,
      Customer customer,
      Setting seller,
      List<InvoiceLines> invoiceLines,
      String title,
      String subTitle,
      bool isProVersion,
      bool isPreview) async {
    var myTheme = ThemeData.withFont(
      base: Font.ttf(await rootBundle.load("assets/fonts/arial.ttf")),
      bold: Font.ttf(await rootBundle.load("assets/fonts/arialbd.ttf")),
    );
    var cairoBoldFont =
        Font.ttf(await rootBundle.load("assets/fonts/Cairo-Bold.ttf"));
    final pdf = Document(theme: myTheme);
    String strAddress = seller.buildingNo;
    strAddress += seller.buildingNo.isNotEmpty ? ' ' : '';
    strAddress += seller.streetName.isNotEmpty ? seller.streetName : '';
    strAddress += seller.district.isNotEmpty ? '-${seller.district}' : '';
    strAddress += seller.city.isNotEmpty ? '-${seller.city}' : '';
    strAddress += seller.country.isNotEmpty ? '-${seller.country}' : '';

    String strCustomerAddress = customer.buildingNo;
    strCustomerAddress += customer.buildingNo.isNotEmpty ? ' ' : '';
    strCustomerAddress +=
        customer.streetName.isNotEmpty ? customer.streetName : '';
    strCustomerAddress +=
        customer.district.isNotEmpty ? '-${customer.district}' : '';
    strCustomerAddress += customer.city.isNotEmpty ? '-${customer.city}' : '';
    strCustomerAddress +=
        customer.country.isNotEmpty ? '-${customer.country}' : '';

    pdf.addPage(Page(
      pageFormat: PdfPageFormat.roll80,
      build: (context) => Column(children: [
        buildHeader(invoice, customer, seller, title, subTitle, cairoBoldFont,
            strAddress, strCustomerAddress, isProVersion),
        // SizedBox(height: 10),
        buildInvoice(invoice, invoiceLines),
        Divider(),
        buildTotal(invoice, seller),
        Divider(),
        buildTerms(invoice, seller),
      ]),
      // footer: (context) => buildFooter(invoice),
    ));
    if (isPreview) {
      await PdfApi.previewDocument(invoice: invoice, pdf: pdf);
    }
  }

  static Future<String> getCustomerName(int? id) async {
    Customer customer = await FatooraDB.instance.getCustomerById(id!);
    return customer.name;
  }

  static Widget buildTerms(Invoice invoice, Setting seller) {
    return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Text(
        seller.terms,
        textDirection: TextDirection.rtl,
        style: const TextStyle(fontSize: 12),
      ),
      Text('Invoice # ${invoice.invoiceNo}'),
      Text(invoice.date),
      SizedBox(height: 40),
    ]);
  }


  static Widget buildHeader(
          Invoice invoice,
          Customer customer,
          Setting seller,
          String title,
          String subTitle,
          Font font,
          String strAddress,
          String strCustomerAddress,
          bool isProVersion) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          buildLogo(seller),
          Column(
              crossAxisAlignment: isProVersion && customer.id != 1
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.center,
              children: [
                SizedBox(width: 10),
                Text(
                  isProVersion && customer.id != 1
                      ? 'المورد: ${seller.seller}'
                      : seller.seller,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold, font: font),
                ),
                SizedBox(height: 5),
                isProVersion && customer.id != 1
                    ? Text(strAddress,
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            fontWeight: FontWeight.normal, fontSize: 12))
                    : buildCenterText(text: strAddress),
                SizedBox(height: 5),
                // seller.vatNumber == Utils.defVatNumber
                seller.showVat == 0
                    ? Container()
                    : buildSimpleText(
                        title: 'الرقم الضريبي:', value: seller.vatNumber),
                // SizedBox(height: 10),
                isProVersion && customer.id != 1
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                            Divider(),
                            Text(
                              'العميل: ${customer.name}',
                              textDirection: TextDirection.rtl,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  font: font),
                            ),
                            SizedBox(height: 5),
                            Text(strCustomerAddress,
                                textDirection: TextDirection.rtl,
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 12)),
                            SizedBox(height: 5),
                            buildSimpleText(
                                title: 'الرقم الضريبي:',
                                value: customer.vatNumber),
                          ])
                    : Container(),
              ]),
          // SizedBox(height: 5 * PdfPageFormat.mm),
          // buildInvoiceInfo(invoice, title, seller),
        ],
      );

  static Widget buildInvoiceInfo(
      Invoice invoice, String title, Setting seller) {
    final titles = <String>[
      'رقم الفاتورة:',
      ' ',
      'التاريخ:',
    ];
    final data = <String>[
      invoice.invoiceNo,
      ' ',
      invoice.date,
    ];

    return Column(
      children: List.generate(titles.length, (index) {
        final value = data[index];
        final title = titles[index];

        return buildText(title: title, value: value);
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
      final total = '${Utils.formatPrice(item.qty * item.price)}';
      final line2 = '${Utils.formatPrice(item.price)} × ${item.qty}';
      return [
        total,
        line2,
        item.productName,
      ];
    }).toList();

    return Center(
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Divider(),
      buildText(
          title: "البيان", value: "الإجمالي", fontWeight1: FontWeight.bold),
      Divider(),
      ListView.builder(
        itemCount: data.length,
        itemBuilder: (Context context, int index) => Column(children: [
          buildText(
              title: data[index][2], value: "", fontWeight: FontWeight.normal),
          buildText(
              title: data[index][1],
              value: data[index][0],
              fontWeight: FontWeight.normal),
          SizedBox(height: 10),
        ]),
      ),
    ]));
  }

  static Widget buildTotal(Invoice invoice, Setting seller) {
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // seller.vatNumber == Utils.defVatNumber
            seller.showVat == 0
                ? Container()
                : buildText(
                    title: 'الإجمالي بدون الضريبة',
                    value: Utils.formatNoCurrency(netTotal),
                    // unite: true,
                  ),
            // seller.vatNumber == Utils.defVatNumber
            seller.showVat == 0
                ? Container()
                : buildText(
                    title:
                        'ضريبة القيمة المضافة ${Utils.formatPercent(vatPercent * 100)} ',
                    value: Utils.formatNoCurrency(vat),
                    // unite: true,
                  ),
            // Divider(),
            buildText(
              title: 'المبلغ المستحق',
              value: Utils.formatNoCurrency(total),
              // unite: true,
            ),
            buildText(
              title: 'طريقة الدفع',
              value: invoice.paymentMethod,
              // unite: true,
            ),
            Divider(),
          ],
        ),
        Container(
          height: 100,
          width: 100,
          child: BarcodeWidget(
            barcode: Barcode.qrCode(),
            data: qrString,
          ),
        ),
      ],
    );
  }

  static buildSimpleText({required String title, required String value}) {
    final styleTitle = TextStyle(fontWeight: FontWeight.bold, fontSize: 12);
    const styleValue = TextStyle(fontSize: 12);

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(value,
            textDirection: TextDirection.rtl, style: styleValue, maxLines: 2),
        SizedBox(width: 2 * PdfPageFormat.mm),
        Text(title, textDirection: TextDirection.rtl, style: styleTitle),
      ],
    );
  }

  static buildCenterText(
      {required String text, FontWeight fontWeight = FontWeight.normal}) {
    final style = TextStyle(fontWeight: fontWeight, fontSize: 12);

    return Center(
      child: Text(text,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.center,
          style: style),
    );
  }

  static buildText(
      {required String title,
      required String value,
      double width = double.infinity,
      TextStyle? titleStyle,
      FontWeight fontWeight = FontWeight.bold,
      FontWeight fontWeight1 = FontWeight.normal,
      bool unite = false}) {
    final style = titleStyle ?? TextStyle(fontWeight: fontWeight, fontSize: 12);
    final style1 =
        titleStyle ?? TextStyle(fontWeight: fontWeight1, fontSize: 12);

    return Container(
      width: width,
      child: Row(
        children: [
          Text(value,
              textDirection: TextDirection.rtl, style: unite ? style : style1),
          Expanded(
              child:
                  Text(title, textDirection: TextDirection.rtl, style: style)),
        ],
      ),
    );
  }
}
