import 'dart:convert';

class ClientFields {
  static const String id = 'id';
  static const String name = 'name';
  static const String email = 'email';
  static const String password = 'password';
  static const String cellphone = 'cellphone';
  static const String seller = 'seller';
  static const String vatNumber = 'vatNumber';
  static const String sheetId = 'sheetId';
  static const String activationCode = 'activationCode';
  static const String startDateTime = 'startDateTime';
  static const String paidAmount = 'paidAmount';

  static List<String> getClientFields() => [
    id,
    name,
    email,
    password,
    cellphone,
    seller,
    vatNumber,
    sheetId,
    activationCode,
    startDateTime,
    paidAmount,
  ];
}

class Client {
  final int? id;
  final String name;
  final String email;
  final String password;
  final String cellphone;
  final String seller;
  final String vatNumber;
  final String sheetId;
  final String activationCode;
  final String startDateTime;
  final int paidAmount;

  const Client({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.cellphone,
    required this.seller,
    this.vatNumber = '',
    required this.sheetId,
    required this.activationCode,
    required this.startDateTime,
    this.paidAmount = 0,
  });

  Client copy({
    int? id,
    String? name,
    String? email,
    String? password,
    String? cellphone,
    String? seller,
    String? vatNumber,
    String? sheetId,
    String? activationCode,
    String? startDateTime,
    int? paidAmount,
  }) =>
      Client(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        password: password ?? this.password,
        cellphone: cellphone ?? this.cellphone,
        seller: seller ?? this.seller,
        vatNumber: vatNumber ?? this.vatNumber,
        sheetId: sheetId ?? this.sheetId,
        activationCode: activationCode ?? this.activationCode,
        startDateTime: startDateTime ?? this.startDateTime,
        paidAmount: paidAmount ?? this.paidAmount,
      );

  factory Client.fromJson(dynamic json) {
    return Client(
      id: jsonDecode(json[ClientFields.id]),
      name: json[ClientFields.name],
      email: json[ClientFields.email],
      password: json[ClientFields.password],
      cellphone: json[ClientFields.cellphone],
      seller: json[ClientFields.seller],
      vatNumber: json[ClientFields.vatNumber],
      sheetId: json[ClientFields.sheetId],
      activationCode: json[ClientFields.activationCode],
      startDateTime: json[ClientFields.startDateTime],
      paidAmount: jsonDecode(json[ClientFields.paidAmount]),
    );
  }

  Map<String, dynamic> toJson() => {
    ClientFields.id: id,
    ClientFields.name: name,
    ClientFields.email: email,
    ClientFields.password: password,
    ClientFields.cellphone: cellphone,
    ClientFields.seller: seller,
    ClientFields.vatNumber: vatNumber,
    ClientFields.sheetId: sheetId,
    ClientFields.activationCode: activationCode,
    ClientFields.startDateTime: startDateTime,
    ClientFields.paidAmount: paidAmount,
  };
}
