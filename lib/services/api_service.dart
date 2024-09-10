// ignore_for_file: deprecated_member_use

import 'dart:developer';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

import '../models/emergency_request.dart';
import '../models/emergency_response.dart';

class ApiService {
  static const String _baseUrl =
      'https://apis.data.go.kr/B552657/ErmctInfoInqireService/getEmrrmRltmUsefulSckbdInfoInqire';
  static const String _serviceKey =
      'B83lUbYvyWdALbF5m3K4XjkmcjOnUoSS7%2FnwjHGidghguCXukwVdXEqMrw%2F%2FPzKsY%2F4FzMeOSInHgJxIwZf5Qg%3D%3D';

  Future<EmergencyResponse?> fetchEmergencyRoomInfo(
      EmergencyRequest request) async {
    String url = '$_baseUrl'
        '?ServiceKey=$_serviceKey'
        '&STAGE1=${request.stage1}'
        '&STAGE2=${request.stage2}'
        '&pageNo=${request.pageNo}'
        '&numOfRows=${request.numOfRows}';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // UTF-8로 인코딩된 응답 본문을 다시 디코딩
        final decodedBody = utf8.decode(response.bodyBytes);

        // XML 파싱
        final xmlResponse = xml.XmlDocument.parse(decodedBody);
        final responseElement = xmlResponse.findAllElements('response').first;

        return EmergencyResponse.fromXml(responseElement);
      } else {
        log('Error: ${response.statusCode}');
        return null;
      }
    } on SocketException {
      log('No Internet connection.');
      return null;
    } catch (e) {
      log('Error: $e');
      return null;
    }
  }
}
