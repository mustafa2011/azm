const String tableSettings = 'settings';

class SettingFields {
  static const String id = '_id';
  static const String name = 'name';
  static const String email = 'email';
  static const String password = 'password';
  static const String cellphone = 'cellphone';
  static const String seller = 'seller';
  static const String sheetId = 'sheetId';
  static const String workOffline = 'workOffline';
  static const String activationCode = 'activationCode';
  static const String startDateTime = 'startDateTime';
  static const String buildingNo = 'buildingNo';
  static const String streetName = 'streetName';
  static const String district = 'district';
  static const String city = 'city';
  static const String country = 'country';
  static const String postalCode = 'postalCode';
  static const String additionalNo = 'additionalNo';
  static const String vatNumber = 'vatNumber';
  static const String logo = 'logo';
  static const String defaultInvoiceTemp = 'defaultInvoiceTemp';
  static const String invoiceTemp1 = 'invoiceTemp1';
  static const String invoiceTemp2 = 'invoiceTemp2';
  static const String invoiceTemp3 = 'invoiceTemp3';
  static const String invoiceTemp4 = 'invoiceTemp4';
  static const String invoiceTemp5 = 'invoiceTemp5';
  static const String terms = 'terms';
  static const String terms1 = 'terms1';
  static const String terms2 = 'terms2';
  static const String terms3 = 'terms3';
  static const String terms4 = 'terms4';
  static const String logoWidth = 'logoWidth';
  static const String logoHeight = 'logoHeight';
  static const String showVat = 'showVat';
  static const String printerName = 'printerName';
  static const String paperSize = 'paperSize';
  static const String optionsCode = 'optionsCode';
  static const String defaultPayment = 'defaultPayment';
  static const String language = 'language';
  static const String freeText2 = 'freeText2';
  static const String freeText3 = 'freeText3';
  static const String freeText4 = 'freeText4';
  static const String freeText5 = 'freeText5';
  static const String freeText6 = 'freeText6';
  static const String freeText7 = 'freeText7';
  static const String freeText8 = 'freeText8';
  static const String freeText9 = 'freeText9';
  static const String freeText10 = 'freeText10';
  static const String sellerNameEn = 'sellerNameEn';
  static const String sellerActivityAr = 'sellerActivityAr';
  static const String sellerActivityEn = 'sellerActivityEn';
  static const String sellerAddress = 'sellerAddress';
  static const String sellerCr = 'sellerCr';

  static final List<String> values = [
    id,
    name,
    email,
    password,
    cellphone,
    seller,
    sheetId,
    workOffline,
    activationCode,
    startDateTime,
    buildingNo,
    streetName,
    district,
    city,
    country,
    postalCode,
    additionalNo,
    vatNumber,
    logo,
    invoiceTemp1,
    invoiceTemp2,
    invoiceTemp3,
    invoiceTemp4,
    invoiceTemp5,
    terms,
    terms1,
    terms2,
    terms3,
    terms4,
    logoWidth,
    logoHeight,
    showVat,
    printerName,
    paperSize,
    optionsCode,
    defaultPayment,
    language,
    freeText2,
    freeText3,
    freeText4,
    freeText5,
    freeText6,
    freeText7,
    freeText8,
    freeText9,
    freeText10,
    sellerNameEn,
    sellerActivityAr,
    sellerActivityEn,
    sellerAddress,
    sellerCr
  ];
}

class Setting {
  final int? id;
  final String name;
  final String email;
  final String password;
  final String cellphone;
  final String seller;
  final String sheetId;
  final int workOffline;
  final String activationCode;
  final String startDateTime;
  final String buildingNo;
  final String streetName;
  final String district;
  final String city;
  final String country;
  final String postalCode;
  final String additionalNo;
  final String vatNumber;
  final String logo;
  final String defaultInvoiceTemp;
  final String invoiceTemp1;
  final String invoiceTemp2;
  final String invoiceTemp3;
  final String invoiceTemp4;
  final String invoiceTemp5;
  final String terms;
  final String terms1;
  final String terms2;
  final String terms3;
  final String terms4;
  final int logoWidth;
  final int logoHeight;
  final int showVat;
  final String printerName;
  final String paperSize;
  final String optionsCode;
  final String defaultPayment;
  final String language;
  final String freeText2;
  final String freeText3;
  final String freeText4;
  final String freeText5;
  final String freeText6;
  final String freeText7;
  final String freeText8;
  final String freeText9;
  final String freeText10;
  final String sellerNameEn;
  final String sellerActivityAr;
  final String sellerActivityEn;
  final String sellerAddress;
  final String sellerCr;

  const Setting({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.cellphone,
    required this.seller,
    this.sheetId = '',
    this.workOffline = 0,
    required this.activationCode,
    required this.startDateTime,
    this.buildingNo = '',
    this.streetName = '',
    this.district = '',
    this.city = 'الرياض',
    this.country = 'السعودية',
    this.postalCode = '',
    this.additionalNo = '',
    this.vatNumber = '',
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
    this.printerName = '',
    this.paperSize = '',
    this.optionsCode = '',
    this.defaultPayment = '',
    this.language = 'Arabic',
    this.freeText2 = '',
    this.freeText3 = '',
    this.freeText4 = '',
    this.freeText5 = '',
    this.freeText6 = '',
    this.freeText7 = '',
    this.freeText8 = '',
    this.freeText9 = '',
    this.freeText10 = '',
    this.sellerNameEn = '',
    this.sellerActivityAr = '',
    this.sellerActivityEn = '',
    this.sellerAddress = '',
    this.sellerCr = '',

  });

  Setting copy({
    int? id,
    String? name,
    String? email,
    String? password,
    String? cellphone,
    String? seller,
    String? sheetId,
    int? workOffline,
    String? activationCode,
    String? startDateTime,
    String? buildingNo,
    String? streetName,
    String? district,
    String? city,
    String? country,
    String? postalCode,
    String? additionalNo,
    String? vatNumber,
    String? logo,
    String? defaultInvoiceTemp,
    String? invoiceTemp1,
    String? invoiceTemp2,
    String? invoiceTemp3,
    String? invoiceTemp4,
    String? invoiceTemp5,
    String? terms,
    String? terms1,
    String? terms2,
    String? terms3,
    String? terms4,
    int? logoWidth,
    int? logoHeight,
    int? showVat,
    String? printerName,
    String? paperSize,
    String? optionsCode,
    String? defaultPayment,
    String? language,
    String? freeText2,
    String? freeText3,
    String? freeText4,
    String? freeText5,
    String? freeText6,
    String? freeText7,
    String? freeText8,
    String? freeText9,
    String? freeText10,
    String? sellerNameEn,
    String? sellerActivityAr,
    String? sellerActivityEn,
    String? sellerAddress,
    String? sellerCr,
  }) =>
      Setting(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        password: password ?? this.password,
        cellphone: cellphone ?? this.cellphone,
        seller: seller ?? this.seller,
        sheetId: sheetId ?? this.sheetId,
        workOffline: workOffline ?? this.workOffline,
        activationCode: activationCode ?? this.activationCode,
        startDateTime: startDateTime ?? this.startDateTime,
        buildingNo: buildingNo ?? this.buildingNo,
        streetName: streetName ?? this.streetName,
        district: district ?? this.district,
        city: city ?? this.city,
        country: country ?? this.country,
        postalCode: postalCode ?? this.postalCode,
        additionalNo: additionalNo ?? this.additionalNo,
        vatNumber: vatNumber ?? this.vatNumber,
        logo: logo ?? this.logo,
        defaultInvoiceTemp: defaultInvoiceTemp ?? this.defaultInvoiceTemp,
        invoiceTemp1: invoiceTemp1 ?? this.invoiceTemp1,
        invoiceTemp2: invoiceTemp2 ?? this.invoiceTemp2,
        invoiceTemp3: invoiceTemp3 ?? this.invoiceTemp3,
        invoiceTemp4: invoiceTemp4 ?? this.invoiceTemp4,
        invoiceTemp5: invoiceTemp5 ?? this.invoiceTemp5,
        terms: terms ?? this.terms,
        terms1: terms1 ?? this.terms1,
        terms2: terms2 ?? this.terms2,
        terms3: terms3 ?? this.terms3,
        terms4: terms4 ?? this.terms4,
        logoWidth: logoWidth ?? this.logoWidth,
        logoHeight: logoHeight ?? this.logoHeight,
        showVat: showVat ?? this.showVat,
        printerName: printerName ?? this.printerName,
        paperSize: paperSize ?? this.paperSize,
        optionsCode: optionsCode ?? this.optionsCode,
        defaultPayment: defaultPayment ?? this.defaultPayment,
        language: language ?? this.language,
        freeText2: freeText2 ?? this.freeText2,
        freeText3: freeText3 ?? this.freeText3,
        freeText4: freeText4 ?? this.freeText4,
        freeText5: freeText5 ?? this.freeText5,
        freeText6: freeText6 ?? this.freeText6,
        freeText7: freeText7 ?? this.freeText7,
        freeText8: freeText8 ?? this.freeText8,
        freeText9: freeText9 ?? this.freeText9,
        freeText10: freeText10 ?? this.freeText10,
        sellerNameEn: sellerNameEn ?? this.sellerNameEn,
        sellerActivityAr: sellerActivityAr ?? this.sellerActivityAr,
        sellerActivityEn: sellerActivityEn ?? this.sellerActivityEn,
        sellerAddress: sellerAddress ?? this.sellerAddress,
        sellerCr: sellerCr ?? this.sellerCr,
      );

  factory Setting.fromJson(dynamic json) {
    return Setting(
      id: json[SettingFields.id] as int,
      name: json[SettingFields.name] as String,
      email: json[SettingFields.email] as String,
      password: json[SettingFields.password] as String,
      cellphone: json[SettingFields.cellphone] as String,
      seller: json[SettingFields.seller] as String,
      sheetId: json[SettingFields.sheetId] as String,
      workOffline: json[SettingFields.workOffline] as int,
      activationCode: json[SettingFields.activationCode] ?? '',
      startDateTime: json[SettingFields.startDateTime] as String,
      buildingNo: json[SettingFields.buildingNo] ?? '',
      streetName: json[SettingFields.streetName] ?? '',
      district: json[SettingFields.district] ?? '',
      city: json[SettingFields.city] ?? '',
      country: json[SettingFields.country] ?? '',
      postalCode: json[SettingFields.postalCode] ?? '',
      additionalNo: json[SettingFields.additionalNo] ?? '',
      vatNumber: json[SettingFields.vatNumber] as String,
      logo: json[SettingFields.logo] ?? '',
      defaultInvoiceTemp: json[SettingFields.defaultInvoiceTemp] ?? '',
      invoiceTemp1: json[SettingFields.invoiceTemp1] ?? '',
      invoiceTemp2: json[SettingFields.invoiceTemp2] ?? '',
      invoiceTemp3: json[SettingFields.invoiceTemp3] ?? '',
      invoiceTemp4: json[SettingFields.invoiceTemp4] ?? '',
      invoiceTemp5: json[SettingFields.invoiceTemp5] ?? '',
      terms: json[SettingFields.terms] ?? '',
      terms1: json[SettingFields.terms1] ?? '',
      terms2: json[SettingFields.terms2] ?? '',
      terms3: json[SettingFields.terms3] ?? '',
      terms4: json[SettingFields.terms4] ?? '',
      logoWidth: json[SettingFields.logoWidth] as int,
      logoHeight: json[SettingFields.logoHeight] as int,
      showVat: json[SettingFields.showVat] as int,
      printerName: json[SettingFields.printerName] ?? '',
      paperSize: json[SettingFields.paperSize] ?? '',
      optionsCode: json[SettingFields.optionsCode] ?? '',
      defaultPayment: json[SettingFields.defaultPayment] ?? '',
      language: json[SettingFields.language] ?? '',
      freeText2: json[SettingFields.freeText2] ?? '',
      freeText3: json[SettingFields.freeText3] ?? '',
      freeText4: json[SettingFields.freeText4] ?? '',
      freeText5: json[SettingFields.freeText5] ?? '',
      freeText6: json[SettingFields.freeText6] ?? '',
      freeText7: json[SettingFields.freeText7] ?? '',
      freeText8: json[SettingFields.freeText8] ?? '',
      freeText9: json[SettingFields.freeText9] ?? '',
      freeText10: json[SettingFields.freeText10] ?? '',
      sellerNameEn: json[SettingFields.sellerNameEn] ?? '',
      sellerActivityAr: json[SettingFields.sellerActivityAr] ?? '',
      sellerActivityEn: json[SettingFields.sellerActivityEn] ?? '',
      sellerAddress: json[SettingFields.sellerAddress] ?? '',
      sellerCr: json[SettingFields.sellerCr] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        SettingFields.id: id,
        SettingFields.name: name,
        SettingFields.email: email,
        SettingFields.password: password,
        SettingFields.cellphone: cellphone,
        SettingFields.seller: seller,
        SettingFields.sheetId: sheetId,
        SettingFields.workOffline: workOffline,
        SettingFields.activationCode: activationCode,
        SettingFields.startDateTime: startDateTime,
        SettingFields.buildingNo: buildingNo,
        SettingFields.streetName: streetName,
        SettingFields.district: district,
        SettingFields.city: city,
        SettingFields.country: country,
        SettingFields.postalCode: postalCode,
        SettingFields.additionalNo: additionalNo,
        SettingFields.vatNumber: vatNumber,
        SettingFields.logo: logo,
        SettingFields.defaultInvoiceTemp: defaultInvoiceTemp,
        SettingFields.invoiceTemp1: invoiceTemp1,
        SettingFields.invoiceTemp2: invoiceTemp2,
        SettingFields.invoiceTemp3: invoiceTemp3,
        SettingFields.invoiceTemp4: invoiceTemp4,
        SettingFields.invoiceTemp5: invoiceTemp5,
        SettingFields.terms: terms,
        SettingFields.terms1: terms1,
        SettingFields.terms2: terms2,
        SettingFields.terms3: terms3,
        SettingFields.terms4: terms4,
        SettingFields.logoWidth: logoWidth,
        SettingFields.logoHeight: logoHeight,
        SettingFields.showVat: showVat,
        SettingFields.printerName: printerName,
        SettingFields.paperSize: paperSize,
        SettingFields.optionsCode: optionsCode,
        SettingFields.defaultPayment: defaultPayment,
        SettingFields.language: language,
        SettingFields.freeText2: freeText2,
        SettingFields.freeText3: freeText3,
        SettingFields.freeText4: freeText4,
        SettingFields.freeText5: freeText5,
        SettingFields.freeText6: freeText6,
        SettingFields.freeText7: freeText7,
        SettingFields.freeText8: freeText8,
        SettingFields.freeText9: freeText9,
        SettingFields.freeText10: freeText10,
        SettingFields.sellerNameEn: sellerNameEn,
        SettingFields.sellerActivityAr: sellerActivityAr,
        SettingFields.sellerActivityEn: sellerActivityEn,
        SettingFields.sellerAddress: sellerAddress,
        SettingFields.sellerCr: sellerCr,
  };
}