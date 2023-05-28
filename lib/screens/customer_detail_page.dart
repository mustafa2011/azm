import '../db/fatoora_db.dart';
import '../models/customers.dart';
import '../models/settings.dart';
import '../screens/customers_page.dart';
import '../widgets/app_colors.dart';
import '../widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'edit_customer_page.dart';

class CustomerDetailPage extends StatefulWidget {
  final int customerId;

  const CustomerDetailPage({
    Key? key,
    required this.customerId,
  }) : super(key: key);
  @override
  State<CustomerDetailPage> createState() => _CustomerDetailPageState();
}


class _CustomerDetailPageState extends State<CustomerDetailPage> {
  late Customer customer;
  int? id;
  String? name;
  String? vatNumber;
  String imgUrl = '';
  bool isLoading = false;
  int workOffline = 1;

  @override
  void initState() {
    super.initState();
    refreshCustomer();
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
              child: const Text("نعم"),
              onPressed: () async {
                // setState(() =>isLoading = true);
                // await SheetApi.deleteCustomerById(widget.customerId);
                await FatooraDB.instance.deleteCustomer(customer);
                int? count = await FatooraDB.instance.getCustomerCount();
                if(count==0){
                  await FatooraDB.instance.deleteCustomerSequence();
                }
                // print(widget.customerId);
                // setState(() =>isLoading = false);
                Get.to(()=>const CustomersPage());
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
  }

  Future refreshCustomer() async {
    setState(() => isLoading = true);

    List<Setting> setting;
    setting = await FatooraDB.instance.getAllSettings();
    if(setting.isNotEmpty){
      setState(() {
        workOffline = setting[0].workOffline;
      });
    }

    if (workOffline==1) {
      customer = await FatooraDB.instance.getCustomerById(widget.customerId);
      // print(customer.name);
    }
    /*else {
      customer = await SheetApi.getCustomerById(widget.customerId);
    }*/
    id = customer.id; // int.parse(customer[0]);
    name = customer.name; // customer[1];
    vatNumber = customer.vatNumber; // String.parse(customer[2]);

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          foregroundColor: AppColor.primary,
          title: Text(
            'صفحة العميل رقم $id',
            style: const TextStyle(
              color: AppColor.primary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [editButton(), deleteButton()],
        ),
        body: Container(
                color: AppColor.background,
                padding: const EdgeInsets.all(12),
                child: isLoading
                    ? const Center(child: Loading(),)
                    : ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    Row(
                      children: [
                        const Text(
                          "رقم العميل",
                          style: TextStyle(
                            color: AppColor.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Text(
                          id.toString(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(thickness: 2),
                    Row(
                      children: [
                        const Text(
                          "اسم العميل",
                          style: TextStyle(
                            color: AppColor.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Text(
                            name!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(thickness: 2),
                    Row(
                      children: [
                        const Text(
                          "الرقم الضريبي",
                          style: TextStyle(
                            color: AppColor.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Text(
                          vatNumber!,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(thickness: 2),
                  ],
                ),
              ),
      );

  Widget editButton() => IconButton(
      icon: const Icon(Icons.edit_outlined),
      onPressed: () async {
        if (isLoading) return;

        await Get.to(()=>AddEditCustomerPage(customer: customer));

        refreshCustomer();
      });

  Widget deleteButton() => IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () async {
          // await CustomersDatabase.instance.delete(widget.customerId);
          var result = messageBox('سوف يتم حذف هذا العميل من قواعد البيانات\n\nهل أنت متأكد من هذا الإجراء');
          return result;
        },
      );
}
