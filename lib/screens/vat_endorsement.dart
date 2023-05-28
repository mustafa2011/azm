import 'dart:io';
import 'package:dropdown_search/dropdown_search.dart';
import '../apis/constants/utils.dart';
import '../models/product.dart';
import '/db/fatoora_db.dart';
import '/models/settings.dart';
import '/widgets/widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/widgets/app_colors.dart';
import 'home_page.dart';

class VatEndorsementPage extends StatefulWidget {
  const VatEndorsementPage({Key? key}) : super(key: key);

  @override
  State<VatEndorsementPage> createState() => _VatEndorsementPageState();
}

class _VatEndorsementPageState extends State<VatEndorsementPage> {
  FatooraDB db = FatooraDB.instance;
  late int uid;
  bool isLoading = false;
  bool isMonthly = false;
  List<Product> products = [];
  late List<Setting> user;
  int selectedYear = DateTime.now().year;
  num? totalSales = 0.0;
  num? firstQuarterSales = 0.0;
  num? secondQuarterSales = 0.0;
  num? thirdQuarterSales = 0.0;
  num? forthQuarterSales = 0.0;
  num? janSales = 0.0;
  num? febSales = 0.0;
  num? marSales = 0.0;
  num? aprSales = 0.0;
  num? maySales = 0.0;
  num? junSales = 0.0;
  num? julSales = 0.0;
  num? augSales = 0.0;
  num? sepSales = 0.0;
  num? octSales = 0.0;
  num? novSales = 0.0;
  num? decSales = 0.0;

  num? totalPurchases = 0.0;
  num? firstQuarterPurchases = 0.0;
  num? secondQuarterPurchases = 0.0;
  num? thirdQuarterPurchases = 0.0;
  num? forthQuarterPurchases = 0.0;
  num? janPurchases = 0.0;
  num? febPurchases = 0.0;
  num? marPurchases = 0.0;
  num? aprPurchases = 0.0;
  num? mayPurchases = 0.0;
  num? junPurchases = 0.0;
  num? julPurchases = 0.0;
  num? augPurchases = 0.0;
  num? sepPurchases = 0.0;
  num? octPurchases = 0.0;
  num? novPurchases = 0.0;
  num? decPurchases = 0.0;

  int workOffline = 0;
  String language = 'Arabic';

  @override
  void initState() {
    super.initState();
    getVatEndorsementCalculation();
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

  Future getVatEndorsementCalculation() async {
    try {
      setState(() => isLoading = true);
      language = await Utils.language();
      List<Setting> setting;
      setting = await FatooraDB.instance.getAllSettings();
      if (setting.isNotEmpty) {
        setState(() {
          workOffline = setting[0].workOffline;
        });
      }

      if (workOffline == 1) {
        totalSales = await FatooraDB.instance.getTotalSales(selectedYear) ?? 0;
        janSales = await FatooraDB.instance.getJanTotalSales(selectedYear) ?? 0;
        febSales = await FatooraDB.instance.getFebTotalSales(selectedYear) ?? 0;
        marSales = await FatooraDB.instance.getMarTotalSales(selectedYear) ?? 0;
        aprSales = await FatooraDB.instance.getAprTotalSales(selectedYear) ?? 0;
        maySales = await FatooraDB.instance.getMayTotalSales(selectedYear) ?? 0;
        junSales = await FatooraDB.instance.getJunTotalSales(selectedYear) ?? 0;
        julSales = await FatooraDB.instance.getJulTotalSales(selectedYear) ?? 0;
        augSales = await FatooraDB.instance.getAugTotalSales(selectedYear) ?? 0;
        sepSales = await FatooraDB.instance.getSepTotalSales(selectedYear) ?? 0;
        octSales = await FatooraDB.instance.getOctTotalSales(selectedYear) ?? 0;
        novSales = await FatooraDB.instance.getNovTotalSales(selectedYear) ?? 0;
        decSales = await FatooraDB.instance.getDecTotalSales(selectedYear) ?? 0;

        firstQuarterSales = janSales! + febSales! + marSales!;
        secondQuarterSales = aprSales! + maySales! + junSales!;
        thirdQuarterSales = julSales! + augSales! + sepSales!;
        forthQuarterSales = octSales! + novSales! + decSales!;

        totalPurchases =
            await FatooraDB.instance.getTotalPurchases(selectedYear) ?? 0;
        janPurchases =
            await FatooraDB.instance.getJanTotalPurchases(selectedYear) ?? 0;
        febPurchases =
            await FatooraDB.instance.getFebTotalPurchases(selectedYear) ?? 0;
        marPurchases =
            await FatooraDB.instance.getMarTotalPurchases(selectedYear) ?? 0;
        aprPurchases =
            await FatooraDB.instance.getAprTotalPurchases(selectedYear) ?? 0;
        mayPurchases =
            await FatooraDB.instance.getMayTotalPurchases(selectedYear) ?? 0;
        junPurchases =
            await FatooraDB.instance.getJunTotalPurchases(selectedYear) ?? 0;
        julPurchases =
            await FatooraDB.instance.getJulTotalPurchases(selectedYear) ?? 0;
        augPurchases =
            await FatooraDB.instance.getAugTotalPurchases(selectedYear) ?? 0;
        sepPurchases =
            await FatooraDB.instance.getSepTotalPurchases(selectedYear) ?? 0;
        octPurchases =
            await FatooraDB.instance.getOctTotalPurchases(selectedYear) ?? 0;
        novPurchases =
            await FatooraDB.instance.getNovTotalPurchases(selectedYear) ?? 0;
        decPurchases =
            await FatooraDB.instance.getDecTotalPurchases(selectedYear) ?? 0;

        firstQuarterPurchases = janPurchases! + febPurchases! + marPurchases!;
        secondQuarterPurchases = aprPurchases! + mayPurchases! + junPurchases!;
        thirdQuarterPurchases = julPurchases! + augPurchases! + sepPurchases!;
        forthQuarterPurchases = octPurchases! + novPurchases! + decPurchases!;
      }
      setState(() => isLoading = false);
    } on Exception catch (e) {
      setState(() => isLoading = false);
      messageBox(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    return Scaffold(
            body: Container(
              height: h,
              width: w,
              color: AppColor.secondary,
              child: Stack(
                children: [
                  Stack(
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width * 0.50,
                        color: AppColor.primary,
                      ),
                      _textTitle(),
                    ],
                  ),
                  buildYear(),
                  buildBody(),
                  buildButtonsActions(),
                ],
              ),
            ),
          );
  }

  _textTitle() {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.only(top: 30),
      padding: const EdgeInsets.only(right: 20),
      child: Stack(
        children: [
          const NewButton(
              icon: Icons.payment,
              iconSize: 40,
              radius: 40,
              iconColor: AppColor.secondary),
          Text(
            language == 'Arabic'
                ? 'الإقرارات الضريبية'
                : 'ZAKAT Endorsement',
            style: const TextStyle(
              fontSize: 25,
              color: AppColor.secondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBody() => Positioned(
        top: 100,
        left: 5,
        right: 5,
        child: Container(
          color: AppColor.background,
          padding: const EdgeInsets.all(10),
          height: MediaQuery.of(context).size.height * 0.76,
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            child: Column(children: [
              isMonthly ? buildSalesMonthly() : buildSalesQuarterly(),
              const SizedBox(height: 50),
              isMonthly ? buildPurchasesMonthly() : buildPurchasesQuarterly(),
              const SizedBox(height: 20),
              buildAmount('الصافي:', (totalSales! - totalPurchases!))
            ]),
          ),
        ),
      );

  Widget buildSalesQuarterly() => Column(
        children: [
          buildHeaderAndFooter(true, true),
          buildAmount('- اقرار الربع الأول', firstQuarterSales!),
          buildAmount('- اقرار الربع الثاني', secondQuarterSales!),
          buildAmount('- اقرار الربع الثالث', thirdQuarterSales!),
          buildAmount('- اقرار الربع الرابع', forthQuarterSales!),
          buildHeaderAndFooter(false, true),
        ],
      );

  Widget buildSalesMonthly() => Column(
        children: [
          buildHeaderAndFooter(true, true),
          buildAmount('- اقرار شهر يناير', janSales!),
          buildAmount('- اقرار شهر فبراير', febSales!),
          buildAmount('- اقرار شهر مارس', marSales!),
          buildAmount('- اقرار شهر ابريل', aprSales!),
          buildAmount('- اقرار شهر مايو', maySales!),
          buildAmount('- اقرار شهر يونيو', junSales!),
          buildAmount('- اقرار شهر يوليو', julSales!),
          buildAmount('- اقرار شهر أغسطس', augSales!),
          buildAmount('- اقرار شهر سبتمبر', sepSales!),
          buildAmount('- اقرار شهر أكتوبر', octSales!),
          buildAmount('- اقرار شهر نوفمبر', novSales!),
          buildAmount('- اقرار شهر ديسمبر', decSales!),
          buildHeaderAndFooter(false, true),
        ],
      );

  Widget buildPurchasesQuarterly() => Column(children: [
        Column(
          children: [
            buildHeaderAndFooter(true, false),
            buildAmount('- اقرار الربع الأول', firstQuarterPurchases!),
            buildAmount('- اقرار الربع الثاني', secondQuarterPurchases!),
            buildAmount('- اقرار الربع الثالث', thirdQuarterPurchases!),
            buildAmount('- اقرار الربع الرابع', forthQuarterPurchases!),
            buildHeaderAndFooter(false, false),
          ],
        ),
      ]);

  Widget buildPurchasesMonthly() => Column(
        children: [
          buildHeaderAndFooter(true, false),
          buildAmount('- اقرار شهر يناير', janPurchases!),
          buildAmount('- اقرار شهر فبراير', febPurchases!),
          buildAmount('- اقرار شهر مارس', marPurchases!),
          buildAmount('- اقرار شهر ابريل', aprPurchases!),
          buildAmount('- اقرار شهر مايو', mayPurchases!),
          buildAmount('- اقرار شهر يونيو', junPurchases!),
          buildAmount('- اقرار شهر يوليو', julPurchases!),
          buildAmount('- اقرار شهر أغسطس', augPurchases!),
          buildAmount('- اقرار شهر سبتمبر', sepPurchases!),
          buildAmount('- اقرار شهر أكتوبر', octPurchases!),
          buildAmount('- اقرار شهر نوفمبر', novPurchases!),
          buildAmount('- اقرار شهر ديسمبر', decPurchases!),
          buildHeaderAndFooter(false, false),
        ],
      );

  Widget buildHeaderAndFooter(bool isHeader, bool isSales) => Column(
        children: [
          const Divider(height: 2, color: AppColor.primary),
          isHeader
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isSales ? 'ضريبة المبيعات' : 'ضريبة المشتريات',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Row(
                      children: [
                        SizedBox(
                          width: 100,
                          child: Text(
                            'المبلغ',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(width: 10),
                        SizedBox(
                          width: 100,
                          child: Text(
                            'الضريبة',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              : isSales
                  ? buildAmount('الإجمالي:', totalSales!)
                  : buildAmount('الإجمالي:', totalPurchases!),
          const Divider(height: 2, color: AppColor.primary),
        ],
      );

  Widget buildAmount(String caption, num total) => Column(
        children: [
          caption == 'الإجمالي:' ||
                  caption == '- اقرار الربع الأول' ||
                  caption == '- اقرار شهر يناير'
              ? Container()
              : const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                ' $caption',
                style: TextStyle(
                    fontWeight: caption == 'الإجمالي:' || caption == 'الصافي:'
                        ? FontWeight.bold
                        : FontWeight.normal),
              ),
              Row(
                children: [
                  Container(
                    color: caption == 'الإجمالي:'
                        ? null
                        : caption == 'الصافي:'
                            ? total>=0 ? Colors.green[200] : Colors.red[200]
                            : Colors.white,
                    width: 100,
                    child: Text(
                      Utils.formatNoCurrency(total / 1.15),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: caption == 'الإجمالي:' || caption == 'الصافي:'
                              ? FontWeight.bold
                              : FontWeight.normal),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    color: caption == 'الإجمالي:' ? null : caption == 'الصافي:'
                        ? (total - total / 1.15)>=0 ? Colors.green[200] : Colors.red[200]
                        : AppColor.secondary,
                    width: 100,
                    child: Text(
                      Utils.formatNoCurrency(total - total / 1.15),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: caption == 'الإجمالي:' || caption == 'الصافي:'
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: caption == 'الإجمالي:' ? null : caption == 'الصافي:' ? Colors.black : Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      );

  Widget buildButtonsActions() => Positioned(
        left: 0,
        bottom: 0,
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.10,
          width: MediaQuery.of(context).size.width,
          child: Container(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
            color: AppColor.background,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Switch(
                          value: isMonthly,
                          onChanged: (bool value) {
                            setState(() {
                              isMonthly = !isMonthly;
                            });
                          },
                        ),
                        isMonthly
                            ? const Text(
                                'اقرار شهري',
                                style: TextStyle(
                                    color: AppColor.primary,
                                    fontWeight: FontWeight.bold),
                              )
                            : const Text(
                                'اقرار ربع سنوي',
                                style: TextStyle(
                                    color: AppColor.primary,
                                    fontWeight: FontWeight.bold),
                              ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        NewButton(
                          icon: Icons.home,
                          iconSize: 24,
                          radius: 24,
                          onTap: () => Get.to(() => const HomePage()),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

  Widget buildYear() => Positioned(
        left: Platform.isAndroid ? 40 : 60,
        top: Platform.isAndroid ? 30 : 35,
        child: Row(
          children: [
            Platform.isAndroid
                ? Container()
                : Row(
                    children: [
                      Text(language == 'Arabic' ? 'السنة :' : 'Year',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                      const SizedBox(width: 10),
                    ],
                  ),
            SizedBox(
              width: Platform.isAndroid ? 90 : 80,
              child: DropdownSearch<String>(
                popupProps: PopupProps.menu(
                    showSelectedItems: true,
                    constraints: BoxConstraints(
                        maxHeight: Platform.isAndroid ? 225 : 200)),
                dropdownDecoratorProps: DropDownDecoratorProps(
                    baseStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                    dropdownSearchDecoration: InputDecoration(
                      hintText:
                          language == 'Arabic' ? 'السنة' : 'Year',
                      hintStyle: const TextStyle(color: Colors.white),
                    )),
                items: [for (int i = 2022; i < 2124; i++) '$i'],
                // items: const ['2022', '2023'],
                onChanged: (val) {
                  setState(() => selectedYear = int.parse(val!));
                  getVatEndorsementCalculation();
                },
                selectedItem: selectedYear.toString(),
              ),
            ),
          ],
        ),
      );
}
