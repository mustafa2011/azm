import 'package:flutter/material.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';
import '../apis/constants/utils.dart';
import '../db/fatoora_db.dart';
import '../models/template.dart';
import '../widgets/app_colors.dart';
import '../widgets/loading.dart';

const firstColWidth = 180.0;
const width = 60.0;
const height = 54.0;
const List<String> list = <String>['1', '2', '3', '4', '5'];

class TemplatePage extends StatefulWidget {
  const TemplatePage({
    Key? key,
    // required this.template,
  }) : super(key: key);

  // final TemplateDetails template;

  @override
  State<TemplatePage> createState() => _TemplatePageState();
}

class _TemplatePageState extends State<TemplatePage> {
  List<TemplateDetails> template = [];
  String selectedTemp = '1';
  bool isLoading = false;

  // final TextEditingController _tempId = TextEditingController();
  // final TextEditingController _colName = TextEditingController();
  final TextEditingController _colTop = TextEditingController();
  final TextEditingController _colLeft = TextEditingController();
  final TextEditingController _colWidth = TextEditingController();
  final TextEditingController _colHeight = TextEditingController();
  final TextEditingController _fontSize = TextEditingController();
  final TextEditingController _isBold = TextEditingController();
  final TextEditingController _backColor = TextEditingController();
  final TextEditingController _borderColor = TextEditingController();
  final TextEditingController _fontColor = TextEditingController();
  final TextEditingController _isVisible = TextEditingController();

  @override
  void initState() {
    super.initState();
    getTemplate();
  }

  Future getTemplate() async {

    try {
      setState(() => isLoading = true);
      await FatooraDB.instance
          .getAllTemplates(int.parse(selectedTemp))
          .then((list) => template = list);
      setState(() => isLoading = false);
    } on Exception catch (e) {
      throw Exception(e);
    }
  }

  Widget buildCol(String labelText, TextEditingController controller) =>
      SizedBox(
        width: 70,
        child: TextFormField(
          keyboardType: (labelText == 'backColor' ||
                  labelText == 'borderColor' ||
                  labelText == 'fontColor')
              ? TextInputType.text
              : const TextInputType.numberWithOptions(),
          controller: controller,
          autofocus: true,
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
          onTap: () {
            var textValue = controller.text;
            controller.selection = TextSelection(
              baseOffset: 0,
              extentOffset: textValue.length,
            );
          },
          style: const TextStyle(
            color: AppColor.primary,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          decoration: InputDecoration(
            labelText: labelText,
          ),
        ),
      );

  void updateData(int recId, int index, String colName) {
    _colTop.text = template[index].colTop.toString();
    _colLeft.text = template[index].colLeft.toString();
    _colWidth.text = template[index].colWidth.toString();
    _colHeight.text = template[index].colHeight.toString();
    _fontSize.text = template[index].fontSize.toString();
    _isBold.text = template[index].isBold.toString();
    _backColor.text = template[index].backColor.toString();
    _borderColor.text = template[index].borderColor.toString();
    _fontColor.text = template[index].fontColor.toString();
    _isVisible.text = template[index].isVisible.toString();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          alignment: Alignment.topCenter,
          actionsAlignment: MainAxisAlignment.center,
          title: Row(
            children: [
              const Text('data'),
              Text(
                " '$colName' ",
                style: const TextStyle(
                    color: AppColor.primary, fontWeight: FontWeight.bold),
              ),
              const Text('Update'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Text('Record [${template[index].id}]', textAlign: TextAlign.center,),
                Row(
                  children: [
                    buildCol('fontSize', _fontSize), Utils.space(0,2),
                    buildCol('isBold', _isBold), Utils.space(0,2),
                    buildCol('colTop', _colTop),
                  ],
                ),
                Row(
                  children: [
                    buildCol('colLeft', _colLeft), Utils.space(0,2),
                    buildCol('colHeight', _colHeight), Utils.space(0,2),
                    buildCol('colWidth', _colWidth)
                  ],
                ),
                Row(
                  children: [
                    buildCol('backColor', _backColor), Utils.space(0,2),
                    buildCol('borderColor', _borderColor), Utils.space(0,2),
                    buildCol('fontColor', _fontColor)
                  ],
                ),
                Row(
                  children: [
                    buildCol('isVisible', _isVisible),
                  ],
                ),
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.only(bottom: 20),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: AppColor.primary)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Save",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: AppColor.primary)),
              onPressed: () {
                TemplateDetails temp = TemplateDetails(
                  id: recId,
                  tempId: int.parse(selectedTemp),
                  colName: colName,
                  colTop: num.parse(_colTop.text),
                  colLeft: num.parse(_colLeft.text),
                  colWidth: num.parse(_colWidth.text),
                  colHeight: num.parse(_colHeight.text),
                  fontSize: num.parse(_fontSize.text),
                  isBold: int.parse(_isBold.text),
                  backColor: _backColor.text.isEmpty ? null : _backColor.text,
                  borderColor: _borderColor.text.isEmpty ? null : _borderColor.text,
                  fontColor: _fontColor.text.isEmpty ? null : _fontColor.text,
                  isVisible: int.parse(_isVisible.text),
                );
                FatooraDB.instance.updateTemplateDetails(temp);
                getTemplate();
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
    return Scaffold(
      appBar: AppBar(
          title: Row(mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text(
                'نموذج رقم ',
                style: TextStyle(
                    color: AppColor.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              DropdownButton(
                value: selectedTemp,
                items: list.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: const TextStyle(
                          color: AppColor.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    selectedTemp = value!;
                    getTemplate();
                  });
                },
              ),
            ],
          )),
      body: isLoading
          ? const Loading()
          : HorizontalDataTable(
        leftHandSideColumnWidth: firstColWidth,
        rightHandSideColumnWidth: 600,
        isFixedHeader: true,
        headerWidgets: _getTitleWidget(),
        isFixedFooter: false,
        footerWidgets: _getTitleWidget(),
        leftSideItemBuilder: _generateFirstColumnRow,
        rightSideItemBuilder: _generateRightHandSideColumnRow,
        itemCount: template.length,
        rowSeparatorWidget: const Divider(
          color: Colors.black38,
          height: 1.0,
          thickness: 0.0,
        ),
        leftHandSideColBackgroundColor: const Color(0x00000000),
        rightHandSideColBackgroundColor: const Color(0xFFFFFFFF),
        itemExtent: 55,
      ),
    );
  }

  List<Widget> _getTitleWidget() {
    return [
      _getTitleItemWidget('Name', firstColWidth),
      _getTitleItemWidget('Font size', width),
      _getTitleItemWidget('Bold', width),
      _getTitleItemWidget('Top', width),
      _getTitleItemWidget('Left', width),
      _getTitleItemWidget('Height', width),
      _getTitleItemWidget('Width', width),
      _getTitleItemWidget('Back color', width),
      _getTitleItemWidget('Border color', width),
      _getTitleItemWidget('Font color', width),
      _getTitleItemWidget('Visible', width),
    ];
  }

  Widget _getTitleItemWidget(String label, double width) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
      alignment: Alignment.centerLeft,
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _generateFirstColumnRow(BuildContext context, int index) {
    return InkWell(
      onTap: () =>
          updateData(template[index].id!, index, '${template[index].colName}'),
      child: Container(
        width: firstColWidth,
        height: height,
        padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
        alignment: Alignment.centerLeft,
        child: Text('${template[index].colName}'),
      ),
    );
  }

  Widget _generateRightHandSideColumnRow(BuildContext context, int index) {
    return Row(
      children: <Widget>[
        Container(
          width: width,
          height: height,
          padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
          alignment: Alignment.centerLeft,
          child: Text('${template[index].fontSize}'),
        ),
        // Container(
        //   width: width,
        //   height: height,
        //   padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
        //   alignment: Alignment.centerLeft,
        //   child: Row(
        //     children: <Widget>[
        //       Icon(
        //           template[index].isBold == 1
        //               ? Icons.check_box
        //               : Icons.check_box_outline_blank,
        //           color:
        //               template[index].isBold == 1 ? Colors.green : Colors.red),
        //     ],
        //   ),
        // ),
        Container(
          width: width,
          height: height,
          padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
          alignment: Alignment.centerLeft,
          child: Text('${template[index].isBold}'),
        ),
        Container(
          width: width,
          height: height,
          padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
          alignment: Alignment.centerLeft,
          child: Text('${template[index].colTop}'),
        ),
        Container(
          width: width,
          height: height,
          padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
          alignment: Alignment.centerLeft,
          child: Text('${template[index].colLeft}'),
        ),
        Container(
          width: width,
          height: height,
          padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
          alignment: Alignment.centerLeft,
          child: Text('${template[index].colHeight}'),
        ),
        Container(
          width: width,
          height: height,
          padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
          alignment: Alignment.centerLeft,
          child: Text('${template[index].colWidth}'),
        ),
        Container(
          width: width,
          height: height,
          padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
          alignment: Alignment.centerLeft,
          child: Text('${template[index].backColor}'),
        ),
        Container(
          width: width,
          height: height,
          padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
          alignment: Alignment.centerLeft,
          child: Text('${template[index].borderColor}'),
        ),
        Container(
          width: width,
          height: height,
          padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
          alignment: Alignment.centerLeft,
          child: Text('${template[index].fontColor}'),
        ),
        Container(
          width: width,
          height: height,
          padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
          alignment: Alignment.centerLeft,
          child: Text('${template[index].isVisible}'),
        ),
      ],
    );
  }
}
