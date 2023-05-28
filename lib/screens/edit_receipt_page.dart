import 'package:dropdown_search/dropdown_search.dart';

import '../apis/constants/utils.dart';
import '../apis/pdf_receipt_api.dart';

import '../db/fatoora_db.dart';
import '../models/receipt.dart';
import '../widgets/app_colors.dart';
import '../widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';

import '../models/settings.dart';
import 'invoices_page.dart';

class AddEditReceiptPage extends StatefulWidget {
  final Receipt? receipt;

  const AddEditReceiptPage({
    Key? key,
    this.receipt,
  }) : super(key: key);

  @override
  State<AddEditReceiptPage> createState() => _AddEditReceiptPageState();
}

class _AddEditReceiptPageState extends State<AddEditReceiptPage> {
  List<String> payTypeList = ['نقدا', 'شيك', 'حوالة'];

  final _key1 = GlobalKey<FormState>();
  late int newId; // This id for new receipt id in cloud database
  late int id; // this is existing receipt id will be retrieved from widget
  late final String date;
  String? payType = 'نقدا';
  late final String receivedFrom;
  late final String sumOf;
  late final num amount;
  late final String amountFor;
  late final String chequeNo;
  late final String chequeDate;
  late final String transferNo;
  late final String transferDate;
  late final String bank;
  late final Setting seller;
  late String receiptNo;
  int counter = 0;

  bool isReceipt = true;

  final TextEditingController _date = TextEditingController();
  final TextEditingController _receivedFrom = TextEditingController();
  final TextEditingController _sumOf = TextEditingController();
  final TextEditingController _amount = TextEditingController();
  final TextEditingController _amountFor = TextEditingController();
  final TextEditingController _payType = TextEditingController();
  final TextEditingController _chequeNo = TextEditingController();
  final TextEditingController _chequeDate = TextEditingController();
  final TextEditingController _transferNo = TextEditingController();
  final TextEditingController _transferDate = TextEditingController();
  final TextEditingController _bank = TextEditingController();

  final FocusNode focusNode = FocusNode();

  bool isLoading = false;
  String language = 'Arabic';

  @override
  void initState() {
    super.initState();
    getReceipt();
    focusNode.requestFocus();
  }

  Future getReceipt() async {
    FatooraDB db = FatooraDB.instance;
    language = await Utils.language();

    try {
      setState(() => isLoading = true);
      var user = await db.getAllSettings();
      int uid = user[0].id as int;
      seller = await db.getSellerById(uid);

      int? receiptsCount = await FatooraDB.instance.getReceiptsCount();

      if (widget.receipt != null) {
        date = widget.receipt!.date;
        sumOf = widget.receipt!.sumOf;
        payType = widget.receipt!.payType;
        receivedFrom = widget.receipt!.receivedFrom;
        amount = widget.receipt!.amount;
        amountFor = widget.receipt!.amountFor;
        chequeNo = widget.receipt!.chequeNo;
        chequeDate = widget.receipt!.chequeDate;
        transferNo = widget.receipt!.transferNo;
        transferDate = widget.receipt!.transferDate;
        bank = widget.receipt!.bank;
      } else {
        date = Utils.formatShortDate(DateTime.now());
        sumOf = '';
        payType = 'نقدا';
        receivedFrom = '';
        amount = 0;
        amountFor = '';
        chequeNo = '';
        chequeDate = '';
        transferNo = '';
        transferDate = '';
        bank = '';
      }
      id = widget.receipt != null
          ? widget.receipt!.id!
          : receiptsCount == 0
              ? 1
              : (await db.getNewReceiptId())! + 1;
      _date.text = date;
      _sumOf.text = sumOf;
      _payType.text = payType!;
      _receivedFrom.text = receivedFrom;
      _amount.text = amount.toString();
      _amountFor.text = amountFor;
      _chequeNo.text = chequeNo;
      _chequeDate.text = chequeDate;
      _transferNo.text = transferNo;
      _transferDate.text = transferDate;
      _bank.text = bank;

      receiptNo = Utils.formatEstimate(id); // like '0000321'

      setState(() {
        isLoading = false;
      });
    } on Exception catch (e) {
      messageBox(e.toString());
    }
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

  void confirmSave() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تأكيد الحفظ'),
          content: const Text('تمت عملية الحفظ بنجاح'),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            TextButton(
              child: const Text("موافق"),
              onPressed: () {
                Get.to(() => const InvoicesPage());
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Center(
            child: Text(
              language == 'Arabic' ? 'سند قبض' : 'Receipt',
              style: const TextStyle(
                  color: AppColor.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            ),
          ),
          actions: [
            buildButtonSave(),
          ],
        ),
        body: isLoading
            ? const Center(
                child: Loading(),
              )
            : buildBody(),
      );

  Widget buildBody() => Stack(
        children: [
          /// ListView header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  child: Form(
                    key: _key1,
                    child: Column(
                      children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Utils.space(5, 0),
                              InkWell(
                                  onTap: () => _selectDate(),
                                  child: Text(
                                      '${language == 'Arabic' ? 'التاريخ:' : 'Date:'} ${_date.text}')),
                              /*Text(Utils.formatEstimate(id),
                                  style: const TextStyle(color: Colors.red,
                                      fontSize: 18, fontWeight: FontWeight.bold))*/
                            ]),
                        buildReceivedFrom(),
                        Row(
                          children: [
                            SizedBox(width: 100, child: buildAmount(),),
                            Utils.space(0, 2),
                            Expanded(child: buildSumOf()),
                          ],
                        ),
                        buildPayType(),
                        buildAmountFor(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),


        ],
      );

  Widget buildButtonSave() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: AppColor.primary,
          backgroundColor: AppColor.background,
        ),
        onPressed: saveAndPreview,
        child: Text(language == 'Arabic' ? 'حفظ/عرض' : 'Print'),
      ),
    );
  }

  Widget buildChequeNo() => TextFormField(
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        controller: _chequeNo,
        onTap: () {
          var textValue = _chequeNo.text;
          _chequeNo.selection = TextSelection(
            baseOffset: 0,
            extentOffset: textValue.length,
          );
        },
        style: const TextStyle(
          color: AppColor.primary,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        decoration: InputDecoration(
          labelText: language == 'Arabic'
                  ? 'رقم الشيك'
                  : 'Cheque No',
        ),
      );

  Widget buildAmount() => TextFormField(
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        controller: _amount,
        maxLines: 2,
        onTap: () {
          var textValue = _amount.text;
          _amount.selection = TextSelection(
            baseOffset: 0,
            extentOffset: textValue.length,
          );
        },
        style: const TextStyle(
          color: AppColor.primary,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        decoration: InputDecoration(
          labelText:
              language == 'Arabic' ? 'المبلغ' : 'Amount',
        ),
        validator: (amount) =>
            amount == null || amount == '' ? 'يجب إدخال المبلغ' : null,
        onChanged: (value) => _sumOf.text = Utils.numToWord(_amount.text),
      );

  Widget buildSumOf() => TextFormField(
        readOnly: true,
        controller: _sumOf,
        maxLines: 2,
        style: const TextStyle(
          color: AppColor.primary,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        decoration: InputDecoration(
          labelText:
              language == 'Arabic' ? 'فقط' : 'Sum Of',
        ),
      );

  Widget buildChequeDate() => TextFormField(
        controller: _chequeDate,
        style: const TextStyle(
          color: AppColor.primary,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        decoration: InputDecoration(
          labelText: language == 'Arabic' ? 'تاريخ الشيك' : 'Cheque Date',
        ),
      );

  Widget buildAmountFor() => TextFormField(
        controller: _amountFor,
        style: const TextStyle(
          color: AppColor.primary,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        decoration: InputDecoration(
          labelText: language == 'Arabic' ? 'وذلك عن' : 'Amount For',
        ),
      );

  Widget buildTransferDate() => TextFormField(
        controller: _transferDate,
        style: const TextStyle(
          color: AppColor.primary,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        decoration: InputDecoration(
          labelText: language == 'Arabic' ? 'تاريخ الحوالة' : 'Transfer Date',
        ),
      );

  Widget buildBank() => TextFormField(
        controller: _bank,
        style: const TextStyle(
          color: AppColor.primary,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        decoration: InputDecoration(
          labelText: language == 'Arabic' ? 'على بنك' : 'Bank',
        ),
      );

  Widget buildReceivedFrom() => TextFormField(
        controller: _receivedFrom,
        autofocus: true,
        style: const TextStyle(
          color: AppColor.primary,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        decoration: InputDecoration(
          labelText: language == 'Arabic' ? 'استلمنا من' : 'Received From',
        ),
      );

  Widget buildTransferNo() => TextFormField(
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        controller: _transferNo,
        onTap: () {
          var textValue = _transferNo.text;
          _transferNo.selection = TextSelection(
            baseOffset: 0,
            extentOffset: textValue.length,
          );
        },
        style: const TextStyle(
          color: AppColor.primary,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        decoration: InputDecoration(
          labelText:
              language == 'Arabic' ? 'رقم الحوالة' : 'Transfer No',
        ),
      );

  Widget buildPayType() => Column(
    children: [
      Row(
            children: [
              SizedBox(
                width: 100,
                child: DropdownSearch<String>(
                  popupProps: const PopupProps.menu(
                      showSelectedItems: true,
                      constraints: BoxConstraints(
                          maxHeight: 170)),
                  dropdownDecoratorProps: const DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration()),
                  items: payTypeList,
                  onChanged: (val) => setState(() {
                    payType = val;
                  }),
                  selectedItem: payType,
                ),
              ),
              payType == 'شيك' || payType == 'حوالة' ? Utils.space(0, 2) : Container(),
              payType == 'شيك'
                  ? Expanded(child: buildChequeNo())
                  : payType == 'حوالة'
                    ? Expanded(child: buildTransferNo())
                    : Container(),
              payType == 'شيك' || payType == 'حوالة' ? Utils.space(0, 2) : Container(),
              payType == 'شيك'
                  ? Expanded(child: buildChequeDate())
                  : payType == 'حوالة'
                    ? Expanded(child: buildTransferDate())
                    : Container(),

            ],
          ),
      payType == 'شيك' || payType == 'حوالة' ? buildBank() : Container(),
    ],
  );

  Widget buildPayerVatNumber() => Text(
        _transferDate.text,
        style: const TextStyle(
          color: AppColor.primary,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      );

  Widget buildProject() => TextFormField(
        controller: _receivedFrom,
        keyboardType: TextInputType.name,
        style: const TextStyle(
          color: AppColor.primary,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        decoration: InputDecoration(
          labelText: language == 'Arabic' ? 'اسم المشروع' : 'Project Name',
        ),
        // onChanged: onChangedPayer,
      );

  _selectDate() async {
    DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2021),
        lastDate: DateTime(2055));
    if (picked != null) {
      setState(() => _date.text = Utils.formatShortDate(picked).toString());
    }
  }

  Widget buildDate() => InkWell(
        onTap: () => _selectDate(),
        child: IgnorePointer(
          child: TextFormField(
            controller: _date,
            keyboardType: TextInputType.text,
            style: const TextStyle(
              color: AppColor.primary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            decoration: InputDecoration(
              labelText:
                  language == 'Arabic' ? 'تاريخ العرض' : 'Receipt Date',
            ),
            // onChanged: onChangedPayer,
          ),
        ),
      );

  void saveAndPreview() {
    addOrUpdateReceipt();
  }
  

  /// To add/update receipt to database
  void addOrUpdateReceipt() async {
    final isValid = Platform.isAndroid
        ? true
        : _key1.currentState!.validate();

    if (isValid) {
      final isUpdating = widget.receipt != null;
      setState(() {
        isLoading = true;
      });

      if (isUpdating) {
        await updateReceipt();
      } else {
        await addReceipt();
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  Future updateReceipt() async {
    Receipt receipt = Receipt(
      id: id,
      date: _date.text,
      sumOf: _sumOf.text,
      payType: payType!,
      receivedFrom: _receivedFrom.text,
      amount: num.parse(_amount.text),
      amountFor: _amountFor.text,
      chequeNo: _chequeNo.text,
      chequeDate: _chequeDate.text,
      transferNo: _transferNo.text,
      transferDate: _transferDate.text,
      bank: _bank.text,
    );

    await FatooraDB.instance.updateReceipt(receipt);

    await PdfReceiptApi.generate(receipt, seller, 'سند قبض', isReceipt: isReceipt);
  }

  Future addReceipt() async {
    Receipt receipt = Receipt(
      id: id,
      date: _date.text,
      sumOf: _sumOf.text,
      payType: payType!,
      receivedFrom: _receivedFrom.text,
      amount:  num.parse(_amount.text),
      amountFor: _amountFor.text,
      chequeNo: _chequeNo.text,
      chequeDate: _chequeDate.text,
      transferNo: _transferNo.text,
      transferDate: _transferDate.text,
      bank: _bank.text,
    );
    await FatooraDB.instance.createReceipt(receipt);

    await PdfReceiptApi.generate(receipt, seller, 'سند قبض', isReceipt: isReceipt);
  }

  @override
  void dispose() {
    super.dispose();
  }

}
