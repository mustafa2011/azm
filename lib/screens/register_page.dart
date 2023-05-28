import 'dart:convert';
import 'dart:io';
import 'package:fatoora/apis/constants/utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sprintf/sprintf.dart';
import '../widgets/widget.dart';
import '/apis/gsheets_api.dart';
import '/db/fatoora_db.dart';
import '/models/settings.dart';
import '/widgets/setting_form_widget.dart';
import '/widgets/app_colors.dart';
import '/widgets/loading.dart';
import 'package:get/get.dart';
import 'home_page.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();
  String name = ''; // Utils.defUserName;
  String email = ''; // Utils.defEmail;
  String password = ''; // Utils.defUserPassword;
  String cellphone = ''; // Utils.defCellphone;
  String seller = ''; // Utils.defSellerName;
  String buildingNo = ''; // Utils.defBuildingNo;
  String streetName = ''; // Utils.defStreetName;
  String district = ''; // Utils.defDistrict;
  String city = ''; // Utils.defCity;
  String country = ''; // Utils.defCountry;
  String postalCode = ''; // Utils.defPostcode;
  String additionalNo = ''; // Utils.defAdditionalNo;
  String vatNumber = ''; // Utils.defVatNumber;
  String logo = '';
  String defaultInvoiceTemp = '';
  String invoiceTemp1 = '';
  String invoiceTemp2 = '';
  String invoiceTemp3 = '';
  String invoiceTemp4 = '';
  String invoiceTemp5 = '';
  String terms = ''; // Utils.defTerms;
  int logoWidth = 75;
  int logoHeight = 75;
  String sheetId = Utils.defSheetId;
  int workOffline = 1;
  int showVat = 1;
  String printerName = ''; // Utils.defPrinterName;
  String paperSize = ''; // Utils.defPaperSize;
  String optionsCode = '';
  String defaultPayment = Utils.defPayMethod;
  String language = Utils.defLanguage;
  String freeText2 = Utils.defWhatsApp;
  String freeText3 = Utils.defShowPayMethod;
  String freeText4 = Utils.defDevice;
  String freeText5 = Utils.defActivity;
  String freeText6 = Utils.defSupportNumber;
  String freeText7 = '';
  String freeText8 = '';
  String freeText9 = '';
  String freeText10 = '';
  String activationCode = '';
  String startDateTime = DateTime.now().toString();
  String? appVersion = '';
  final TextEditingController _supportNumber = TextEditingController();

  @override
  void initState() {
    // FatooraDB.instance.close();
    getVersion();
    super.initState();
    _supportNumber.text = Utils.defSupportNumber;
    initNewSettings();
    initGSheet();
  }

  initNewSettings() async {
    await addNewSetting();
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

  initGSheet() async {
    await SheetApi.init();
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

  Widget buildSupportNumber() => SizedBox(
    width: 200,
    child: TextFormField(
      textAlign: TextAlign.center,
      keyboardType: const TextInputType.numberWithOptions(),
      controller: _supportNumber,
      autofocus: true,
      textDirection: TextDirection.ltr,
      onTap: () {
        var textValue = _supportNumber.text;
        _supportNumber.selection = TextSelection(
          baseOffset: 0,
          extentOffset: textValue.length,
        );
      },
      style: const TextStyle(
        color: AppColor.primary,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
      decoration: const InputDecoration(
        labelText: 'رقم الدعم الفني الحالي لصاحب البرنامج',
      ),
    ),
  );

  void updateSupportNumber() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          alignment: Alignment.topCenter,
          actionsAlignment: MainAxisAlignment.center,
          title: const Text('تغيير رقم الدعم الفني',
              style: TextStyle(
                  color: AppColor.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold)),
          content: SizedBox(
            height: 100,
            child: Column(
              children: [
                buildSupportNumber(),
                const Text('للتواصل ارسل واتساب',
                    style: TextStyle(
                        color: AppColor.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold))
              ],
            ),
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            TextButton(
              child: const Text("موافق"),
              onPressed: () {
                setState(() {
                  freeText6 = _supportNumber.text;
                });
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
    double w = MediaQuery.of(context).size.width;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Center(
            child: Text(
              'تسجيل مستخدم جديد',
              style: TextStyle(
                  color: AppColor.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            ),
          ),
          actions: [
            PopupMenuButton(
              tooltip: 'القائمة',
              itemBuilder: (context) {
                return [
                  const PopupMenuItem<int>(
                    value: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('تسجيل',
                            style: TextStyle(
                                color: AppColor.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.bold)),
                        Icon(
                          Icons.app_registration,
                          color: AppColor.primary,
                          size: 30,
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuItem<int>(
                    value: 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('رقم الدعم الفني',
                            style: TextStyle(
                                color: AppColor.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.bold)),
                        Icon(
                          Icons.phone,
                          color: AppColor.primary,
                          size: 30,
                        ),
                      ],
                    ),
                  ),
                ];
              },
              onSelected: (value) async {
                switch (value) {
                  case 0:
                    setState(() => isLoading = true);
                    await addNewSetting();
                    setState(() => isLoading = false);
                    break;
                  case 1:
                    File? customImageFile;
                    if (Platform.isWindows) {
                      var image = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['jpg', 'png', 'jpeg'],
                      );
                      customImageFile = image != null
                          ? File(image.files.first.path.toString())
                          : File(
                          '${(await getTemporaryDirectory()).path}/logo.png');
                    } else {
                      var img = await ImagePicker()
                          .pickImage(source: ImageSource.gallery);
                      customImageFile = File(img!.path);
                    }
                    String imgString =
                    Utils.base64String(customImageFile.readAsBytesSync());
                    setState(() {
                      logo = imgString;
                    });
                    final byteData =
                    await rootBundle.load('assets/images/logo.png');

                    customImageFile = File(
                        '${(await getTemporaryDirectory()).path}/logo.png');
                    customImageFile.writeAsBytes(byteData.buffer.asUint8List(
                        byteData.offsetInBytes, byteData.lengthInBytes));
                    break;
                  case 2:
                    updateSupportNumber();
                    break;
                  default:
                    break;
                }
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  width: w,
                  child: isLoading
                      ? const Loading()
                      : Column(
                    children: [
                      Form(
                        key: _formKey,
                        child: RegisterFormWidget(
                          name: name,
                          email: email,
                          password: password,
                          cellphone: cellphone,
                          seller: seller,
                          buildingNo: buildingNo,
                          streetName: streetName,
                          district: district,
                          city: city,
                          country: country,
                          postalCode: postalCode,
                          additionalNo: additionalNo,
                          vatNumber: vatNumber,
                          startDateTime: startDateTime,
                          logo: logo,
                          terms: terms,
                          logoWidth: logoWidth,
                          logoHeight: logoHeight,
                          workOffline: workOffline,
                          showVat: showVat,
                          onChangedName: (name) =>
                              setState(() => this.name = name),
                          onChangedEmail: (email) =>
                              setState(() => this.email = email),
                          onChangedPassword: (password) =>
                              setState(() => this.password = password),
                          onChangedCellphone: (cellphone) =>
                              setState(() => this.cellphone = cellphone),
                          onChangedSeller: (seller) =>
                              setState(() => this.seller = seller),
                          onChangedBuildingNo: (buildingNo) =>
                              setState(() => this.buildingNo = buildingNo),
                          onChangedStreetName: (streetName) =>
                              setState(() => this.streetName = streetName),
                          onChangedDistrict: (district) =>
                              setState(() => this.district = district),
                          onChangedCity: (city) =>
                              setState(() => this.city = city),
                          onChangedCountry: (country) =>
                              setState(() => this.country = country),
                          onChangedPostalCode: (postalCode) =>
                              setState(() => this.postalCode = postalCode),
                          onChangedAdditionalNo: (additionalNo) =>
                              setState(() => this.additionalNo = additionalNo),
                          onChangedVatNumber: (vatNumber) =>
                              setState(() => this.vatNumber = vatNumber),
                          onChangedSheetId: (sheetId) =>
                              setState(() => this.sheetId = sheetId),
                          onChangedLogo: (logo) =>
                              setState(() => this.logo = logo),
                          onChangedTerms: (terms) =>
                              setState(() => this.terms = terms),
                          onChangedLogoWidth: (logoWidth) => setState(
                                  () => this.logoWidth = int.parse(logoWidth)),
                          onChangedLogoHeight: (logoHeight) => setState(
                                  () => this.logoHeight = int.parse(logoHeight)),
                          onChangedWorkOffline: (workOffline) {},
                          onChangedShowVat: (value) =>
                              setState(() => showVat = value ? 1 : 0),
                        ),
                      ),
                      Utils.space(4, 0),
                      SizedBox(
                        width: 150,
                        child: NewButton(
                          icon: Icons.app_registration,
                          text: 'تسجيل',
                          fontSize: 16,
                          iconSize: 30,
                          padding: 15,
                          radius: 30,
                          onTap: () async {
                            setState(() => isLoading = true);
                            await addNewSetting();
                            setState(() => isLoading = false);
                          },
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ));
  }

  Future<File> getLogoFile() async {
    final byteData = await rootBundle.load('assets/images/logo.png');

    final file = File('${(await getTemporaryDirectory()).path}/logo.png');
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }

  Future<File> getDefaultInvoiceTemp() async {
    final byteData = await rootBundle.load('assets/images/defaultInvoiceTemp.png');
    final file = File('${(await getTemporaryDirectory()).path}/defaultInvoiceTemp.png');
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    return file;
  }

  Future<File> getInvoiceTemp1() async {
    final byteData = await rootBundle.load('assets/images/invoiceTemp1.png');

    final file = File('${(await getTemporaryDirectory()).path}/invoiceTemp1.png');
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }

  Future<File> getInvoiceTemp2() async {
    final byteData = await rootBundle.load('assets/images/invoiceTemp2.png');

    final file = File('${(await getTemporaryDirectory()).path}/invoiceTemp2.png');
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }

  Future<File> getInvoiceTemp3() async {
    final byteData = await rootBundle.load('assets/images/invoiceTemp3.png');

    final file = File('${(await getTemporaryDirectory()).path}/invoiceTemp3.png');
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }

  Future<File> getInvoiceTemp4() async {
    final byteData = await rootBundle.load('assets/images/invoiceTemp4.png');

    final file = File('${(await getTemporaryDirectory()).path}/invoiceTemp4.png');
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }

  Future<File> getInvoiceTemp5() async {
    final byteData = await rootBundle.load('assets/images/invoiceTemp5.png');

    final file = File('${(await getTemporaryDirectory()).path}/invoiceTemp5.png');
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }


  Future addNewSetting() async {
    final isValid = _formKey.currentState?.validate();
    if (isValid == null
        ? false
        : true &&
        cellphone.isNotEmpty &&
        name.isNotEmpty &&
        seller.isNotEmpty &&
        email.isNotEmpty &&
        vatNumber.isNotEmpty) {
      int newId = await SheetApi.getRowCount() + 1;
      if (logo == '') {
        File f = await getLogoFile();
        final byte = f.readAsBytesSync();
        logo = base64Encode(byte);
      }
      if (defaultInvoiceTemp == '') {
        File f = await getDefaultInvoiceTemp();
        final byte = f.readAsBytesSync();
        defaultInvoiceTemp = base64Encode(byte);
      }
      if (invoiceTemp1 == '') {
        File f = await getInvoiceTemp1();
        final byte = f.readAsBytesSync();
        invoiceTemp1 = base64Encode(byte);
      }
      if (invoiceTemp2 == '') {
        File f = await getInvoiceTemp2();
        final byte = f.readAsBytesSync();
        invoiceTemp2 = base64Encode(byte);
      }
      if (invoiceTemp3 == '') {
        File f = await getInvoiceTemp3();
        final byte = f.readAsBytesSync();
        invoiceTemp3 = base64Encode(byte);
      }
      if (invoiceTemp4 == '') {
        File f = await getInvoiceTemp4();
        final byte = f.readAsBytesSync();
        invoiceTemp4 = base64Encode(byte);
      }
      if (invoiceTemp5 == '') {
        File f = await getInvoiceTemp5();
        final byte = f.readAsBytesSync();
        invoiceTemp5 = base64Encode(byte);
      }
      dynamic user = Setting(
        id: newId,
        name: name,
        email: email,
        password: '', // '${password}appVersion=$appVersion',
        cellphone: cellphone,
        seller: seller,
        buildingNo: buildingNo,
        streetName: streetName,
        district: district,
        city: city,
        country: country,
        postalCode: postalCode,
        additionalNo: additionalNo,
        vatNumber: vatNumber,
        logo: logo,
        invoiceTemp1: invoiceTemp1,
        invoiceTemp2: invoiceTemp2,
        invoiceTemp3: invoiceTemp3,
        invoiceTemp4: invoiceTemp4,
        invoiceTemp5: invoiceTemp5,
        terms: terms,
        logoWidth: logoWidth,
        logoHeight: logoHeight,
        sheetId: sheetId,
        workOffline: workOffline,
        showVat: showVat,
        activationCode: '',
        startDateTime: DateTime.now().toString(),
        printerName: printerName,
        paperSize: paperSize,
        optionsCode: optionsCode,
        defaultPayment: defaultPayment,
        language: language,
        freeText2: freeText2, // assigned for Whatsapp
        freeText3: freeText3, // assigned for ShowPayMethod
        freeText4: freeText4, // assigned for Device
        freeText5: freeText5, // assigned for Activity
        freeText6: freeText6, // assigned for SupportNumber
        freeText7: freeText7,
        freeText8: freeText8,
        freeText9: freeText9,
        freeText10: freeText10,
      );
      await FatooraDB.instance.createSetting(user);

      setState(() {
        activationCode = toHex(int.parse(cellphone) +
            newId +
            (DateTime.now().month + 1) +
            DateTime.now().year);
        startDateTime = DateTime.now().toString();
      });

      dynamic client = [
        {
          'id': newId,
          'name': name,
          'email': email,
          'password': 'appVersion=$appVersion', // '${password}appVersion=$appVersion',
          'cellphone': cellphone,
          'seller': seller,
          'vatNumber': vatNumber,
          'sheetId': sheetId,
          'activationCode': activationCode,
          'startDateTime': DateTime.now().toString(),
          'paidAmount': 0,
        }
      ];
      await SheetApi.insertNewClient(client);

      Get.to(() => const HomePage());
    }
  }
  void getVersion() async{
    final dbVersion = await Utils.dbVersion();
    final pkgVersion = Platform.isWindows
        ? '${Platform.operatingSystem}[$dbVersion]'
        : '${(await PackageInfo.fromPlatform()).version}[$dbVersion]';
    setState(() {
      appVersion = pkgVersion;
    });
  }
}
