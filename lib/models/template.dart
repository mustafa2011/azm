const String tableTemplate = 'template';
const String tableTemplateDetails = 'templateDetails';

class TemplateFields {
  static const String id = 'id';
  static const String tempName = 'tempName';

  static List<String> getTemplateFields() => [id, tempName];
}

class Template {
  int? id;
  String? tempName;

  Template({
    this.id,
    this.tempName,
  });

  Template copy({
    int? id,
    String? tempName,
  }) =>
      Template(
        id: id ?? this.id,
        tempName: tempName ?? this.tempName,
      );

  factory Template.fromJson(dynamic json) {
    return Template(
      id: json[TemplateFields.id] as int,
      tempName: json[TemplateFields.tempName],
    );
  }

  Map<String, dynamic> toJson() => {
        TemplateFields.id: id,
        TemplateFields.tempName: tempName,
      };
}

class TemplateDetailsFields {
  static const String id = 'id';
  static const String tempId = 'tempId';
  static const String colName = 'colName';
  static const String colTop = 'colTop';
  static const String colLeft = 'colLeft';
  static const String colWidth = 'colWidth';
  static const String colHeight = 'colHeight';
  static const String fontSize = 'fontSize';
  static const String isBold = 'isBold';
  static const String backColor = 'backColor';
  static const String borderColor = 'borderColor';
  static const String fontColor = 'fontColor';
  static const String isVisible = 'isVisible';

  static List<String> getTemplateDetailsFields() => [
        id,
        tempId,
        colName,
        colTop,
        colLeft,
        colWidth,
        colHeight,
        fontSize,
        isBold,
        backColor,
        borderColor,
        fontColor,
        isVisible
      ];
}

class TemplateDetails {
  int? id;
  int? tempId;
  String? colName;
  num? colTop;
  num? colLeft;
  num? colWidth;
  num? colHeight;
  num? fontSize;
  int? isBold;
  String? backColor;
  String? borderColor;
  String? fontColor;
  int? isVisible;

  TemplateDetails({
    this.id,
    this.tempId,
    this.colName,
    this.colTop,
    this.colLeft,
    this.colWidth,
    this.colHeight,
    this.fontSize,
    this.isBold,
    this.backColor,
    this.borderColor,
    this.fontColor,
    this.isVisible,
  });

  TemplateDetails copy({
    int? id,
    int? tempId,
    String? colName,
    num? colTop,
    num? colLeft,
    num? colWidth,
    num? colHeight,
    num? fontSize,
    int? isBold,
    String? backColor,
    String? borderColor,
    String? fontColor,
    int? isVisible,
  }) =>
      TemplateDetails(
        id: id ?? this.id,
        tempId: tempId ?? this.tempId,
        colName: colName ?? this.colName,
        colTop: colTop ?? this.colTop,
        colLeft: colLeft ?? this.colLeft,
        colWidth: colWidth ?? this.colWidth,
        colHeight: colHeight ?? this.colHeight,
        fontSize: fontSize ?? this.fontSize,
        isBold: isBold ?? this.isBold,
        backColor: backColor ?? this.backColor,
        borderColor: borderColor ?? this.borderColor,
        fontColor: fontColor ?? this.fontColor,
        isVisible: isVisible ?? this.isVisible,
      );

  factory TemplateDetails.fromJson(dynamic json) {
    return TemplateDetails(
      id: json[TemplateDetailsFields.id] as int,
      tempId: json[TemplateDetailsFields.tempId] as int,
      colName: json[TemplateDetailsFields.colName],
      colTop: json[TemplateDetailsFields.colTop] as num,
      colLeft: json[TemplateDetailsFields.colLeft] as num,
      colWidth: json[TemplateDetailsFields.colWidth] as num,
      colHeight: json[TemplateDetailsFields.colHeight] as num,
      fontSize: json[TemplateDetailsFields.fontSize] as num,
      isBold: json[TemplateDetailsFields.isBold] as int,
      backColor: json[TemplateDetailsFields.backColor],
      borderColor: json[TemplateDetailsFields.borderColor],
      fontColor: json[TemplateDetailsFields.fontColor],
      isVisible: json[TemplateDetailsFields.isVisible] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        TemplateDetailsFields.id: id,
        TemplateDetailsFields.tempId: tempId,
        TemplateDetailsFields.colName: colName,
        TemplateDetailsFields.colTop: colTop,
        TemplateDetailsFields.colLeft: colLeft,
        TemplateDetailsFields.colWidth: colWidth,
        TemplateDetailsFields.colHeight: colHeight,
        TemplateDetailsFields.fontSize: fontSize,
        TemplateDetailsFields.isBold: isBold,
        TemplateDetailsFields.backColor: backColor,
        TemplateDetailsFields.borderColor: borderColor,
        TemplateDetailsFields.fontColor: fontColor,
        TemplateDetailsFields.isVisible: isVisible,
      };
}
