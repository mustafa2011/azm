import '../models/invoice.dart';
import '../models/product.dart';
import '../models/purchase.dart';
import '../screens/edit_estimate_page.dart';

import '../apis/constants/utils.dart';
import '../models/estimate.dart';
import '../models/po.dart';
import '../models/receipt.dart';
import '../widgets/widget.dart';
import '/db/fatoora_db.dart';
import '/models/settings.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'edit_invoice_android_page.dart';
import 'edit_po_page.dart';
import 'edit_receipt_page.dart';

class InvoicesPage extends StatefulWidget {
  const InvoicesPage({Key? key}) : super(key: key);

  @override
  State<InvoicesPage> createState() => _InvoicesPageState();
}

class _InvoicesPageState extends State<InvoicesPage> {
  FatooraDB db = FatooraDB.instance;
  late int uid;
  bool isLoading = false;
  List<Invoice> invoices = [];
  List<Purchase> purchases = [];
  List<Product> products = [];
  List<Receipt> receipts = [];
  List<Estimate> estimates = [];
  List<Po> po = [];
  late List<Setting> user;
  bool noInvoiceFount = false;
  bool showPurchase = false;
  bool showEstimate = false;
  bool showPo = false;
  bool showReceipt = false;
  String language = 'Arabic';
  String transType = 'فاتورة مبيعات';
  bool isListView = true;
  int tabValue = 0;

  @override
  void initState() {
    super.initState();
    refreshData();
  }

  @override
  void dispose() {
    super.dispose();
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

  Future getSalesList() async {
    try {
      setState(() => isLoading = true);
      await FatooraDB.instance.getAllInvoices().then((list) => invoices = list);
      setState(() => isLoading = false);
    } on Exception catch (e) {
      messageBox(e.toString());
    }
  }

  Future getPurchasesList() async {
    try {
      setState(() => isLoading = true);
      await FatooraDB.instance
          .getAllPurchases()
          .then((list) => purchases = list);
      setState(() => isLoading = false);
    } on Exception catch (e) {
      messageBox(e.toString());
    }
  }

  Future getReceiptsList() async {
    try {
      setState(() => isLoading = true);
      await FatooraDB.instance.getAllReceipts().then((list) => receipts = list);
      setState(() => isLoading = false);
    } on Exception catch (e) {
      messageBox(e.toString());
    }
  }

  Future getEstimatesList() async {
    try {
      setState(() => isLoading = true);
      await FatooraDB.instance
          .getAllEstimates()
          .then((list) => estimates = list);
      setState(() => isLoading = false);
    } on Exception catch (e) {
      messageBox(e.toString());
    }
  }

  Future getPoList() async {
    try {
      setState(() => isLoading = true);
      await FatooraDB.instance.getAllPo().then((list) => po = list);
      setState(() => isLoading = false);
    } on Exception catch (e) {
      messageBox(e.toString());
    }
  }

  Future refreshData() async {
    language = await Utils.language();
    getSalesList();
    getPurchasesList();
    getEstimatesList();
    getReceiptsList();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
          body: NewForm(
            title: 'شاشة الفواتير',
            icon: Icons.refresh,
            onIconTab: refreshData,
            isLoading: isLoading,
            action: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                NewButton(
                  text:  "مبيعات",
                  icon: Icons.add, iconSize: 20,
                  onTap: () => Get.to(() => const AddEditInvoiceAndroidPage(
                      isCreditNote: false, isPurchases: false)),
                ),
                Utils.space(0, 1),
                NewButton(
                  text: "مشتريات",
                  icon: Icons.add, iconSize: 20,
                  onTap: () => Get.to(() => const AddEditInvoiceAndroidPage(
                      isCreditNote: false, isPurchases: true)),
                ),
                Utils.space(0, 1),
                NewButton(
                  text: "عرض سعر",
                  icon: Icons.add, iconSize: 20,
                  onTap: () => Get.to(() => const AddEditEstimatePage()),
                ),
                Utils.space(0, 1),
                NewButton(
                  text: "سند قبض",
                  icon: Icons.add,iconSize: 20,
                  onTap: () => Get.to(() => const AddEditReceiptPage()),
                ),
                Utils.space(0, 1),
                NewButton(
                  text: "طلب شراء",
                  icon: Icons.add,  iconSize: 20,
                  onTap: () => Get.to(() => const AddEditPoPage()),
                ),
              ],
            ),
            tab: TabBar(
              isScrollable: true,
              indicatorWeight: 10.0,
              labelStyle: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
              indicatorPadding: const EdgeInsets.only(bottom: 0),
              onTap: (val) => setState(() => tabValue = val),
              tabs: const [
                Text('المبيعات'),
                Text('المشتريات'),
                Text('العروض'),
                Text('السندات'),
                Text('طلبات الشراء'),
                // Text(''),
              ],
            ),
            child: tabValue == 0
                ? TableInvoice(invoice: invoices)
                : tabValue == 1
                ? TablePurchase(purchase: purchases)
                : tabValue == 2
                ? TableEstimate(estimate: estimates)
                : tabValue == 3
                ? TableReceipt(receipt: receipts)
                : tabValue == 4
                ? TablePo(po: po)
                : Container(),
          )),
    );
  }
}
