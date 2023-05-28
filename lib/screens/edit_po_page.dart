import 'package:dropdown_search/dropdown_search.dart';

import '../apis/constants/utils.dart';
import '../apis/pdf_po_api.dart';

import '../db/fatoora_db.dart';
import '../models/customers.dart';
import '../models/po.dart';
import '../models/product.dart';
import '../models/settings.dart';
import '../widgets/app_colors.dart';
import '../widgets/widget.dart';
import '../widgets/loading.dart';
import '../widgets/product_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'dart:io';

import 'invoices_page.dart';

class AddEditPoPage extends StatefulWidget {
  final dynamic product;
  final Po? po;

  const AddEditPoPage({
    Key? key,
    this.product,
    this.po,
  }) : super(key: key);

  @override
  State<AddEditPoPage> createState() => _AddEditPoPageState();
}

class _AddEditPoPageState extends State<AddEditPoPage> {
  List<String> payMethod = ['شبكة', 'كاش', 'آجل', 'حوالة'];
  String? selectedPayMethod = Utils.defPayMethod;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool scanned = false;

  TextEditingController textQRCode = TextEditingController();

  final _key1 = GlobalKey<FormState>();
  late int recId;
  late int newId; // This id for new po id in cloud database
  late int id; // this is existing po id will be retrieved from widget
  late final Customer payer;
  late final Setting seller;
  late final Setting vendor;
  late final Setting vendorVatNumber;
  late final String project;
  late final String date;
  late final String supplyDate;
  late List<PoLines> items = [];
  late List<Po> dailyPos = [];
  late List<String> customers = [];
  late String poNo;
  int counter = 0;

  // bool isSimplifiedTaxPo = false;
  bool isPreview = false;
  bool isPo = true;

  final TextEditingController _productName = TextEditingController();
  final TextEditingController _qty = TextEditingController();
  final TextEditingController _totalPrice = TextEditingController();
  final TextEditingController _price = TextEditingController();
  final TextEditingController _priceWithoutVat = TextEditingController();
  final TextEditingController _payer = TextEditingController();
  final TextEditingController _payerVatNumber = TextEditingController();
  final TextEditingController _project = TextEditingController();
  final TextEditingController _date = TextEditingController();
  final TextEditingController _supplyDate = TextEditingController();
  final FocusNode focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  num total = 0.0;
  int cardQty = 1;

  bool noProductFount = true;
  bool isManualPo = true;
  bool isLoading = false;
  List<Product> products = [];
  List<String> productsList = [];
  int workOffline = 1;
  int curPayerId = 1;
  String curProject = '';
  String curDate = Utils.formatDate(DateTime.now());
  String curSupplyDate = Utils.formatDate(DateTime.now());
  bool printerBinded = false;
  String sellerAddress = '';
  String payerAddress = '';
  String newPayerAddress = '';
  String language = 'Arabic';


  @override
  void initState() {
    super.initState();
    getPo();
    focusNode.requestFocus();
  }

  Future getPo() async {
    FatooraDB db = FatooraDB.instance;
    language = await Utils.language();

    try {
      setState(() => isLoading = true);
      var user = await db.getAllSettings();
      int uid = user[0].id as int;
      seller = await db.getSellerById(uid);

      int? posCount = await FatooraDB.instance.getPoCount();
      int? countCustomers = await FatooraDB.instance.getCustomerCount();
      bool? checkFirstPayer = await FatooraDB.instance.isFirstCustomerExist();

      Customer newPayer = const Customer(
          id: 1, name: 'عميل نقدي', vatNumber: '000000000000000');

      if (!checkFirstPayer!) {
        await FatooraDB.instance.createCustomer(newPayer);
      }
      if (widget.po != null) {
        curPayerId = widget.po!.payerId!;
        curProject = widget.po!.project;
        curDate = widget.po!.date;
        curSupplyDate = widget.po!.supplyDate;
        selectedPayMethod = widget.po!.paymentMethod;
      }

      id = widget.po != null
          ? widget.po!.id!
          : posCount == 0
              ? 1
              : (await db.getNewPoId())! + 1;
      payer = countCustomers == 0
          ? newPayer
          : await FatooraDB.instance.getCustomerById(curPayerId);
      _payer.text = '${payer.id}-${payer.name}';
      _payerVatNumber.text = payer.vatNumber;
      _project.text = curProject;
      _date.text = curDate;
      _supplyDate.text = curSupplyDate;

      List<Customer> list = await FatooraDB.instance.getAllCustomers();
      customers.clear();
      for (int i = 0; i < list.length; i++) {
        customers.add("${list[i].id}-${list[i].name}");
      }

      recId = id;

      poNo = Utils.formatEstimate(recId); // like '0000321'

      ///  Initialize Po lines
      if (widget.po != null) {
        items = await db.getPoLinesById(recId);
        for (int i = 0; i < items.length; i++) {
          total = total + (items[i].qty * items[i].price);
        }
      }

      /// Initialize products list offLine/onLine
      if (workOffline == 1) {
        await db.getAllProducts().then((list) {
          products = list;
          for (int i = 0; i < products.length; i++) {
            productsList.add('${products[i].id!}-${products[i].productName!}');
          }
        });
        if (products.isEmpty) {
          noProductFount = true;
        } else {
          noProductFount = false;
        }
      }

      /// Initialize po form controller header
      _totalPrice.text = '0.00';
      _price.text = '0.00';
      _priceWithoutVat.text = '0.00';
      _qty.text = '1';

      sellerAddress += seller.buildingNo;
      sellerAddress += seller.buildingNo.isNotEmpty ? ' ' : '';
      sellerAddress += seller.streetName.isNotEmpty ? seller.streetName : '';
      sellerAddress += seller.district.isNotEmpty ? '-${seller.district}' : '';
      sellerAddress += seller.city.isNotEmpty ? '-${seller.city}' : '';
      sellerAddress += seller.country.isNotEmpty ? '-${seller.country}' : '';

      payerAddress += payer.buildingNo;
      payerAddress += payer.buildingNo.isNotEmpty ? ' ' : '';
      payerAddress += payer.streetName.isNotEmpty ? payer.streetName : '';
      payerAddress += payer.district.isNotEmpty ? '-${payer.district}' : '';
      payerAddress += payer.city.isNotEmpty ? '-${payer.city}' : '';
      payerAddress += payer.country.isNotEmpty ? '-${payer.country}' : '';

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
              language == 'Arabic' ? 'طلب شراء' : 'Po',
              style: const TextStyle(
                  color: AppColor.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            ),
          ),
          actions: [
            buildButtonSave(),
            buildSwitch(),
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
          /// Product card list
          Positioned(
            top: 0,
            child: isManualPo
                ? SizedBox(
                    height: MediaQuery.of(context).size.height * 0.60,
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          child: Form(
                            key: _key1,
                            child: Column(
                              children: [
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      InkWell(
                                          onTap: () => _selectDate(),
                                          child: Text(
                                              '${language == 'Arabic' ? 'التاريخ:' : 'Date:'} ${_date.text}')),
                                    ]),
                                buildProject(),
                                /*Row(
                                  children: [
                                    buildPayer(),
                                    Utils.space(0, 2),
                                    buildPayMethod(),
                                  ],
                                ),*/
                              ],
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(
                              right: 10, left: 10, top: 0, bottom: 10),
                          child: Column(
                            children: [
                              Container(
                                      width: MediaQuery.of(context).size.width -
                                          100,
                                      padding: const EdgeInsets.only(
                                          top: 5, bottom: 5),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        color: Colors.grey,
                                      ),
                                      child: Text(
                                        language == 'Arabic'
                                            ? 'بيانات سطور العرض'
                                            : 'Po lines',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white),
                                      ),
                                    ),
                              buildProductName(),
                              Row(
                                children: [
                                  Expanded(child: buildQty()),
                                  Utils.space(0, 2),
                                  Expanded(child: buildPriceWithoutVat()),
                                  Utils.space(0, 1),
                                  Expanded(child: buildPrice()),
                                  Utils.space(0, 1),
                                  Container(),
                                  buildInsertButton(),
                                  Utils.space(0, 2),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(
                    height: MediaQuery.of(context).size.height * 0.50,
                    width: MediaQuery.of(context).size.width,
                    color: AppColor.primary,
                    child: noProductFount
                        ? Center(
                            child: Text(
                              language == 'Arabic'
                                  ? 'لا يوجد لديك منتجات مسجلة'
                                  : 'No products recorded',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 16, color: AppColor.background),
                            ),
                          )
                        : StaggeredGridView.countBuilder(
                            padding: const EdgeInsets.all(2),
                            itemCount: products.length,
                            staggeredTileBuilder: (index) =>
                                const StaggeredTile.fit(1),
                            crossAxisCount: 4,
                            mainAxisSpacing: 0,
                            crossAxisSpacing: 2,
                            itemBuilder: (context, index) {
                              final product = products[index];

                              return InkWell(
                                onTap: () async {
                                  bool found = false;
                                  for (int i = 0; i < items.length; i++) {
                                    if (items[i].productName ==
                                        (product.productName.toString())) {
                                      found = true;
                                      break;
                                    }
                                  }
                                  setState(() {
                                    if (!found) {
                                      items.add(PoLines(
                                        productName:
                                            product.productName.toString(),
                                        qty: 1,
                                        price: product.price!,
                                        recId: recId,
                                      ));
                                    }
                                    total = 0;
                                    for (int i = 0; i < items.length; i++) {
                                      total = total +
                                          ((items[i].qty) * items[i].price);
                                    }
                                  });
                                },
                                child: ProductCardWidgetToBeInvoiced(
                                    product: product, index: index),
                              );
                            },
                          ),
                  ),
          ),

          /// ListView header
          Positioned(
            top: MediaQuery.of(context).size.height * 0.50,
            left: 0,
            right: 0,
            child: Container(
              height: 40,
              color: Colors.grey,
              padding: const EdgeInsets.only(right: 5, left: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    language == 'Arabic'
                            ? "البيان"
                            : "DESC",
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Colors.white),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        language == 'Arabic' ? 'الإجمالي' : 'TOTAL',
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Colors.white),
                      ),
                      Utils.space(0, 2),
                      Text(
                        total.toStringAsFixed(2),
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          /// ListView body
          Positioned(
            top: MediaQuery.of(context).size.height * 0.50 + 40,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.50 - 140,
              padding: const EdgeInsets.only(right: 0, left: 0),
              child: Scrollbar(
                  thumbVisibility: true,
                  controller: _scrollController,
                  child: ListView.builder(
                      controller: _scrollController,
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        return Container(
                          color: index % 2 == 1
                              ? AppColor.background
                              : Colors.white24,
                          child: Column(
                            children: [
                              Utils.space(0, 1),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Utils.space(0, 1),
                                  Expanded(
                                    child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          items[index].productName,
                                          textDirection: TextDirection.rtl,
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black),
                                        )),
                                  ),
                                  Utils.space(0, 1),
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Row(
                                          children: [
                                            NewButton(
                                              backgroundColor: Colors.grey,
                                              icon: Icons.add,
                                              padding: 2,
                                              onTap: () => _addQuantity(index),
                                            ),
                                            SizedBox(
                                                width: 40,
                                                child: Text(
                                                  items[index]
                                                      .qty
                                                      .toStringAsFixed(2),
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      // fontWeight: FontWeight.w900,
                                                      color: Colors.black),
                                                )),
                                            NewButton(
                                              backgroundColor: Colors.grey,
                                              icon: Icons.remove,
                                              padding: 2,
                                              onTap: () =>
                                                  _removeQuantity(index),
                                            ),
                                          ],
                                        ),
                                        Utils.space(0, 1),
                                        Expanded(
                                            child: Text(
                                          items[index].price.toStringAsFixed(2),
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black),
                                        )),
                                        Utils.space(0, 1),
                                        Expanded(
                                            child: Text(
                                          (items[index].qty *
                                                  (items[index].price))
                                              .toStringAsFixed(2),
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black),
                                        )),
                                      ],
                                    ),
                                  ),

                                  ///Remove item from list
                                  NewButton(
                                    backgroundColor: Colors.grey,
                                    padding: 2,
                                    icon: Icons.clear,
                                    onTap: () async {
                                      setState(() {
                                        num lineTotal = items[index].qty *
                                            items[index].price;
                                        total = total - lineTotal;
                                        items.removeAt(index);
                                      });
                                    },
                                  ),
                                  Utils.space(0, 1),
                                ],
                              ),
                              Utils.space(0, 1),
                              const Divider(
                                thickness: 1,
                                height: 0,
                              ),
                            ],
                          ),
                        );
                      })),
            ),
          ),
        ],
      );

  Widget buildButtonSave() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor:
              isManualPo ? AppColor.primary : AppColor.background,
          backgroundColor:
              isManualPo ? AppColor.background : AppColor.primary,
        ),
        onPressed: saveAndPreview,
        child: Text(language == 'Arabic' ? 'حفظ/عرض' : 'Print'),
      ),
    );
  }

  Widget buildSwitch() => Switch(
      value: isManualPo,
      activeColor: isManualPo ? AppColor.background : null,
      inactiveThumbColor: isManualPo ? null : AppColor.primary,
      onChanged: (value) => setState(() => isManualPo = value));

  Widget buildProductName1() => Row(
        children: [
          Expanded(
            child: DropdownSearch<String>(
              popupProps: const PopupProps.menu(
                showSearchBox: true,
                showSelectedItems: true,
                searchFieldProps: TextFieldProps(),
              ),
              dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  labelText: language == 'Arabic' ? 'المنتج' : 'Product',
                ),
              ),
              items: productsList,
              onChanged: (val) async {
                int productId = int.parse(val!.split('-')[0]);
                Product prod =
                    await FatooraDB.instance.getProductById(productId);
                num? productPrice = prod.price;
                setState(() {
                  _productName.text = val;
                  // _price.text = Utils.formatNoCurrency(productPrice!);
                  _price.text = (productPrice!.toString());
                  _priceWithoutVat.text =
                      Utils.formatNoCurrency(productPrice / 1.15);
                });
              },
              selectedItem: _productName.text,
            ),
          ),
          // SizedBox(width: 100,child: ElevatedButton(onPressed: () =>Get.to(
          //         () => const AddEditProductPage()), child: const Text('أضف منتج'),)),
        ],
      );

  Widget buildQty() => TextFormField(
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        controller: _qty,
        onTap: () {
          var textValue = _qty.text;
          _qty.selection = TextSelection(
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
                  ? 'الكمية'
                  : 'Qty',
        ),
        validator: (qty) =>
            qty == null || qty == '' ? 'يجب إدخال الكمية' : null,
        onChanged: (value) => _totalPrice.text =
            "${Utils.formatNoCurrency(num.parse(value) * num.parse(_price.text))}",
      );

  Widget buildPrice() => TextFormField(
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        controller: _price,
        onTap: () {
          var textValue = _price.text;
          _price.selection = TextSelection(
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
              language == 'Arabic' ? 'السعر مع الضريبة' : 'Price VAT Included',
        ),
        validator: (price) =>
            price == null || price == '' ? 'يجب إدخال سعر المنتج' : null,
        onChanged: (value) => _priceWithoutVat.text =
            "${Utils.formatNoCurrency(num.parse(value) / 1.15)}",
      );

  Widget buildTotalPrice() => TextFormField(
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        controller: _totalPrice,
        onTap: () {
          var textValue = _totalPrice.text;
          _totalPrice.selection = TextSelection(
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
          labelText: language == 'Arabic' ? 'المبلغ' : 'Paid Amount',
        ),
        validator: (price) =>
            price == null || price == '' ? 'يجب ادخال المبلغ' : null,
        onChanged: (value) => _qty.text =
            "${Utils.formatNoCurrency(num.parse(value) / num.parse(_price.text))}",
      );

  Widget buildPriceWithoutVat() => TextFormField(
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        controller: _priceWithoutVat,
        onTap: () {
          var textValue = _priceWithoutVat.text;
          _priceWithoutVat.selection = TextSelection(
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
              language == 'Arabic' ? 'السعر بدون ضريبة' : 'Price VAT Excluded',
        ),
        validator: (price) =>
            price == null || price == '' ? 'يجب إدخال سعر المنتج' : null,
        onChanged: (value) =>
            _price.text = "${Utils.formatNoCurrency(num.parse(value) * 1.15)}",
      );

  Widget buildInsertButton() => IconButton(
        onPressed: () {
          String price = _price.text.replaceAll(',', '');
          if (_productName.text != '' &&
              num.parse(_qty.text) > 0 &&
              num.parse(price) >= 0) {
            setState(() {
              items.add(PoLines(
                /*productName: num.parse(price) == 0
                    ? '${_productName.text.split('-')[1]}- مجاناً'
                    : _productName.text.split('-')[1],*/
                productName: _productName.text,
                qty: num.parse(_qty.text.toString()),
                price: num.parse(price),
                recId: recId,
              ));
              num lineTotal = num.parse(_qty.text) * num.parse(price);
              total = total + lineTotal;
              _productName.clear();
              _qty.text = '1';
              _price.text = '0.00';
              _totalPrice.text = '0.00';
              _priceWithoutVat.text = '0.00';
              focusNode.requestFocus();
            });
          }
        },
        icon: const Icon(
          Icons.add_shopping_cart_sharp,
          size: 40,
          color: AppColor.primary,
        ),
      );

  Widget buildPayer() => Expanded(
          child: DropdownSearch<String>(
        popupProps:
            const PopupProps.menu(showSearchBox: true, showSelectedItems: true),
        dropdownDecoratorProps: DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
              label: Text(language == 'Arabic' ? 'العميل' : 'Customer')),
        ),
        items: customers,
        onChanged: (val) async {
          int id = int.parse(val!.split("-")[0]);
          Customer changedPayer = await FatooraDB.instance.getCustomerById(id);
          setState(() {
            _payer.text = val;
            _payerVatNumber.text = changedPayer.vatNumber;
          });
        },
        selectedItem: _payer.text,
      ));

  Widget buildPayMethod() => Row(
        children: [
          SizedBox(
            width: 100,
            child: DropdownSearch<String>(
              popupProps: PopupProps.menu(
                  showSelectedItems: true,
                  constraints: BoxConstraints(
                      maxHeight: Platform.isAndroid ? 225 : 200)),
              dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                      label: Text(
                          language == 'Arabic' ? 'الدفع: ' : 'Pay method '))),
              items: payMethod,
              onChanged: (val) => setState(() {
                selectedPayMethod = val;
              }),
              selectedItem: selectedPayMethod,
            ),
          )
        ],
      );

  Widget buildPayerVatNumber() => Text(
        _payerVatNumber.text,
        style: const TextStyle(
          color: AppColor.primary,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      );

  Widget buildProject() => TextFormField(
        controller: _project,
        autofocus: true,
        keyboardType: TextInputType.name,
        style: const TextStyle(
          color: AppColor.primary,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        decoration: InputDecoration(
          labelText: language == 'Arabic' ? 'اسم المورد' : 'Vendor Name',
        ),
        // onChanged: onChangedPayer,
      );

  Widget buildProductName() => TextFormField(
        controller: _productName,
        autofocus: true,
        keyboardType: TextInputType.name,
        style: const TextStyle(
          color: AppColor.primary,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        decoration: InputDecoration(
          labelText: language == 'Arabic' ? 'البيان' : 'Description',
        ),
      );

  _selectDate() async {
    DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2021),
        lastDate: DateTime(2055));
    if (picked != null) {
      setState(() => _date.text = Utils.formatDate(picked).toString());
    }
  }

  _selectSupplyDate() async {
    DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2021),
        lastDate: DateTime(2055));
    if (picked != null) {
      setState(() => _supplyDate.text = Utils.formatDate(picked));
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
                  language == 'Arabic' ? 'تاريخ العرض' : 'Po Date',
            ),
            // onChanged: onChangedPayer,
          ),
        ),
      );

  Widget buildSupplyDate() => InkWell(
        onTap: () => _selectSupplyDate(),
        child: IgnorePointer(
          child: TextFormField(
            controller: _supplyDate,
            keyboardType: TextInputType.text,
            style: const TextStyle(
              color: AppColor.primary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            decoration: InputDecoration(
              labelText: language == 'Arabic' ? 'تاريخ التوريد' : 'Supply Date',
            ),
            // onChanged: onChangedPayer,
          ),
        ),
      );

  void saveAndPreview() {
    addOrUpdatePo();
  }
  

  /// To add/update po to database
  void addOrUpdatePo() async {
    final isValid = Platform.isAndroid
        ? true
        : isManualPo
            ? _key1.currentState!.validate()
            : true;
    final hasLines = items.isNotEmpty ? true : false;

    if (!hasLines) {
      messageBox('يجب إدخال سطور للعرض');
    }

    if (isValid && hasLines) {
      final isUpdating = widget.po != null;
      setState(() {
        isLoading = true;
      });

      if (isUpdating) {
        await updatePo();
      } else {
        await addPo();
      }
      setState(() {
        isLoading = false;
      });

      // Get.to(() => const PosPage());
    }
  }

  Future updatePo() async {
    int payerId = int.parse(_payer.text.split("-")[0]);
    Customer currentPayer = await FatooraDB.instance.getCustomerById(payerId);
    Po po = Po(
      id: id,
      poNo: poNo,
      date: _date.text,
      supplyDate: _supplyDate.text,
      sellerId: seller.id,
      project: _project.text,
      total: total,
      totalVat: total - (total / 1.15),
      posted: 0,
      payerId: payerId,
      noOfLines: items.length,
      paymentMethod: selectedPayMethod!,
    );

    await FatooraDB.instance.updatePo(po);
    await FatooraDB.instance.deletePoLines(id);

    for (int i = 0; i < items.length; i++) {
      await FatooraDB.instance.createPoLines(items[i], items[i].recId);
    }
    await PdfPoApi.generate(po, currentPayer, seller, items,
            'طلب شراء', po.project, isPreview, isPo: isPo);
  }

  Future addPo() async {
    int payerId = int.parse(_payer.text.split("-")[0]);
    Customer currentPayer = await FatooraDB.instance.getCustomerById(payerId);
    Po po = Po(
      poNo: poNo,
      date: _date.text,
      supplyDate: _supplyDate.text,
      sellerId: seller.id,
      project: _project.text,
      total: total,
      totalVat: total - (total / 1.15),
      posted: 0,
      payerId: payerId,
      noOfLines: items.length,
      paymentMethod: selectedPayMethod!,
    );
    await FatooraDB.instance.createPo(po);

    for (int i = 0; i < items.length; i++) {
      await FatooraDB.instance.createPoLines(items[i], items[i].recId);
    }
    await PdfPoApi.generate(po, currentPayer, seller, items,
            'طلب شراء', po.project, isPreview, isPo: isPo);
  }

  _addQuantity(int index) {
    setState(() {
      {
        num newQty = items[index].qty;
        String productName = items[index].productName;
        num price = items[index].price;
        items.insert(
            index,
            PoLines(
              // id: index,
              productName: productName,
              qty: newQty + 1,
              price: price,
              recId: recId,
            ));
        items.removeAt(index + 1);
      }
      total = 0;
      for (int i = 0; i < items.length; i++) {
        total = total + ((items[i].qty) * items[i].price);
      }
    });
  }

  _removeQuantity(int index) {
    setState(() {
      {
        num newQty = items[index].qty;
        String productName = items[index].productName;
        num price = items[index].price;
        if (newQty > 1) {
          items.insert(
              index,
              PoLines(
                // id: index,
                productName: productName,
                qty: newQty - 1,
                price: price,
                recId: recId,
              ));
          items.removeAt(index + 1);
        }
      }
      total = 0;
      for (int i = 0; i < items.length; i++) {
        total = total + ((items[i].qty) * items[i].price);
      }
    });
  }


  @override
  void dispose() {
    super.dispose();
  }

  changeToCashCustomer() {
    setState(() {
      _payer.text = "1-عميل نقدي";
    });
  }

  /// End of QR code scanner
}
