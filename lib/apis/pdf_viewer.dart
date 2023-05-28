import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:open_file/open_file.dart';
import 'package:pdfx/pdfx.dart';
import 'package:whatsapp_share2/whatsapp_share2.dart';

import '../models/estimate.dart';
import '../models/invoice.dart';
import '../models/po.dart';
import '../models/receipt.dart';
import '../widgets/app_colors.dart';
import 'constants/utils.dart';

class OpenPDF extends StatefulWidget {
  final String? path;
  final Invoice? invoice;
  final Estimate? estimate;
  final Receipt? receipt;
  final Po? po;

  const OpenPDF(
      {Key? key, this.path, this.invoice, this.estimate, this.receipt, this.po})
      : super(key: key);

  @override
  State<OpenPDF> createState() => _OpenPDFState();
}

class _OpenPDFState extends State<OpenPDF> with WidgetsBindingObserver {
  int? pages = 0;
  int? currentPage = 0;
  String errorMessage = '';
  String whatsapp = 'واتساب';
  String whatsappNumber = '';
  final TextEditingController _whatsappNumber = TextEditingController();

  @override
  void initState() {
    super.initState();
    getStart();
  }

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

  Widget buildWhatsappNumber() => SizedBox(
        width: 200,
        child: TextFormField(
          keyboardType: const TextInputType.numberWithOptions(),
          controller: _whatsappNumber,
          autofocus: true,
          textDirection: TextDirection.ltr,
          onTap: () {
            var textValue = _whatsappNumber.text;
            _whatsappNumber.selection = TextSelection(
              baseOffset: 0,
              extentOffset: textValue.length,
            );
          },
          style: const TextStyle(
            color: AppColor.primary,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          decoration: const InputDecoration(
            labelText: 'رقم الواتساب',
          ),
        ),
      );

  void enterWhatsapp() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('رسالة'),
          content: buildWhatsappNumber(),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            TextButton(
              child: const Text("موافق"),
              onPressed: () {
                String number = Utils.formatCellphone(_whatsappNumber.text);
                WhatsappShare.shareFile(
                        filePath: [widget.path!],
                        phone: number,
                        package: whatsapp == 'واتساب'
                            ? Package.whatsapp
                            : Package.businessWhatsapp)
                    .catchError((e) {
                  messageBox('فضلاً تأكد من نوع باقة الواتساب لديك');
                  return null;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  getStart() async {
    whatsapp = await Utils.whatsapp();
    whatsappNumber = await Utils.whatsappNumber();
    _whatsappNumber.text = whatsappNumber;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.invoice != null
              ? "فاتورة ${widget.invoice!.invoiceNo}"
              : widget.estimate != null
                  ? "عرض سعر ${widget.estimate!.estimateNo}"
                  : widget.po != null
                      ? "طلب شراء ${widget.po!.poNo}"
                      : "سند قبض ${Utils.formatEstimate(widget.receipt!.id!)}",
          style: const TextStyle(
              color: AppColor.primary,
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
        actions: <Widget>[
          Platform.isWindows
              ? InkWell(
                  onTap: () => OpenFile.open(widget.path),
                  child: Row(
                    children: [
                      Text(
                        widget.path!,
                        // textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: AppColor.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
                      Utils.space(0, 2),
                    ],
                  ))
              : IconButton(
                  icon: const FaIcon(FontAwesomeIcons.whatsapp),
                  onPressed: () {
                    enterWhatsapp();
                  },
                ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          Platform.isWindows
              ? PdfView(
                  controller: PdfController(
                      document: PdfDocument.openFile('${widget.path}')))
              : PdfViewPinch(
                  controller: PdfControllerPinch(
                      document: PdfDocument.openFile('${widget.path}')),
                ),
          errorMessage.isEmpty
              ? Container()
              : Center(
                  child: Text(errorMessage),
                )
        ],
      ),
    );
  }
}
