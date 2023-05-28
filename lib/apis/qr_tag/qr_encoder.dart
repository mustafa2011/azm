import 'dart:convert';

import './invoice_date.dart';
import './invoice_tax_amount.dart';
import './invoice_total_amount.dart';
import './seller.dart';
import './tax_number.dart';


class QRBarcodeEncoder {
  QRBarcodeEncoder() {
    //Factory method pattern
  }

  static String encode(Seller seller,
      TaxNumber taxNumber,
      InvoiceDate invoiceDate,
      InvoiceTotalAmount invoiceTotalAmount,
      InvoiceTaxAmount invoiceTaxAmount,
      ) {
    return toBase64(toTLV(
        seller, taxNumber, invoiceDate, invoiceTotalAmount, invoiceTaxAmount));
  }


  static String decode(Seller seller,
      TaxNumber taxNumber,
      InvoiceDate invoiceDate,
      InvoiceTotalAmount invoiceTotalAmount,
      InvoiceTaxAmount invoiceTaxAmount,
      ) {
    return toBase64Decode(toTLV(
        seller, taxNumber, invoiceDate, invoiceTotalAmount, invoiceTaxAmount));
  }

  static String toTLV(Seller seller,
      TaxNumber taxNumber,
      InvoiceDate invoiceDate,
      InvoiceTotalAmount invoiceTotalAmount,
      InvoiceTaxAmount invoiceTaxAmount) {
    return seller.toString() +
        taxNumber.toString() +
        invoiceDate.toString() +
        invoiceTotalAmount.toString() +
        invoiceTaxAmount.toString();
  }

  static String toBase64(String tlvString) {
    Codec<String, String> stringToBase64 = utf8.fuse(base64);

    var encoded = stringToBase64.encode(tlvString) ;
    return encoded;
  }

  static String toBase64Decode(String tlvString) {
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    String decode = stringToBase64.decode(tlvString);
    return decode;
  }

}
