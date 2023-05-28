import 'dart:core';
import '../apis/constants/utils.dart';
import '../db/fatoora_db.dart';
import '../models/receipt.dart';
import '../widgets/app_colors.dart';
import '../widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'edit_receipt_page.dart';
import 'invoices_page.dart';

class ReceiptDetailPage extends StatefulWidget {
  final int receiptId;

  const ReceiptDetailPage({
    Key? key,
    required this.receiptId,
  }) : super(key: key);

  @override
  State<ReceiptDetailPage> createState() => _ReceiptDetailPageState();
}

class _ReceiptDetailPageState extends State<ReceiptDetailPage> {
  late Receipt receipt;
  int? id;
  String? receiptNo;
  String? receivedFrom;
  String? date;
  String? sumOf;
  String? bank;
  String? amountFor;
  String? payType;
  num? amount;
  String? chequeNo;
  String? chequeDate;
  String? transferNo;
  String? transferDate;
  bool isLoading = false;
  bool isCreditNote = false;
  String pageTitle = 'سند قبض';
  String language = 'Arabic';

  @override
  void initState() {
    super.initState();

    refreshReceipt();
  }

  void messageBox(String? message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('رسالة'),
          content: Text(message!),
          actions: <Widget>[
            TextButton(
              child: const Text("نعم"),
              onPressed: () async {
                await FatooraDB.instance.deleteReceiptById(widget.receiptId);
                int? receiptsCount =
                    await FatooraDB.instance.getReceiptsCount();
                if (receiptsCount == 0) {
                  await FatooraDB.instance.deleteReceiptSequence();
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

  Future refreshReceipt() async {
    setState(() => isLoading = true);
    language = await Utils.language();

    receipt = await FatooraDB.instance.getReceiptById(widget.receiptId);
    id = receipt.id;
    receiptNo = Utils.formatEstimate(id!);
    receivedFrom = receipt.receivedFrom;
    date = receipt.date;
    amountFor = receipt.amountFor;
    sumOf = receipt.sumOf;
    amount = receipt.amount;
    chequeNo = receipt.chequeNo;
    chequeDate = receipt.chequeDate;
    transferNo = receipt.transferNo;
    transferDate = receipt.transferDate;
    bank = receipt.bank;
    payType = receipt.payType;

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          foregroundColor: AppColor.primary,
          title: Text(
            language == 'Arabic'
                ? 'سند قبض رقم $receiptNo'
                : 'Receipt No $receiptNo',
            style: const TextStyle(
              color: AppColor.primary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [editButton(), deleteButton()],
        ),
        body: Container(
          color: AppColor.background,
          padding: const EdgeInsets.all(12),
          child: isLoading
              ? const Center(
                  child: Loading(),
                )
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
                          language == 'Arabic' ? 'استلمنا من' : 'Received From',
                          style: const TextStyle(
                            color: AppColor.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Text(
                            receivedFrom!,
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
                          language == 'Arabic' ? 'مبلغ' : 'Amount',
                          style: const TextStyle(
                            color: AppColor.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Text(
                            Utils.format(amount!),
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
                          language == 'Arabic' ? "فقط" : "Sum of",
                          style: const TextStyle(
                            color: AppColor.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Text(
                            sumOf!,
                            maxLines: 2,
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
                          language == 'Arabic' ? "طريقة الدفع" : "Pay type",
                          style: const TextStyle(
                            color: AppColor.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Text(
                            payType!,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    payType == 'نقدا'
                        ? const Divider(thickness: 2)
                        : payType == 'شيك'
                            ? Column(
                                children: [
                                  const Divider(thickness: 2),
                                  Row(
                                    children: [
                                      Text(
                                        language == 'Arabic'
                                            ? "رقم الشيك"
                                            : "Cheque No",
                                        style: const TextStyle(
                                          color: AppColor.primary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      Expanded(
                                        child: Text(
                                          chequeNo!,
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
                                        language == 'Arabic'
                                            ? "تاريخ الشيك"
                                            : "Cheque Date",
                                        style: const TextStyle(
                                          color: AppColor.primary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      Expanded(
                                        child: Text(
                                          chequeDate!,
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
                                        language == 'Arabic'
                                            ? "على بنك"
                                            : "Bank",
                                        style: const TextStyle(
                                          color: AppColor.primary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      Expanded(
                                        child: Text(
                                          bank!,
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
                            : payType == 'حوالة'
                                ? Column(
                                    children: [
                                      const Divider(thickness: 2),
                                      Row(
                                        children: [
                                          Text(
                                            language == 'Arabic'
                                                ? "رقم الحوالة"
                                                : "Transfer No",
                                            style: const TextStyle(
                                              color: AppColor.primary,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 20),
                                          Expanded(
                                            child: Text(
                                              transferNo!,
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
                                            language == 'Arabic'
                                                ? "تاريخ الحوالة"
                                                : "Transfer Date",
                                            style: const TextStyle(
                                              color: AppColor.primary,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 20),
                                          Expanded(
                                            child: Text(
                                              transferDate!,
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
                                            language == 'Arabic'
                                                ? "على بنك"
                                                : "Bank",
                                            style: const TextStyle(
                                              color: AppColor.primary,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 20),
                                          Expanded(
                                            child: Text(
                                              bank!,
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
                                : Container(),
                    Row(
                      children: [
                        Text(
                          language == 'Arabic' ? "وذلك عن" : "Amount for",
                          style: const TextStyle(
                            color: AppColor.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Text(
                            amountFor!,
                            maxLines: 2,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      );

  Widget editButton() => IconButton(
      icon: const Icon(Icons.edit_outlined),
      onPressed: () async {
        {
          if (isLoading) return;
          await Get.to(() => AddEditReceiptPage(receipt: receipt));
        }
      });

  Widget deleteButton() => IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () async {
          var result = messageBox(
              'سوف يتم حذف هذا السند من قواعد البيانات\n\nهل أنت متأكد من هذا الإجراء');
          return result;
        },
      );
}
