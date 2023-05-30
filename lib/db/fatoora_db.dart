import 'dart:io';

import 'package:fatoora/models/template.dart';

import '../models/customers.dart';
import '../models/invoice.dart';
import '../models/product.dart';
import '../models/purchase.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/estimate.dart';
import '../models/po.dart';
import '../models/receipt.dart';
import '/models/settings.dart';

final currentYear = DateTime.now().year;
final lastFebDay = currentYear % 4 == 0 ? 29 : 28;
const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
const intType = 'INTEGER';
const intTypeNN = 'INTEGER NOT NULL';
const textType = 'TEXT NOT NULL';
const text = 'TEXT';
const boolType = 'INTEGER NOT NULL';
const integerType = 'INTEGER NOT NULL';
const numType = 'NUMERIC NOT NULL';

class FatooraDB {
  static final FatooraDB instance = FatooraDB.init();

  static Database? _database;
  static String dbFileName = 'fatoora';

  FatooraDB.init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDb('$dbFileName.db');
    return _database!;
  }

  Future<Database> initDb(String filePath) async {
    Directory? appDirectory;
    if (Platform.isAndroid) {
      appDirectory = await getExternalStorageDirectory();
    } else {
      appDirectory = await getApplicationDocumentsDirectory();
    }
    String dbFilePath = '${appDirectory!.path}/Fatoora/Database/$filePath';
    String oldDbFilePath = '${appDirectory.path}/Fatoora/OldDatabase/$filePath';
    final dbPath = await getDatabasesPath();
    final oldDbpath = '$dbPath/$filePath';
    bool isOldDbExist = await File(oldDbpath).exists();
    bool isOldDbExistInFolder = await File(oldDbFilePath).exists();

    if (isOldDbExist && !isOldDbExistInFolder) {
      File(oldDbpath).copy(oldDbFilePath);
    }

    return await databaseFactory.openDatabase(dbFilePath,
        options: OpenDatabaseOptions(
            version: 3,
            onConfigure: onConfigure,
            onCreate: (db, version) async {
              var batch = db.batch();
              _createTables(batch); // create all the tables
              await batch.commit();
            },
            onUpgrade: (db, oldVersion, newVersion) async {
              var batch = db.batch();
              if (oldVersion < 2) {
                _updateToV2(batch);
              }
              if (oldVersion < 3) {
                _updateToV3(batch);
              }
              await batch.commit();
            },
            onDowngrade: (db, oldVersion, newVersion) async {
              onDatabaseDowngradeDelete;
            }));
  }

  Future<Database> initNewDb(String filePath) async {
    return await databaseFactory.openDatabase(filePath);
  }

  /// Let's use FOREIGN KEY constraints
  Future onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  /// Create tables
  void _createTables(Batch batch) {
    // Create settings table
    batch.execute('''
CREATE TABLE $tableSettings ( 
  ${SettingFields.id} $idType, 
  ${SettingFields.name} $textType,
  ${SettingFields.email} $textType,
  ${SettingFields.password} $textType,
  ${SettingFields.cellphone} $textType,
  ${SettingFields.seller} $textType,
  ${SettingFields.buildingNo} $text,
  ${SettingFields.streetName} $text,
  ${SettingFields.district} $text,
  ${SettingFields.city} $text,
  ${SettingFields.country} $text,
  ${SettingFields.postalCode} $text,
  ${SettingFields.additionalNo} $text,
  ${SettingFields.vatNumber} $textType,
  ${SettingFields.sheetId} $textType,
  ${SettingFields.workOffline} $boolType,
  ${SettingFields.activationCode} $text,
  ${SettingFields.startDateTime} $textType,
  ${SettingFields.logo} $text,
  ${SettingFields.terms} $text,
  ${SettingFields.logoWidth} $intType,
  ${SettingFields.logoHeight} $intType,
  ${SettingFields.showVat} $boolType,
  ${SettingFields.printerName} $text,
  ${SettingFields.paperSize} $text,
  ${SettingFields.optionsCode} $text,
  ${SettingFields.defaultPayment} $text,
  ${SettingFields.language} $text,
  ${SettingFields.freeText2} $text,
  ${SettingFields.freeText3} $text,
  ${SettingFields.freeText4} $text,
  ${SettingFields.freeText5} $text,
  ${SettingFields.freeText6} $text,
  ${SettingFields.freeText7} $text,
  ${SettingFields.freeText8} $text,
  ${SettingFields.freeText9} $text,
  ${SettingFields.freeText10} $text
  )
''');

    // Create products table
    batch.execute('''
CREATE TABLE $tableProducts ( 
  ${ProductFields.id} $idType, 
  ${ProductFields.productName} $textType,
  ${ProductFields.price} $numType
  )
''');

    // Create customers table
    batch.execute('''
CREATE TABLE $tableCustomers ( 
  ${CustomerFields.id} $idType, 
  ${CustomerFields.name} $textType,
  ${CustomerFields.buildingNo} $text,
  ${CustomerFields.streetName} $text,
  ${CustomerFields.district} $text,
  ${CustomerFields.city} $text,
  ${CustomerFields.country} $text,
  ${CustomerFields.postalCode} $text,
  ${CustomerFields.additionalNo} $text,
  ${CustomerFields.vatNumber} $textType,
  ${CustomerFields.contactNumber} $text
  )
''');

    // Create invoices table
    batch.execute('''
CREATE TABLE $tableInvoices ( 
  ${InvoiceFields.id} $idType, 
  ${InvoiceFields.invoiceNo} $textType, 
  ${InvoiceFields.date} $textType,
  ${InvoiceFields.supplyDate} $text,
  ${InvoiceFields.sellerId} $intType,
  ${InvoiceFields.total} $numType,
  ${InvoiceFields.totalVat} $numType,
  ${InvoiceFields.posted} $boolType,
  ${InvoiceFields.payerId} $intType,
  ${InvoiceFields.noOfLines} $integerType,
  ${InvoiceFields.project} $text,
  ${InvoiceFields.paymentMethod} $text
  )
''');

    // Create purchases table
    batch.execute('''
CREATE TABLE $tablePurchases ( 
  ${PurchaseFields.id} $idType, 
  ${PurchaseFields.date} $textType,
  ${PurchaseFields.vendor} $textType,
  ${PurchaseFields.vendorVatNumber} $textType,
  ${PurchaseFields.total} $numType,
  ${PurchaseFields.totalVat} $numType
  )
''');

    // Create invoiceLines table
    batch.execute('''
CREATE TABLE $tableInvoiceLines ( 
  ${InvoiceLinesFields.id} $idType, 
  ${InvoiceLinesFields.recId} $integerType, 
  ${InvoiceLinesFields.productName} $textType,
  ${InvoiceLinesFields.price} $numType,
  ${InvoiceLinesFields.qty} $numType
  )
''');

    _updateToV2(batch);
    _updateToV3(batch);
  }

  void _updateToV2(Batch batch) {
    batch.execute('''
    CREATE TABLE TEMP ( 
        ${SettingFields.id} $idType, 
        ${SettingFields.name} $textType,
        ${SettingFields.email} $textType,
        ${SettingFields.password} $textType,
        ${SettingFields.cellphone} $textType,
        ${SettingFields.seller} $textType,
        ${SettingFields.buildingNo} $text,
        ${SettingFields.streetName} $text,
        ${SettingFields.district} $text,
        ${SettingFields.city} $text,
        ${SettingFields.country} $text,
        ${SettingFields.postalCode} $text,
        ${SettingFields.additionalNo} $text,
        ${SettingFields.vatNumber} $textType,
        ${SettingFields.sheetId} $textType,
        ${SettingFields.workOffline} $boolType,
        ${SettingFields.activationCode} $text,
        ${SettingFields.startDateTime} $textType,
        ${SettingFields.logo} $text,
        ${SettingFields.terms} $text,
        ${SettingFields.logoWidth} $intType,
        ${SettingFields.logoHeight} $intType,
        ${SettingFields.showVat} $boolType,
        ${SettingFields.printerName} $text,
        ${SettingFields.paperSize} $text,
        ${SettingFields.optionsCode} $text,
        ${SettingFields.defaultPayment} $text,
        ${SettingFields.language} $text,
        ${SettingFields.freeText2} $text,
        ${SettingFields.freeText3} $text,
        ${SettingFields.freeText4} $text,
        ${SettingFields.freeText5} $text,
        ${SettingFields.freeText6} $text,
        ${SettingFields.freeText7} $text,
        ${SettingFields.freeText8} $text,
        ${SettingFields.freeText9} $text,
        ${SettingFields.freeText10} $text,
        ${SettingFields.terms1} $text,
        ${SettingFields.terms2} $text,
        ${SettingFields.terms3} $text,
        ${SettingFields.terms4} $text
        )
    ''');
    batch.execute('''
    INSERT INTO TEMP (
      ${SettingFields.id}, 
      ${SettingFields.name},
      ${SettingFields.email},
      ${SettingFields.password},
      ${SettingFields.cellphone},
      ${SettingFields.seller},
      ${SettingFields.buildingNo},
      ${SettingFields.streetName},
      ${SettingFields.district},
      ${SettingFields.city},
      ${SettingFields.country},
      ${SettingFields.postalCode},
      ${SettingFields.additionalNo},
      ${SettingFields.vatNumber},
      ${SettingFields.sheetId},
      ${SettingFields.workOffline},
      ${SettingFields.activationCode},
      ${SettingFields.startDateTime},
      ${SettingFields.logo},
      ${SettingFields.terms},
      ${SettingFields.logoWidth},
      ${SettingFields.logoHeight},
      ${SettingFields.showVat},
      ${SettingFields.printerName},
      ${SettingFields.paperSize},
      ${SettingFields.optionsCode},
      ${SettingFields.defaultPayment},
      ${SettingFields.language},
      ${SettingFields.freeText2},
      ${SettingFields.freeText3},
      ${SettingFields.freeText4},
      ${SettingFields.freeText5},
      ${SettingFields.freeText6},
      ${SettingFields.freeText7},
      ${SettingFields.freeText8},
      ${SettingFields.freeText9},
      ${SettingFields.freeText10}
      ) SELECT
      ${SettingFields.id},
      ${SettingFields.name},
      ${SettingFields.email},
      ${SettingFields.password},
      ${SettingFields.cellphone},
      ${SettingFields.seller},
      ${SettingFields.buildingNo},
      ${SettingFields.streetName},
      ${SettingFields.district},
      ${SettingFields.city},
      ${SettingFields.country},
      ${SettingFields.postalCode},
      ${SettingFields.additionalNo},
      ${SettingFields.vatNumber},
      ${SettingFields.sheetId},
      ${SettingFields.workOffline},
      ${SettingFields.activationCode},
      ${SettingFields.startDateTime},
      ${SettingFields.logo},
      ${SettingFields.terms},
      ${SettingFields.logoWidth},
      ${SettingFields.logoHeight},
      ${SettingFields.showVat},
      ${SettingFields.printerName},
      ${SettingFields.paperSize},
      ${SettingFields.optionsCode},
      ${SettingFields.defaultPayment},
      ${SettingFields.language},
      ${SettingFields.freeText2},
      ${SettingFields.freeText3},
      ${SettingFields.freeText4},
      ${SettingFields.freeText5},
      ${SettingFields.freeText6},
      ${SettingFields.freeText7},
      ${SettingFields.freeText8},
      ${SettingFields.freeText9},
      ${SettingFields.freeText10}
      FROM $tableSettings
    ''');
    batch.execute('''DROP TABLE $tableSettings''');
    batch.execute('''ALTER TABLE TEMP RENAME TO $tableSettings''');
  }

  void _updateToV3(Batch batch) {
    _updateTableEstimate(batch);
    _updateTablePurchase(batch);
    _updateTablePo(batch);
    _updateSettings(batch);
    _updateCustomers(batch);
    _updateProducts(batch);
    _updateInvoices(batch);
    _updateTemplate(batch);
    _updateInvoiceLines(batch);
  }

  void _updateTableEstimate(Batch batch) {
    batch.execute('''
    CREATE TABLE $tableEstimates ( 
      ${EstimateFields.id} $idType, 
      ${EstimateFields.estimateNo} $textType, 
      ${EstimateFields.date} $textType,
      ${EstimateFields.supplyDate} $text,
      ${EstimateFields.sellerId} $intType,
      ${EstimateFields.total} $numType,
      ${EstimateFields.totalVat} $numType,
      ${EstimateFields.posted} $boolType,
      ${EstimateFields.payerId} $intType,
      ${EstimateFields.noOfLines} $integerType,
      ${EstimateFields.project} $text,
      ${EstimateFields.paymentMethod} $text
      )
    ''');
    batch.execute('''
    CREATE TABLE $tableEstimateLines ( 
      ${EstimateLinesFields.id} $idType, 
      ${EstimateLinesFields.recId} $integerType, 
      ${EstimateLinesFields.productName} $textType,
      ${EstimateLinesFields.price} $numType,
      ${EstimateLinesFields.qty} $numType
      )
    ''');
    batch.execute('''
    CREATE TABLE $tableReceipts ( 
      ${ReceiptFields.id} $idType, 
      ${ReceiptFields.date} $textType, 
      ${ReceiptFields.receivedFrom} $textType,
      ${ReceiptFields.sumOf} $textType,
      ${ReceiptFields.amount} $numType,
      ${ReceiptFields.amountFor} $textType,
      ${ReceiptFields.payType} $textType,
      ${ReceiptFields.chequeNo} $text,
      ${ReceiptFields.chequeDate} $text,
      ${ReceiptFields.transferNo} $text,
      ${ReceiptFields.transferDate} $text,
      ${ReceiptFields.bank} $text
      )
    ''');
  }

  void _updateTablePurchase(Batch batch) {
    batch.execute('''
    CREATE TABLE TEMP ( 
      ${PurchaseFields.id} $idType, 
      ${PurchaseFields.date} $textType,
      ${PurchaseFields.vendor} $textType,
      ${PurchaseFields.vendorVatNumber} $textType,
      ${PurchaseFields.total} $numType,
      ${PurchaseFields.totalVat} $numType,
      ${PurchaseFields.details} $text
      )
    ''');
    batch.execute('''
    INSERT INTO TEMP ( 
      ${PurchaseFields.id}, 
      ${PurchaseFields.date},
      ${PurchaseFields.vendor},
      ${PurchaseFields.vendorVatNumber},
      ${PurchaseFields.total},
      ${PurchaseFields.totalVat},
      ${PurchaseFields.details}
      ) SELECT 
      ${PurchaseFields.id}, 
      ${PurchaseFields.date},
      ${PurchaseFields.vendor},
      ${PurchaseFields.vendorVatNumber},
      ${PurchaseFields.total},
      ${PurchaseFields.totalVat},
      "*"
      FROM $tablePurchases
    ''');
    batch.execute('''DROP TABLE $tablePurchases''');
    batch.execute('''ALTER TABLE TEMP RENAME TO $tablePurchases''');
  }

  void _updateTablePo(Batch batch) {
    batch.execute('''
    CREATE TABLE $tablePo ( 
      ${PoFields.id} $idType, 
      ${PoFields.poNo} $textType, 
      ${PoFields.date} $textType,
      ${PoFields.supplyDate} $text,
      ${PoFields.sellerId} $intType,
      ${PoFields.total} $numType,
      ${PoFields.totalVat} $numType,
      ${PoFields.posted} $boolType,
      ${PoFields.payerId} $intType,
      ${PoFields.noOfLines} $integerType,
      ${PoFields.project} $text,
      ${PoFields.paymentMethod} $text
      )
    ''');
    batch.execute('''
    CREATE TABLE $tablePoLines ( 
      ${PoLinesFields.id} $idType, 
      ${PoLinesFields.recId} $integerType, 
      ${PoLinesFields.productName} $textType,
      ${PoLinesFields.price} $numType,
      ${PoLinesFields.qty} $numType
      )
    ''');
  }

  void _updateTemplate(Batch batch) {
    batch.execute("DROP TABLE IF EXISTS $tableTemplate");
    batch.execute("DROP TABLE IF EXISTS $tableTemplateDetails");
    batch.execute('''
    CREATE TABLE $tableTemplate ( 
        ${TemplateFields.id} $idType, 
        ${TemplateFields.tempName} $text
        )
    ''');
    batch.execute('''
    CREATE TABLE $tableTemplateDetails ( 
        ${TemplateDetailsFields.id} $idType, 
        ${TemplateDetailsFields.tempId} $intTypeNN DEFAULT 1,
        ${TemplateDetailsFields.colName} $textType,
        ${TemplateDetailsFields.colTop} $numType  DEFAULT 0,
        ${TemplateDetailsFields.colLeft} $numType  DEFAULT 0,
        ${TemplateDetailsFields.colWidth} $numType DEFAULT 50,
        ${TemplateDetailsFields.colHeight} $numType DEFAULT 13,
        ${TemplateDetailsFields.fontSize} $numType DEFAULT 8,
        ${TemplateDetailsFields.isBold} $intType DEFAULT 1,
        ${TemplateDetailsFields.backColor} $text,
        ${TemplateDetailsFields.borderColor} $text,
        ${TemplateDetailsFields.fontColor} $text,
        ${TemplateDetailsFields.isVisible} $intType DEFAULT 1
        );
    ''');

    /// Initiate Templates
    String insertTemplate = "INSERT INTO $tableTemplate (tempName) VALUES ";
    String insertValues =
        "INSERT INTO $tableTemplateDetails (tempId,colName,colTop,colLeft,colWidth,colHeight,fontSize,isBold,isVisible) VALUES ";
    int totalTemp = 5;
    // ToDo: total cols = 38 to be changed if new column add in future version
    for (int j = 0; j < totalTemp; j++) {
      batch.execute("$insertTemplate('invoiceTemp${j + 1}')");
      batch.execute("$insertValues(${j + 1}, 'sellerName',0,0,50,13,10,1,0)");
      batch.execute("$insertValues(${j + 1}, 'sellerVatNo',0,0,120,13,8.5,1,0)");
      batch.execute("$insertValues(${j + 1}, 'sellerCellphone',0,0,120,13,8.5,1,0)");
      batch.execute("$insertValues(${j + 1}, 'sellerBuildingNo',0,0,50,13,8.5,1,0)");
      batch.execute("$insertValues(${j + 1}, 'sellerStreet',0,0,0,13,8.5,1,0)");
      batch.execute("$insertValues(${j + 1}, 'sellerDistrict',0,0,50,13,8.5,1,0)");
      batch.execute("$insertValues(${j + 1}, 'sellerCity',0,0,50,13,8.5,1,0)");
      batch.execute("$insertValues(${j + 1}, 'sellerCountry',0,0,50,13,8.5,1,0)");
      batch.execute("$insertValues(${j + 1}, 'sellerZipCode',0,0,50,13,8.5,1,0)");
      batch.execute("$insertValues(${j + 1}, 'sellerAdditionalNo',0,0,50,12,8.5,1,0)");
      batch.execute("$insertValues(${j + 1}, 'customerName',51,17,443.5,12,10,1,1)");
      batch.execute("$insertValues(${j + 1}, 'customerCellphone',0,0,0,12,8.5,1,0)");
      batch.execute("$insertValues(${j + 1}, 'customerBuildingNo',0,0,50,12,8.5,1,0)");
      batch.execute("$insertValues(${j + 1}, 'customerStreet',62.8,17,390,12,10,1,1)");
      batch.execute("$insertValues(${j + 1}, 'customerDistrict',0,0,50,12,8.5,1,0)");
      batch.execute("$insertValues(${j + 1}, 'customerCity',98.5,25,170,12,8.5,1,0)");
      batch.execute("$insertValues(${j + 1}, 'customerCountry',0,0,50,12,8.5,1,0)");
      batch.execute("$insertValues(${j + 1}, 'customerZipCode',45,50,80,12,9,1,1)");
      batch.execute("$insertValues(${j + 1}, 'customerAdditionalNo',45,3,70,12,9,1,1)");
      batch.execute("$insertValues(${j + 1}, 'invoiceNo',45,143,70,12,9,1,1)");
      batch.execute("$insertValues(${j + 1}, 'invoiceDate',45,108.7,70,12,9,1,1)");
      batch.execute("$insertValues(${j + 1}, 'barcode',5,0,43,12,11,1,0)");
      batch.execute("$insertValues(${j + 1}, 'productName',75.5,175.5,40.5,12,11,1,1)");
      batch.execute("$insertValues(${j + 1}, 'qty',75.5,123,40,12,11,1,1)");
      batch.execute("$insertValues(${j + 1}, 'price',75.5,138,52,12,11,1,1)");
      batch.execute("$insertValues(${j + 1}, 'discount',0,0,32,12,11,1,0)");
      batch.execute("$insertValues(${j + 1}, 'customerVatNo',57,132,105,12,10,1,1)");
      batch.execute("$insertValues(${j + 1}, 'unit',75.5,158,48,12,11,1,1)");
      batch.execute("$insertValues(${j + 1}, 'vatLinePercent',75.5,68,55,12,11,1,1)");
      batch.execute("$insertValues(${j + 1}, 'vatLineAmount',75.5,51,44,12,11,1,1)");
      batch.execute("$insertValues(${j + 1}, 'totalLineAmount',75.5,89,94,12,11,1,1)");
      batch.execute("$insertValues(${j + 1}, 'netLineAmount',75.5,17.5,90,12,11,1,1)");
      batch.execute("$insertValues(${j + 1}, 'totalDiscount',149.3,59.5,100,14,10,1,1)");
      batch.execute("$insertValues(${j + 1}, 'totalAmount',144.9,59.5,100,14,10,1,1)");
      batch.execute("$insertValues(${j + 1}, 'totalNetAmount',164,59.5,100,14,10,1,1)");
      batch.execute("$insertValues(${j + 1}, 'totalVat',159,59.5,100,14,10,1,1)");
      batch.execute("$insertValues(${j + 1}, 'sumOfAmount',154,59.5,100,14,10,1,1)");
      batch.execute("$insertValues(${j + 1}, 'qrCode',144.5,24,70,70,10,1,1)");
    }
  }

  void _updateSettings(Batch batch) {
    batch.execute('''
    CREATE TABLE TEMP ( 
        ${SettingFields.id} $idType, 
        ${SettingFields.name} $textType,
        ${SettingFields.email} $textType,
        ${SettingFields.password} $textType,
        ${SettingFields.cellphone} $textType,
        ${SettingFields.seller} $textType,
        ${SettingFields.buildingNo} $text,
        ${SettingFields.streetName} $text,
        ${SettingFields.district} $text,
        ${SettingFields.city} $text,
        ${SettingFields.country} $text,
        ${SettingFields.postalCode} $text,
        ${SettingFields.additionalNo} $text,
        ${SettingFields.vatNumber} $textType,
        ${SettingFields.sheetId} $textType,
        ${SettingFields.workOffline} $boolType,
        ${SettingFields.activationCode} $text,
        ${SettingFields.startDateTime} $textType,
        ${SettingFields.logo} $text,
        ${SettingFields.terms} $text,
        ${SettingFields.logoWidth} $intType,
        ${SettingFields.logoHeight} $intType,
        ${SettingFields.showVat} $boolType,
        ${SettingFields.printerName} $text,
        ${SettingFields.paperSize} $text,
        ${SettingFields.optionsCode} $text,
        ${SettingFields.defaultPayment} $text,
        ${SettingFields.language} $text,
        ${SettingFields.freeText2} $text,
        ${SettingFields.freeText3} $text,
        ${SettingFields.freeText4} $text,
        ${SettingFields.freeText5} $text,
        ${SettingFields.freeText6} $text,
        ${SettingFields.freeText7} $text,
        ${SettingFields.freeText8} $text,
        ${SettingFields.freeText9} $text,
        ${SettingFields.freeText10} $text,
        ${SettingFields.terms1} $text,
        ${SettingFields.terms2} $text,
        ${SettingFields.terms3} $text,
        ${SettingFields.terms4} $text,
        ${SettingFields.sellerNameEn} $text,
        ${SettingFields.sellerActivityAr} $text,
        ${SettingFields.sellerActivityEn} $text,
        ${SettingFields.sellerAddress} $text,
        ${SettingFields.sellerCr} $text,
        ${SettingFields.defaultInvoiceTemp} $text,
        ${SettingFields.invoiceTemp1} $text,
        ${SettingFields.invoiceTemp2} $text,
        ${SettingFields.invoiceTemp3} $text,
        ${SettingFields.invoiceTemp4} $text,
        ${SettingFields.invoiceTemp5} $text
        )
    ''');
    batch.execute('''
    INSERT INTO TEMP (
      ${SettingFields.id}, 
      ${SettingFields.name},
      ${SettingFields.email},
      ${SettingFields.password},
      ${SettingFields.cellphone},
      ${SettingFields.seller},
      ${SettingFields.buildingNo},
      ${SettingFields.streetName},
      ${SettingFields.district},
      ${SettingFields.city},
      ${SettingFields.country},
      ${SettingFields.postalCode},
      ${SettingFields.additionalNo},
      ${SettingFields.vatNumber},
      ${SettingFields.sheetId},
      ${SettingFields.workOffline},
      ${SettingFields.activationCode},
      ${SettingFields.startDateTime},
      ${SettingFields.logo},
      ${SettingFields.terms},
      ${SettingFields.logoWidth},
      ${SettingFields.logoHeight},
      ${SettingFields.showVat},
      ${SettingFields.printerName},
      ${SettingFields.paperSize},
      ${SettingFields.optionsCode},
      ${SettingFields.defaultPayment},
      ${SettingFields.language},
      ${SettingFields.freeText2},
      ${SettingFields.freeText3},
      ${SettingFields.freeText4},
      ${SettingFields.freeText5},
      ${SettingFields.freeText6},
      ${SettingFields.freeText7},
      ${SettingFields.freeText8},
      ${SettingFields.freeText9},
      ${SettingFields.freeText10},
      ${SettingFields.terms1},
      ${SettingFields.terms2},
      ${SettingFields.terms3},
      ${SettingFields.terms4}
      ) SELECT
      ${SettingFields.id},
      ${SettingFields.name},
      ${SettingFields.email},
      ${SettingFields.password},
      ${SettingFields.cellphone},
      ${SettingFields.seller},
      ${SettingFields.buildingNo},
      ${SettingFields.streetName},
      ${SettingFields.district},
      ${SettingFields.city},
      ${SettingFields.country},
      ${SettingFields.postalCode},
      ${SettingFields.additionalNo},
      ${SettingFields.vatNumber},
      ${SettingFields.sheetId},
      ${SettingFields.workOffline},
      ${SettingFields.activationCode},
      ${SettingFields.startDateTime},
      ${SettingFields.logo},
      ${SettingFields.terms},
      ${SettingFields.logoWidth},
      ${SettingFields.logoHeight},
      ${SettingFields.showVat},
      ${SettingFields.printerName},
      ${SettingFields.paperSize},
      ${SettingFields.optionsCode},
      ${SettingFields.defaultPayment},
      ${SettingFields.language},
      ${SettingFields.freeText2},
      ${SettingFields.freeText3},
      ${SettingFields.freeText4},
      ${SettingFields.freeText5},
      ${SettingFields.freeText6},
      ${SettingFields.freeText7},
      ${SettingFields.freeText8},
      ${SettingFields.freeText9},
      ${SettingFields.freeText10},
      ${SettingFields.terms1},
      ${SettingFields.terms2},
      ${SettingFields.terms3},
      ${SettingFields.terms4}
      FROM $tableSettings
    ''');
    batch.execute('''DROP TABLE $tableSettings''');
    batch.execute('''ALTER TABLE TEMP RENAME TO $tableSettings''');
  }

  void _updateCustomers(Batch batch) {
    batch.execute('''
    CREATE TABLE TEMP ( 
        ${CustomerFields.id} $idType, 
        ${CustomerFields.name} $textType,
        ${CustomerFields.buildingNo} $text,
        ${CustomerFields.streetName} $text,
        ${CustomerFields.district} $text,
        ${CustomerFields.city} $text,
        ${CustomerFields.country} $text,
        ${CustomerFields.postalCode} $text,
        ${CustomerFields.additionalNo} $text,
        ${CustomerFields.vatNumber} $textType,
        ${CustomerFields.contactNumber} $textType,
        ${CustomerFields.address} $text
        )
    ''');
    batch.execute('''
    INSERT INTO TEMP (
      ${CustomerFields.id}, 
      ${CustomerFields.name},
      ${CustomerFields.buildingNo},
      ${CustomerFields.streetName},
      ${CustomerFields.district},
      ${CustomerFields.city},
      ${CustomerFields.country},
      ${CustomerFields.postalCode},
      ${CustomerFields.additionalNo},
      ${CustomerFields.vatNumber},
      ${CustomerFields.contactNumber}
      ) SELECT
      ${CustomerFields.id}, 
      ${CustomerFields.name},
      ${CustomerFields.buildingNo},
      ${CustomerFields.streetName},
      ${CustomerFields.district},
      ${CustomerFields.city},
      ${CustomerFields.country},
      ${CustomerFields.postalCode},
      ${CustomerFields.additionalNo},
      ${CustomerFields.vatNumber},
      ${CustomerFields.contactNumber}          
      FROM $tableCustomers
    ''');
    batch.execute('''DROP TABLE $tableCustomers''');
    batch.execute('''ALTER TABLE TEMP RENAME TO $tableCustomers''');

    /// Initialize first customer
    batch.execute('''
    INSERT INTO $tableCustomers (
      ${CustomerFields.name},
      ${CustomerFields.vatNumber},
      ${CustomerFields.contactNumber}
      ) VALUES (
      'عميل نقدي', 
      '000000000000000',
      '0000000000'
      )          
    ''');
  }

  void _updateProducts(Batch batch) {
    batch.execute('''
    CREATE TABLE TEMP ( 
        ${ProductFields.id} $idType, 
        ${ProductFields.productName} $textType,
        ${ProductFields.price} $numType,
        ${ProductFields.unit} $text,
        ${ProductFields.barcode} $textType DEFAULT ''
        )
    ''');
    batch.execute('''
    INSERT INTO TEMP (
        ${ProductFields.id},
        ${ProductFields.productName},
        ${ProductFields.price}
      ) SELECT
        ${ProductFields.id},
        ${ProductFields.productName},
        ${ProductFields.price}
      FROM $tableProducts
    ''');
    batch.execute('''DROP TABLE $tableProducts''');
    batch.execute('''ALTER TABLE TEMP RENAME TO $tableProducts''');

    /// Initialize first product
    batch.execute('''
    INSERT INTO $tableProducts (
      ${ProductFields.productName},
      ${ProductFields.barcode},
      ${ProductFields.unit},
      ${ProductFields.price}
      ) VALUES (
      'طماطم بلاستيك', 
      '1111',
      'كرتون',
      17.25
      )          
    ''');
  }

  void _updateInvoices(Batch batch) {
    batch.execute('''
    CREATE TABLE TEMP ( 
        ${InvoiceFields.id} $idType, 
        ${InvoiceFields.invoiceNo} $textType, 
        ${InvoiceFields.date} $textType,
        ${InvoiceFields.supplyDate} $text,
        ${InvoiceFields.sellerId} $intType,
        ${InvoiceFields.total} $numType,
        ${InvoiceFields.totalVat} $numType,
        ${InvoiceFields.posted} $boolType,
        ${InvoiceFields.payerId} $intType,
        ${InvoiceFields.noOfLines} $integerType,
        ${InvoiceFields.project} $text,
        ${InvoiceFields.paymentMethod} $text,
        ${InvoiceFields.totalDiscount} $numType DEFAULT 0,
        ${InvoiceFields.template} $text DEFAULT 'نموذج 1'
        )
    ''');
    batch.execute('''
    INSERT INTO TEMP (
        ${InvoiceFields.id}, 
        ${InvoiceFields.invoiceNo}, 
        ${InvoiceFields.date},
        ${InvoiceFields.supplyDate},
        ${InvoiceFields.sellerId},
        ${InvoiceFields.total},
        ${InvoiceFields.totalVat},
        ${InvoiceFields.posted},
        ${InvoiceFields.payerId},
        ${InvoiceFields.noOfLines},
        ${InvoiceFields.project},
        ${InvoiceFields.paymentMethod}
      ) SELECT
        ${InvoiceFields.id}, 
        ${InvoiceFields.invoiceNo}, 
        ${InvoiceFields.date},
        ${InvoiceFields.supplyDate},
        ${InvoiceFields.sellerId},
        ${InvoiceFields.total},
        ${InvoiceFields.totalVat},
        ${InvoiceFields.posted},
        ${InvoiceFields.payerId},
        ${InvoiceFields.noOfLines},
        ${InvoiceFields.project},
        ${InvoiceFields.paymentMethod}
      FROM $tableInvoices
    ''');
    batch.execute('''DROP TABLE $tableInvoices''');
    batch.execute('''ALTER TABLE TEMP RENAME TO $tableInvoices''');
  }

  void _updateInvoiceLines(Batch batch) {
    batch.execute('''
    CREATE TABLE TEMP ( 
        ${InvoiceLinesFields.id} $idType, 
        ${InvoiceLinesFields.recId} $integerType, 
        ${InvoiceLinesFields.productName} $textType,
        ${InvoiceLinesFields.price} $numType,
        ${InvoiceLinesFields.qty} $numType DEFAULT 1,
        ${InvoiceLinesFields.barcode} $textType DEFAULT '',
        ${InvoiceLinesFields.unit} $textType DEFAULT '',
        ${InvoiceLinesFields.discount} $numType DEFAULT 0
        )
    ''');
    batch.execute('''
    INSERT INTO TEMP (
        ${InvoiceLinesFields.id}, 
        ${InvoiceLinesFields.recId}, 
        ${InvoiceLinesFields.productName},
        ${InvoiceLinesFields.price},
        ${InvoiceLinesFields.qty}
      ) SELECT
        ${InvoiceLinesFields.id}, 
        ${InvoiceLinesFields.recId}, 
        ${InvoiceLinesFields.productName},
        ${InvoiceLinesFields.price},
        ${InvoiceLinesFields.qty}
      FROM $tableInvoiceLines
    ''');
    batch.execute('''DROP TABLE $tableInvoiceLines''');
    batch.execute('''ALTER TABLE TEMP RENAME TO $tableInvoiceLines''');
  }

  /// Table settings CRUD operations
  Future<Setting> createSetting(Setting setting) async {
    final db = await instance.database;
    final id = await db.insert(tableSettings, setting.toJson());

    if (id > 0) {
      return setting.copy(id: id);
    } else {
      throw Exception('Record NOT created');
    }
  }

  Future<Setting> getSettingById(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      tableSettings,
      columns: SettingFields.values,
      where: '${SettingFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Setting.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found in the local database');
    }
  }

  Future<List<Setting>> getAllSettings() async {
    final db = await instance.database;

    const orderBy = '${SettingFields.id} ASC';
    final result = await db.query(tableSettings, orderBy: orderBy);

    return result.map((json) => Setting.fromJson(json)).toList();
  }

  Future<Setting> getSellerById(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      tableSettings,
      columns: SettingFields.values,
      where: '${SettingFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Setting.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found in the local database');
    }
  }

  Future<TemplateDetails> getTemplateDetailsById(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      tableTemplateDetails,
      columns: TemplateDetailsFields.getTemplateDetailsFields(),
      where: '${TemplateDetailsFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return TemplateDetails.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found in the local database');
    }
  }

  Future<List<TemplateDetails>> getTemplateById(int tempId) async {
    final db = await instance.database;

    final maps = await db.query(
      tableTemplateDetails,
      columns: TemplateDetailsFields.getTemplateDetailsFields(),
      where: '${TemplateDetailsFields.tempId} = ?',
      orderBy: TemplateDetailsFields.id,
      whereArgs: [tempId],
    );

    if (maps.isNotEmpty) {
      return maps.map((json) => TemplateDetails.fromJson(json)).toList();
    } else {
      throw Exception('ID $tempId not found in the local database');
    }
  }

  Future<int> updateSetting(Setting setting) async {
    final db = await instance.database;

    return db.update(
      tableSettings,
      setting.toJson(),
      where: '${SettingFields.id} = ?',
      whereArgs: [setting.id],
    );
  }

  Future<int> deleteSetting(Setting setting) async {
    final db = await instance.database;

    return await db.delete(
      tableSettings,
      where: '${SettingFields.id} = ?',
      whereArgs: [setting.id],
    );
  }

  /// End table settings CRUD operations

  /// Table products CRUD operations
  Future<Product> createProduct(Product product) async {
    final db = await instance.database;
    final id = await db.insert(tableProducts, product.toJson());

    if (id > 0) {
      return product.copy(id: id);
    } else {
      throw Exception('Record NOT created');
    }
  }

  Future<int?> getProductsCount() async {
    //database connection
    Database db = await database;
    int? count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $tableProducts'));
    return count;
  }

  Future<Product> getProductById(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      tableProducts,
      columns: ProductFields.getProductsFields(),
      where: '${ProductFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Product.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found in the local database');
    }
  }

  Future<List<Product>> getAllProducts() async {
    final db = await instance.database;

    const orderBy = '${ProductFields.id} ASC';
    final result = await db.query(tableProducts, orderBy: orderBy);

    return result.map((json) => Product.fromJson(json)).toList();
  }

  Future<int> updateProduct(Product product) async {
    final db = await instance.database;

    return db.update(
      tableProducts,
      product.toJson(),
      where: '${ProductFields.id} = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(Product product) async {
    final db = await instance.database;

    return await db.delete(
      tableProducts,
      where: '${ProductFields.id} = ?',
      whereArgs: [product.id],
    );
  }

  Future<int?> deleteProductSequence() async {
    Database db = await database;
    int? count = Sqflite.firstIntValue(await db
        .rawQuery("DELETE FROM sqlite_sequence where name= 'products'"));
    return count;
  }

  /// End table products CRUD operations

  /// Table customers CRUD operations
  Future<Customer> createCustomer(Customer customer) async {
    final db = await instance.database;
    final id = await db.insert(tableCustomers, customer.toJson());

    if (id > 0) {
      return customer.copy(id: id);
    } else {
      throw Exception('Record NOT created');
    }
  }

  Future<int?> getCustomerCount() async {
    //database connection
    Database db = await database;
    int? count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $tableCustomers'));
    return count;
  }

  Future<bool?> isFirstCustomerExist() async {
    Database db = await database;
    int? count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT * FROM $tableCustomers WHERE id=1'));

    return count != null ? true : false;
  }

  Future<Customer> getCustomerById(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      tableCustomers,
      columns: CustomerFields.getCustomerFields(),
      where: '${CustomerFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Customer.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found in the local database');
    }
  }

  Future<String> getCustomerNameById(int id) async {
    Customer customer = await getCustomerById(id);
    return customer.name;
  }

  Future<String> getProductBarcode(int id) async {
    Product product = await getProductById(id);
    return product.barcode ?? '';
  }

  Future<String> getProductUnit(int id) async {
    Product product = await getProductById(id);
    return product.unit ?? '';
  }

  Future<String> getCustomerVatNumberById(int id) async {
    Customer customer = await getCustomerById(id);
    return customer.vatNumber;
  }

  Future<List<Customer>> getAllCustomers() async {
    final db = await instance.database;

    const orderBy = '${CustomerFields.id} ASC';
    final result = await db.query(tableCustomers, orderBy: orderBy);

    return result.map((json) => Customer.fromJson(json)).toList();
  }

  Future<int> updateCustomer(Customer customer) async {
    final db = await instance.database;

    return db.update(
      tableCustomers,
      customer.toJson(),
      where: '${CustomerFields.id} = ?',
      whereArgs: [customer.id],
    );
  }

  Future<int> deleteCustomer(Customer customer) async {
    final db = await instance.database;

    return await db.delete(
      tableCustomers,
      where: '${CustomerFields.id} = ?',
      whereArgs: [customer.id],
    );
  }

  Future<int?> deleteCustomerSequence() async {
    Database db = await database;
    int? count = Sqflite.firstIntValue(await db
        .rawQuery("DELETE FROM sqlite_sequence where name= 'customers'"));
    return count;
  }

  /// End table customers CRUD operations

  /// Table Invoices CRUD operations
  Future<Invoice> createInvoice(Invoice invoice) async {
    final db = await instance.database;
    final id = await db.insert(tableInvoices, invoice.toJson());

    if (id > 0) {
      return invoice.copy(id: id);
    } else {
      throw Exception('Record NOT created');
    }
  }

  Future<Po> createPo(Po po) async {
    final db = await instance.database;
    final id = await db.insert(tablePo, po.toJson());

    if (id > 0) {
      return po.copy(id: id);
    } else {
      throw Exception('Record NOT created');
    }
  }

  Future<Estimate> createEstimate(Estimate estimate) async {
    final db = await instance.database;
    final id = await db.insert(tableEstimates, estimate.toJson());

    if (id > 0) {
      return estimate.copy(id: id);
    } else {
      throw Exception('Record NOT created');
    }
  }

  Future<Receipt> createReceipt(Receipt receipt) async {
    final db = await instance.database;
    final id = await db.insert(tableReceipts, receipt.toJson());

    if (id > 0) {
      return receipt.copy(id: id);
    } else {
      throw Exception('Record NOT created');
    }
  }

  Future<int?> getInvoicesCount() async {
    //database connection
    Database db = await database;
    int? count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $tableInvoices'));
    return count;
  }

  Future<int?> getEstimatesCount() async {
    //database connection
    Database db = await database;
    int? count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $tableEstimates'));
    return count;
  }

  Future<int?> getPoCount() async {
    //database connection
    Database db = await database;
    int? count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $tablePo'));
    return count;
  }

  Future<int?> getReceiptsCount() async {
    //database connection
    Database db = await database;
    int? count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $tableReceipts'));
    return count;
  }

  Future<int?> getNewInvoiceId() async {
    Database db = await database;
    int? count = Sqflite.firstIntValue(await db.rawQuery(
        "SELECT seq FROM sqlite_sequence where name= '$tableInvoices'"));
    return count;
  }

  Future<int?> getNewEstimateId() async {
    Database db = await database;
    int? count = Sqflite.firstIntValue(await db.rawQuery(
        "SELECT seq FROM sqlite_sequence where name= '$tableEstimates'"));
    return count;
  }

  Future<int?> getNewPoId() async {
    Database db = await database;
    int? count = Sqflite.firstIntValue(await db
        .rawQuery("SELECT seq FROM sqlite_sequence where name= '$tablePo'"));
    return count;
  }

  Future<int?> getNewReceiptId() async {
    Database db = await database;
    int? count = Sqflite.firstIntValue(await db.rawQuery(
        "SELECT seq FROM sqlite_sequence where name= '$tableReceipts'"));
    return count;
  }

  Future<int?> deleteAllInvoices() async {
    Database db = await database;
    int? count =
        Sqflite.firstIntValue(await db.rawQuery('DELETE FROM $tableInvoices'));
    return count;
  }

  Future<int?> deleteAllInvoiceLines() async {
    Database db = await database;
    int? count = Sqflite.firstIntValue(
        await db.rawQuery('DELETE FROM $tableInvoiceLines'));
    return count;
  }

  Future<int?> deleteInvoiceSequence() async {
    Database db = await database;
    int? count = Sqflite.firstIntValue(await db
        .rawQuery("DELETE FROM sqlite_sequence where name= 'invoices'"));
    return count;
  }

  Future<int?> deleteInvoiceLinesSequence() async {
    Database db = await database;
    int? count = Sqflite.firstIntValue(await db
        .rawQuery("DELETE FROM sqlite_sequence where name= 'invoice_lines'"));
    return count;
  }

  Future<num?> getInvoicesTotal() async {
    Database db = await database;
    var sum = (await db.rawQuery(
        'SELECT SUM(${InvoiceFields.total}) AS ttl FROM $tableInvoices'));
    return sum[0]['ttl'] == null ? 0 : num.parse('${sum[0]['ttl']}');
  }

  Future<num?> getTotalSales(int year) async {
    Database db = await database;
    var sum = (await db.rawQuery(
        "SELECT SUM(${InvoiceFields.total}) AS ttl FROM $tableInvoices  "
        "WHERE ${InvoiceFields.date} >= '$year-01-01' AND ${InvoiceFields.date} <= '$year-12-31 23:59'"));
    return sum[0]['ttl'] == null ? 0 : num.parse('${sum[0]['ttl']}');
  }

  Future<num?> getJanTotalSales(int year) async {
    Database db = await database;
    var sum = (await db.rawQuery(
        "SELECT SUM(${InvoiceFields.total}) AS ttl FROM $tableInvoices  "
        "WHERE ${InvoiceFields.date} >= '$year-01-01' AND ${InvoiceFields.date} <= '$year-01-31 23:59'"));
    return sum[0]['ttl'] == null ? 0 : num.parse('${sum[0]['ttl']}');
  }

  Future<num?> getFebTotalSales(int year) async {
    Database db = await database;
    var sum = (await db.rawQuery(
        "SELECT SUM(${InvoiceFields.total}) AS ttl FROM $tableInvoices  "
        "WHERE ${InvoiceFields.date} >= '$year-02-01' AND ${InvoiceFields.date} <= '$year-02-$lastFebDay 23:59'"));
    return sum[0]['ttl'] == null ? 0 : num.parse('${sum[0]['ttl']}');
  }

  Future<num?> getMarTotalSales(int year) async {
    Database db = await database;
    var sum = (await db.rawQuery(
        "SELECT SUM(${InvoiceFields.total}) AS ttl FROM $tableInvoices  "
        "WHERE ${InvoiceFields.date} >= '$year-03-01' AND ${InvoiceFields.date} <= '$year-03-31 23:59'"));
    return sum[0]['ttl'] == null ? 0 : num.parse('${sum[0]['ttl']}');
  }

  Future<num?> getAprTotalSales(int year) async {
    Database db = await database;
    var sum = (await db.rawQuery(
        "SELECT SUM(${InvoiceFields.total}) AS ttl FROM $tableInvoices  "
        "WHERE ${InvoiceFields.date} >= '$year-04-01' AND ${InvoiceFields.date} <= '$year-04-30 23:59'"));
    return sum[0]['ttl'] == null ? 0 : num.parse('${sum[0]['ttl']}');
  }

  Future<num?> getMayTotalSales(int year) async {
    Database db = await database;
    var sum = (await db.rawQuery(
        "SELECT SUM(${InvoiceFields.total}) AS ttl FROM $tableInvoices  "
        "WHERE ${InvoiceFields.date} >= '$year-05-01' AND ${InvoiceFields.date} <= '$year-05-31 23:59'"));
    return sum[0]['ttl'] == null ? 0 : num.parse('${sum[0]['ttl']}');
  }

  Future<num?> getJunTotalSales(int year) async {
    Database db = await database;
    var sum = (await db.rawQuery(
        "SELECT SUM(${InvoiceFields.total}) AS ttl FROM $tableInvoices  "
        "WHERE ${InvoiceFields.date} >= '$year-06-01' AND ${InvoiceFields.date} <= '$year-06-30 23:59'"));
    return sum[0]['ttl'] == null ? 0 : num.parse('${sum[0]['ttl']}');
  }

  Future<num?> getJulTotalSales(int year) async {
    Database db = await database;
    var sum = (await db.rawQuery(
        "SELECT SUM(${InvoiceFields.total}) AS ttl FROM $tableInvoices  "
        "WHERE ${InvoiceFields.date} >= '$year-07-01' AND ${InvoiceFields.date} <= '$year-07-31 23:59'"));
    return sum[0]['ttl'] == null ? 0 : num.parse('${sum[0]['ttl']}');
  }

  Future<num?> getAugTotalSales(int year) async {
    Database db = await database;
    var sum = (await db.rawQuery(
        "SELECT SUM(${InvoiceFields.total}) AS ttl FROM $tableInvoices  "
        "WHERE ${InvoiceFields.date} >= '$year-08-01' AND ${InvoiceFields.date} <= '$year-08-31 23:59'"));
    return sum[0]['ttl'] == null ? 0 : num.parse('${sum[0]['ttl']}');
  }

  Future<num?> getSepTotalSales(int year) async {
    Database db = await database;
    var sum = (await db.rawQuery(
        "SELECT SUM(${InvoiceFields.total}) AS ttl FROM $tableInvoices  "
        "WHERE ${InvoiceFields.date} >= '$year-09-01' AND ${InvoiceFields.date} <= '$year-09-30 23:59'"));
    return sum[0]['ttl'] == null ? 0 : num.parse('${sum[0]['ttl']}');
  }

  Future<num?> getOctTotalSales(int year) async {
    Database db = await database;
    var sum = (await db.rawQuery(
        "SELECT SUM(${InvoiceFields.total}) AS ttl FROM $tableInvoices  "
        "WHERE ${InvoiceFields.date} >= '$year-10-01' AND ${InvoiceFields.date} <= '$year-10-31 23:59'"));
    return sum[0]['ttl'] == null ? 0 : num.parse('${sum[0]['ttl']}');
  }

  Future<num?> getNovTotalSales(int year) async {
    Database db = await database;
    var sum = (await db.rawQuery(
        "SELECT SUM(${InvoiceFields.total}) AS ttl FROM $tableInvoices  "
        "WHERE ${InvoiceFields.date} >= '$year-11-01' AND ${InvoiceFields.date} <= '$year-11-30 23:59'"));
    return sum[0]['ttl'] == null ? 0 : num.parse('${sum[0]['ttl']}');
  }

  Future<num?> getDecTotalSales(int year) async {
    Database db = await database;
    var sum = (await db.rawQuery(
        "SELECT SUM(${InvoiceFields.total}) AS ttl FROM $tableInvoices  "
        "WHERE ${InvoiceFields.date} >= '$year-12-01' AND ${InvoiceFields.date} <= '$year-12-31 23:59'"));
    return sum[0]['ttl'] == null ? 0 : num.parse('${sum[0]['ttl']}');
  }

  Future<num?> getTotalCreditNotes() async {
    Database db = await database;
    var sum = (await db.rawQuery(
        'SELECT SUM(${InvoiceFields.total}) AS ttl FROM $tableInvoices WHERE ${InvoiceFields.total} < 0'));
    return sum[0]['ttl'] == null ? 0 : num.parse('${sum[0]['ttl']}');
  }

  Future<Invoice> getInvoiceById(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      tableInvoices,
      columns: InvoiceFields.getInvoiceFields(),
      where: '${InvoiceFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Invoice.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found in the local database');
    }
  }

  Future<Estimate> getEstimateById(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      tableEstimates,
      columns: EstimateFields.getEstimateFields(),
      where: '${EstimateFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Estimate.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found in the local database');
    }
  }

  Future<Po> getPoById(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      tablePo,
      columns: PoFields.getPoFields(),
      where: '${PoFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Po.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found in the local database');
    }
  }

  Future<Receipt> getReceiptById(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      tableReceipts,
      columns: ReceiptFields.getReceiptFields(),
      where: '${ReceiptFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Receipt.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found in the local database');
    }
  }

  Future<List<Invoice>> getAllInvoices() async {
    final db = await instance.database;

    const orderBy = '${InvoiceFields.id} DESC';
    final result = await db.query(tableInvoices, orderBy: orderBy);

    return result.map((json) => Invoice.fromJson(json)).toList();
  }

  Future<List<TemplateDetails>> getAllTemplates(int tempId) async {
    final db = await instance.database;

    const orderBy = '${TemplateDetailsFields.id} ASC';
    final where = '${TemplateDetailsFields.tempId} = $tempId';
    final result =
        await db.query(tableTemplateDetails, orderBy: orderBy, where: where);

    return result.map((json) => TemplateDetails.fromJson(json)).toList();
  }

  Future<List<Invoice>> getAllInvoicesBetweenTwoDates(
      String dateFrom, String dateTo) async {
    final db = await instance.database;

    final result = await db.rawQuery(
        "SELECT * FROM $tableInvoices WHERE ${InvoiceFields.date} >= '$dateFrom' AND ${InvoiceFields.date} <= '$dateTo 23:59'");

    return result.map((json) => Invoice.fromJson(json)).toList();
  }

  Future<List<Purchase>> getAllPurchasesBetweenTwoDates(
      String dateFrom, String dateTo) async {
    final db = await instance.database;

    final result = await db.rawQuery(
        "SELECT * FROM $tablePurchases WHERE ${PurchaseFields.date} >= '$dateFrom' AND ${PurchaseFields.date} <= '$dateTo 23:59'");

    return result.map((json) => Purchase.fromJson(json)).toList();
  }

  Future<int> updateInvoice(Invoice invoice) async {
    final db = await instance.database;

    return db.update(
      tableInvoices,
      invoice.toJson(),
      where: '${InvoiceFields.id} = ?',
      whereArgs: [invoice.id],
    );
  }

  Future<int> updateTemplateDetails(TemplateDetails table) async {
    final db = await instance.database;

    return db.update(
      tableTemplateDetails,
      table.toJson(),
      where: '${TemplateDetailsFields.id} = ?',
      whereArgs: [table.id],
    );
  }

  Future<int> updateEstimate(Estimate estimate) async {
    final db = await instance.database;

    return db.update(
      tableEstimates,
      estimate.toJson(),
      where: '${EstimateFields.id} = ?',
      whereArgs: [estimate.id],
    );
  }

  Future<int> updatePo(Po po) async {
    final db = await instance.database;

    return db.update(
      tablePo,
      po.toJson(),
      where: '${PoFields.id} = ?',
      whereArgs: [po.id],
    );
  }

  Future<int> updateReceipt(Receipt receipt) async {
    final db = await instance.database;

    return db.update(
      tableReceipts,
      receipt.toJson(),
      where: '${ReceiptFields.id} = ?',
      whereArgs: [receipt.id],
    );
  }

  Future<int> deleteInvoice(Invoice invoice) async {
    final db = await instance.database;

    deleteInvoiceLines(invoice.id!);

    return await db.delete(
      tableInvoices,
      where: '${InvoiceFields.id} = ?',
      whereArgs: [invoice.id],
    );
  }

  /// End table invoices CRUD operations

  /// Table Purchases CRUD operations
  Future<Purchase> createPurchase(Purchase purchase) async {
    final db = await instance.database;
    final id = await db.insert(tablePurchases, purchase.toJson());

    if (id > 0) {
      return purchase.copy(id: id);
    } else {
      throw Exception('Record NOT created');
    }
  }

  Future<int?> getPurchasesCount() async {
    //database connection
    Database db = await database;
    int? count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $tablePurchases'));
    return count;
  }

  Future<int?> getNewPurchaseId() async {
    Database db = await database;
    int? count = Sqflite.firstIntValue(await db
        .rawQuery('SELECT id FROM $tablePurchases ORDER BY id DESC limit 1'));
    return count;
  }

  Future<int?> deleteAllPurchases() async {
    Database db = await database;
    int? count =
        Sqflite.firstIntValue(await db.rawQuery('DELETE FROM $tablePurchases'));
    return count;
  }

  Future<int?> deletePurchaseSequence() async {
    Database db = await database;
    int? count = Sqflite.firstIntValue(await db
        .rawQuery("DELETE FROM sqlite_sequence where name= 'purchases'"));
    return count;
  }

  Future<int?> deleteEstimateSequence() async {
    Database db = await database;
    int? count = Sqflite.firstIntValue(await db
        .rawQuery("DELETE FROM sqlite_sequence where name= 'estimates'"));
    return count;
  }

  Future<int?> deletePoSequence() async {
    Database db = await database;
    int? count = Sqflite.firstIntValue(
        await db.rawQuery("DELETE FROM sqlite_sequence where name= 'po'"));
    return count;
  }

  Future<int?> deleteReceiptSequence() async {
    Database db = await database;
    int? count = Sqflite.firstIntValue(await db
        .rawQuery("DELETE FROM sqlite_sequence where name= 'receipts'"));
    return count;
  }

  Future<num?> getTotalPurchases(int year) async {
    Database db = await database;
    var sum = (await db.rawQuery(
        "SELECT SUM(${PurchaseFields.total}) AS ttl FROM $tablePurchases  "
        "WHERE ${PurchaseFields.date} >= '$year-01-01' AND ${PurchaseFields.date} <= '$year-12-31 23:59'"));
    return sum[0]['ttl'] == null ? 0 : num.parse('${sum[0]['ttl']}');
  }

  Future<num?> getJanTotalPurchases(int year) async {
    Database db = await database;
    var sum = (await db.rawQuery(
        "SELECT SUM(${PurchaseFields.total}) AS ttl FROM $tablePurchases "
        "WHERE ${PurchaseFields.date} >= '$year-01-01' AND ${PurchaseFields.date} <= '$year-01-31 23:59'"));
    return sum[0]['ttl'] == null ? 0 : num.parse('${sum[0]['ttl']}');
  }

  Future<num?> getFebTotalPurchases(int year) async {
    Database db = await database;
    var sum = (await db.rawQuery(
        "SELECT SUM(${PurchaseFields.total}) AS ttl FROM $tablePurchases  "
        "WHERE ${PurchaseFields.date} >= '$year-02-01' AND ${PurchaseFields.date} <= '$year-02-$lastFebDay 23:59'"));
    return sum[0]['ttl'] == null ? 0 : num.parse('${sum[0]['ttl']}');
  }

  Future<num?> getMarTotalPurchases(int year) async {
    Database db = await database;
    var sum = (await db.rawQuery(
        "SELECT SUM(${PurchaseFields.total}) AS ttl FROM $tablePurchases  "
        "WHERE ${PurchaseFields.date} >= '$year-03-01' AND ${PurchaseFields.date} <= '$year-03-31 23:59'"));
    return sum[0]['ttl'] == null ? 0 : num.parse('${sum[0]['ttl']}');
  }

  Future<num?> getAprTotalPurchases(int year) async {
    Database db = await database;
    var sum = (await db.rawQuery(
        "SELECT SUM(${PurchaseFields.total}) AS ttl FROM $tablePurchases  "
        "WHERE ${PurchaseFields.date} >= '$year-04-01' AND ${PurchaseFields.date} <= '$year-04-30 23:59'"));
    return sum[0]['ttl'] == null ? 0 : num.parse('${sum[0]['ttl']}');
  }

  Future<num?> getMayTotalPurchases(int year) async {
    Database db = await database;
    var sum = (await db.rawQuery(
        "SELECT SUM(${PurchaseFields.total}) AS ttl FROM $tablePurchases  "
        "WHERE ${PurchaseFields.date} >= '$year-05-01' AND ${PurchaseFields.date} <= '$year-05-31 23:59'"));
    return sum[0]['ttl'] == null ? 0 : num.parse('${sum[0]['ttl']}');
  }

  Future<num?> getJunTotalPurchases(int year) async {
    Database db = await database;
    var sum = (await db.rawQuery(
        "SELECT SUM(${PurchaseFields.total}) AS ttl FROM $tablePurchases  "
        "WHERE ${PurchaseFields.date} >= '$year-06-01' AND ${PurchaseFields.date} <= '$year-06-30 23:59'"));
    return sum[0]['ttl'] == null ? 0 : num.parse('${sum[0]['ttl']}');
  }

  Future<num?> getJulTotalPurchases(int year) async {
    Database db = await database;
    var sum = (await db.rawQuery(
        "SELECT SUM(${PurchaseFields.total}) AS ttl FROM $tablePurchases  "
        "WHERE ${PurchaseFields.date} >= '$year-07-01' AND ${PurchaseFields.date} <= '$year-07-31 23:59'"));
    return sum[0]['ttl'] == null ? 0 : num.parse('${sum[0]['ttl']}');
  }

  Future<num?> getAugTotalPurchases(int year) async {
    Database db = await database;
    var sum = (await db.rawQuery(
        "SELECT SUM(${PurchaseFields.total}) AS ttl FROM $tablePurchases  "
        "WHERE ${PurchaseFields.date} >= '$year-08-01' AND ${PurchaseFields.date} <= '$year-08-31 23:59'"));
    return sum[0]['ttl'] == null ? 0 : num.parse('${sum[0]['ttl']}');
  }

  Future<num?> getSepTotalPurchases(int year) async {
    Database db = await database;
    var sum = (await db.rawQuery(
        "SELECT SUM(${PurchaseFields.total}) AS ttl FROM $tablePurchases  "
        "WHERE ${PurchaseFields.date} >= '$year-09-01' AND ${PurchaseFields.date} <= '$year-09-30 23:59'"));
    return sum[0]['ttl'] == null ? 0 : num.parse('${sum[0]['ttl']}');
  }

  Future<num?> getOctTotalPurchases(int year) async {
    Database db = await database;
    var sum = (await db.rawQuery(
        "SELECT SUM(${PurchaseFields.total}) AS ttl FROM $tablePurchases  "
        "WHERE ${PurchaseFields.date} >= '$year-10-01' AND ${PurchaseFields.date} <= '$year-10-31 23:59'"));
    return sum[0]['ttl'] == null ? 0 : num.parse('${sum[0]['ttl']}');
  }

  Future<num?> getNovTotalPurchases(int year) async {
    Database db = await database;
    var sum = (await db.rawQuery(
        "SELECT SUM(${PurchaseFields.total}) AS ttl FROM $tablePurchases  "
        "WHERE ${PurchaseFields.date} >= '$year-11-01' AND ${PurchaseFields.date} <= '$year-11-30 23:59'"));
    return sum[0]['ttl'] == null ? 0 : num.parse('${sum[0]['ttl']}');
  }

  Future<num?> getDecTotalPurchases(int year) async {
    Database db = await database;
    var sum = (await db.rawQuery(
        "SELECT SUM(${PurchaseFields.total}) AS ttl FROM $tablePurchases  "
        "WHERE ${PurchaseFields.date} >= '$year-12-01' AND ${PurchaseFields.date} <= '$year-12-31 23:59'"));
    return sum[0]['ttl'] == null ? 0 : num.parse('${sum[0]['ttl']}');
  }

  Future<Purchase> getPurchaseById(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      tablePurchases,
      columns: PurchaseFields.getPurchaseFields(),
      where: '${PurchaseFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Purchase.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found in the local database');
    }
  }

  Future<List<Purchase>> getAllPurchases() async {
    final db = await instance.database;

    const orderBy = '${PurchaseFields.id} DESC';
    final result = await db.query(tablePurchases, orderBy: orderBy);

    return result.map((json) => Purchase.fromJson(json)).toList();
  }

  Future<List<Estimate>> getAllEstimates() async {
    final db = await instance.database;

    const orderBy = '${EstimateFields.id} DESC';
    final result = await db.query(tableEstimates, orderBy: orderBy);

    return result.map((json) => Estimate.fromJson(json)).toList();
  }

  Future<List<Po>> getAllPo() async {
    final db = await instance.database;

    const orderBy = '${PoFields.id} DESC';
    final result = await db.query(tablePo, orderBy: orderBy);

    return result.map((json) => Po.fromJson(json)).toList();
  }

  Future<List<Receipt>> getAllReceipts() async {
    final db = await instance.database;

    const orderBy = '${ReceiptFields.id} DESC';
    final result = await db.query(tableReceipts, orderBy: orderBy);

    return result.map((json) => Receipt.fromJson(json)).toList();
  }

  Future<int> updatePurchase(Purchase invoice) async {
    final db = await instance.database;

    return db.update(
      tablePurchases,
      invoice.toJson(),
      where: '${PurchaseFields.id} = ?',
      whereArgs: [invoice.id],
    );
  }

  Future<int> deletePurchaseById(int id) async {
    final db = await instance.database;

    return await db.delete(
      tablePurchases,
      where: '${PurchaseFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteEstimateById(int id) async {
    final db = await instance.database;

    return await db.delete(
      tableEstimates,
      where: '${EstimateFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future<int> deletePoById(int id) async {
    final db = await instance.database;

    return await db.delete(
      tablePo,
      where: '${PoFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteReceiptById(int id) async {
    final db = await instance.database;

    return await db.delete(
      tableReceipts,
      where: '${ReceiptFields.id} = ?',
      whereArgs: [id],
    );
  }

  /// End table invoices CRUD operations

  /// Table InvoiceLines CRUD operations
  Future<InvoiceLines> createInvoiceLines(
      InvoiceLines invoiceLines, int recId) async {
    final db = await instance.database;
    final id = await db.insert(tableInvoiceLines, invoiceLines.toJson());

    if (id > 0) {
      return invoiceLines.copy(id: id, recId: recId);
    } else {
      throw Exception('Record NOT created');
    }
  }

  Future<EstimateLines> createEstimateLines(
      EstimateLines estimateLines, int recId) async {
    final db = await instance.database;
    final id = await db.insert(tableEstimateLines, estimateLines.toJson());

    if (id > 0) {
      return estimateLines.copy(id: id, recId: recId);
    } else {
      throw Exception('Record NOT created');
    }
  }

  Future<PoLines> createPoLines(PoLines poLines, int recId) async {
    final db = await instance.database;
    final id = await db.insert(tablePoLines, poLines.toJson());

    if (id > 0) {
      return poLines.copy(id: id, recId: recId);
    } else {
      throw Exception('Record NOT created');
    }
  }

  Future<List<InvoiceLines>> getInvoiceLinesById(int recId) async {
    final db = await instance.database;

    final maps = await db.query(
      tableInvoiceLines,
      columns: InvoiceLinesFields.getInvoiceLinesFields(),
      where: '${InvoiceLinesFields.recId} = ?',
      orderBy: InvoiceLinesFields.id,
      whereArgs: [recId],
    );

    if (maps.isNotEmpty) {
      return maps.map((json) => InvoiceLines.fromJson(json)).toList();
    } else {
      throw Exception('ID $recId not found in the local database');
    }
  }

  Future<List<EstimateLines>> getEstimateLinesById(int recId) async {
    final db = await instance.database;

    final maps = await db.query(
      tableEstimateLines,
      columns: EstimateLinesFields.getEstimateLinesFields(),
      where: '${EstimateLinesFields.recId} = ?',
      orderBy: EstimateLinesFields.id,
      whereArgs: [recId],
    );

    if (maps.isNotEmpty) {
      return maps.map((json) => EstimateLines.fromJson(json)).toList();
    } else {
      throw Exception('ID $recId not found in the local database');
    }
  }

  Future<List<PoLines>> getPoLinesById(int recId) async {
    final db = await instance.database;

    final maps = await db.query(
      tablePoLines,
      columns: PoLinesFields.getPoLinesFields(),
      where: '${PoLinesFields.recId} = ?',
      orderBy: PoLinesFields.id,
      whereArgs: [recId],
    );

    if (maps.isNotEmpty) {
      return maps.map((json) => PoLines.fromJson(json)).toList();
    } else {
      throw Exception('ID $recId not found in the local database');
    }
  }

  Future<List<InvoiceLines>> getAllInvoiceLines() async {
    final db = await instance.database;

    const orderBy = '${InvoiceLinesFields.recId}, ${InvoiceLinesFields.id} ASC';
    final result = await db.query(tableInvoiceLines, orderBy: orderBy);

    return result.map((json) => InvoiceLines.fromJson(json)).toList();
  }

  Future<int> updateInvoiceLines(InvoiceLines invoiceLines) async {
    final db = await instance.database;

    return db.update(
      tableInvoiceLines,
      invoiceLines.toJson(),
      where: '${InvoiceLinesFields.id} = ?',
      whereArgs: [invoiceLines.id],
    );
  }

  Future<int> updateEstimateLines(EstimateLines estimateLines) async {
    final db = await instance.database;

    return db.update(
      tableInvoiceLines,
      estimateLines.toJson(),
      where: '${EstimateLinesFields.id} = ?',
      whereArgs: [estimateLines.id],
    );
  }

  Future<int> updatePoLines(PoLines poLines) async {
    final db = await instance.database;

    return db.update(
      tableInvoiceLines,
      poLines.toJson(),
      where: '${PoLinesFields.id} = ?',
      whereArgs: [poLines.id],
    );
  }

  Future deleteInvoiceLines(int recId) async {
    final db = await instance.database;

    return await db
        .rawQuery('DELETE FROM $tableInvoiceLines WHERE recId=$recId');
  }

  Future deleteEstimateLines(int recId) async {
    final db = await instance.database;

    return await db
        .rawQuery('DELETE FROM $tableEstimateLines WHERE recId=$recId');
  }

  Future deletePoLines(int recId) async {
    final db = await instance.database;

    return await db.rawQuery('DELETE FROM $tablePoLines WHERE recId=$recId');
  }

  /// End table invoiceLines CRUD operations

  Future<String> get version async {
    int? result = await _database?.getVersion();
    String ver = '$result';
    return ver;
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
