import 'dart:io';

import 'package:fatoora/screens/template_page.dart';

import '../apis/constants/utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:whatsapp_share2/whatsapp_share2.dart';
import '/db/fatoora_db.dart';
import '/models/settings.dart';
import '/widgets/app_colors.dart';
import '/widgets/loading.dart';
import '/widgets/setting_form_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'home_page.dart';

class SettingsPage extends StatefulWidget {
  final bool? validLicense;
  const SettingsPage({
    Key? key,
    this.validLicense
  }) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late List<Setting> setting;
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();
  int? uid;
  String name = '';
  String email = '';
  String password = '';
  String cellphone = '';
  String seller = '';
  String buildingNo = '';
  String streetName = '';
  String district = '';
  String city = '';
  String country = '';
  String postalCode = '';
  String additionalNo = '';
  String vatNumber = '';
  String logo = '';
  String defaultInvoiceTemp = '';
  String invoiceTemp1 = '';
  String invoiceTemp2 = '';
  String invoiceTemp3 = '';
  String invoiceTemp4 = '';
  String invoiceTemp5 = '';
  String terms = '';
  String terms1 = '';
  String terms2 = '';
  String terms3 = '';
  String terms4 = '';
  int logoWidth = 75;
  int logoHeight = 75;
  String sheetId = '';
  int workOffline = 1;
  String activationCode = '';
  String? startDateTime;
  int showVat = 1;
  String printerName = '';
  String paperSize = '';
  String optionsCode = '';
  String defaultPayment = '';
  String language = '';
  String freeText2 = 'واتساب'; // reserved for whatsapp
  String freeText3 = 'اظهار'; // reserved for show/hide payMethod
  String freeText4 = '';
  String freeText5 = '';
  String freeText6 = '';
  String freeText7 = '';
  String freeText8 = '';
  String freeText9 = '';
  String freeText10 = '';

  @override
  void initState() {
    super.initState();
    getSetting();
  }

  Future getSetting() async {
    setState(() => isLoading = true);
    Directory? appDirectory;
    if (Platform.isAndroid) {
      appDirectory = await getExternalStorageDirectory();
    } else {
      appDirectory = await getApplicationDocumentsDirectory();
    }
    String newDbFile = '${appDirectory!.path}/Fatoora/Database/$uid.db';
    FatooraDB db = FatooraDB.instance;
    await db.initNewDb(newDbFile);

    setting = await db.getAllSettings();

    setState(() {
      uid = setting[0].id as int;
      name = setting[0].name;
      email = setting[0].email;
      password = setting[0].password.split('appVersion')[0];
      cellphone = setting[0].cellphone;
      seller = setting[0].seller;
      buildingNo = setting[0].buildingNo;
      streetName = setting[0].streetName;
      district = setting[0].district;
      city = setting[0].city;
      country = setting[0].country;
      postalCode = setting[0].postalCode;
      additionalNo = setting[0].additionalNo;
      vatNumber = setting[0].vatNumber;
      logo = setting[0].logo;
      invoiceTemp1 = setting[0].invoiceTemp1;
      invoiceTemp2 = setting[0].invoiceTemp2;
      invoiceTemp3 = setting[0].invoiceTemp3;
      invoiceTemp4 = setting[0].invoiceTemp4;
      invoiceTemp5 = setting[0].invoiceTemp5;
      terms = setting[0].terms;
      terms1 = setting[0].terms1;
      terms2 = setting[0].terms2;
      terms3 = setting[0].terms3;
      terms4 = setting[0].terms4;
      logoWidth = setting[0].logoWidth;
      logoHeight = setting[0].logoHeight;
      sheetId = setting[0].sheetId;
      workOffline = setting[0].workOffline;
      showVat = setting[0].showVat;
      startDateTime = setting[0].startDateTime;
      activationCode = setting[0].activationCode;
      printerName = setting[0].printerName;
      paperSize = setting[0].paperSize;
      optionsCode = setting[0].optionsCode;
      defaultPayment = setting[0].defaultPayment;
      language = setting[0].language;
      freeText2 = setting[0].freeText2;
      freeText3 = setting[0].freeText3;
      freeText4 = setting[0].freeText4;
      freeText5 = setting[0].freeText5;
      freeText6 = setting[0].freeText6;
      freeText7 = setting[0].freeText7;
      freeText8 = setting[0].freeText8;
      freeText9 = setting[0].freeText9;
      freeText10 = setting[0].freeText10;
    });

    setState(() => isLoading = false);
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

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    return Scaffold(
        // resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Center(
            child: Text('شاشة الإعدادات',
                style: TextStyle(
                    color: AppColor.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18)),
          ),
          actions: [
            Utils.isDefaultProject
            ? PopupMenuButton(
              tooltip: 'القائمة',
              itemBuilder: (context) {
                return [
                  const PopupMenuItem<int>(
                    value: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('حفظ الاعدادات',
                            style: TextStyle(
                                color: AppColor.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.bold)),
                        Icon(
                          Icons.save,
                          color: AppColor.primary,
                          size: 30,
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuItem<int>(
                    value: 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('تغيير الشعار',
                            style: TextStyle(
                                color: AppColor.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.bold)),
                        Icon(
                          Icons.assistant_photo,
                          color: AppColor.primary,
                          size: 30,
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuItem<int>(
                      height: 2, enabled: false, child: Divider(thickness: 2)),
                  const PopupMenuItem<int>(
                    value: 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('الصفحة الرئيسية',
                            style: TextStyle(
                                color: AppColor.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.bold)),
                        Icon(
                          Icons.home,
                          color: AppColor.primary,
                          size: 30,
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuItem<int>(
                    value: 3,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('نسخ قواعد البيانات',
                            style: TextStyle(
                                color: AppColor.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.bold)),
                        Icon(
                          Icons.share,
                          // Icons.backup,
                          color: AppColor.primary,
                          size: 30,
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuItem<int>(
                      height: 2, enabled: false, child: Divider(thickness: 2)),
                  const PopupMenuItem<int>(
                    value: 4,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('تغيير نموذج الفاتورة',
                            style: TextStyle(
                                color: AppColor.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.bold)),
                        Icon(
                          Icons.note,
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
                    await updateSetting();
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
                    Get.to(() => const HomePage());
                    break;
                  case 3:
                    await backupDatabase('fatoora_$uid.db');
                    break;
                  case 4:
                    File? customImageFile;
                    if (Platform.isWindows) {
                      var image = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['jpg', 'png', 'jpeg'],
                      );
                      customImageFile = image != null
                          ? File(image.files.first.path.toString())
                          : File(
                          '${(await getTemporaryDirectory()).path}defaultInvoiceTemp.png');
                    } else {
                      var img = await ImagePicker()
                          .pickImage(source: ImageSource.gallery);
                      customImageFile = File(img!.path);
                    }
                    String imgString =
                    Utils.base64String(customImageFile.readAsBytesSync());
                    setState(() {
                      defaultInvoiceTemp = imgString;
                    });
                    final byteData = await rootBundle
                        .load('assets/images/defaultInvoiceTemp.png');

                    customImageFile = File(
                        '${(await getTemporaryDirectory()).path}/defaultInvoiceTemp.png');
                    customImageFile.writeAsBytes(byteData.buffer.asUint8List(
                        byteData.offsetInBytes, byteData.lengthInBytes));
                    break;
                  case 5:
                    File? customImageFile;
                    if (Platform.isWindows) {
                      var image = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['jpg', 'png', 'jpeg'],
                      );
                      customImageFile = image != null
                          ? File(image.files.first.path.toString())
                          : File(
                          '${(await getTemporaryDirectory()).path}invoiceTemp1.png');
                    } else {
                      var img = await ImagePicker()
                          .pickImage(source: ImageSource.gallery);
                      customImageFile = File(img!.path);
                    }
                    String imgString =
                    Utils.base64String(customImageFile.readAsBytesSync());
                    setState(() {
                      invoiceTemp1 = imgString;
                    });
                    final byteData = await rootBundle
                        .load('assets/images/invoiceTemp1.png');

                    customImageFile = File(
                        '${(await getTemporaryDirectory()).path}/invoiceTemp1.png');
                    customImageFile.writeAsBytes(byteData.buffer.asUint8List(
                        byteData.offsetInBytes, byteData.lengthInBytes));
                    break;
                  case 6:
                    File? customImageFile;
                    if (Platform.isWindows) {
                      var image = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['jpg', 'png', 'jpeg'],
                      );
                      customImageFile = image != null
                          ? File(image.files.first.path.toString())
                          : File(
                          '${(await getTemporaryDirectory()).path}invoiceTemp2.png');
                    } else {
                      var img = await ImagePicker()
                          .pickImage(source: ImageSource.gallery);
                      customImageFile = File(img!.path);
                    }
                    String imgString =
                    Utils.base64String(customImageFile.readAsBytesSync());
                    setState(() {
                      invoiceTemp2 = imgString;
                    });
                    final byteData = await rootBundle
                        .load('assets/images/invoiceTemp2.png');

                    customImageFile = File(
                        '${(await getTemporaryDirectory()).path}/invoiceTemp2.png');
                    customImageFile.writeAsBytes(byteData.buffer.asUint8List(
                        byteData.offsetInBytes, byteData.lengthInBytes));
                    break;
                  case 7:
                    File? customImageFile;
                    if (Platform.isWindows) {
                      var image = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['jpg', 'png', 'jpeg'],
                      );
                      customImageFile = image != null
                          ? File(image.files.first.path.toString())
                          : File(
                          '${(await getTemporaryDirectory()).path}invoiceTemp3.png');
                    } else {
                      var img = await ImagePicker()
                          .pickImage(source: ImageSource.gallery);
                      customImageFile = File(img!.path);
                    }
                    String imgString =
                    Utils.base64String(customImageFile.readAsBytesSync());
                    setState(() {
                      invoiceTemp3 = imgString;
                    });
                    final byteData = await rootBundle
                        .load('assets/images/invoiceTemp3.png');

                    customImageFile = File(
                        '${(await getTemporaryDirectory()).path}/invoiceTemp3.png');
                    customImageFile.writeAsBytes(byteData.buffer.asUint8List(
                        byteData.offsetInBytes, byteData.lengthInBytes));
                    break;
                  case 8:
                    File? customImageFile;
                    if (Platform.isWindows) {
                      var image = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['jpg', 'png', 'jpeg'],
                      );
                      customImageFile = image != null
                          ? File(image.files.first.path.toString())
                          : File(
                          '${(await getTemporaryDirectory()).path}invoiceTemp4.png');
                    } else {
                      var img = await ImagePicker()
                          .pickImage(source: ImageSource.gallery);
                      customImageFile = File(img!.path);
                    }
                    String imgString =
                    Utils.base64String(customImageFile.readAsBytesSync());
                    setState(() {
                      invoiceTemp4 = imgString;
                    });
                    final byteData = await rootBundle
                        .load('assets/images/invoiceTemp4.png');

                    customImageFile = File(
                        '${(await getTemporaryDirectory()).path}/invoiceTemp4.png');
                    customImageFile.writeAsBytes(byteData.buffer.asUint8List(
                        byteData.offsetInBytes, byteData.lengthInBytes));
                    break;
                  case 9:
                    File? customImageFile;
                    if (Platform.isWindows) {
                      var image = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['jpg', 'png', 'jpeg'],
                      );
                      customImageFile = image != null
                          ? File(image.files.first.path.toString())
                          : File(
                          '${(await getTemporaryDirectory()).path}invoiceTemp5.png');
                    } else {
                      var img = await ImagePicker()
                          .pickImage(source: ImageSource.gallery);
                      customImageFile = File(img!.path);
                    }
                    String imgString =
                    Utils.base64String(customImageFile.readAsBytesSync());
                    setState(() {
                      invoiceTemp5 = imgString;
                    });
                    final byteData = await rootBundle
                        .load('assets/images/invoiceTemp5.png');

                    customImageFile = File(
                        '${(await getTemporaryDirectory()).path}/invoiceTemp5.png');
                    customImageFile.writeAsBytes(byteData.buffer.asUint8List(
                        byteData.offsetInBytes, byteData.lengthInBytes));
                    break;
                  default:
                    break;
                }
              },
            )
            : PopupMenuButton(
              tooltip: 'القائمة',
              itemBuilder: (context) {
                return [
                  const PopupMenuItem<int>(
                    value: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('حفظ الاعدادات',
                            style: TextStyle(
                                color: AppColor.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.bold)),
                        Icon(
                          Icons.save,
                          color: AppColor.primary,
                          size: 30,
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuItem<int>(
                    value: 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('تغيير الشعار',
                            style: TextStyle(
                                color: AppColor.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.bold)),
                        Icon(
                          Icons.assistant_photo,
                          color: AppColor.primary,
                          size: 30,
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuItem<int>(
                      height: 2, enabled: false, child: Divider(thickness: 2)),
                  const PopupMenuItem<int>(
                    value: 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('الصفحة الرئيسية',
                            style: TextStyle(
                                color: AppColor.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.bold)),
                        Icon(
                          Icons.home,
                          color: AppColor.primary,
                          size: 30,
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuItem<int>(
                    value: 3,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('نسخ قواعد البيانات',
                            style: TextStyle(
                                color: AppColor.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.bold)),
                        Icon(
                          Icons.share,
                          // Icons.backup,
                          color: AppColor.primary,
                          size: 30,
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuItem<int>(
                      height: 1, enabled: false, child: Divider(thickness: 1)),
                  const PopupMenuItem<int>(
                    value: 5,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('تغيير نموذج 1',
                            style: TextStyle(
                                color: AppColor.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.bold)),
                        Icon(
                          Icons.note,
                          color: AppColor.primary,
                          size: 30,
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuItem<int>(
                    value: 6,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('تغيير نموذج 2',
                            style: TextStyle(
                                color: AppColor.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.bold)),
                        Icon(
                          Icons.note,
                          color: AppColor.primary,
                          size: 30,
                        ),
                      ],
                    ),
                  ),
                  /*const PopupMenuItem<int>(
                    value: 7,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('تغيير نموذج 3',
                            style: TextStyle(
                                color: AppColor.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.bold)),
                        Icon(
                          Icons.note,
                          color: AppColor.primary,
                          size: 30,
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuItem<int>(
                    value: 8,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('تغيير نموذج 4',
                            style: TextStyle(
                                color: AppColor.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.bold)),
                        Icon(
                          Icons.note,
                          color: AppColor.primary,
                          size: 30,
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuItem<int>(
                    value: 9,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('تغيير نموذج 5',
                            style: TextStyle(
                                color: AppColor.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.bold)),
                        Icon(
                          Icons.note,
                          color: AppColor.primary,
                          size: 30,
                        ),
                      ],
                    ),
                  ),*/
                  const PopupMenuItem<int>(
                      height: 1, enabled: false, child: Divider(thickness: 1)),
                  const PopupMenuItem<int>(
                    value: 10,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('مصمم النماذج',
                            style: TextStyle(
                                color: AppColor.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.bold)),
                        Icon(
                          Icons.compare_arrows,
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
                    await updateSetting();
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
                    Get.to(() => const HomePage());
                    break;
                  case 3:
                    await backupDatabase('fatoora_$uid.db');
                    break;
                  case 4:
                    File? customImageFile;
                    if (Platform.isWindows) {
                      var image = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['jpg', 'png', 'jpeg'],
                      );
                      customImageFile = image != null
                          ? File(image.files.first.path.toString())
                          : File(
                          '${(await getTemporaryDirectory()).path}defaultInvoiceTemp.png');
                    } else {
                      var img = await ImagePicker()
                          .pickImage(source: ImageSource.gallery);
                      customImageFile = File(img!.path);
                    }
                    String imgString =
                    Utils.base64String(customImageFile.readAsBytesSync());
                    setState(() {
                      defaultInvoiceTemp = imgString;
                    });
                    final byteData = await rootBundle
                        .load('assets/images/defaultInvoiceTemp.png');

                    customImageFile = File(
                        '${(await getTemporaryDirectory()).path}/defaultInvoiceTemp.png');
                    customImageFile.writeAsBytes(byteData.buffer.asUint8List(
                        byteData.offsetInBytes, byteData.lengthInBytes));
                    break;
                  case 5:
                    File? customImageFile;
                    if (Platform.isWindows) {
                      var image = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['jpg', 'png', 'jpeg'],
                      );
                      customImageFile = image != null
                          ? File(image.files.first.path.toString())
                          : File(
                          '${(await getTemporaryDirectory()).path}invoiceTemp1.png');
                    } else {
                      var img = await ImagePicker()
                          .pickImage(source: ImageSource.gallery);
                      customImageFile = File(img!.path);
                    }
                    String imgString =
                    Utils.base64String(customImageFile.readAsBytesSync());
                    setState(() {
                      invoiceTemp1 = imgString;
                    });
                    final byteData = await rootBundle
                        .load('assets/images/invoiceTemp1.png');

                    customImageFile = File(
                        '${(await getTemporaryDirectory()).path}/invoiceTemp1.png');
                    customImageFile.writeAsBytes(byteData.buffer.asUint8List(
                        byteData.offsetInBytes, byteData.lengthInBytes));
                    break;
                  case 6:
                    File? customImageFile;
                    if (Platform.isWindows) {
                      var image = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['jpg', 'png', 'jpeg'],
                      );
                      customImageFile = image != null
                          ? File(image.files.first.path.toString())
                          : File(
                          '${(await getTemporaryDirectory()).path}invoiceTemp2.png');
                    } else {
                      var img = await ImagePicker()
                          .pickImage(source: ImageSource.gallery);
                      customImageFile = File(img!.path);
                    }
                    String imgString =
                    Utils.base64String(customImageFile.readAsBytesSync());
                    setState(() {
                      invoiceTemp2 = imgString;
                    });
                    final byteData = await rootBundle
                        .load('assets/images/invoiceTemp2.png');

                    customImageFile = File(
                        '${(await getTemporaryDirectory()).path}/invoiceTemp2.png');
                    customImageFile.writeAsBytes(byteData.buffer.asUint8List(
                        byteData.offsetInBytes, byteData.lengthInBytes));
                    break;
                  case 7:
                    File? customImageFile;
                    if (Platform.isWindows) {
                      var image = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['jpg', 'png', 'jpeg'],
                      );
                      customImageFile = image != null
                          ? File(image.files.first.path.toString())
                          : File(
                          '${(await getTemporaryDirectory()).path}invoiceTemp3.png');
                    } else {
                      var img = await ImagePicker()
                          .pickImage(source: ImageSource.gallery);
                      customImageFile = File(img!.path);
                    }
                    String imgString =
                    Utils.base64String(customImageFile.readAsBytesSync());
                    setState(() {
                      invoiceTemp3 = imgString;
                    });
                    final byteData = await rootBundle
                        .load('assets/images/invoiceTemp3.png');

                    customImageFile = File(
                        '${(await getTemporaryDirectory()).path}/invoiceTemp3.png');
                    customImageFile.writeAsBytes(byteData.buffer.asUint8List(
                        byteData.offsetInBytes, byteData.lengthInBytes));
                    break;
                  case 8:
                    File? customImageFile;
                    if (Platform.isWindows) {
                      var image = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['jpg', 'png', 'jpeg'],
                      );
                      customImageFile = image != null
                          ? File(image.files.first.path.toString())
                          : File(
                          '${(await getTemporaryDirectory()).path}invoiceTemp4.png');
                    } else {
                      var img = await ImagePicker()
                          .pickImage(source: ImageSource.gallery);
                      customImageFile = File(img!.path);
                    }
                    String imgString =
                    Utils.base64String(customImageFile.readAsBytesSync());
                    setState(() {
                      invoiceTemp4 = imgString;
                    });
                    final byteData = await rootBundle
                        .load('assets/images/invoiceTemp4.png');

                    customImageFile = File(
                        '${(await getTemporaryDirectory()).path}/invoiceTemp4.png');
                    customImageFile.writeAsBytes(byteData.buffer.asUint8List(
                        byteData.offsetInBytes, byteData.lengthInBytes));
                    break;
                  case 9:
                    File? customImageFile;
                    if (Platform.isWindows) {
                      var image = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['jpg', 'png', 'jpeg'],
                      );
                      customImageFile = image != null
                          ? File(image.files.first.path.toString())
                          : File(
                          '${(await getTemporaryDirectory()).path}invoiceTemp5.png');
                    } else {
                      var img = await ImagePicker()
                          .pickImage(source: ImageSource.gallery);
                      customImageFile = File(img!.path);
                    }
                    String imgString =
                    Utils.base64String(customImageFile.readAsBytesSync());
                    setState(() {
                      invoiceTemp5 = imgString;
                    });
                    final byteData = await rootBundle
                        .load('assets/images/invoiceTemp5.png');

                    customImageFile = File(
                        '${(await getTemporaryDirectory()).path}/invoiceTemp5.png');
                    customImageFile.writeAsBytes(byteData.buffer.asUint8List(
                        byteData.offsetInBytes, byteData.lengthInBytes));
                    break;
                  case 10:
                    Get.to(() => const TemplatePage());
                    break;
                  default:
                    break;
                }
              },
            ),
          ],
          leading: Container(),
        ),
        body: Container(
          width: w,
          color: AppColor.background,
          child: Column(
            children: [
              Expanded(
                  child: Container(
                padding: const EdgeInsets.all(10),
                width: w,
                child: isLoading
                    ? const Loading()
                    : Form(
                        key: _formKey,
                        child: SettingFormWidget(
                          id: uid,
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
                          activationCode: activationCode,
                          logo: logo,
                          validLicense: widget.validLicense ?? false,
                          defaultInvoiceTemp: defaultInvoiceTemp,
                          invoiceTemp1: invoiceTemp1,
                          invoiceTemp2: invoiceTemp2,
                          invoiceTemp3: invoiceTemp3,
                          invoiceTemp4: invoiceTemp4,
                          invoiceTemp5: invoiceTemp5,
                          terms: terms,
                          terms1: terms1,
                          terms2: terms2,
                          terms3: terms3,
                          terms4: terms4,
                          logoWidth: logoWidth,
                          logoHeight: logoHeight,
                          workOffline: workOffline,
                          showVat: showVat,
                          printerName: printerName,
                          language: language,
                          freeText2: freeText2,
                          freeText3: freeText3,
                          freeText4: freeText4,
                          freeText5: freeText5,
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
                          onChangedActivationCode: (activationCode) => setState(
                              () => this.activationCode = activationCode),
                          onChangedLogo: (logo) =>
                              setState(() => this.logo = logo),
                          onChangedDefaultInvoiceTemp: (tmp) =>
                              setState(() => defaultInvoiceTemp = tmp),
                          onChangedInvoiceTemp1: (val) =>
                              setState(() => invoiceTemp1 = val),
                          onChangedInvoiceTemp2: (val) =>
                              setState(() => invoiceTemp2 = val),
                          onChangedInvoiceTemp3: (val) =>
                              setState(() => invoiceTemp3 = val),
                          onChangedInvoiceTemp4: (val) =>
                              setState(() => invoiceTemp4 = val),
                          onChangedInvoiceTemp5: (val) =>
                              setState(() => invoiceTemp5 = val),
                          onChangedTerms: (val) => setState(() => terms = val),
                          onChangedTerms1: (val) =>
                              setState(() => terms1 = val),
                          onChangedTerms2: (val) =>
                              setState(() => terms2 = val),
                          onChangedTerms3: (val) =>
                              setState(() => terms3 = val),
                          onChangedTerms4: (val) =>
                              setState(() => terms4 = val),
                          onChangedLogoWidth: (val) =>
                              setState(() => logoWidth = int.parse(val)),
                          onChangedLogoHeight: (val) =>
                              setState(() => logoHeight = int.parse(val)),
                          onChangedWorkOffline: (val) {},
                          onChangedShowVat: (val) =>
                              setState(() => showVat = val ? 1 : 0),
                          onChangedPrinterName: (printerName) =>
                              setState(() => this.printerName = printerName),
                          onChangedLanguage: (val) =>
                              setState(() => language = val!),
                          onChangedFreeText2: (val) =>
                              setState(() => freeText2 = val!),
                          onChangedFreeText3: (val) =>
                              setState(() => freeText3 = val!),
                          onChangedFreeText4: (val) =>
                              setState(() => freeText4 = val!),
                          onChangedFreeText5: (val) =>
                              setState(() => freeText5 = val!),
                        ),
                      ),
              )),
            ],
          ),
        ));
  }

  Future<File> getLogoFile(ByteData byteData) async {
    final byteData = await rootBundle.load('assets/images/logo.png');

    final file = File('${(await getTemporaryDirectory()).path}/logo.png');
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }

  Future updateSetting() async {
    FatooraDB db = FatooraDB.instance;
    final isValid = _formKey.currentState?.validate();
    try {
      if (isValid == null
          ? false
          : true &&
              cellphone.isNotEmpty &&
              name.isNotEmpty &&
              seller.isNotEmpty &&
              email.isNotEmpty &&
              vatNumber.isNotEmpty) {
        var user = Setting(
          id: uid,
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
          logo: logo,
          invoiceTemp1: invoiceTemp1,
          invoiceTemp2: invoiceTemp2,
          invoiceTemp3: invoiceTemp3,
          invoiceTemp4: invoiceTemp4,
          invoiceTemp5: invoiceTemp5,
          terms: terms,
          terms1: terms1,
          terms2: terms2,
          terms3: terms3,
          terms4: terms4,
          logoWidth: logoWidth,
          logoHeight: logoHeight,
          sheetId: sheetId,
          workOffline: workOffline,
          showVat: showVat,
          activationCode: activationCode,
          startDateTime: startDateTime!,
          printerName: printerName,
          paperSize: paperSize,
          optionsCode: optionsCode,
          defaultPayment: defaultPayment,
          language: language,
          freeText2: freeText2,
          freeText3: freeText3,
          freeText4: freeText4,
          freeText5: freeText5,
          freeText6: freeText6.isEmpty ? Utils.defSupportNumber : freeText6,
          freeText7: freeText7,
          freeText8: freeText8,
          freeText9: freeText9,
          freeText10: freeText10,
        );
        await db.updateSetting(user);
        Get.to(() => const HomePage());
      }
    } on Exception catch (e) {
      throw Exception(e);
      // messageBox("تأكد من وجود اتصال بالانترنت\n$e");
    }
  }

  Future<void> backupDatabase(String filename) async {
    Directory? appDirectory;
    if (Platform.isAndroid) {
      appDirectory = await getExternalStorageDirectory();
    } else {
      appDirectory = await getApplicationDocumentsDirectory();
    }
    String source = Platform.isAndroid
        ? "${appDirectory!.path}/Fatoora/Database/fatoora.db"
        : "${appDirectory!.path}\\Fatoora\\Database\\fatoora.db";
    String backup = Platform.isAndroid
        ? "${appDirectory.path}/Fatoora/Database/$filename"
        : "${appDirectory.path}\\Fatoora\\Database\\$filename";
    await File(source).copy(backup);
    if (Platform.isWindows) {
      messageBox('تم نسخ البيانات بنجاح تحت المسار:\n$backup');
      /*setState(() => isLoading = true);
      bool val = await GoogleDrive().uploadFileToGoogleDrive(File(backup));
      if (val) {
        messageBox('تم نسخ البيانات بنجاح');
      } else {
        messageBox('تم فقط حفظ نسخة من البيانات على جهازك\n'
            'فضلا تأكد من وجود اتصال بالانترنت لحفظ نسخة على الكلاود');
      }
      setState(() => isLoading = false);*/
    } else if (Platform.isAndroid) {
      WhatsappShare.shareFile(
              filePath: [backup],
              phone: '966502300618',
              package: freeText2 == 'واتساب'
                  ? Package.whatsapp
                  : Package.businessWhatsapp)
          .catchError((e) {
        messageBox('فضلاً تأكد من نوع باقة الواتساب لديك');
        return null;
      });
    }
  }
}
