import '../db/fatoora_db.dart';
import '../models/dashboard.dart';
import '../models/invoice.dart';
import '../models/settings.dart';
import 'package:flutter/cupertino.dart';

import '../models/news.dart';
import '/models/clients.dart';
import '/models/product.dart';
import 'package:gsheets/gsheets.dart';

import 'constants/my_constants.dart';

class SheetApi {
  static final gSheet = GSheets(MyConstant.credentials);
  static Worksheet? productSheet;
  static Worksheet? invoiceSheet;
  static Worksheet? invoiceLinesSheet;
  static Worksheet? clientSheet;
  static Worksheet? dashboardSheet;
  static Worksheet? defaultSheet;
  static Worksheet? newsSheet;

  static Future init() async {
    try {

      String strSheetId='1uA1Yib05DypFgGnv6r77KoqRwgbP3r9Oz1uXy_NpQG4'; //Default sheet until user set his own sheetId
      List<Setting> setting;
      setting = await FatooraDB.instance.getAllSettings();
      if (setting.isNotEmpty) {
        strSheetId = setting[0].sheetId;
      }

      final mySheetId = await gSheet.spreadsheet(strSheetId);
      final clientSheetId = await gSheet.spreadsheet(MyConstant.clientSheetId);

      clientSheet = await _getWorkSheet(clientSheetId, title: 'fatoora');
      newsSheet = await _getWorkSheet(clientSheetId, title: 'news');
      productSheet = await _getWorkSheet(mySheetId, title: 'products');
      invoiceSheet = await _getWorkSheet(mySheetId, title: 'invoices');
      invoiceLinesSheet = await _getWorkSheet(mySheetId, title: 'invoice_lines');
      dashboardSheet = await _getWorkSheet(mySheetId, title: 'dashboard');

      // To delete the defalut created work sheet named 'Sheet1'
      defaultSheet = await _getWorkSheet(mySheetId, title: 'Sheet1');
      await _deleteWorkSheet(mySheetId, defaultSheet!);

      // await getDashBoard();

      final firstRow = ClientFields.getClientFields();
      clientSheet!.values.insertRow(1, firstRow);

      final firstProductRow = ProductFields.getProductsFields();
      productSheet!.values.insertRow(1, firstProductRow);

      final firstInvoiceRow = InvoiceFields.getInvoiceFields();
      invoiceSheet!.values.insertRow(1, firstInvoiceRow);

      final firstInvoiceLinesRow = InvoiceLinesFields.getInvoiceLinesFields();
      invoiceLinesSheet!.values.insertRow(1, firstInvoiceLinesRow);

      final firstDashboarRow = DashboardTitleFields.getDashboardTitleFields();
      dashboardSheet!.values.insertRow(1, firstDashboarRow);

      final secondDashboarRow = DashboardFormulaFields.getDashboardTitleFields();
      dashboardSheet!.values.insertRow(2, secondDashboarRow);

    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static Future<Worksheet?> _getWorkSheet(Spreadsheet spreadsheet, {required String title}) async {
    try {
      return await spreadsheet.addWorksheet(title);
    } catch (e) {
      return spreadsheet.worksheetByTitle(title);
    }
  }

  static Future<bool?> _deleteWorkSheet(Spreadsheet spreadsheet, Worksheet worksheet) async {
    try {
      return await spreadsheet.deleteWorksheet(worksheet);
    } catch (e) {
      return false;
    }
  }

  static Future<List<Product>> getAllProducts() async {
    if (productSheet == null) return <Product>[];
    List<Map<String, String>>? products;
    try {
      products = await productSheet!.values.map.allRows();
    } on Exception catch (e) {
      debugPrint(e.toString());
    }

    return products == null
        ? <Product>[]
        : products.map((json) => Product.fromJson(json)).toList();
  }

  static Future<List<News>> getAllNews() async {
    if (newsSheet == null) return <News>[];
    List<Map<String, String>>? news;
    try {
      news = await newsSheet!.values.map.allRows();
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
    //sort((e1, e2) => e1.key.compareTo(e2.key)));
    return news == null
        ? <News>[]
        : news.map((json) => News.fromJson(json)).toList();
  }

  static Future<List<Invoice>> getAllInvoices() async {
    if (invoiceSheet == null) return <Invoice>[];
    List<Map<String, String>>? invoices;
    try {
      invoices = await invoiceSheet!.values.map.allRows();
    } on Exception catch (e) {
      debugPrint(e.toString());
    }

    return invoices!.isEmpty
        ? <Invoice>[]
        : invoices.map((json) => Invoice.fromJson(json)).toList();
  }

  static Future<List<Client>> getAllClients() async {
    if (clientSheet == null) return <Client>[];
    final customers = await clientSheet!.values.map.allRows();
    return customers!.isEmpty
        ? <Client>[]
        : customers.map((json) => Client.fromJson(json)).toList();
  }
/*
  static Future<List<dynamic>> getInvoiceLines(int invoiceId) async {
    if (invoiceLinesSheet == null) return <InvoiceLines>[];
    final invoiceLines = await invoiceLinesSheet!.values.map.allRows(); //invoiceId);
    List<dynamic> list =[];
    list.clear();
    // print(invoiceLines);
    for (int i=0; i< invoiceLines!.length; i++){
      String? recId = invoiceLines[i]["recId"];
      if(int.parse(recId!) == invoiceId){
        list.add(invoiceLines[i]);
      }
    }
    // print(list);
    return list;
  }
*/

  static Future insertNewClient(List<Map<String, dynamic>> rowList) async {
    if (clientSheet == null) return;
    await clientSheet!.values.map.appendRows(rowList);
  }

  static Future insertNewProduct(List<Map<String, dynamic>> rowList) async {
    if (productSheet == null) return;
    await productSheet!.values.map.appendRows(rowList);
  }

  // static Future insertNewInvoice(List<Map<String, dynamic>> rowList) async {
  static Future insertNewInvoice(List<Map<String, dynamic>> rowList) async {
    if (invoiceSheet == null) return;
    await invoiceSheet!.values.map.appendRows(rowList);
  }

  static Future insertNewInvoiceLines(List<Map<String, dynamic>> rowList) async {
    if (invoiceLinesSheet == null) return;
    await invoiceLinesSheet!.values.map.appendRows(rowList);
  }

  static Future<bool> update(int id, Map<String, dynamic> customer,) async {
    if (clientSheet == null) return false;
    return await clientSheet!.values.map.insertRowByKey(id, customer);
  }

  static Future<bool> updateProduct(int id, Map<String, dynamic> product,) async {
    if (productSheet == null) return false;
    return await productSheet!.values.map.insertRowByKey(id, product);
  }

  static Future<bool> updateInvoice(int id, Map<String, dynamic> invoice,) async {
    if (invoiceSheet == null) return false;
    return await invoiceSheet!.values.map.insertRowByKey(id, invoice);
  }

  static Future<int> getRowCount() async {
    if (clientSheet == null) return 0;
    final lastRow = await clientSheet!.values.lastRow();
    return lastRow == null ? 1 : int.tryParse(lastRow.first) ?? 0;
  }

  static Future<int> getProductsRowCount() async {
    if (productSheet == null) return 0;
    final lastRow = await productSheet!.values.lastRow();
    return lastRow == null ? 1 : int.tryParse(lastRow.first) ?? 0;
  }

  static Future<int> getInvoicesRowCount() async {
    if (invoiceSheet == null) return 0;
    final lastRow = await invoiceSheet!.values.lastRow();
    return lastRow == null ? 1 : int.tryParse(lastRow.first) ?? 0;
  }

  static Future<int> getInvoiceLinesRowCount() async {
    if (invoiceLinesSheet == null) return 0;
    final lastRow = await invoiceLinesSheet!.values.lastRow();
    return lastRow == null ? 1 : int.tryParse(lastRow.first) ?? 0;
  }

  static Future<dynamic> getDashBoard() async {
    if (dashboardSheet == null) return null;
    final dashboard = await dashboardSheet!.values.row(2);
    return dashboard;
  }

  static Future<bool> updateClientCell({required int id, required String key, required dynamic value,}) async {
    if (clientSheet == null) return false;
    return clientSheet!.values
        .insertValueByKeys(value, columnKey: key, rowKey: id);
  }

  static Future<dynamic> getNameById(int id) async {
    if (clientSheet == null) return '';
    final name = await clientSheet!.values.value(column: 3, row: id);
    return name == '' ? '' : name;
  }

  static Future<dynamic> getClientById(int id) async {
    if (clientSheet == null) return null;
    final client = await clientSheet!.values.rowByKey(id);
    return client;
  }

  static Future<dynamic> getProductById(int id) async {
    if (productSheet == null) return null;
    final product = await productSheet!.values.rowByKey(id, fromColumn: 1) as List<String>;
    return product;
  }

  static Future<dynamic> getInvoiceById(int id) async {
    if (invoiceSheet == null) return null;
    final invoice = await invoiceSheet!.values.rowByKey(id, fromColumn: 1) as List<String>;
    return invoice;
  }

  static Future<dynamic> getPasswordById(int id) async {
    if (clientSheet == null) return '';
    final password = await clientSheet!.values.value(column: 3, row: id);
    return password == '' ? '' : password;
  }

  static Future<bool> deleteClientById(int id) async {
    if (clientSheet == null) return false;

    final index = await clientSheet!.values.rowIndexOf(id);
    if (index == -1) return false;

    return clientSheet!.deleteRow(index);
  }

  static Future<bool> deleteProductById(int id) async {
    if (productSheet == null) return false;

    final index = await productSheet!.values.rowIndexOf(id);
    if (index == -1) return false;

    return productSheet!.deleteRow(index);
  }

  static Future<bool> deleteInvoiceById(int id) async {
    if (invoiceSheet == null) return false;

    final index = await invoiceSheet!.values.rowIndexOf(id);
    if (index == -1) return false;

    return invoiceSheet!.deleteRow(index);
  }

  static Future<bool> deleteInvoiceLinesById(int id, int totalRows) async {
    if (invoiceLinesSheet == null) return false;

    final index = await invoiceLinesSheet!.values.rowIndexOf(id);
    if (index == -1) return false;

    return invoiceLinesSheet!.deleteRow(index, count: totalRows);
  }

}
