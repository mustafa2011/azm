import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sprintf/sprintf.dart';
import '../../db/fatoora_db.dart';
import 'package:number_to_word_arabic/number_to_word_arabic.dart';


const C = 'ريال';

class Utils {
  static formatPrice(num price) => price.toStringAsFixed(2);

  static formatPercent(double percent) => '%${percent.toStringAsFixed(0)}';

  static formatDate(DateTime date) =>
      DateFormat('yyyy-MM-dd HH:mm').format(date);

  static formatTime(DateTime date) => DateFormat('HH:mm').format(date);

  static formatShortDateRtl(DateTime date) =>
      DateFormat('yyyy-MM-dd').format(date);

  static formatShortDate(DateTime date) =>
      DateFormat('dd-MM-yyyy').format(date);

  static format(num price) => NumberFormat("#,##0.00 $C").format(price);
  static formatAmount(num price) => NumberFormat("#,##0.00").format(price);
  static formatItemCode(int itemCode) => NumberFormat("ITM0000").format(itemCode);

  static format00(int intNumber) => NumberFormat("00").format(intNumber);
  static formatEstimate(int intNumber) => NumberFormat("0000000").format(intNumber);


  static formatCellphone(String cellphone) {
    if (cellphone.length == 10 && cellphone.substring(0, 1) == "0") {
      cellphone = "966${cellphone.substring(1, 10)}";
    }
    return cellphone;
  }

  static formatNoCurrency(num price) => NumberFormat("#,##0.00").format(price);

  static formatNoCurrencyNoComma(num price) =>
      NumberFormat("#0.00").format(price);

  static Image imageFromBase64String(String base64String) =>
      Image.memory(base64Decode(base64String), fit: BoxFit.fill);

  static bool isAnnualSubscribe = true; /// Set to false in case of open licenses
  static bool isProVersion = true;
  static bool isA4Invoice = true;
  static bool isHandScanner = false;
  static bool isOilServices = true;
  static bool isLaundry = false;

  ///Default settings
  static String defUserName = 'مستخدم عام';
  static String defUserPassword = '123';
  static String defSellerName = 'الواضح تقنية معلومات';
  static String defEmail = 'adm@gmail.com';
  static String defCellphone = '0502300618';
  static String defBuildingNo = '46';
  static String defStreetName = 'طريق الملك فهد';
  static String defDistrict = 'حي عتيقة';
  static String defCity = 'الرياض';
  static String defCountry = 'السعودية';
  static String defPostcode = '1111';
  static String defAdditionalNo = '1234';
  static String defVatNumber = '300005555500003';
  static String defTerms = 'الأسعار بالريال وتشمل الضريبة';
  static String defSheetId = '1uA1Yib05DypFgGnv6r77KoqRwgbP3r9Oz1uXy_NpQG4';
  static String defSupportNumber = '00966502300618'; // owner
  static String defPayMethod = 'شبكة';
  static String defShowPayMethod = 'اظهار';
  static String defDevice = Platform.isWindows ? 'Laptop' : 'Mobile';
  static String defActivity = 'General';
  static String defPaperSize = 'a4';
  static String defPrinterName = 'MTP-II';
  static String defLanguage = 'Arabic';
  static String defWhatsApp = 'واتساب';
  static String defFullSupportNumber = '966502300618'; // Reseller #1
  /// End of default settings

  static Uint8List dataFromBase64String(String base64String) {
    return base64Decode(base64String);
  }

  static String base64String(Uint8List data) {
    return base64Encode(data);
  }


  static Future<String> bluetoothPrinterName() async {
    FatooraDB db = FatooraDB.instance;
    var user = await db.getAllSettings();
    return user[0].printerName;
  }

  static Future<String> language() async {
    FatooraDB db = FatooraDB.instance;
    String result = 'Arabic';
    var user = await db.getAllSettings();
    if (user.isNotEmpty) result = user[0].language;
    return result;
  }

  static Future<bool> existUser() async {
    FatooraDB db = FatooraDB.instance;
    bool result = false;
    var user = await db.getAllSettings();
    if (user.isNotEmpty) result = true;
    return result;
  }

  static Future<String> dbVersion() async {
    FatooraDB db = FatooraDB.instance;
    return db.version;
  }

  static Future<String> whatsapp() async {
    FatooraDB db = FatooraDB.instance;
    String result = 'واتساب';
    var user = await db.getAllSettings();
    if (user.isNotEmpty) result = user[0].freeText2;
    return result;
  }

  static Future<String> payMethod() async {
    FatooraDB db = FatooraDB.instance;
    String result = 'اظهار';
    var user = await db.getAllSettings();
    if (user.isNotEmpty) result = user[0].freeText3;
    return result;
  }

  static Future<String> device() async {
    FatooraDB db = FatooraDB.instance;
    String result = defDevice;
    var user = await db.getAllSettings();
    if (user.isNotEmpty) result = user[0].freeText4;
    return result;
  }

  static Future<String> activity() async {
    FatooraDB db = FatooraDB.instance;
    String result = defActivity;
    var user = await db.getAllSettings();
    if (user.isNotEmpty) result = user[0].freeText5;
    return result;
  }

  static Future<String> whatsappNumber() async {
    FatooraDB db = FatooraDB.instance;
    String result = Utils.defFullSupportNumber;
    var user = await db.getAllSettings();
    if (user.isNotEmpty) result = '966${user[0].cellphone.substring(1, 10)}';
    return result;
  }

  static String toHex(int value) {
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

  static String numToWord(String number){
    String newNumber = number; // formatNoCurrency(num.parse(number));
    String numInWord='';
    String strOnly = 'فقط ';
    String strNothing = ' لا غير';
    if(number.contains('.')) {
      num numberBeforeDot = num.parse(newNumber.split('.')[0].replaceAll(",", ""));
      num numberAfterDot = num.parse(newNumber.split('.')[1].replaceAll(",", ""));
      numInWord = Tafqeet.convert(numberBeforeDot.toString());
      numInWord += ' ريال';
      numInWord += numberAfterDot > 0 ? ' و' : '';
      numInWord += numberAfterDot > 0 ? Tafqeet.convert(numberAfterDot.toString()) : '';
      numInWord += numberAfterDot > 0 ? ' هللة' : '';
    } else {
      numInWord = Tafqeet.convert(number);
      numInWord += ' ريال';
    }

    return '$strOnly $numInWord $strNothing';
  }

  static Future<bool> isDemo() async {
    FatooraDB db = FatooraDB.instance;
    bool result = false;
    var userSetting = await db.getAllSettings();
    if (userSetting.isNotEmpty) {
      int? intCode = (int.parse(userSetting[0].cellphone) +
          userSetting[0].id! +
          (DateTime.now().month + 1) +
          DateTime.now().year);
      String? validationCode = toHex(intCode);
      String? activationCode = userSetting[0].activationCode;
      if (validationCode != activationCode) {
        result = true;
      }
    }
    return result;
  }

  static Future<bool> validLicense() async {
    FatooraDB db = FatooraDB.instance;
    bool result = false;
    var userSetting = await db.getAllSettings();
    if (userSetting.isNotEmpty) {
      int? intCode = int.parse(userSetting[0].cellphone) +
          userSetting[0].id! +
          ((DateTime.parse(userSetting[0].startDateTime)).month + 1) +
          DateTime.now().year;
      String validationCode = toHex(intCode);
      String activationCode = userSetting[0].activationCode;
      if (validationCode == activationCode) {
        result = true;
      }
    }
    return result;
  }

  static Future<bool> isValidLicense() async {
    FatooraDB db = FatooraDB.instance;
    bool result = false;
    var userSetting = await db.getAllSettings();
    if (userSetting.isNotEmpty) {
      int? intCode = (int.parse(userSetting[0].cellphone) +
          userSetting[0].id! +
          (DateTime.now().month + 1) +
          DateTime.now().year);
      String? validationCode = toHex(intCode);
      String? activationCode = userSetting[0].activationCode;
      if (validationCode == activationCode) {
        result = true;
      }
    }
    return result;
  }

  static Widget space(double height, double width) =>
      SizedBox(height: height * 5, width: width * 5);

  static bool isDefaultProject = false;

}
