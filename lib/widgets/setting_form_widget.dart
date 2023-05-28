import 'dart:convert';
import 'dart:io';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:fatoora/widgets/widget.dart';
import '../models/address.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../apis/constants/utils.dart';
import '/widgets/app_colors.dart';
import 'package:flutter/material.dart';

class SettingFormWidget extends StatelessWidget {
  final int? id;
  final String? name;
  final String? email;
  final String? password;
  final String? cellphone;
  final String? seller;
  final String? buildingNo;
  final String? streetName;
  final String? district;
  final String? city;
  final String? country;
  final String? postalCode;
  final String? additionalNo;
  final String? vatNumber;
  final Address? sellerAddress;
  final String? sheetId;
  final int? workOffline;
  final String? activationCode;
  final String? startDateTime;
  final String? logo;
  final bool? validLicense;
  final String? defaultInvoiceTemp;
  final String? invoiceTemp1;
  final String? invoiceTemp2;
  final String? invoiceTemp3;
  final String? invoiceTemp4;
  final String? invoiceTemp5;
  final String? terms;
  final String? terms1;
  final String? terms2;
  final String? terms3;
  final String? terms4;
  final int? logoWidth;
  final int? logoHeight;
  final int? showVat;
  final String? printerName;
  final String? language;
  final String? freeText2; // for whatsapp
  final String? freeText3; // for payMethod
  final String? freeText4; // for device
  final String? freeText5; // for activity
  final int? dbVersion;
  final ValueChanged<String> onChangedName;
  final ValueChanged<String> onChangedEmail;
  final ValueChanged<String> onChangedPassword;
  final ValueChanged<String> onChangedCellphone;
  final ValueChanged<String> onChangedSeller;
  final ValueChanged<String> onChangedBuildingNo;
  final ValueChanged<String> onChangedStreetName;
  final ValueChanged<String> onChangedDistrict;
  final ValueChanged<String> onChangedCity;
  final ValueChanged<String> onChangedCountry;
  final ValueChanged<String> onChangedPostalCode;
  final ValueChanged<String> onChangedAdditionalNo;
  final ValueChanged<String> onChangedVatNumber;
  final ValueChanged<String> onChangedSheetId;
  final ValueChanged<bool> onChangedWorkOffline;
  final ValueChanged<String> onChangedActivationCode;
  final ValueChanged<String> onChangedLogo;
  final ValueChanged<String> onChangedDefaultInvoiceTemp;
  final ValueChanged<String> onChangedInvoiceTemp1;
  final ValueChanged<String> onChangedInvoiceTemp2;
  final ValueChanged<String> onChangedInvoiceTemp3;
  final ValueChanged<String> onChangedInvoiceTemp4;
  final ValueChanged<String> onChangedInvoiceTemp5;
  final ValueChanged<String> onChangedTerms;
  final ValueChanged<String> onChangedTerms1;
  final ValueChanged<String> onChangedTerms2;
  final ValueChanged<String> onChangedTerms3;
  final ValueChanged<String> onChangedTerms4;
  final ValueChanged<String> onChangedLogoWidth;
  final ValueChanged<String> onChangedLogoHeight;
  final ValueChanged<bool> onChangedShowVat;
  final ValueChanged<String> onChangedPrinterName;
  final ValueChanged<String?> onChangedLanguage;
  final ValueChanged<String?> onChangedFreeText2;
  final ValueChanged<String?> onChangedFreeText3;
  final ValueChanged<String?> onChangedFreeText4;
  final ValueChanged<String?> onChangedFreeText5;

  const SettingFormWidget({
    Key? key,
    this.id,
    this.name = '',
    this.email = '',
    this.password = '',
    this.cellphone = '',
    this.seller = '',
    this.buildingNo = '',
    this.streetName = '',
    this.district = '',
    this.city = 'الرياض',
    this.country = 'المملكة العربية السعوية',
    this.postalCode = '',
    this.additionalNo = '',
    this.vatNumber = '',
    this.sellerAddress,
    this.sheetId = '',
    this.workOffline = 0,
    this.activationCode = '',
    this.startDateTime,
    this.logo = '',
    this.defaultInvoiceTemp = '',
    this.invoiceTemp1 = '',
    this.invoiceTemp2 = '',
    this.invoiceTemp3 = '',
    this.invoiceTemp4 = '',
    this.invoiceTemp5 = '',
    this.terms = '',
    this.terms1 = '',
    this.terms2 = '',
    this.terms3 = '',
    this.terms4 = '',
    this.logoWidth = 75,
    this.logoHeight = 75,
    this.showVat = 1,
    this.printerName = 'IposPrinter',
    this.language = 'Arabic',
    this.freeText2 = 'واتساب',
    this.freeText3 = 'اظهار',
    this.freeText4 = 'Mobile',
    this.freeText5 = 'General',
    this.dbVersion = 1,
    this.validLicense = false,
    required this.onChangedName,
    required this.onChangedEmail,
    required this.onChangedPassword,
    required this.onChangedCellphone,
    required this.onChangedSeller,
    required this.onChangedBuildingNo,
    required this.onChangedStreetName,
    required this.onChangedDistrict,
    required this.onChangedCity,
    required this.onChangedCountry,
    required this.onChangedPostalCode,
    required this.onChangedAdditionalNo,
    required this.onChangedVatNumber,
    required this.onChangedSheetId,
    required this.onChangedWorkOffline,
    required this.onChangedActivationCode,
    required this.onChangedLogo,
    required this.onChangedDefaultInvoiceTemp,
    required this.onChangedInvoiceTemp1,
    required this.onChangedInvoiceTemp2,
    required this.onChangedInvoiceTemp3,
    required this.onChangedInvoiceTemp4,
    required this.onChangedInvoiceTemp5,
    required this.onChangedTerms,
    required this.onChangedTerms1,
    required this.onChangedTerms2,
    required this.onChangedTerms3,
    required this.onChangedTerms4,
    required this.onChangedLogoWidth,
    required this.onChangedLogoHeight,
    required this.onChangedShowVat,
    required this.onChangedPrinterName,
    required this.onChangedLanguage,
    required this.onChangedFreeText2,
    required this.onChangedFreeText3,
    required this.onChangedFreeText4,
    required this.onChangedFreeText5,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(5),
          child: Column(
            children: [
              Column(
                children: [
                  validLicense! ? Container() : Column(
                    children: [
                      NewFrame(
                          title: 'النسخة الحالية',
                          child: Text(
                            'النسخة الحالية تجريبية أو منتهية\n'
                                'رقم المستخدم: $id\n'
                                'رقم الجوال: $cellphone\n'
                                'للحصول على كود التفعيل قم بتصوير هذه الشاشة وأرسلها إلى واتساب رقم: ${Utils.defSupportNumber}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColor.primary),
                          )),
                      Utils.space(4, 0),
                    ],
                  ),
                  NewFrame(
                    title: 'بيانات المستخدم',
                    child: Row(children: [
                      Expanded(child: buildName()),
                      Utils.space(0, 4),
                      Expanded(child: buildUserId()),
                      Utils.space(0, 4),
                      Expanded(child: buildStartDate())
                    ],
                    ),
                  ),
                  Utils.space(4, 0),
                  NewFrame(
                    title: 'بيانات الشركة/المؤسسة',
                    child: Column(
                      children: [
                        buildSeller(),
                        Row(children: [
                          Expanded(child: buildVatNumber()),
                          Utils.space(0, 4),
                          Expanded(child: buildCellphone()),
                        ]),
                        buildEmail()
                      ],
                    ),
                  ),
                  Utils.space(4, 0),
                  NewFrame(
                    title: 'بيانات العنوان الوطني',
                    child: Column(children: [
                      Row(children: [
                        SizedBox(width: 100, child: buildBuildingNo()),
                        Utils.space(0, 4),
                        Expanded(child: buildStreetName()),
                      ],),
                      Row(children: [
                        Expanded(child: buildDistrict()),
                        Utils.space(0, 4),
                        Expanded(child: buildCity()),
                        Utils.space(0, 4),
                        Expanded(child: buildCountry()),
                      ],),
                      Row(children: [
                        Expanded(child: buildPostalCode()),
                        Utils.space(0, 4),
                        Expanded(child: buildAdditionalNo()),
                      ],),
                    ],),
                  ),
                  Utils.space(4, 0),
                  NewFrame(
                    title: 'إعدادات عامة',
                    child: Column(children: [
                      buildShowVat(),
                      Row(children: [
                        Expanded(child: buildActivationCode()),
                        Utils.space(0, 4),
                        Expanded(child: buildLanguage()),
                      ]),
                      Row(children: [
                        Expanded(child: buildPayMethod()),
                        Utils.space(0, 4),
                        Expanded(child: buildWhatsapp()),
                      ]),
                      Row(children: [
                        Expanded(child: buildActivity()),
                        Utils.space(0, 4),
                        Expanded(child: buildPrinterName()),
                      ]),
                    ],),
                  ),
                  Utils.space(4, 0),
                  buildTerms(),
                  Utils.space(4, 0),
                  buildLogoRow(),
                  Utils.space(4, 0),
                  NewFrame(
                    title: 'نماذج طباعة الفواتير',
                    child: Column(
                      children: [
                        Utils.isDefaultProject ? Utils.space(2, 0) : Container(),
                        Utils.isDefaultProject ? buildDefaultInvoiceTemp() : Container(),
                        Utils.isDefaultProject ? Container() : Utils.space(2, 0),
                        Utils.isDefaultProject ? Container() : buildInvoiceTemp1(),
                        Utils.isDefaultProject ? Container() : Utils.space(2, 0),
                        Utils.isDefaultProject ? Container() : buildInvoiceTemp2(),
                        // Utils.isDefaultProject ? Container() : Utils.space(2, 0),
                        // Utils.isDefaultProject ? Container() : buildInvoiceTemp3(),
                        // Utils.isDefaultProject ? Container() : Utils.space(2, 0),
                        // Utils.isDefaultProject ? Container() : buildInvoiceTemp4(),
                        // Utils.isDefaultProject ? Container() : Utils.space(2, 0),
                        // Utils.isDefaultProject ? Container() : buildInvoiceTemp5(),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
  Widget buildStartDate() => TextFormField(
    initialValue: Utils.formatShortDate(DateTime.parse(startDateTime!)),
    enabled: false,
    style: const TextStyle(
        color: AppColor.primary, fontWeight: FontWeight.bold, fontSize: 14),
    decoration: InputDecoration(
      labelText: language == 'Arabic' ? 'تاريخ البداية' : 'Start Date',
    ),
  );
  Widget buildLanguage() => DropdownSearch<String>(
    popupProps: const PopupProps.menu(
      showSelectedItems: true,
      constraints: BoxConstraints(maxHeight: 100),
    ),
    dropdownDecoratorProps: const DropDownDecoratorProps(
      baseStyle: TextStyle(
        color: AppColor.primary,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
      dropdownSearchDecoration: InputDecoration(label: Text('اللغة')),
    ),
    items: const ['Arabic', 'English'],
    onChanged: onChangedLanguage,
    selectedItem: language,
  );

  Widget buildWhatsapp() => DropdownSearch<String>(
    popupProps: PopupProps.menu(
      showSelectedItems: true,
      constraints:
      BoxConstraints(maxHeight: Platform.isAndroid ? 115 : 100),
    ),
    dropdownDecoratorProps: const DropDownDecoratorProps(
      baseStyle: TextStyle(
        color: AppColor.primary,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
      dropdownSearchDecoration:
      InputDecoration(label: Text('باقة الواتساب')),
    ),
    items: const ['واتساب', 'أعمال'],
    onChanged: onChangedFreeText2,
    selectedItem: freeText2 ?? 'واتساب',
  );

  Widget buildPayMethod() => DropdownSearch<String>(
    popupProps: PopupProps.menu(
      showSelectedItems: true,
      constraints:
      BoxConstraints(maxHeight: Platform.isAndroid ? 115 : 100),
    ),
    dropdownDecoratorProps: const DropDownDecoratorProps(
      baseStyle: TextStyle(
        color: AppColor.primary,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
      dropdownSearchDecoration: InputDecoration(label: Text('طرق الدفع')),
    ),
    items: const ['اظهار', 'اخفاء'],
    onChanged: onChangedFreeText3,
    selectedItem: freeText3,
  );

  Widget buildDevice() => DropdownSearch<String>(
    popupProps: PopupProps.menu(
      showSelectedItems: true,
      constraints:
      BoxConstraints(maxHeight: Platform.isAndroid ? 230 : 300),
    ),
    dropdownDecoratorProps: const DropDownDecoratorProps(
      baseStyle: TextStyle(
        color: AppColor.primary,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
      dropdownSearchDecoration: InputDecoration(label: Text('الجهاز')),
    ),
    items: const [
      'Mobile',
      'Sunmi',
      'Handheld',
      'Portable',
      'Desktop',
      'Laptop'
    ],
    onChanged: onChangedFreeText4,
    selectedItem: freeText4,
  );

  Widget buildActivity() => DropdownSearch<String>(
    popupProps: PopupProps.menu(
      showSelectedItems: true,
      constraints:
      BoxConstraints(maxHeight: Platform.isAndroid ? 230 : 250),
    ),
    dropdownDecoratorProps: const DropDownDecoratorProps(
      baseStyle: TextStyle(
        color: AppColor.primary,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
      dropdownSearchDecoration: InputDecoration(label: Text('النشاط')),
    ),
    items: const ['OilServices', 'Laundry', 'General'],
    onChanged: onChangedFreeText5,
    selectedItem: freeText5,
  );

  Widget buildPrinterName() => TextFormField(
        maxLines: 1,
        initialValue: printerName,
        keyboardType: TextInputType.name,
        style: const TextStyle(
          color: AppColor.primary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        decoration: const InputDecoration(
          labelText: 'اسم الطابعة',
        ),
        validator: (name) =>
            name != null && name.isEmpty ? 'يجب أدخال اسم الطابعة' : null,
        onChanged: onChangedPrinterName,
      );

  Widget buildTerms() => NewFrame(
    title: 'شروط تظهر أسفل الفاتورة',
    child: Column(
            children: [
              buildTerms0(),
              buildTerms1(),
              buildTerms2(),
              buildTerms3(),
              buildTerms4(),
            ]),
  );

  Widget buildTerms0() => TextFormField(
        maxLines: 1,
        initialValue: terms1,
        keyboardType: TextInputType.multiline,
        style: const TextStyle(
          color: AppColor.primary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        decoration: const InputDecoration(
          labelText: 'شرط 1',
        ),
        onChanged: onChangedTerms1,
      );
  Widget buildTerms1() => TextFormField(
        maxLines: 1,
        initialValue: terms1,
        keyboardType: TextInputType.multiline,
        style: const TextStyle(
          color: AppColor.primary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        decoration: const InputDecoration(
          labelText: 'شرط 2',
        ),
        onChanged: onChangedTerms1,
      );

  Widget buildTerms2() => TextFormField(
        maxLines: 1,
        initialValue: terms2,
        keyboardType: TextInputType.multiline,
        style: const TextStyle(
          color: AppColor.primary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        decoration: const InputDecoration(
          labelText: 'شرط 3',
        ),
        onChanged: onChangedTerms2,
      );

  Widget buildTerms3() => TextFormField(
        maxLines: 1,
        initialValue: terms3,
        keyboardType: TextInputType.multiline,
        style: const TextStyle(
          color: AppColor.primary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        decoration: const InputDecoration(
          labelText: 'شرط 4',
        ),
        onChanged: onChangedTerms3,
      );

  Widget buildTerms4() => TextFormField(
        maxLines: 1,
        initialValue: terms4,
        keyboardType: TextInputType.multiline,
        style: const TextStyle(
          color: AppColor.primary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        decoration: const InputDecoration(
          labelText: 'شرط 5',
        ),
        onChanged: onChangedTerms4,
      );

  Widget buildName() => TextFormField(
        maxLines: 1,
        initialValue: name,
        keyboardType: TextInputType.name,
        style: const TextStyle(
          color: AppColor.primary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        decoration: const InputDecoration(
          labelText: 'اسم المستخدم',
        ),
        validator: (name) =>
            name != null && name.isEmpty ? 'يجب أدخال الاسم' : null,
        onChanged: onChangedName,
      );

  Widget buildUserId() => TextFormField(
    maxLines: 1,
    initialValue: id.toString(),
    enabled: false,
    style: const TextStyle(
      color: AppColor.primary,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    ),
    decoration: const InputDecoration(
      labelText: 'رقم المستخدم',
    ),
  );

  Widget buildEmail() => TextFormField(
        maxLines: 1,
        initialValue: email,
        keyboardType: TextInputType.emailAddress,
        style: const TextStyle(
          color: AppColor.primary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        decoration: const InputDecoration(
          labelText: 'الايميل',
        ),
        validator: (email) =>
            email != null && email.isEmpty ? 'يجب أدخال الايميل' : null,
        onChanged: onChangedEmail,
      );

  Widget buildPassword() => SizedBox(
        width: 100,
        child: TextFormField(
          maxLines: 1,
          initialValue: password,
          obscureText: true,
          style: const TextStyle(
            color: AppColor.primary,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          decoration: const InputDecoration(
            labelText: 'كلمة المرور',
          ),
          validator: (password) => password != null && password.isEmpty
              ? 'يجب أدخال كلمة المرور'
              : null,
          onChanged: onChangedPassword,
        ),
      );

  Widget buildCellphone() => TextFormField(
        maxLines: 1,
        initialValue: cellphone,
        keyboardType: TextInputType.phone,
        style: const TextStyle(
          color: AppColor.primary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        decoration: const InputDecoration(
          labelText: 'رقم الجوال',
        ),
        validator: (cellphone) => cellphone != null && cellphone.isEmpty
            ? 'يجب أدخال رقم الجوال'
            : null,
        onChanged: onChangedCellphone,
      );

  Widget buildSeller() => TextFormField(
        maxLines: 1,
        initialValue: seller,
        keyboardType: TextInputType.name,
        style: const TextStyle(
          color: AppColor.primary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        decoration: const InputDecoration(
          labelText: 'اسم الشركة (البائع بالفاتورة)',
        ),
        validator: (seller) =>
            seller != null && seller.isEmpty ? 'يجب أدخال اسم الشركة' : null,
        onChanged: onChangedSeller,
      );

  Widget buildBuildingNo() => TextFormField(
        maxLines: 1,
        initialValue: buildingNo,
        keyboardType: TextInputType.number,
        style: const TextStyle(
          color: AppColor.primary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        decoration: const InputDecoration(
          labelText: 'رقم المبنى',
        ),
        onChanged: onChangedBuildingNo,
      );

  Widget buildStreetName() => TextFormField(
        maxLines: 1,
        initialValue: streetName,
        keyboardType: TextInputType.text,
        style: const TextStyle(
          color: AppColor.primary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        decoration: const InputDecoration(
          labelText: 'الشارع',
        ),
        onChanged: onChangedStreetName,
      );

  Widget buildDistrict() => TextFormField(
        maxLines: 1,
        initialValue: district,
        keyboardType: TextInputType.text,
        style: const TextStyle(
          color: AppColor.primary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        decoration: const InputDecoration(
          labelText: 'الحي',
        ),
        onChanged: onChangedDistrict,
      );

  Widget buildCity() => TextFormField(
        maxLines: 1,
        initialValue: city,
        keyboardType: TextInputType.text,
        style: const TextStyle(
          color: AppColor.primary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        decoration: const InputDecoration(
          labelText: 'المدينة',
        ),
        onChanged: onChangedCity,
      );

  Widget buildCountry() => TextFormField(
        maxLines: 1,
        initialValue: country,
        keyboardType: TextInputType.text,
        style: const TextStyle(
          color: AppColor.primary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        decoration: const InputDecoration(
          labelText: 'البلد',
        ),
        onChanged: onChangedCountry,
      );

  Widget buildPostalCode() => TextFormField(
        maxLines: 1,
        initialValue: postalCode,
        keyboardType: TextInputType.text,
        style: const TextStyle(
          color: AppColor.primary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        decoration: const InputDecoration(
          labelText: 'الرمز البريدي',
        ),
        onChanged: onChangedPostalCode,
      );

  Widget buildAdditionalNo() => TextFormField(
        maxLines: 1,
        initialValue: additionalNo,
        keyboardType: TextInputType.text,
        style: const TextStyle(
          color: AppColor.primary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        decoration: const InputDecoration(
          labelText: 'الرقم الإضافي',
        ),
        onChanged: onChangedAdditionalNo,
      );

  Widget buildVatNumber() => TextFormField(
        maxLines: 1,
        initialValue: vatNumber,
        keyboardType: TextInputType.number,
        style: const TextStyle(
          color: AppColor.primary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        decoration: const InputDecoration(
          labelText: 'الرقم الضريبي',
        ),
        validator: (vatNumber) => vatNumber != null && vatNumber.isEmpty
            ? 'يجب أدخال الرقم الضريبي'
            : vatNumber!.length != 15
                ? 'يجب أدخال الرقم الضريبي مكون من 15 رقم'
                : null,
        onChanged: onChangedVatNumber,
      );

  Widget buildShowVat() => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'إظهار الرقم الضريبي والضريبة على الفاتورة',
            style: TextStyle(fontSize: 14),
          ),
          Switch(
            value: showVat == 1 ? true : false,
            onChanged: onChangedShowVat,
          ),
        ],
      );

  static Future<String> getLogoFile() async {
    final byteData = await rootBundle.load('assets/images/logo.png');

    final file = File('${(await getTemporaryDirectory()).path}/logo.png');
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    final byte = file.readAsBytesSync();
    var base64 = base64Encode(byte);

    return base64;
  }
  Widget buildLogoRow() => NewFrame(
    title: 'شعار الشركة/المؤسسة',
    child: Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            buildLogoWidth(),
            buildLogoHeight(),
          ],),
        Utils.space(3, 0),
        buildLogo(),
      ],
    ),
  );
  Widget buildLogo() => logo != ''
      ? Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Image.memory(
          base64Decode(logo!),
          height: logoHeight!.toDouble(),
          width: logoWidth!.toDouble(),
          fit: BoxFit.fill,
        ))
      : Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Image(
          image: const AssetImage('assets/images/logo.png'),
          height: logoHeight!.toDouble(),
          width: logoWidth!.toDouble(),
          fit: BoxFit.fill,
        ));
  Widget buildLogoWidth() => SizedBox(
    width: 100,
    child: TextFormField(
      maxLines: 1,
      initialValue: logoWidth.toString(),
      keyboardType: TextInputType.number,
      style: const TextStyle(
        color: AppColor.primary,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
      decoration: const InputDecoration(
        labelText: 'عرض الشعار',
      ),
      onChanged: onChangedLogoWidth,
    ),
  );
  Widget buildLogoHeight() => SizedBox(
    width: 100,
    child: TextFormField(
      maxLines: 1,
      initialValue: logoHeight.toString(),
      keyboardType: TextInputType.number,
      style: const TextStyle(
        color: AppColor.primary,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
      decoration: const InputDecoration(
        labelText: 'ارتفاع الشعار',
      ),
      onChanged: onChangedLogoHeight,
    ),
  );
  Widget buildTextLogo() => TextFormField(
        initialValue: logo,
        onChanged: onChangedLogo,
      );

  Widget buildDefaultInvoiceTemp() => defaultInvoiceTemp != ''
      ?  Column(children: [
    const Text(
      'نموذج فاتورة',
      style: TextStyle(
        color: Colors.black54,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    ),
    Utils.space(1, 0),
    Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Image.memory(
          base64Decode(defaultInvoiceTemp!),
          height: 400,
          width: 300,
          fit: BoxFit.fill,
        )),
  ],)
      : Column(children: [
    const Text(
      'نموذج فاتورة',
      style: TextStyle(
        color: Colors.black54,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    ),
    Utils.space(1, 0),
    Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: const Image(
          image: AssetImage('assets/images/defaultInvoiceTemp.png'),
          height: 400,
          width: 300,
          fit: BoxFit.fill,
        )),

  ],);


  Widget buildInvoiceTemp1() => invoiceTemp1 != ''
      ?  Column(children: [
    const Text(
      'نموذج 1',
      style: TextStyle(
        color: Colors.black54,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    ),
    Utils.space(1, 0),
    Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Image.memory(
      base64Decode(invoiceTemp1!),
      height: 400,
      width: 300,
      fit: BoxFit.fill,
    )),
  ],)
      : Column(children: [
    const Text(
      'نموذج 1',
      style: TextStyle(
        color: Colors.black54,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    ),
    Utils.space(1, 0),
    Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
          child: const Image(
        image: AssetImage('assets/images/invoiceTemp1.png'),
        height: 400,
        width: 300,
        fit: BoxFit.fill,
      )),

  ],);

  Widget buildInvoiceTemp2() => invoiceTemp2 != ''
      ? Column(children: [
    const Text(
      'نموذج 2',
      style: TextStyle(
        color: Colors.black54,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    ),
    Utils.space(1, 0),
    Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Image.memory(
      base64Decode(invoiceTemp2!),
      height: 400,
      width: 300,
      fit: BoxFit.fill,
    )),
  ],)
      : Column(children:  [
    const Text(
      'نموذج 2',
      style: TextStyle(
        color: Colors.black54,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    ),
    Utils.space(1, 0),
    Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: const Image(
      image: AssetImage('assets/images/invoiceTemp2.png'),
      height: 400,
      width: 300,
      fit: BoxFit.fill,
    ))
  ],);

  Widget buildInvoiceTemp3() => invoiceTemp3 != ''
      ? Column(children: [
    const Text(
      'نموذج 3',
      style: TextStyle(
        color: Colors.black54,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    ),
    Utils.space(1, 0),
    Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Image.memory(
      base64Decode(invoiceTemp3!),
      height: 400,
      width: 300,
      fit: BoxFit.fill,
    )),
  ],)
      : Column(children: [
    const Text(
      'نموذج 3',
      style: TextStyle(
        color: Colors.black54,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    ),
    Utils.space(1, 0),
    Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: const Image(
      image: AssetImage('assets/images/invoiceTemp3.png'),
      height: 400,
      width: 300,
      fit: BoxFit.fill,
    ))
  ],);

  Widget buildInvoiceTemp4() => invoiceTemp4 != ''
      ? Column(children: [
    const Text(
      'نموذج 4',
      style: TextStyle(
        color: Colors.black54,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    ),
    Utils.space(1, 0),
    Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Image.memory(
      base64Decode(invoiceTemp4!),
      height: 400,
      width: 300,
      fit: BoxFit.fill,
    )),
  ],)
      : Column(children: [
    const Text(
      'نموذج 4',
      style: TextStyle(
        color: Colors.black54,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    ),
    Utils.space(1, 0),
    Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: const Image(
      image: AssetImage('assets/images/invoiceTemp4.png'),
      height: 400,
      width: 300,
      fit: BoxFit.fill,
    ))
  ],);

  Widget buildInvoiceTemp5() => invoiceTemp5 != ''
      ?  Column(children: [
    const Text(
      'نموذج 5',
      style: TextStyle(
        color: Colors.black54,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    ),
    Utils.space(1, 0),
    Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Image.memory(
      base64Decode(invoiceTemp5!),
      height: 400,
      width: 300,
      fit: BoxFit.fill,
    )),
  ],)
      : Column(children: [
    const Text(
      'نموذج 5',
      style: TextStyle(
        color: Colors.black54,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    ),
    Utils.space(1, 0),
    Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: const Image(
      image: AssetImage('assets/images/invoiceTemp5.png'),
      height: 400,
      width: 300,
      fit: BoxFit.fill,
    ))
  ],);

  Widget buildSheetId() => TextFormField(
        minLines: 1,
        maxLines: 2,
        initialValue: sheetId,
        keyboardType: TextInputType.text,
        style: const TextStyle(
          color: AppColor.primary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        decoration: const InputDecoration(
          labelText: 'معرف ملف قاعدة البيانات',
        ),
        // validator: (sheetId) => sheetId != null && sheetId.isEmpty
        //     ? 'يجب أدخال معرف ملف قاعدة البيانات'
        //     : null,
        onChanged: onChangedSheetId,
      );

  Widget buildActivationCode() => TextFormField(
        minLines: 1,
        maxLines: 2,
        initialValue: activationCode,
        keyboardType: TextInputType.text,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColor.primary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        decoration: const InputDecoration(
          labelText: 'كود التفعيل',
          // hintText: 'مدة النسخة التجريبية 3 أيام بعدها يطلب كود التفعيل لتحميل النصخة الأصلية'
        ),
        // validator: (sheetId) => sheetId != null && sheetId.isEmpty
        //     ? 'يجب أدخال معرف ملف قاعدة البيانات'
        //     : null,
        onChanged: onChangedActivationCode,
      );

  Widget buildWorkOffline() => Switch(
        value: workOffline == 1 ? true : false,
        onChanged: onChangedWorkOffline,
      );
}

class RegisterFormWidget extends StatelessWidget {
  final String? name;
  final String? email;
  final String? password;
  final String? cellphone;
  final String? seller;
  final String? buildingNo;
  final String? streetName;
  final String? district;
  final String? city;
  final String? country;
  final String? postalCode;
  final String? additionalNo;
  final String? vatNumber;
  final Address? sellerAddress;
  final String? sheetId;
  final int? workOffline;
  final String? startDateTime;
  final String? logo;
  final String? terms;
  final int? logoWidth;
  final int? logoHeight;
  final int? showVat;
  final ValueChanged<String> onChangedName;
  final ValueChanged<String> onChangedEmail;
  final ValueChanged<String> onChangedPassword;
  final ValueChanged<String> onChangedCellphone;
  final ValueChanged<String> onChangedSeller;
  final ValueChanged<String> onChangedBuildingNo;
  final ValueChanged<String> onChangedStreetName;
  final ValueChanged<String> onChangedDistrict;
  final ValueChanged<String> onChangedCity;
  final ValueChanged<String> onChangedCountry;
  final ValueChanged<String> onChangedPostalCode;
  final ValueChanged<String> onChangedAdditionalNo;
  final ValueChanged<String> onChangedVatNumber;
  final ValueChanged<String> onChangedSheetId;
  final ValueChanged<bool> onChangedWorkOffline;
  final ValueChanged<String> onChangedLogo;
  final ValueChanged<String> onChangedTerms;
  final ValueChanged<String> onChangedLogoWidth;
  final ValueChanged<String> onChangedLogoHeight;
  final ValueChanged<bool> onChangedShowVat;

  const RegisterFormWidget({
    Key? key,
    this.name = '',
    this.email = '',
    this.password = '',
    this.cellphone = '',
    this.seller = '',
    this.buildingNo = '',
    this.streetName = '',
    this.district = '',
    this.city = '',
    this.country = '',
    this.postalCode = '',
    this.additionalNo = '',
    this.vatNumber = '',
    this.sellerAddress,
    this.sheetId = '',
    this.workOffline = 0,
    this.startDateTime,
    this.logo = '',
    this.terms = '',
    this.logoWidth = 75,
    this.logoHeight = 75,
    this.showVat = 1,
    required this.onChangedName,
    required this.onChangedEmail,
    required this.onChangedPassword,
    required this.onChangedCellphone,
    required this.onChangedSeller,
    required this.onChangedBuildingNo,
    required this.onChangedStreetName,
    required this.onChangedDistrict,
    required this.onChangedCity,
    required this.onChangedCountry,
    required this.onChangedPostalCode,
    required this.onChangedAdditionalNo,
    required this.onChangedVatNumber,
    required this.onChangedSheetId,
    required this.onChangedWorkOffline,
    required this.onChangedLogo,
    required this.onChangedTerms,
    required this.onChangedLogoWidth,
    required this.onChangedLogoHeight,
    required this.onChangedShowVat,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(5),
        child: Column(
          children: [
            Column(
              children: [
                Row(
                  children: [
                    Expanded(child: buildName()),
                    Utils.space(0, 2),
                    Expanded(child: buildCellphone()),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: buildSeller()),
                    Utils.space(0, 2),
                    Expanded(child: buildVatNumber()),
                  ],
                ),
                buildEmail(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTerms() => TextFormField(
    maxLines: 1,
    initialValue: terms,
    keyboardType: TextInputType.multiline,
    style: const TextStyle(
      color: AppColor.primary,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    ),
    decoration: const InputDecoration(
      labelText: 'شروط وأحكام (تظهر بأسفل الفاتورة)',
    ),
    onChanged: onChangedTerms,
  );

  Widget buildName() => TextFormField(
    maxLines: 1,
    initialValue: name,
    autofocus: true,
    keyboardType: TextInputType.name,
    style: const TextStyle(
      color: AppColor.primary,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    ),
    decoration: const InputDecoration(
      labelText: 'اسم المستخدم',
    ),
    validator: (name) =>
    name != null && name.isEmpty ? 'يجب أدخال اسم المستخدم' : null,
    onChanged: onChangedName,
  );

  Widget buildEmail() => Row(
    children: [
      Expanded(
          child: TextFormField(
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center,
            maxLines: 1,
            initialValue: email,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(
              color: AppColor.primary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            decoration: const InputDecoration(
              labelText: 'الايميل',
            ),
            validator: (email) =>
            email != null && email.isEmpty ? 'يجب أدخال الايميل' : null,
            onChanged: onChangedEmail,
          ))
    ],
  );

  Widget buildPassword() => TextFormField(
    maxLines: 1,
    initialValue: password,
    obscureText: true,
    style: const TextStyle(
      color: AppColor.primary,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    ),
    decoration: const InputDecoration(
      labelText: 'كلمة المرور',
    ),
    // validator: (password) => password != null && password.isEmpty
    //     ? 'يجب أدخال كلمة المرور'
    //     : null,
    onChanged: onChangedPassword,
  );

  Widget buildCellphone() => TextFormField(
    maxLines: 1,
    initialValue: cellphone,
    textAlign: TextAlign.center,
    textDirection: TextDirection.ltr,
    keyboardType: TextInputType.phone,
    style: const TextStyle(
      color: AppColor.primary,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    ),
    decoration: const InputDecoration(
      labelText: 'رقم الجوال',
    ),
    validator: (cellphone) => cellphone != null && cellphone.isEmpty
        ? 'يجب أدخال رقم الجوال'
        : null,
    onChanged: onChangedCellphone,
  );

  Widget buildSeller() => TextFormField(
    maxLines: 1,
    initialValue: seller,
    keyboardType: TextInputType.name,
    style: const TextStyle(
      color: AppColor.primary,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    ),
    decoration: const InputDecoration(
      labelText: 'اسم الشركة/المؤسسة',
    ),
    validator: (seller) => seller != null && seller.isEmpty
        ? 'يجب أدخال اسم الشركة/المؤسسة'
        : null,
    onChanged: onChangedSeller,
  );

  Widget buildBuildingNo() => TextFormField(
    maxLines: 1,
    initialValue: buildingNo,
    keyboardType: TextInputType.number,
    style: const TextStyle(
      color: AppColor.primary,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    ),
    decoration: const InputDecoration(
      labelText: 'رقم المبنى',
    ),
    onChanged: onChangedBuildingNo,
  );

  Widget buildStreetName() => TextFormField(
    maxLines: 1,
    initialValue: streetName,
    keyboardType: TextInputType.text,
    style: const TextStyle(
      color: AppColor.primary,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    ),
    decoration: const InputDecoration(
      labelText: 'الشارع',
    ),
    onChanged: onChangedStreetName,
  );

  Widget buildDistrict() => TextFormField(
    maxLines: 1,
    initialValue: district,
    keyboardType: TextInputType.text,
    style: const TextStyle(
      color: AppColor.primary,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    ),
    decoration: const InputDecoration(
      labelText: 'الحي',
    ),
    onChanged: onChangedDistrict,
  );

  Widget buildCity() => TextFormField(
    maxLines: 1,
    initialValue: city,
    keyboardType: TextInputType.text,
    style: const TextStyle(
      color: AppColor.primary,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    ),
    decoration: const InputDecoration(
      labelText: 'المدينة',
    ),
    onChanged: onChangedCity,
  );

  Widget buildCountry() => TextFormField(
    maxLines: 1,
    initialValue: country,
    keyboardType: TextInputType.text,
    style: const TextStyle(
      color: AppColor.primary,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    ),
    decoration: const InputDecoration(
      labelText: 'البلد',
    ),
    onChanged: onChangedCountry,
  );

  Widget buildPostalCode() => TextFormField(
    maxLines: 1,
    initialValue: postalCode,
    keyboardType: TextInputType.text,
    style: const TextStyle(
      color: AppColor.primary,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    ),
    decoration: const InputDecoration(
      labelText: 'الرمز البريدي',
    ),
    onChanged: onChangedPostalCode,
  );

  Widget buildAdditionalNo() => TextFormField(
    maxLines: 1,
    initialValue: additionalNo,
    keyboardType: TextInputType.text,
    style: const TextStyle(
      color: AppColor.primary,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    ),
    decoration: const InputDecoration(
      labelText: 'الرقم الإضافي للعنوان',
    ),
    onChanged: onChangedAdditionalNo,
  );
  Widget buildVatNumber() => TextFormField(
    maxLines: 1,
    initialValue: vatNumber,
    keyboardType: TextInputType.number,
    style: const TextStyle(
      color: AppColor.primary,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    ),
    decoration: const InputDecoration(
      labelText: 'الرقم الضريبي',
    ),
    validator: (vatNumber) => vatNumber != null && vatNumber.isEmpty
        ? 'يجب أدخال الرقم الضريبي'
        : vatNumber!.length != 15
        ? 'يجب أدخال الرقم الضريبي مكون من 15 رقم'
        : null,
    onChanged: onChangedVatNumber,
  );

  static Future<String> getLogoFile() async {
    final byteData = await rootBundle.load('assets/images/logo.png');

    final file = File('${(await getTemporaryDirectory()).path}/logo.png');
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    final byte = file.readAsBytesSync();
    var base64 = base64Encode(byte);

    return base64;
  }

  Widget buildLogo() => logo != ''
      ? Image.memory(
    base64Decode(logo!),
    height: logoHeight!.toDouble(),
    width: logoWidth!.toDouble(),
    fit: BoxFit.fill,
  )
      : Image(
    image: const AssetImage('assets/images/logo.png'),
    height: logoHeight!.toDouble(),
    width: logoWidth!.toDouble(),
    fit: BoxFit.fill,
  );

  Widget buildTextLogo() => TextFormField(
    initialValue: logo,
    onChanged: onChangedLogo,
  );

  Widget buildShowVat() => Row(
    children: [
      Switch(
        value: showVat == 1 ? true : false,
        onChanged: onChangedShowVat,
      ),
      const Text(
        'إظهار الرقم الضريبي وضريبة القيمة المضافة',
        style: TextStyle(fontSize: 14),
      ),
    ],
  );

  Widget buildLogoWidth() => TextFormField(
    maxLines: 1,
    initialValue: logoWidth.toString(),
    keyboardType: TextInputType.number,
    style: const TextStyle(
      color: AppColor.primary,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    ),
    decoration: const InputDecoration(
      labelText: 'عرض الشعار',
    ),
    onChanged: onChangedLogoWidth,
  );

  Widget buildLogoHeight() => TextFormField(
    maxLines: 1,
    initialValue: logoHeight.toString(),
    keyboardType: TextInputType.number,
    style: const TextStyle(
      color: AppColor.primary,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    ),
    decoration: const InputDecoration(
      labelText: 'ارتفاع الشعار',
    ),
    onChanged: onChangedLogoHeight,
  );

  Widget buildSheetId() => TextFormField(
    minLines: 1,
    maxLines: 2,
    initialValue: sheetId,
    keyboardType: TextInputType.text,
    style: const TextStyle(
      color: AppColor.primary,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    ),
    decoration: const InputDecoration(
      labelText: 'معرف ملف قاعدة البيانات',
    ),
    // validator: (sheetId) => sheetId != null && sheetId.isEmpty
    //     ? 'يجب أدخال معرف ملف قاعدة البيانات'
    //     : null,
    onChanged: onChangedSheetId,
  );

  Widget buildWorkOffline() => Switch(
    value: workOffline == 1 ? true : false,
    onChanged: onChangedWorkOffline,
  );
}
