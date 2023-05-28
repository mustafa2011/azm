import 'package:fatoora/models/customers.dart';
import '../apis/constants/utils.dart';
import '/db/fatoora_db.dart';
import '/models/settings.dart';
import '/widgets/widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'edit_customer_page.dart';

class CustomersPage extends StatefulWidget {
  const CustomersPage({Key? key}) : super(key: key);

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  FatooraDB db = FatooraDB.instance;
  late int uid;
  bool isLoading = false;
  List<Customer> customers = [];
  late List<Setting> user;
  bool noCustomerFount = false;
  int workOffline = 0;
  String language = 'Arabic';

  @override
  void initState() {
    super.initState();
    refreshData();
  }

  Future refreshData() async {
    language = await Utils.language();
    getCustomersList();
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

  Future getCustomersList() async {
    try {
      setState(() => isLoading = true);

      List<Setting> setting;
      setting = await FatooraDB.instance.getAllSettings();
      if (setting.isNotEmpty) {
        setState(() {
          workOffline = setting[0].workOffline;
        });
      }
      if (workOffline == 1) {
        await FatooraDB.instance.getAllCustomers().then((list) {
          customers = list;
        });
      }
      if (customers.isEmpty) {
        setState(() {
          noCustomerFount = true;
        });
      }

      setState(() => isLoading = false);
    } on Exception catch (e) {
      messageBox(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 1,
      child: Scaffold(
          body: NewForm(
            title: 'شاشة العملاء',
            icon: Icons.refresh,
            onIconTab: refreshData,
            isLoading: isLoading,
            action: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                NewButton(
                  text: "إضافة عميل",
                  iconSize: 20,
                  icon: Icons.add,
                  onTap: () => Get.to(() => const AddEditCustomerPage()),
                ),
              ],
            ),
            tab: TabBar(
              isScrollable: true,
              indicatorWeight: 10.0,
              labelStyle: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
              indicatorPadding: const EdgeInsets.only(bottom: 0),
              onTap: (val) {
                switch (val) {
                  case 0:
                    break;
                // case 1 : print(val); break;
                // case 2 : print(val); break;
                }
              },
              tabs: const [
                Text('جميع العملاء'),
                // Text(''),
                // Text(''),
              ],
            ),
            child: TableCustomer(customer: customers),
          )),
    );
  }
}
