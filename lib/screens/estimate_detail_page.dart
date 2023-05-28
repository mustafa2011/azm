import 'dart:core';
import '../apis/constants/utils.dart';
import '../db/fatoora_db.dart';
import '../models/customers.dart';
import '../models/estimate.dart';
import '../models/settings.dart';
import '../widgets/app_colors.dart';
import '../widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'edit_estimate_page.dart';
import 'invoices_page.dart';

class EstimateDetailPage extends StatefulWidget {
  final int estimateId;

  const EstimateDetailPage({
    Key? key,
    required this.estimateId,
  }) : super(key: key);

  @override
  State<EstimateDetailPage> createState() => _EstimateDetailPageState();
}

class _EstimateDetailPageState extends State<EstimateDetailPage> {
  late Estimate estimate;
  int? id;
  String? estimateNo;
  String? date;
  String? vendor;
  String? vendorVatNumber;
  Setting? seller;
  Customer? payer;
  int? sellerId;
  String? vatNumber;
  num? total;
  num? totalVat;
  int? posted;
  int? payerId;
  late String qrString;
  late String qrString1;
  bool isLoading = false;
  bool isCreditNote = false;
  String pageTitle = 'عرض سعر';
  String language = 'Arabic';

  @override
  void initState() {
    super.initState();

    refreshEstimate();
  }

  void messageBox(String? message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('رسالة'),
          content: Text(message!),
          actions:
              <Widget>[
                  TextButton(
                    child: const Text("نعم"),
                    onPressed: () async {
                      await FatooraDB.instance.deleteEstimateById(widget.estimateId);
                      int? estimatesCount = await FatooraDB.instance.getEstimatesCount();
                      if (estimatesCount == 0) {
                        await FatooraDB.instance.deleteEstimateSequence();
                      }

                      Get.to(() => const InvoicesPage());
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

  Future refreshEstimate() async {
    setState(() => isLoading = true);
    language = await Utils.language();

      estimate = await FatooraDB.instance.getEstimateById(widget.estimateId);
      id = estimate.id;
      estimateNo = estimate.estimateNo;
      date = estimate.date;
      sellerId = estimate.sellerId;
      seller = await FatooraDB.instance.getSellerById(sellerId!);
      total = estimate.total;
      totalVat = estimate.totalVat;
      posted = estimate.posted;
      payerId = estimate.payerId;
      payer = await FatooraDB.instance.getCustomerById(payerId!);

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          foregroundColor: AppColor.primary,
          title: Text(
            language == 'Arabic'
                ? 'عرض سعر رقم $estimateNo'
                : 'Estimate No $estimateNo',
            style: const TextStyle(
              color: AppColor.primary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions:[editButton(), deleteButton()],
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
                        Text(
                          language == 'Arabic' ? "التاريخ" : "Date",
                          style: const TextStyle(
                            color: AppColor.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Text(
                            date!,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(thickness: 2),
                    Row(
                      children: [
                        Text(
                          language == 'Arabic' ? 'البائع' : 'Seller',
                          style: const TextStyle(
                            color: AppColor.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Text(seller!.seller,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(thickness: 2),
                    Row(
                      children: [
                        Text(
                         language == 'Arabic' ? 'الرقم الضريبي للبائع' : 'Seller VAT No',
                          style: const TextStyle(
                            color: AppColor.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Text(
                            seller!.vatNumber,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(thickness: 2),
                    Row(
                      children: [
                        Text(
                          language == 'Arabic' ? "إجمالي العرض" : "Total Estimate",
                          style: const TextStyle(
                            color: AppColor.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Text(
                          Utils.formatNoCurrency(total!),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(thickness: 2),
                    Row(
                      children: [
                        Text(
                          language == 'Arabic' ? "إجمالي الضريبة" : "Total VAT",
                          style: const TextStyle(
                            color: AppColor.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Text(
                            Utils.formatNoCurrency(totalVat!),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Divider(thickness: 2),
                        Utils.isProVersion ? Row(
                          children: [
                            Text(
                              language == 'Arabic' ? 'المشتري' : 'Payer',
                              style: const TextStyle(
                                color: AppColor.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Text(
                                payer!.name,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ) : Container(),
                        const Divider(thickness: 2),
                        Row(
                          children: [
                            Text(
                              language == 'Arabic' ? "الرقم الضريبي للمشتري" : "Payer VAT No",
                              style: const TextStyle(
                                color: AppColor.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Text(
                                payer!.vatNumber,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(thickness: 2),
                      ],
                    )
                  ],
                ),
              ),
      );

  Widget editButton() => IconButton(
      icon: const Icon(Icons.edit_outlined),
      onPressed: () async {
        {
          if (isLoading) return;
          await Get.to(() =>  AddEditEstimatePage(estimate: estimate));
        }
      });

  Widget deleteButton() => IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () async {
          var result = messageBox(
                'سوف يتم حذف هذا العرض من قواعد البيانات\n\nهل أنت متأكد من هذا الإجراء');
          return result;
        },
      );

}