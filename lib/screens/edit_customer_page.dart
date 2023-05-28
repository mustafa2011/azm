import '../db/fatoora_db.dart';
import '../models/customers.dart';
import '../models/settings.dart';
import '../screens/customers_page.dart';
import '../widgets/app_colors.dart';
import '../widgets/customer_form_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddEditCustomerPage extends StatefulWidget {
  final dynamic customer;

  const AddEditCustomerPage({
    Key? key,
    this.customer,
  }) : super(key: key);

  @override
  State<AddEditCustomerPage> createState() => _AddEditCustomerPageState();
}

class _AddEditCustomerPageState extends State<AddEditCustomerPage> {
  final _formKey = GlobalKey<FormState>();
  late String name;
  late String vatNumber;
  String buildingNo = '';
  String streetName = '';
  String district = '';
  String city = '';
  String country = '';
  String postalCode = '';
  String additionalNo = '';
  String contactNumber = '';

  int workOffline = 0;

  @override
  void initState() {
    super.initState();
    name = widget.customer?.name ?? '';
    vatNumber = widget.customer?.vatNumber??'';
    buildingNo = widget.customer?.buildingNo??'';
    streetName = widget.customer?.streetName??'';
    district = widget.customer?.district??'';
    city = widget.customer?.city??'';
    country = widget.customer?.country??'';
    postalCode = widget.customer?.postalCode??'';
    additionalNo = widget.customer?.additionalNo??'';
    contactNumber = widget.customer?.contactNumber??'';

  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          actions: [buildButton()],
        ),
        body: Form(
          key: _formKey,
          child: CustomerFormWidget(
            vatNumber: vatNumber,
            name: name,
            buildingNo: buildingNo,
            streetName: streetName,
            district: district,
            city: city,
            country: country,
            postalCode: postalCode,
            additionalNo: additionalNo,
            contactNumber: contactNumber,
            onChangedVatNumber: (vatNumber) => setState(() => this.vatNumber = vatNumber),
            onChangedBuildingNo: (buildingNo) => setState(() => this.buildingNo = buildingNo),
            onChangedStreetName: (streetName) => setState(() => this.streetName = streetName),
            onChangedDistrict: (district) => setState(() => this.district = district),
            onChangedCity: (city) => setState(() => this.city = city),
            onChangedCountry: (country) => setState(() => this.country = country),
            onChangedPostalCode: (postalCode) => setState(() => this.postalCode = postalCode),
            onChangedAdditionalNo: (additionalNo) => setState(() => this.additionalNo = additionalNo),
            onChangedContactNumber: (contactNumber) => setState(() => this.contactNumber = contactNumber),
            onChangedName: (name) => setState(() => this.name = name),
          ),
        ),
      );

  Widget buildButton() {
    final isFormValid = name.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: AppColor.background, backgroundColor: isFormValid ? AppColor.primary : Colors.grey.shade700,
        ),
        onPressed: addOrUpdateCustomer,
        child: const Text('حفظ'),
      ),
    );
  }

  void addOrUpdateCustomer() async {
    final isValid = _formKey.currentState!.validate();

    if (isValid) {
      final isUpdating = widget.customer != null;

      if (isUpdating) {
        await updateCustomer();
      } else {
        await addCustomer();
      }

      Get.to(()=>const CustomersPage());
    }
  }

  Future updateCustomer() async {
    List<Setting> setting;
    setting = await FatooraDB.instance.getAllSettings();
    if(setting.isNotEmpty){
      setState(() {
        workOffline = setting[0].workOffline;
      });
    }

    if (workOffline==1) {
      final customer = widget.customer!.copy(
        vatNumber: vatNumber,
        name: name,
        buildingNo: buildingNo,
        streetName: streetName,
        district: district,
        city: city,
        country: country,
        postalCode: postalCode,
        additionalNo: additionalNo,
        contactNumber: contactNumber,
      );
      await FatooraDB.instance.updateCustomer(customer);
    }
  }

  Future addCustomer() async {
    List<Setting> setting;
    setting = await FatooraDB.instance.getAllSettings();
    if(setting.isNotEmpty){
      setState(() {
        workOffline = setting[0].workOffline;
      });
    }

    if (workOffline==1) {
      final customer = Customer(
        name: name,
        vatNumber: vatNumber,
        buildingNo: buildingNo,
        streetName: streetName,
        district: district,
        city: city,
        country: country,
        postalCode: postalCode,
        additionalNo: additionalNo,
        contactNumber: contactNumber,
      );
      await FatooraDB.instance.createCustomer(customer);
    }
  }
}
