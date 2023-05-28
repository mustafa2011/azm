import 'dart:convert';
import 'dart:io';

import 'package:fatoora/apis/constants/utils.dart';
import 'package:fatoora/models/settings.dart';
import 'package:fatoora/screens/products_page.dart';
import 'package:fatoora/screens/reports_page.dart';
import 'package:fatoora/screens/vat_endorsement.dart';
import 'package:package_info/package_info.dart';
import 'package:sprintf/sprintf.dart';
import 'package:url_launcher/url_launcher.dart';

import '../apis/gsheets_api.dart';
import '../models/news.dart';
import '/db/fatoora_db.dart';
import '/screens/settings_page.dart';

import '/models/product.dart';

import '/widgets/loading.dart';
import '/widgets/widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/widgets/app_colors.dart';

import 'customers_page.dart';
import 'invoices_page.dart';

const trial = 15; // set max days for demo version

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String dbVersion = "";
  String pkgVersion = "";
  FatooraDB db = FatooraDB.instance;
  int uid = 0;
  String sellerName = 'شركة تجريبية';
  String cellphone = '0000000000';
  int workOffline = 1;
  bool isLoading = false;
  bool isLoadingNews = false;
  List<Product> products = [];
  List<News> news = [];
  int productsCount = 0;

  int customersCount = 0;
  int invoicesCount = 0;
  int purchasesCount = 0;
  num totalSales = 0;
  num totalPurchases = 0;
  num totalVAT = 0;
  dynamic vat;
  // bool existLocalUser = false;
  bool validLicense = false;
  String strVersion = 'نسخة تجريبية';
  String language = 'Arabic';
  final TextEditingController _message = TextEditingController();
  bool isShowNews = false;
  bool isConnectionError = false;
  String? supportNumber = Utils.defSupportNumber;
  String? appVersionNumber;

  @override
  void initState() {
    // db.close();
    getVersion();
    super.initState();

    getNewsList();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String toHex(int value) {
    String hex = sprintf("%02X", [value]).toString();
    String input = hex.length % 2 == 0 ? hex : "${hex}0";
    final output = StringBuffer();
    for (int i = 0; i < input.length; i += 2) {
      String str = input.substring(i, i + 2);
      var charRadix16 = int.tryParse(str, radix: 16);
      output.writeCharCode(charRadix16!);
    }
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    var encoded = stringToBase64.encode(output.toString());
    return encoded;
  }

  Future checkAuthentication() async {
    try {
      setState(() => isLoading = true);
      language = await Utils.language();
      dbVersion = await Utils.dbVersion();
      validLicense = await Utils.validLicense();

      var userSetting = await db.getAllSettings();
      if (userSetting.isNotEmpty) {
        uid = userSetting[0].id as int;
        sellerName = userSetting[0].seller;
        cellphone = userSetting[0].cellphone;
        supportNumber = userSetting[0].freeText6;
        productsCount = await db.getProductsCount() ?? 0;
        customersCount = await db.getCustomerCount() ?? 0;
        invoicesCount = await db.getInvoicesCount() ?? 0;
        purchasesCount = await db.getPurchasesCount() ?? 0;
        totalSales = await db.getTotalSales(DateTime.now().year) ?? 0.0;
        totalVAT = totalSales - (totalSales / 1.15);
        totalPurchases = await db.getTotalPurchases(DateTime.now().year) ?? 0.0;

        DateTime? startDateTime = DateTime.parse(userSetting[0].startDateTime);
        DateTime validationDateTime = DateTime(
          startDateTime.year,
          startDateTime.month,
          startDateTime.day + trial,
        );
        int? intCode = int.parse(userSetting[0].cellphone) + userSetting[0].id! + (startDateTime.month + 1) + DateTime.now().year;
        String? validationCode = toHex(intCode);
        debugPrint("Activation code: $validationCode");
        debugPrint("validationDateTime: $validationDateTime");
        debugPrint("DateTime.now: ${DateTime.now()}");
        // String? activationCode = userSetting[0].activationCode;
        // if (validationCode == activationCode) {

        if (validLicense) {
          setState(() {
            // validLicense = true;
            strVersion =
            language == 'Arabic' ? 'النسخة الأصلية' : 'Original Version';
          });
        } else {
          if (validationDateTime.year < DateTime.now().year) {
            if (validationDateTime.month == DateTime.now().month) {
              // setState(() => validLicense = false);
              messageBox(language == 'Arabic'
                  ? 'يجب عليك تجديد الاشتراك السنوي قبل نهاية الشهر الحالي\n'
                  'رقم المستخدم: $uid\n'
                  'رقم الجوال: $cellphone\n'
                  'قم بنسخ هذه الرسالة وأرسلها إلى واتساب رقم: ${Utils.defSupportNumber}\n'
                  'للحصول كود التفعيل الجديد'
                  : 'You need to renew subscription before end of this month\n'
                  'user no: $uid\n'
                  'cellphone no: $cellphone\n'
                  'Copy this message and send it to whatsApp no ${Utils.defSupportNumber}\n'
                  'to get the new activation code');
            } else if (validationDateTime.month < DateTime.now().month) {
              // setState(() => validLicense = false);
              Get.to(()=> SettingsPage(validLicense: validLicense));
            } else if (validationDateTime.month > DateTime.now().month) {
              setState(() {
                // validLicense = true;
                strVersion = language == 'Arabic'
                    ? 'النسخة الأصلية'
                    : 'Original Version';
              });
            }
          } else {
            if (validationDateTime.isBefore(DateTime.now())) {
              Get.to(()=> SettingsPage(validLicense: validLicense));
            } else {
              // setState(() => validLicense = true);
              setState(() => strVersion =
              language == 'Arabic' ? 'نسخة تجريبية' : 'Trial version');
            }
          }
        }
      }
      setState(() => isLoading = false);
    } on Exception catch (e) {
      messageBox(e.toString());
    }
  }

  Future<int> offLine() async {
    int result = 0;
    List<Setting> setting;
    setting = await FatooraDB.instance.getAllSettings();
    if (setting.isNotEmpty) {
      result = setting[0].workOffline;
    }
    return result;
  }

  void messageBox(String? message) {
    _message.text = message!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            language == 'Arabic' ? 'رسالة' : 'Alarm',
            textAlign: language == 'Arabic' ? TextAlign.right : TextAlign.left,
          ),
          content: TextFormField(
            controller: _message,
            maxLines: 6,
            readOnly: true,
            autofocus: true,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppColor.primary),
            textAlign: language == 'Arabic' ? TextAlign.right : TextAlign.left,
            onTap: () {
              var textValue = _message.text;
              _message.selection = TextSelection(
                baseOffset: 0,
                extentOffset: textValue.length,
              );
            },
          ),
          actionsAlignment: language == 'Arabic'
              ? MainAxisAlignment.end
              : MainAxisAlignment.start, // Text(message!),
          actions: [
            // usually buttons at the bottom of the dialog
            TextButton(
              child: Text(language == 'Arabic' ? "موافق" : "Ok"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        height: h,
        width: w,
        color: AppColor.background,
        child: Stack(
          children: [
            buildHeader(),
            buildBody(h * 0.30),
            // buildBottomMenu(),
            // buildRefreshButton(),
          ],
        ),
      ),
    );
  }

  Widget buildHeader() => Container(
    height: MediaQuery.of(context).size.height * 0.30,
    color: AppColor.secondary,
    child: Stack(
      children: [
        Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width * 0.45,
          color: AppColor.primary,
        ),
        buildHeaderBackground(),
        buildTextHeader(),
      ],
    ),
  );

  Widget buildHeaderBackground() => Positioned(
      top: 0,
      right: 0,
      left: 70,
      bottom: 0,
      child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.fitHeight,
              image: AssetImage("assets/images/header_page.png"),
            ),
          )));

  Widget buildTextHeader() => Container(
    width: MediaQuery.of(context).size.width,
    padding: const EdgeInsets.only(right: 20, left: 20),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          language == 'Arabic' ? 'الواضح فاتورة' : 'Alwadeh Fatoora',
          style: const TextStyle(
            fontSize: 35,
            color: AppColor.secondary,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  language == 'Arabic'
                      ? "رقم المستخدم: $uid"
                      : "User No.: $uid",
                  style: const TextStyle(
                      color: AppColor.secondary,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  language == 'Arabic'
                      ? 'رقم الدعم الفني: $supportNumber'
                      : 'Support No: $supportNumber',
                  style: const TextStyle(fontSize: 10, color: Colors.white),
                ),
                Utils.space(2, 0),
                Text(
                  sellerName,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  strVersion,
                  style: const TextStyle(
                      color: AppColor.primary, fontWeight: FontWeight.bold),
                ),
                Text(
                  "ver: $pkgVersion[$dbVersion]",
                  style: const TextStyle(color: AppColor.primary),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );

  TextStyle bodyStyle() => const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    fontFamily: "Cairo",
  );

  TextStyle headerStyle() => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColor.primary,
    fontFamily: "Cairo",
  );

  Future getNewsList() async {
    try {
      setState(() => isLoadingNews = true);

      await SheetApi.getAllNews().then((list) {
        news = list;
        news.sort((e1, e2) => e2.date.compareTo(e1.date));
      });
      setState(() => isLoadingNews = false);
    } on Exception catch (e) {
      setState(() => isConnectionError = true);
      debugPrint(e.toString());
    }
  }

  Widget buildBody(double h) => Positioned(
    top: h,
    left: 0,
    child: Column(
      children: [
        Platform.isAndroid
            ? Column(
          children: [
            InkWell(
                onTap: () => checkAuthentication(),
                child: Row(
                  children: [
                    Text('احصائيات عامة', style: headerStyle()),
                    Utils.space(0, 4),
                    const Icon(
                      Icons.refresh,
                      color: AppColor.primary,
                    )
                  ],
                )),
            Container(
              color: AppColor.background,
              padding: const EdgeInsets.only(left: 5, right: 5),
              height: isShowNews
                  ? MediaQuery.of(context).size.height * 0.25
                  : MediaQuery.of(context).size.height *
                  (0.25 + 0.17),
              width: MediaQuery.of(context).size.width,
              child: makeWindowsDashboard(),
            ),
            Row(children: [
              InkWell(
                  onTap: () => getNewsList(),
                  child: Row(
                    children: [
                      Text('أخبار الواضح', style: headerStyle()),
                      Utils.space(0, 4),
                      const Icon(
                        Icons.refresh,
                        // Icons.keyboard_arrow_down,
                        color: AppColor.primary,
                      ),
                    ],
                  )),
              Utils.space(0, 4),
              InkWell(
                onTap: () => setState(() => isShowNews = !isShowNews),
                child: Icon(
                  isShowNews
                      ? Icons.keyboard_arrow_down_outlined
                      : Icons.keyboard_arrow_up_outlined,
                  color: AppColor.primary,
                ),
              ),
            ]),
            isShowNews
                ? Container(
              color: AppColor.background,
              padding: const EdgeInsets.only(
                  left: 5, right: 5, bottom: 0),
              height: isShowNews
                  ? MediaQuery.of(context).size.height * 0.17
                  : 0,
              width: MediaQuery.of(context).size.width,
              child: makeNewsDashboard(),
            )
                : Container(),
          ],
        )
            : Platform.isWindows
            ? Row(
          children: [
            Column(
              children: [
                Row(
                  children: [
                    Text('احصائيات عامة', style: headerStyle()),
                    Utils.space(0, 4),
                    InkWell(
                      onTap: () => checkAuthentication(),
                      child: const Icon(
                        Icons.refresh,
                        color: AppColor.primary,
                      ),
                    )
                  ],
                ),
                Container(
                  color: AppColor.background,
                  padding:
                  const EdgeInsets.only(left: 5, right: 5),
                  height:
                  MediaQuery.of(context).size.height * 0.45,
                  width: isShowNews
                      ? MediaQuery.of(context).size.width * 0.49
                      : MediaQuery.of(context).size.width * 0.96,
                  child: makeWindowsDashboard(),
                ),
              ],
            ),
            Column(
              children: [
                InkWell(
                  onTap: () =>
                      setState(() => isShowNews = !isShowNews),
                  child: Icon(
                    isShowNews
                        ? Icons.keyboard_arrow_left_outlined
                        : Icons.keyboard_arrow_right_outlined,
                    color: AppColor.primary,
                  ),
                ),
                InkWell(
                  onTap: () =>
                      setState(() => isShowNews = !isShowNews),
                  child: buildRotateText(' أخبار الواضح'),
                ),
                InkWell(
                  onTap: () =>
                      setState(() => isShowNews = !isShowNews),
                  child: Icon(
                    isShowNews
                        ? Icons.keyboard_arrow_left_outlined
                        : Icons.keyboard_arrow_right_outlined,
                    color: AppColor.primary,
                  ),
                ),
              ],
            ),
            isShowNews
                ? Column(
              children: [
                Row(children: [
                  Text('أخبار الواضح',
                      style: headerStyle()),
                  Utils.space(0, 4),
                  InkWell(
                    onTap: () => getNewsList(),
                    child: const Icon(
                      Icons.refresh,
                      color: AppColor.primary,
                    ),
                  )
                ]),
                Container(
                  color: AppColor.background,
                  padding: const EdgeInsets.only(
                      left: 5, right: 5),
                  height:
                  MediaQuery.of(context).size.height *
                      0.45,
                  width: MediaQuery.of(context).size.width *
                      0.49,
                  child: makeNewsDashboard(),
                ),
              ],
            )
                : Container(),
          ],
        )
            : Container(),
        Row(
          children: [
            NewButton(
              icon: Icons.handshake_outlined,
              text: language == 'Arabic'
                  ? "الإقرارات الضريبية"
                  : "ZAKAT Endorsement",
              onTap: () => Get.to(() => const VatEndorsementPage()),
              radius: 15,
              iconSize: 30,
              fontSize: 16,
              backgroundColor: AppColor.secondary,
              iconColor: AppColor.primary,
            ),
            const SizedBox(width: 10),
            NewButton(
              icon: Icons.find_in_page_rounded,
              text: language == 'Arabic' ? "التقارير" : "Reports",
              onTap: () => Get.to(() => const ReportsPage()),
              radius: 15,
              iconSize: 30,
              fontSize: 16,
              backgroundColor: AppColor.secondary,
              iconColor: AppColor.primary,
            ),
          ],
        ),
        Utils.space(2, 0),
        Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.only(left: 5, right: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  NewButton(
                    icon: Icons.store,
                    textPositionDown: false,
                    text: language == 'Arabic' ? "منتجات" : "Products",
                    onTap: () => Get.to(() => const ProductsPage()),
                  ),
                  const SizedBox(width: 3),
                  NewButton(
                    icon: Icons.person_pin_rounded,
                    textPositionDown: false,
                    text: language == 'Arabic' ? "عملاء" : "Customers",
                    onTap: () => Get.to(() => const CustomersPage()),
                  ),
                  const SizedBox(width: 3),
                  NewButton(
                    icon: Icons.money, // .point_of_sale,
                    textPositionDown: false,
                    text: language == 'Arabic' ? "فواتير" : "Invoices",
                    onTap: () => Get.to(() => const InvoicesPage()),
                  ),
                ],
              ),
              NewButton(
                icon: Icons.settings,
                textPositionDown: false,
                text: language == 'Arabic' ? "اعدادات" : "Setting",
                onTap: () => Get.to(()=> SettingsPage(validLicense: validLicense)),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget buildRotateText(String text) => Wrap(
    direction: Axis.vertical,
    children: verticalText(text),
  );

  List<Widget> verticalText(String text) {
    List<Widget> res = [];
    var words = text.split(" ");
    for (var word in words) {
      var parts = word.split(" ");
      int i = 0;
      res.add(RotatedBox(
          quarterTurns: 3, child: Text('${parts[i]} ', style: headerStyle())));
    }
    return res;
  }

  Widget makeDashboardItem(
      String result, String title, String result1, String title1) {
    return Card(
        elevation: 8.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            const SizedBox(width: 0),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title,
                      style: const TextStyle(
                        fontSize: 16.0,
                        color: AppColor.secondary,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            blurRadius: 6.0,
                            color: Colors.grey,
                            offset: Offset(2.0, 2.0),
                          ),
                        ],
                      )),
                  title1 == ''
                      ? const SizedBox(height: 0)
                      : const SizedBox(height: 20),
                  title1 == ''
                      ? Container()
                      : Text(title1,
                      style: const TextStyle(
                        fontSize: 16.0,
                        color: AppColor.secondary,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            blurRadius: 6.0,
                            color: Colors.grey,
                            offset: Offset(2.0, 2.0),
                          ),
                        ],
                      )),
                ],
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(result,
                      style: const TextStyle(
                        fontSize: 12.0,
                        color: AppColor.primary,
                        fontWeight: FontWeight.w800,
                        shadows: [
                          Shadow(
                            blurRadius: 6.0,
                            color: Colors.grey,
                            offset: Offset(2.0, 2.0),
                          ),
                        ],
                      )),
                  title1 == ''
                      ? const SizedBox(height: 0)
                      : const SizedBox(height: 20),
                  result1 == ''
                      ? Container()
                      : Text(result1,
                      style: const TextStyle(
                        fontSize: 12.0,
                        color: AppColor.primary,
                        fontWeight: FontWeight.w800,
                        shadows: [
                          Shadow(
                            blurRadius: 6.0,
                            color: Colors.grey,
                            offset: Offset(2.0, 2.0),
                          ),
                        ],
                      )),
                ],
              ),
            ),
            const SizedBox(width: 0),
          ],
        ));
  }

  Widget makeWindowsDashboard() {
    final titles = Utils.isProVersion
        ? <String>[
      language == 'Arabic' ? 'عدد المنتجات' : 'Products',
      language == 'Arabic' ? 'عدد العملاء' : 'Customers',
      language == 'Arabic' ? 'عدد فواتير المبيعات' : 'Sales Invoices',
      language == 'Arabic'
          ? 'عدد فواتير المشتريات'
          : 'Purchases Invoices',
      language == 'Arabic' ? 'إجمالي المبيعات' : 'Total Sales',
      language == 'Arabic' ? 'إجمالي ضريبة المبيعات' : 'TTL Sales VAT',
      language == 'Arabic' ? 'إجمالي المشتريات' : 'Total Purchases',
      language == 'Arabic'
          ? 'إجمالي ضريبة المشتريات'
          : 'TTL Purchases VAT',
    ]
        : <String>[
      language == 'Arabic' ? 'عدد المنتجات' : 'Products',
      language == 'Arabic' ? 'عدد فواتير المبيعات' : 'Sales Invoices',
      language == 'Arabic'
          ? 'عدد فواتير المشتريات'
          : 'Purchases Invoices',
      language == 'Arabic' ? 'إجمالي المبيعات' : 'Total Sales',
      language == 'Arabic' ? 'إجمالي ضريبة المبيعات' : 'TTL Sales VAT',
      language == 'Arabic' ? 'إجمالي المشتريات' : 'Total Purchases',
      language == 'Arabic'
          ? 'إجمالي ضريبة المشتريات'
          : 'TTL Purchases VAT',
    ];
    final data = <String>[
      '$productsCount',
      '$customersCount',
      '$invoicesCount',
      '$purchasesCount',
      '${Utils.format(totalSales / 1.15)}',
      '${Utils.format(totalVAT)}',
      '${Utils.format(totalPurchases / 1.15)}',
      '${Utils.format(totalPurchases - totalPurchases / 1.15)}',
    ];
    return Card(
        elevation: 8.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.all(8.0),
        child: Container(
          margin: const EdgeInsets.all(20),
          child: isLoading
              ? const Loading()
              : ListView.builder(
            padding: const EdgeInsets.only(top: 0),
            itemCount: titles.length,
            itemBuilder: (BuildContext context, int index) =>
                Column(children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.75,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(titles[index]),
                          Text(data[index]),
                        ]),
                  ),
                  const Divider(),
                ]),
          ),
        ));
  }

  Widget makeNewsDashboard() => Card(
      elevation: 8.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.all(8.0),
      child: Container(
        child: news.isEmpty && Platform.isWindows
            ? isLoadingNews
            ? const Loading()
            : Center(
          child: IconButton(
            icon: const Icon(Icons.refresh),
            iconSize: 50,
            color: AppColor.secondary,
            tooltip: 'تحديث الأخبار',
            onPressed: () {
              getNewsList();
            },
          ),
        )
            : isLoadingNews
            ? const Loading()
            : ListView.builder(
          // controller: _scrollController,
          padding:
          const EdgeInsets.only(left: 15, right: 10, top: 10),
          itemCount: news.length,
          itemBuilder: (BuildContext context, int index) => Container(
            height: 45,
            color:
            index % 2 == 1 ? AppColor.background : Colors.white24,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                          width: 90,
                          padding: const EdgeInsets.only(right: 10),
                          child: Text((news[index].date).toString(),
                              textAlign: TextAlign.right,
                              style: bodyStyle())),
                      SizedBox(
                          width: Platform.isAndroid
                              ? 245
                              : MediaQuery.of(context).size.width *
                              0.30,
                          child: Text(news[index].title.toString(),
                              style: bodyStyle())),
                    ],
                  ),
                  InkWell(
                    onTap: () =>
                        launchUrl(Uri.parse(news[index].link)),
                    child: const Icon(Icons.link),
                  ),
                ]),
          ),
        ),
      ));

  Widget buildBottomMenu() => Positioned(
    left: 0,
    bottom: 0,
    child: SizedBox(
      height: MediaQuery.of(context).size.height * 0.11,
      width: MediaQuery.of(context).size.width,
      child: Container(
        padding:
        const EdgeInsets.only(left: 5, right: 5, top: 10, bottom: 0),
        color: AppColor.background,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                NewButton(
                  icon: Icons.store,
                  textPositionDown: false,
                  text: language == 'Arabic' ? "منتجات" : "Products",
                  onTap: () => Get.to(() => const ProductsPage()),
                ),
                const SizedBox(width: 3),
                NewButton(
                  icon: Icons.person_pin_rounded,
                  textPositionDown: false,
                  text: language == 'Arabic' ? "عملاء" : "Customers",
                  onTap: () => Get.to(() => const CustomersPage()),
                ),
                const SizedBox(width: 3),
                NewButton(
                  icon: Icons.money, // .point_of_sale,
                  textPositionDown: false,
                  text: language == 'Arabic' ? "فواتير" : "Invoices",
                  onTap: () => Get.to(() => const InvoicesPage()),
                ),
              ],
            ),
            Row(
              children: [
                NewButton(
                  icon: Icons.settings,
                  textPositionDown: false,
                  text: language == 'Arabic' ? "اعدادات" : "Setting",
                  onTap: () => Get.to(()=> SettingsPage(validLicense: validLicense)),
                ),
              ],
            )
          ],
        ),
        // )
      ),
    ),
  );

  Widget buildRefreshButton() => Positioned(
    left: 10,
    top: 50,
    child: NewButton(
      icon: Icons.refresh,
      iconSize: 24,
      radius: 24,
      onTap: () => checkAuthentication(),
    ),
  );

  void getVersion() async {
    final pkgVer = Platform.isWindows
        ? Platform.operatingSystem
        : (await PackageInfo.fromPlatform()).version;
    setState(() {
      pkgVersion = pkgVer;
    });
    checkAuthentication();
  }
}