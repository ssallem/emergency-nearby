import 'dart:developer';

import 'package:xml/xml.dart' as xml;

class EmergencyHeader {
  final String resultCode;
  final String resultMsg;

  EmergencyHeader({
    required this.resultCode,
    required this.resultMsg,
  });

  factory EmergencyHeader.fromXml(xml.XmlElement xml) {
    return EmergencyHeader(
      resultCode: xml.findElements('resultCode').first.text,
      resultMsg: xml.findElements('resultMsg').first.text,
    );
  }
}

class EmergencyItem {
  final String dutyName;
  final String dutyTel3;
  final String hpid;
  final String? hv10;
  final String? hv11;
  final String? hvec;
  final String? hvgc;
  final String? hvamyn;
  final String? hvangioayn;
  final String? hvventiayn;
  final String hvidate;
  final String phpid;
  final String rnum;

  EmergencyItem({
    required this.dutyName,
    required this.dutyTel3,
    required this.hpid,
    this.hv10,
    this.hv11,
    this.hvec,
    this.hvgc,
    this.hvamyn,
    this.hvangioayn,
    this.hvventiayn,
    required this.hvidate,
    required this.phpid,
    required this.rnum,
  });

  factory EmergencyItem.fromXml(xml.XmlElement xmlElement) {
    // 존재하지 않는 경우 null 또는 기본값 처리
    String getTextOrDefault(String tagName, {String defaultValue = 'N/A'}) {
      final element = xmlElement.findElements(tagName);
      return element.isNotEmpty ? element.first.text : defaultValue;
    }

    String? getOptionalText(String tagName) {
      final element = xmlElement.findElements(tagName);
      return element.isNotEmpty ? element.first.text : null;
    }

    return EmergencyItem(
      dutyName: getTextOrDefault('dutyName'),
      dutyTel3: getTextOrDefault('dutyTel3'),
      hpid: getTextOrDefault('hpid'),
      hv10: getOptionalText('hv10'),
      hv11: getOptionalText('hv11'),
      hvec: getTextOrDefault('hvec'),
      hvgc: getTextOrDefault('hvgc'),
      hvamyn: getTextOrDefault('hvamyn'),
      hvangioayn: getOptionalText('hvangioayn'),
      hvventiayn: getOptionalText('hvventiayn'),
      hvidate: getTextOrDefault('hvidate'),
      phpid: getTextOrDefault('phpid'),
      rnum: getTextOrDefault('rnum'),
    );
  }
}

class EmergencyBody {
  final List<EmergencyItem> items;
  final int numOfRows;
  final int pageNo;
  final int totalCount;

  EmergencyBody({
    required this.items,
    required this.numOfRows,
    required this.pageNo,
    required this.totalCount,
  });

  factory EmergencyBody.fromXml(xml.XmlElement xml) {
    final items = xml.findAllElements('item').map((item) {
      return EmergencyItem.fromXml(item);
    }).toList();

    return EmergencyBody(
      items: items,
      numOfRows: int.parse(xml.findElements('numOfRows').first.text),
      pageNo: int.parse(xml.findElements('pageNo').first.text),
      totalCount: int.parse(xml.findElements('totalCount').first.text),
    );
  }
}

class EmergencyResponse {
  final EmergencyHeader header;
  final EmergencyBody body;

  EmergencyResponse({
    required this.header,
    required this.body,
  });

  factory EmergencyResponse.fromXml(xml.XmlElement xml) {
    final header = EmergencyHeader.fromXml(xml.findElements('header').first);
    final body = EmergencyBody.fromXml(xml.findElements('body').first);

    log(xml.findElements('header').first.toString());
    log(xml.findElements('body').first.toString());

    return EmergencyResponse(
      header: header,
      body: body,
    );
  }
}
