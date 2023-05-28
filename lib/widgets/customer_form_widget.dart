import 'package:flutter/material.dart';

import 'app_colors.dart';

class CustomerFormWidget extends StatelessWidget {
  final String vatNumber;
  final String? name;
  final String? buildingNo;
  final String? streetName;
  final String? district;
  final String? city;
  final String? country;
  final String? postalCode;
  final String? additionalNo;
  final String? contactNumber;
  final ValueChanged<String> onChangedBuildingNo;
  final ValueChanged<String> onChangedStreetName;
  final ValueChanged<String> onChangedDistrict;
  final ValueChanged<String> onChangedCity;
  final ValueChanged<String> onChangedCountry;
  final ValueChanged<String> onChangedPostalCode;
  final ValueChanged<String> onChangedAdditionalNo;
  final ValueChanged<String> onChangedVatNumber;
  final ValueChanged<String> onChangedName;
  final ValueChanged<String> onChangedContactNumber;

  const CustomerFormWidget({
    Key? key,
    this.vatNumber = '',
    this.name = '',
    this.buildingNo = '',
    this.streetName = '',
    this.district = '',
    this.city = 'الرياض',
    this.country = 'المملكة العربية السعوية',
    this.postalCode = '',
    this.additionalNo,
    this.contactNumber = '',
    required this.onChangedBuildingNo,
    required this.onChangedStreetName,
    required this.onChangedDistrict,
    required this.onChangedCity,
    required this.onChangedCountry,
    required this.onChangedPostalCode,
    required this.onChangedAdditionalNo,
    required this.onChangedVatNumber,
    required this.onChangedName,
    required this.onChangedContactNumber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(child: buildName()),
                  const SizedBox(width: 20),
                  Expanded(child: buildContactNumber()),
                ],
              ),
              Row(
                children: [
                  Expanded(child: buildVatNumber()),
                  const SizedBox(width: 20),
                  Expanded(child: buildBuildingNo()),
                ],
              ),
              Row(
                children: [
                  Expanded(child: buildStreetName()),
                  const SizedBox(width: 20),
                  Expanded(child: buildDistrict()),
                ],
              ),
              Row(
                children: [
                  Expanded(child: buildCity()),
                  const SizedBox(width: 20),
                  Expanded(child: buildCountry()),
                ],
              ),
              Row(
                children: [
                  Expanded(child: buildPostalCode()),
                  const SizedBox(width: 20),
                  Expanded(child: buildAdditionalNo()),
                ],
              ),
            ],
          ),
        ),
      );

  Widget buildName() => TextFormField(
        initialValue: name,
        keyboardType: TextInputType.name,
        style: const TextStyle(
          color: AppColor.primary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        decoration: const InputDecoration(
          labelText: 'اسم العميل',
        ),
        validator: (name) =>
            name != null && name.isEmpty ? 'يجب إدخال اسم الصنف' : null,
        onChanged: onChangedName,
      );

  Widget buildContactNumber() => TextFormField(
        maxLines: 1,
        initialValue: contactNumber,
        keyboardType: TextInputType.phone,
        style: const TextStyle(
          color: AppColor.primary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        decoration: const InputDecoration(
          labelText: 'رقم الجوال',
        ),
        validator: (contactNumber) =>
            contactNumber != null && contactNumber.isEmpty
                ? 'يجب أدخال رقم الجوال'
                : null,
        onChanged: onChangedContactNumber,
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
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        initialValue: vatNumber.toString(),
        style: const TextStyle(
          color: AppColor.primary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        decoration: const InputDecoration(
          labelText: 'الرقم الضريبي',
        ),
        validator: (vatNumber) => vatNumber == null || vatNumber == ''
            ? 'يجب إدخال الرقم الضريبي'
            : null,
        onChanged: (vatNumber) => onChangedVatNumber(vatNumber),
      );
}
