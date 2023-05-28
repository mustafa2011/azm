import 'dart:io';

import '../apis/pdf_viewer.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart';
import '../models/estimate.dart';
import '../models/invoice.dart';
import '../models/po.dart';
import '../models/receipt.dart';

class PdfApi {
  static Future<File> saveDocument(
      {required String name,
      required Document pdf,
      // required DragoBluePrinter bluetooth,
      required bool isPreview}) async {
    // final bytes = await pdf.save();
    File file;
    Directory docDir = await getApplicationSupportDirectory();
    try {
      file = File('${docDir.path}/Fatoora/$name');
    } on Exception catch (e) {
      throw Exception(e);
    }

    return file;
  }

  static Future<File> previewDocument(
      {required Invoice invoice, required Document pdf, bool isEstimate=false}) async {
    final bytes = await pdf.save();
    String name ='${invoice.invoiceNo}.pdf';
    String invoiceMonth =invoice.date.substring(5, 7);
    String invoiceYear =invoice.date.substring(0, 4);
    File file;
    Directory? docDir = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    try {
      file = File(
          Platform.isAndroid
              ? '${docDir?.path}/Fatoora/$invoiceYear/Invoices/$invoiceMonth/$name'
              : '${docDir?.path}\\Fatoora\\$invoiceYear\\Invoices\\$invoiceMonth\\$name'
      );
      await file.writeAsBytes(bytes);
      // openFile(file);
      Get.to(() => OpenPDF(path: file.path, invoice: invoice));
    } on Exception catch (e) {
      throw Exception(e);
    }
    return file;
  }

  static Future<File> previewEstimate(
      {required Estimate estimate,
      required Document pdf}) async {
    final bytes = await pdf.save();
    String name ='EST-${estimate.estimateNo}.pdf';
    String estimateMonth =estimate.date.substring(5, 7);
    String estimateYear =estimate.date.substring(0, 4);
    File file;
    Directory? docDir = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    try {
      file = File(
          Platform.isAndroid
              ? '${docDir?.path}/Fatoora/$estimateYear/Estimates/$estimateMonth/$name'
              : '${docDir?.path}\\Fatoora\\$estimateYear\\Estimates\\$estimateMonth\\$name'
      );
      await file.writeAsBytes(bytes);
      // openFile(file);
      Get.to(() => OpenPDF(path: file.path, estimate: estimate));
    } on Exception catch (e) {
      throw Exception(e);
    }
    return file;
  }

  static Future<File> previewPo(
      {required Po po,
      required Document pdf}) async {
    final bytes = await pdf.save();
    String name ='EST-${po.poNo}.pdf';
    String poMonth =po.date.substring(5, 7);
    String poYear =po.date.substring(0, 4);
    File file;
    Directory? docDir = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    try {
      file = File(
          Platform.isAndroid
              ? '${docDir?.path}/Fatoora/$poYear/Po/$poMonth/$name'
              : '${docDir?.path}\\Fatoora\\$poYear\\Po\\$poMonth\\$name'
      );
      await file.writeAsBytes(bytes);
      // openFile(file);
      Get.to(() => OpenPDF(path: file.path, po: po));
    } on Exception catch (e) {
      throw Exception(e);
    }
    return file;
  }

  static Future<File> previewReceipt(
      {required Receipt receipt,
      required Document pdf}) async {
    final bytes = await pdf.save();
    String name ='RST-${receipt.id}.pdf';
    String receiptMonth =receipt.date.substring(5, 7);
    String receiptYear =receipt.date.substring(0, 4);
    File file;
    Directory? docDir = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    try {
      file = File(
          Platform.isAndroid
              ? '${docDir?.path}/Fatoora/$receiptYear/Receipts/$receiptMonth/$name'
              : '${docDir?.path}\\Fatoora\\$receiptYear\\Receipts\\$receiptMonth\\$name'
      );
      await file.writeAsBytes(bytes);
      // openFile(file);
      Get.to(() => OpenPDF(path: file.path, receipt: receipt));
    } on Exception catch (e) {
      throw Exception(e);
    }
    return file;
  }

  static Future<File> savePreviewDailyReport(
      {required String name, required Document pdf}) async {
    final bytes = await pdf.save();
    File file;
    Directory? docDir = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();

    try {
      file = File('${docDir?.path}/Fatoora/Reports/$name');
      await file.writeAsBytes(bytes);
      await openFile(file);
    } on Exception catch (e) {
      throw Exception(e);
    }

    return file;
  }

  static Future<File> savePreviewMonthlyReport(
      {required String name, required Document pdf}) async {
    final bytes = await pdf.save();
    File file;
    Directory docDir = await getApplicationSupportDirectory();
    try {
      file = File('${docDir.path}/Fatoora/monthly/$name');
      await file.writeAsBytes(bytes);

    } on Exception catch (e) {
      throw Exception(e);
    }

    return file;
  }

  static Future openFile(File file) async {
    final url = file.path;

    await OpenFile.open(url);
  }

}
