import 'dart:io';

import 'package:fatoora/screens/home_page.dart';

import '../screens/register_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '/widgets/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'apis/constants/utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Directory? docDir;
  if (Platform.isAndroid) {
    docDir = await getExternalStorageDirectory();
  } else {
    // for Windows and others OS
    docDir = await getApplicationDocumentsDirectory();
    sqfliteFfiInit(); // To initialize FFI
    databaseFactory = databaseFactoryFfi; // To change the default factory
  }
  final fatooraDir = await createNewDirectory('${docDir?.path}/Fatoora');
  final oldYearDir = await createNewDirectory('${fatooraDir.path}/2022');
  final yearDir = await createNewDirectory('${fatooraDir.path}/${DateTime
      .now()
      .year
      .toString()}');
  await createNewDirectory('${docDir?.path}/Fatoora/Database');
  await createNewDirectory('${docDir?.path}/Fatoora/OldDatabase');
  await createNewDirectory('${docDir?.path}/Fatoora/Reports');
  final oldEstimatesDir = await createNewDirectory('${oldYearDir.path}/Estimates');
  final estimatesDir = await createNewDirectory('${yearDir.path}/Estimates');
  final oldPoDir = await createNewDirectory('${oldYearDir.path}/Po');
  final poDir = await createNewDirectory('${yearDir.path}/Po');
  final oldReceiptsDir = await createNewDirectory('${oldYearDir.path}/Receipts');
  final receiptDir = await createNewDirectory('${yearDir.path}/Receipts');
  final oldInvoicesDir = await createNewDirectory('${oldYearDir.path}/Invoices');
  final invoicesDir = await createNewDirectory('${yearDir.path}/Invoices');

  for (int i = 1; i < 13; i++) {
    await createNewDirectory('${oldReceiptsDir.path}/${Utils.format00(i)}');
    await createNewDirectory('${receiptDir.path}/${Utils.format00(i)}');
    await createNewDirectory('${oldEstimatesDir.path}/${Utils.format00(i)}');
    await createNewDirectory('${estimatesDir.path}/${Utils.format00(i)}');
    await createNewDirectory('${oldPoDir.path}/${Utils.format00(i)}');
    await createNewDirectory('${poDir.path}/${Utils.format00(i)}');
    await createNewDirectory('${oldInvoicesDir.path}/${Utils.format00(i)}');
    await createNewDirectory('${invoicesDir.path}/${Utils.format00(i)}');
  }
  try {
    final existUser = await Utils.existUser();
    runApp(MyApp(existUser: existUser,));
  } on Exception catch (e) {
    throw Exception(e);
  }

}

class MyApp extends StatelessWidget {
  const MyApp({Key? key, this.existUser}) : super(key: key);
  final bool? existUser;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FATOORA',
      theme: ThemeData(
        fontFamily: 'Cairo',
        primarySwatch: Colors.orange,
        primaryColor: AppColor.primary,
        primaryColorLight: AppColor.secondary,
        scaffoldBackgroundColor: AppColor.background,
      ),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      home: existUser! ? const HomePage() : const Register(),
      // home: isUserExist! ? const HomePage() : const Register(),
    );
  }
}

Future<Directory> createNewDirectory(String strPath) async {
  final newDirectory = Directory(strPath);
  if (!(await newDirectory.exists())) {
    await newDirectory.create();
  }
  return newDirectory;
}

